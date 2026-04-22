use crate::proto::common::{ActionType, ConditionType, GeoInfo, Operator};
use crate::proto::proxy::{Condition, Rule};
use crate::ratelimit::RateLimiter;
use chrono::Timelike;
use ipnet::IpNet;
use regex::Regex;
use sha2::{Digest, Sha256};
use std::net::IpAddr;
use std::sync::Arc;
use x509_parser::extensions::GeneralName;
use x509_parser::prelude::*;

const MAX_REGEX_LENGTH: usize = 256;

#[derive(Debug, Clone, Default)]
pub struct TlsPeerInfo {
    pub fingerprint: String,
    pub common_name: String,
    pub serial: String,
    pub issuer_common_name: String,
    pub subject_alt_names: Vec<String>,
    pub organizational_units: Vec<String>,
}

impl TlsPeerInfo {
    pub fn from_der(cert_der: &[u8]) -> Option<Self> {
        let (_, cert) = X509Certificate::from_der(cert_der).ok()?;

        let common_name = cert
            .subject()
            .iter_common_name()
            .next()
            .and_then(|attr| attr.as_str().ok())
            .unwrap_or("")
            .to_string();
        let issuer_common_name = cert
            .issuer()
            .iter_common_name()
            .next()
            .and_then(|attr| attr.as_str().ok())
            .unwrap_or("")
            .to_string();
        let organizational_units = cert
            .subject()
            .iter_organizational_unit()
            .filter_map(|attr| attr.as_str().ok().map(ToString::to_string))
            .collect();

        let mut subject_alt_names = Vec::new();
        if let Ok(Some(san)) = cert.subject_alternative_name() {
            for name in &san.value.general_names {
                match name {
                    GeneralName::DNSName(v) => subject_alt_names.push(v.to_string()),
                    GeneralName::RFC822Name(v) => subject_alt_names.push(v.to_string()),
                    GeneralName::IPAddress(v) => {
                        if v.len() == 4 {
                            subject_alt_names.push(format!("{}.{}.{}.{}", v[0], v[1], v[2], v[3]));
                        } else if v.len() == 16 {
                            if let Ok(bytes) = <[u8; 16]>::try_from(*v) {
                                subject_alt_names.push(std::net::Ipv6Addr::from(bytes).to_string());
                            }
                        }
                    }
                    _ => {}
                }
            }
        }

        Some(Self {
            fingerprint: hex::encode(Sha256::digest(cert_der)),
            common_name,
            serial: serial_decimal(cert.raw_serial()),
            issuer_common_name,
            subject_alt_names,
            organizational_units,
        })
    }
}

#[derive(Debug, Clone)]
pub struct RuleMatcher {
    rule: Rule,
    rate_limiter: Option<Arc<RateLimiter>>,
}

impl RuleMatcher {
    pub fn new(rule: Rule) -> Self {
        let rate_limiter = rule
            .rate_limit
            .clone()
            .map(|config| Arc::new(RateLimiter::new(config)));

        Self { rule, rate_limiter }
    }

    pub fn matches(&self, ip: IpAddr, geo: &Option<GeoInfo>, tls: Option<&TlsPeerInfo>) -> bool {
        if !self.rule.enabled {
            return false;
        }

        if self.rule.conditions.is_empty() {
            return true;
        }

        for cond in &self.rule.conditions {
            if !self.check_condition(cond, ip, geo, tls) {
                return false;
            }
        }

        true
    }

