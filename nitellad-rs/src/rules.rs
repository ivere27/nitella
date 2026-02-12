use crate::proto::proxy::{Rule, Condition};
use crate::proto::common::{GeoInfo, ConditionType};
use std::net::IpAddr;
use ipnet::IpNet;

#[derive(Debug, Clone)]
pub struct RuleMatcher {
    rule: Rule,
    source_cidrs: Vec<IpNet>,
}

impl RuleMatcher {
    pub fn new(rule: Rule) -> Self {
        let mut source_cidrs = Vec::new();
        for cond in &rule.conditions {
            if cond.r#type == ConditionType::SourceIp as i32 {
                if let Ok(net) = cond.value.parse::<IpNet>() {
                    source_cidrs.push(net);
                } else if let Ok(ip) = cond.value.parse::<IpAddr>() {
                    source_cidrs.push(IpNet::from(ip));
                }
            }
        }
        
        Self {
            rule,
            source_cidrs,
        }
    }

    pub fn matches(&self, ip: IpAddr, geo: &Option<GeoInfo>) -> bool {
        if !self.rule.enabled {
            return false;
        }

        if self.rule.conditions.is_empty() {
            return true;
        }

        for cond in &self.rule.conditions {
            if !self.check_condition(cond, ip, geo) {
                return false;
            }
        }

        true
    }

    fn check_condition(&self, cond: &Condition, ip: IpAddr, geo: &Option<GeoInfo>) -> bool {
        let result = match ConditionType::try_from(cond.r#type).unwrap_or(ConditionType::Unspecified) {
            ConditionType::SourceIp => {
                self.source_cidrs.iter().any(|net| net.contains(&ip))
            },
            ConditionType::GeoCountry => {
                if let Some(g) = geo {
                    g.country_code.eq_ignore_ascii_case(&cond.value) || g.country.eq_ignore_ascii_case(&cond.value)
                } else {
                    false
                }
            },
            ConditionType::GeoIsp => {
                if let Some(g) = geo {
                    g.isp.to_lowercase().contains(&cond.value.to_lowercase())
                } else {
                    false
                }
            },
            _ => false,
        };

        if cond.negate { !result } else { result }
    }
}

pub struct RuleEngine {
    matchers: Vec<RuleMatcher>,
}

impl RuleEngine {
    pub fn new(rules: Vec<Rule>) -> Self {
        let mut matchers: Vec<RuleMatcher> = rules.into_iter().map(RuleMatcher::new).collect();
        matchers.sort_by(|a, b| b.rule.priority.cmp(&a.rule.priority));
        Self { matchers }
    }

    pub fn evaluate(&self, ip: IpAddr, geo: &Option<GeoInfo>) -> Option<Rule> {
        for matcher in &self.matchers {
            if matcher.matches(ip, geo) {
                return Some(matcher.rule.clone());
            }
        }
        None
    }
    
    pub fn update_rules(&mut self, rules: Vec<Rule>) {
         let mut matchers: Vec<RuleMatcher> = rules.into_iter().map(RuleMatcher::new).collect();
        matchers.sort_by(|a, b| b.rule.priority.cmp(&a.rule.priority));
        self.matchers = matchers;
    }

    pub fn get_rules(&self) -> Vec<Rule> {
        self.matchers.iter().map(|m| m.rule.clone()).collect()
    }
}
