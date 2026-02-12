fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Compile the Protobuf definitions from the parent 'api' directory
    // We include all relevant protos to ensure all types are generated
    let serde_impl = "#[derive(serde::Serialize, serde::Deserialize)]";

    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .type_attribute("nitella.proxy.CreateProxyRequest", serde_impl)
        .type_attribute("nitella.proxy.Rule", serde_impl)
        .type_attribute("nitella.proxy.Condition", serde_impl)
        .type_attribute("nitella.proxy.RateLimitConfig", serde_impl)
        .type_attribute("nitella.proxy.MockConfig", serde_impl)
        .type_attribute("nitella.proxy.HealthCheckConfig", serde_impl)
        .type_attribute("nitella.common.ActionType", serde_impl)
        .type_attribute("nitella.common.MockPreset", serde_impl)
        .type_attribute("nitella.common.FallbackAction", serde_impl)
        .type_attribute("nitella.common.ConditionType", serde_impl)
        .type_attribute("nitella.common.Operator", serde_impl)
        .type_attribute("nitella.proxy.ClientAuthType", serde_impl)
        .type_attribute("nitella.proxy.HealthCheckType", serde_impl)
        .compile(
            &[
                "../api/common/common.proto",
                "../api/geoip/geoip.proto",
                "../api/hub/hub_admin.proto",
                "../api/hub/hub_common.proto",
                "../api/hub/hub_mobile.proto",
                "../api/hub/hub_node.proto",
                "../api/hub/hub_node.proto",
                "../api/local/nitella_local.proto",
                "../api/process/process.proto",
                "../api/proxy/proxy.proto",
            ],
            &["../api"], // Include path
        )?;

    // Re-run this build script if the proto files change
    println!("cargo:rerun-if-changed=../api");
    Ok(())
}