    fn check_condition(
        &self,
        cond: &Condition,
        ip: IpAddr,
        geo: &Option<GeoInfo>,
        tls: Option<&TlsPeerInfo>,
    ) -> bool {
        let result = match ConditionType::try_from(cond.r#type)
            .unwrap_or(ConditionType::Unspecified)
        {
            ConditionType::SourceIp => match_string(
                Operator::try_from(cond.op).unwrap_or(Operator::Unspecified),
                &cond.value,
                &ip.to_string(),
            ),
            ConditionType::GeoCountry => {
                if let Some(g) = geo {
                    match_string(
                        Operator::try_from(cond.op).unwrap_or(Operator::Unspecified),
                        &cond.value,
                        &g.country,
                    )
                } else {
                    false
                }
            }
            ConditionType::GeoCity => {
                if let Some(g) = geo {
                    match_string(
                        Operator::try_from(cond.op).unwrap_or(Operator::Unspecified),
                        &cond.value,
                        &g.city,
                    )
                } else {
                    false
                }
            }
            ConditionType::GeoIsp => {
                if let Some(g) = geo {
                    match_string(
                        Operator::try_from(cond.op).unwrap_or(Operator::Unspecified),
                        &cond.value,
                        &g.isp,
                    )
                } else {
                    false
                }
            }
            ConditionType::TimeRange => match_time_range(&cond.value),
            ConditionType::TlsFingerprint => tls
                .map(|t| {
                    match_string(
                        Operator::try_from(cond.op).unwrap_or(Operator::Unspecified),
                        &cond.value,
                        &t.fingerprint,
                    )
                })
                .unwrap_or(false),
            ConditionType::TlsCn => tls
                .map(|t| {
                    match_string(
                        Operator::try_from(cond.op).unwrap_or(Operator::Unspecified),
                        &cond.value,
                        &t.common_name,
                    )
                })
                .unwrap_or(false),
            ConditionType::TlsSerial => tls
                .map(|t| {
                    match_string(
                        Operator::try_from(cond.op).unwrap_or(Operator::Unspecified),
                        &cond.value,
                        &t.serial,
                    )
                })
                .unwrap_or(false),
            ConditionType::TlsPresent => {
                let present = tls.is_some();
                if cond.value.eq_ignore_ascii_case("false") {
                    !present
                } else {
                    present
                }
            }
            ConditionType::TlsCa => tls
                .map(|t| {
                    match_string(
                        Operator::try_from(cond.op).unwrap_or(Operator::Unspecified),
                        &cond.value,
                        &t.issuer_common_name,
                    )
                })
                .unwrap_or(false),
            ConditionType::TlsSan => tls
                .map(|t| {
                    let refs: Vec<&str> = t.subject_alt_names.iter().map(|s| s.as_str()).collect();
                    match_string_any(
                        Operator::try_from(cond.op).unwrap_or(Operator::Unspecified),
                        &cond.value,
                        &refs,
                    )
                })
                .unwrap_or(false),
            ConditionType::TlsOu => tls
                .map(|t| {
                    let refs: Vec<&str> =
                        t.organizational_units.iter().map(|s| s.as_str()).collect();
                    match_string_any(
                        Operator::try_from(cond.op).unwrap_or(Operator::Unspecified),
                        &cond.value,
                        &refs,
                    )
                })
                .unwrap_or(false),
            _ => false,
        };

        if cond.negate {
            !result
        } else {
            result
        }
    }
}

#[derive(Clone)]
pub struct MatchedRule {
    pub rule: Rule,
    pub rate_limiter: Option<Arc<RateLimiter>>,
}

pub struct RuleEngine {
    matchers: Vec<RuleMatcher>,
    has_tls_conditions: bool,
}

impl RuleEngine {
    pub fn new(rules: Vec<Rule>) -> Self {
        let (matchers, has_tls_conditions) = build_matchers(rules);
        Self {
            matchers,
            has_tls_conditions,
        }
    }

    pub fn is_empty(&self) -> bool {
        self.matchers.is_empty()
    }

    pub fn has_tls_conditions(&self) -> bool {
        self.has_tls_conditions
    }

    pub fn evaluate(&self, ip: IpAddr, geo: &Option<GeoInfo>) -> Option<Rule> {
        self.evaluate_details(ip, geo).map(|matched| matched.rule)
    }

    pub fn evaluate_with_tls(
        &self,
        ip: IpAddr,
        geo: &Option<GeoInfo>,
        tls: Option<&TlsPeerInfo>,
    ) -> Option<Rule> {
        self.evaluate_with_tls_details(ip, geo, tls_if_needed(self.has_tls_conditions, tls))
            .map(|matched| matched.rule)
    }

    pub fn evaluate_details(&self, ip: IpAddr, geo: &Option<GeoInfo>) -> Option<MatchedRule> {
        self.evaluate_with_tls_details(ip, geo, None)
    }

    pub fn evaluate_with_tls_details(
        &self,
        ip: IpAddr,
        geo: &Option<GeoInfo>,
        tls: Option<&TlsPeerInfo>,
    ) -> Option<MatchedRule> {
        let tls = tls_if_needed(self.has_tls_conditions, tls);
        for matcher in &self.matchers {
            if matcher.matches(ip, geo, tls) {
                return Some(MatchedRule {
                    rule: matcher.rule.clone(),
                    rate_limiter: matcher.rate_limiter.clone(),
                });
            }
        }
        None
    }

