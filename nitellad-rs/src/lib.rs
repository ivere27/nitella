pub mod proto {
    pub mod common {
        tonic::include_proto!("nitella");
    }
    // Expose common types (ActionType, etc) to siblings
    pub use common::*;

    pub mod geoip {
        tonic::include_proto!("nitella.geoip");
    }
    pub mod hub {
        tonic::include_proto!("nitella.hub");
    }
    pub mod process {
        tonic::include_proto!("nitella.process");
    }
    pub mod proxy {
        tonic::include_proto!("nitella.proxy");
    }
    pub mod local {
        tonic::include_proto!("nitella.local");
    }
}

pub mod admin;
pub mod admin_security;
pub mod approval;
pub mod cert_utils;
pub mod config;
pub mod cpace;
pub mod crypto; // Added
pub mod db;
pub mod geoip;
pub mod health;
pub mod hub;
pub mod hubca;
pub mod manager;
pub mod pairing_offline;
pub mod process_proxy;
pub mod proxy;
pub mod rules;
pub mod server;
pub mod stats;
pub mod synurang;

pub mod mobile;
pub mod mobile_service;
