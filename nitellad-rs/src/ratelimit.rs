use crate::proto::proxy::RateLimitConfig;
use dashmap::DashMap;
use parking_lot::Mutex;
use std::net::IpAddr;
use std::time::{Duration, Instant};

#[derive(Debug)]
pub struct RateLimiter {
    config: RateLimitConfig,
    counters: DashMap<IpAddr, IpState>,
    blocks: DashMap<IpAddr, Instant>,
    last_cleanup: Mutex<Instant>,
}

#[derive(Debug)]
struct IpState {
    count: i32,
    first_seen: Instant,
    last_seen: Instant,
    failed_count: i32,
    ban_level: usize,
}

impl RateLimiter {
    pub fn new(config: RateLimitConfig) -> Self {
        let now = Instant::now();
        Self {
            config,
            counters: DashMap::new(),
            blocks: DashMap::new(),
            last_cleanup: Mutex::new(now),
        }
    }

    pub fn check(&self, ip: &str) -> bool {
        let Some(ip) = parse_ip(ip) else {
            return true;
        };

        let now = Instant::now();
        self.cleanup_if_due(now);

        let blocked_until = self.blocks.get(&ip).map(|expiry| *expiry);
        if let Some(expiry) = blocked_until {
            if now < expiry {
                return false;
            }
            self.blocks.remove(&ip);
            if let Some(mut counter) = self.counters.get_mut(&ip) {
                counter.failed_count = (self.config.max_connections - 1).max(0);
                counter.first_seen = now;
            }
        }

        let interval = self.interval_duration();
        let block_until = {
            let mut counter = self.counters.entry(ip).or_insert_with(|| IpState::new(now));

            if now.duration_since(counter.first_seen) > interval {
                counter.count = 0;
                counter.failed_count = 0;
                counter.first_seen = now;
            }
            counter.last_seen = now;

            if !self.config.count_only_failures && counter.count >= self.config.max_connections {
                if self.config.auto_block {
                    Some(now + self.block_duration(counter.ban_level))
                } else {
                    None
                }
            } else {
                return true;
            }
        };

        if let Some(expiry) = block_until {
            self.blocks.insert(ip, expiry);
        }
        false
    }

    pub fn track_connection(&self, ip: &str) {
        let Some(ip) = parse_ip(ip) else {
            return;
        };

        let now = Instant::now();
        let mut counter = self.counters.entry(ip).or_insert_with(|| IpState::new(now));
        counter.count += 1;
        counter.last_seen = now;
    }

    pub fn report_result(&self, ip: &str, duration: Duration) {
        if !self.config.count_only_failures {
            return;
        }

        let threshold = if self.config.failure_duration_threshold > 0 {
            Duration::from_secs(self.config.failure_duration_threshold as u64)
        } else {
            Duration::from_secs(1)
        };
        if duration >= threshold {
            return;
        }

        let Some(ip) = parse_ip(ip) else {
            return;
        };

        let now = Instant::now();

        let block_until = {
            let mut counter = match self.counters.get_mut(&ip) {
                Some(counter) => counter,
                None => return,
            };
            counter.failed_count += 1;
            counter.last_seen = now;

            if counter.failed_count >= self.config.max_connections && self.config.auto_block {
                let block_duration = self.block_duration(counter.ban_level);
                counter.ban_level += 1;
                Some(now + block_duration)
            } else {
                None
            }
        };

        if let Some(expiry) = block_until {
            self.blocks.insert(ip, expiry);
        }
    }

    fn cleanup_if_due(&self, now: Instant) {
        let interval = self.interval_duration();
        {
            let mut last_cleanup = self.last_cleanup.lock();
            if now.duration_since(*last_cleanup) < interval {
                return;
            }
            *last_cleanup = now;
        }

        let stale_threshold = self.interval_duration() * 2;
        self.blocks.retain(|_, expiry| now < *expiry);
        self.counters
            .retain(|_, counter| now.duration_since(counter.last_seen) <= stale_threshold);
    }

    fn interval_duration(&self) -> Duration {
        if self.config.interval_seconds > 0 {
            Duration::from_secs(self.config.interval_seconds as u64)
        } else {
            Duration::from_secs(60)
        }
    }

    fn block_duration(&self, ban_level: usize) -> Duration {
        if !self.config.block_steps_seconds.is_empty() {
            let idx = ban_level.min(self.config.block_steps_seconds.len() - 1);
            return Duration::from_secs(self.config.block_steps_seconds[idx].max(0) as u64);
        }
        if self.config.block_duration_seconds > 0 {
            Duration::from_secs(self.config.block_duration_seconds as u64)
        } else {
            Duration::from_secs(600)
        }
    }
}

impl IpState {
    fn new(now: Instant) -> Self {
        Self {
            count: 0,
            first_seen: now,
            last_seen: now,
            failed_count: 0,
            ban_level: 0,
        }
    }
}

fn parse_ip(ip: &str) -> Option<IpAddr> {
    ip.parse().ok()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn config(max_connections: i32) -> RateLimitConfig {
        RateLimitConfig {
            max_connections,
            interval_seconds: 60,
            auto_block: true,
            block_duration_seconds: 60,
            ..Default::default()
        }
    }

    #[test]
    fn blocks_after_max_connections_in_window() {
        let limiter = RateLimiter::new(config(1));
        assert!(limiter.check("10.0.0.1"));
        limiter.track_connection("10.0.0.1");
        assert!(!limiter.check("10.0.0.1"));
    }

    #[test]
    fn count_only_failures_blocks_after_short_results() {
        let limiter = RateLimiter::new(RateLimitConfig {
            count_only_failures: true,
            failure_duration_threshold: 10,
            ..config(1)
        });
        assert!(limiter.check("10.0.0.2"));
        limiter.track_connection("10.0.0.2");
        limiter.report_result("10.0.0.2", Duration::from_secs(1));
        assert!(!limiter.check("10.0.0.2"));
    }
}