    pub fn evaluate_global(&self, ip: IpAddr, geo: &Option<GeoInfo>) -> Option<Rule> {
        self.evaluate_global_with_tls(ip, geo, None)
    }

    pub fn evaluate_global_with_tls(
        &self,
        ip: IpAddr,
        geo: &Option<GeoInfo>,
        tls: Option<&TlsPeerInfo>,
    ) -> Option<Rule> {
        let tls = tls_if_needed(self.has_tls_conditions, tls);
        let mut allow_match = None;
        for matcher in &self.matchers {
            if matcher.matches(ip, geo, tls) {
                match matcher.rule.action() {
                    ActionType::Block => return Some(matcher.rule.clone()),
                    ActionType::Allow if allow_match.is_none() => {
                        allow_match = Some(matcher.rule.clone());
                    }
                    _ => {}
                }
            }
        }
        allow_match
    }

    pub fn update_rules(&mut self, rules: Vec<Rule>) {
        let (matchers, has_tls_conditions) = build_matchers(rules);
        self.matchers = matchers;
        self.has_tls_conditions = has_tls_conditions;
    }

    pub fn get_rules(&self) -> Vec<Rule> {
        self.matchers.iter().map(|m| m.rule.clone()).collect()
    }
}

fn build_matchers(rules: Vec<Rule>) -> (Vec<RuleMatcher>, bool) {
    let has_tls_conditions = rules.iter().any(rule_has_tls_conditions);
    let mut matchers: Vec<RuleMatcher> = rules.into_iter().map(RuleMatcher::new).collect();
    matchers.sort_by(|a, b| b.rule.priority.cmp(&a.rule.priority));
    (matchers, has_tls_conditions)
}

fn tls_if_needed<'a>(
    has_tls_conditions: bool,
    tls: Option<&'a TlsPeerInfo>,
) -> Option<&'a TlsPeerInfo> {
    if has_tls_conditions {
        tls
    } else {
        None
    }
}

fn rule_has_tls_conditions(rule: &Rule) -> bool {
    rule.conditions.iter().any(condition_is_tls)
}

fn condition_is_tls(cond: &Condition) -> bool {
    matches!(
        ConditionType::try_from(cond.r#type).unwrap_or(ConditionType::Unspecified),
        ConditionType::TlsFingerprint
            | ConditionType::TlsCn
            | ConditionType::TlsSerial
            | ConditionType::TlsPresent
            | ConditionType::TlsCa
            | ConditionType::TlsSan
            | ConditionType::TlsOu
    )
}

fn match_string(op: Operator, expected: &str, actual: &str) -> bool {
    match op {
        Operator::Contains => actual.contains(expected),
        Operator::Regex => {
            if expected.len() > MAX_REGEX_LENGTH {
                return false;
            }
            Regex::new(expected)
                .map(|re| re.is_match(actual))
                .unwrap_or(false)
        }
        Operator::Cidr => {
            if let (Ok(net), Ok(ip)) = (expected.parse::<IpNet>(), actual.parse::<IpAddr>()) {
                net.contains(&ip)
            } else {
                false
            }
        }
        Operator::Eq => expected == actual,
        _ => false,
    }
}

fn match_string_any(op: Operator, expected: &str, actuals: &[&str]) -> bool {
    actuals
        .iter()
        .any(|actual| match_string(op, expected, actual))
}

fn serial_decimal(raw: &[u8]) -> String {
    let raw = raw
        .iter()
        .skip_while(|byte| **byte == 0)
        .copied()
        .collect::<Vec<_>>();
    if raw.is_empty() {
        return "0".to_string();
    }

    let mut digits = vec![0u8];
    for byte in raw {
        let mut carry = byte as u32;
        for digit in &mut digits {
            let value = (*digit as u32) * 256 + carry;
            *digit = (value % 10) as u8;
            carry = value / 10;
        }
        while carry > 0 {
            digits.push((carry % 10) as u8);
            carry /= 10;
        }
    }

    digits
        .iter()
        .rev()
        .map(|digit| char::from(b'0' + *digit))
        .collect()
}

fn match_time_range(value: &str) -> bool {
    let Some((start, end)) = value.split_once('-') else {
        return false;
    };
    let Some(start_minutes) = parse_hhmm(start.trim()) else {
        return false;
    };
    let Some(end_minutes) = parse_hhmm(end.trim()) else {
        return false;
    };

    let now = chrono::Local::now();
    let current = now.hour() * 60 + now.minute();
    if start_minutes <= end_minutes {
        current >= start_minutes && current <= end_minutes
    } else {
        current >= start_minutes || current <= end_minutes
    }
}

fn parse_hhmm(value: &str) -> Option<u32> {
    let (h, m) = value.split_once(':')?;
    let h: u32 = h.parse().ok()?;
    let m: u32 = m.parse().ok()?;
    if h > 23 || m > 59 {
        return None;
    }
    Some(h * 60 + m)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::proto::common::{ActionType, ConditionType, Operator};
    use crate::proto::proxy::RateLimitConfig;

    fn test_rule(condition: Condition) -> Rule {
        test_rule_with_conditions(vec![condition])
    }

    fn test_rule_with_conditions(conditions: Vec<Condition>) -> Rule {
        Rule {
            id: "r1".to_string(),
            name: "test".to_string(),
            priority: 1,
            enabled: true,
            conditions,
            action: ActionType::Allow as i32,
            ..Default::default()
        }
    }

    #[test]
    fn source_ip_supports_cidr_operator() {
        let engine = RuleEngine::new(vec![test_rule(Condition {
            r#type: ConditionType::SourceIp as i32,
            op: Operator::Cidr as i32,
            value: "10.10.0.0/16".to_string(),
            negate: false,
        })]);

        assert!(engine
            .evaluate("10.10.5.7".parse().unwrap(), &None)
            .is_some());
        assert!(engine
            .evaluate("10.11.5.7".parse().unwrap(), &None)
            .is_none());
    }

    #[test]
    fn source_ip_requires_explicit_operator() {
        let engine = RuleEngine::new(vec![test_rule(Condition {
            r#type: ConditionType::SourceIp as i32,
            op: Operator::Unspecified as i32,
            value: "10.10.5.7".to_string(),
            negate: false,
        })]);

        assert!(engine
            .evaluate("10.10.5.7".parse().unwrap(), &None)
            .is_none());
    }

    #[test]
    fn multiple_source_ip_conditions_are_and_matched() {
        let engine = RuleEngine::new(vec![test_rule_with_conditions(vec![
            Condition {
                r#type: ConditionType::SourceIp as i32,
                op: Operator::Cidr as i32,
                value: "10.10.0.0/16".to_string(),
                negate: false,
            },
            Condition {
                r#type: ConditionType::SourceIp as i32,
                op: Operator::Cidr as i32,
                value: "192.168.0.0/16".to_string(),
                negate: false,
            },
        ])]);

        assert!(engine
            .evaluate("10.10.5.7".parse().unwrap(), &None)
            .is_none());
    }

    #[test]
    fn geo_conditions_honor_operator_and_negation() {
        let geo = GeoInfo {
            city: "Seoul".to_string(),
            isp: "Example ISP".to_string(),
            ..Default::default()
        };
        let engine = RuleEngine::new(vec![test_rule(Condition {
            r#type: ConditionType::GeoIsp as i32,
            op: Operator::Contains as i32,
            value: "ISP".to_string(),
            negate: false,
        })]);

        assert!(engine
            .evaluate("8.8.8.8".parse().unwrap(), &Some(geo))
            .is_some());

        let negated = RuleEngine::new(vec![test_rule(Condition {
            r#type: ConditionType::GeoCity as i32,
            op: Operator::Eq as i32,
            value: "Busan".to_string(),
            negate: true,
        })]);
        let geo = GeoInfo {
            city: "Seoul".to_string(),
            ..Default::default()
        };
        assert!(negated
            .evaluate("8.8.8.8".parse().unwrap(), &Some(geo))
            .is_some());
    }

    #[test]
    fn geo_country_matches_country_field_only() {
        let geo = GeoInfo {
            country: "United States".to_string(),
            country_code: "US".to_string(),
            ..Default::default()
        };
        let code_rule = RuleEngine::new(vec![test_rule(Condition {
            r#type: ConditionType::GeoCountry as i32,
            op: Operator::Eq as i32,
            value: "US".to_string(),
            negate: false,
        })]);
        assert!(code_rule
            .evaluate("8.8.8.8".parse().unwrap(), &Some(geo.clone()))
            .is_none());

        let country_rule = RuleEngine::new(vec![test_rule(Condition {
            r#type: ConditionType::GeoCountry as i32,
            op: Operator::Eq as i32,
            value: "United States".to_string(),
            negate: false,
        })]);
        assert!(country_rule
            .evaluate("8.8.8.8".parse().unwrap(), &Some(geo))
            .is_some());
    }

    #[test]
    fn rule_engine_tracks_empty_and_tls_condition_state() {
        let mut engine = RuleEngine::new(Vec::new());
        assert!(engine.is_empty());
        assert!(!engine.has_tls_conditions());

        engine.update_rules(vec![test_rule(Condition {
            r#type: ConditionType::SourceIp as i32,
            op: Operator::Cidr as i32,
            value: "10.0.0.0/8".to_string(),
            negate: false,
        })]);
        assert!(!engine.is_empty());
        assert!(!engine.has_tls_conditions());

        engine.update_rules(vec![test_rule(Condition {
            r#type: ConditionType::TlsPresent as i32,
            op: Operator::Eq as i32,
            value: "true".to_string(),
            negate: false,
        })]);
        assert!(!engine.is_empty());
        assert!(engine.has_tls_conditions());
    }

    #[test]
    fn global_rule_evaluation_prefers_block_over_allow() {
        let allow_rule = Rule {
            id: "allow".to_string(),
            name: "allow".to_string(),
            priority: 1000,
            enabled: true,
            conditions: vec![Condition {
                r#type: ConditionType::SourceIp as i32,
                op: Operator::Cidr as i32,
                value: "10.0.0.0/8".to_string(),
                negate: false,
            }],
            action: ActionType::Allow as i32,
            ..Default::default()
        };
        let block_rule = Rule {
            id: "block".to_string(),
            name: "block".to_string(),
            priority: 1000,
            enabled: true,
            conditions: vec![Condition {
                r#type: ConditionType::SourceIp as i32,
                op: Operator::Cidr as i32,
                value: "10.1.0.0/16".to_string(),
                negate: false,
            }],
            action: ActionType::Block as i32,
            ..Default::default()
        };
        let engine = RuleEngine::new(vec![allow_rule, block_rule]);

        let matched = engine
            .evaluate_global_with_tls("10.1.2.3".parse().unwrap(), &None, None)
            .expect("global rule should match");
        assert_eq!(matched.action(), ActionType::Block);
    }

    #[test]
    fn tls_conditions_match_extracted_peer_fields() {
        let tls = TlsPeerInfo {
            common_name: "node.example".to_string(),
            subject_alt_names: vec!["node.example".to_string(), "10.0.0.10".to_string()],
            ..Default::default()
        };
        let engine = RuleEngine::new(vec![test_rule(Condition {
            r#type: ConditionType::TlsSan as i32,
            op: Operator::Eq as i32,
            value: "node.example".to_string(),
            negate: false,
        })]);

        assert!(engine
            .evaluate_with_tls("8.8.8.8".parse().unwrap(), &None, Some(&tls))
            .is_some());
    }

    #[test]
    fn tls_serial_uses_go_decimal_format() {
        let mut params = rcgen::CertificateParams::new(vec!["node.example".to_string()]);
        params.serial_number = Some(rcgen::SerialNumber::from(99999u64));
        let cert = rcgen::Certificate::from_params(params).unwrap();
        let der = cert.serialize_der().unwrap();
        let tls = TlsPeerInfo::from_der(&der).unwrap();

        assert_eq!(tls.serial, "99999");
    }

    #[test]
    fn matched_rule_includes_rate_limiter() {
        let mut rule = test_rule(Condition {
            r#type: ConditionType::SourceIp as i32,
            op: Operator::Cidr as i32,
            value: "10.10.0.0/16".to_string(),
            negate: false,
        });
        rule.rate_limit = Some(RateLimitConfig {
            max_connections: 1,
            interval_seconds: 60,
            ..Default::default()
        });
        let engine = RuleEngine::new(vec![rule]);

        let matched = engine
            .evaluate_with_tls_details("10.10.5.7".parse().unwrap(), &None, None)
            .expect("rule should match");
        assert!(matched.rate_limiter.is_some());
    }
}
