use hdk::prelude::*;
use service_providers_integrity::MakeServiceRequestInput;

#[hdk_extern]
pub fn make_service_request(input: MakeServiceRequestInput) -> ExternResult<ExternIO> {
    let response = call_remote_extern_io_payload(
        input.service_provider,
        "gateway",
        input.fn_name,
        None,
        input.payload,
    )?;
    let ZomeCallResponse::Ok(result) = response else {
        return Err(wasm_error!(
            "Failed to make service request: {:?}",
            response
        ));
    };

    Ok(result)
}

pub fn call_remote_extern_io_payload<Z>(
    agent: AgentPubKey,
    zome: Z,
    fn_name: FunctionName,
    cap_secret: Option<CapSecret>,
    payload: ExternIO,
) -> ExternResult<ZomeCallResponse>
where
    Z: Into<ZomeName>,
{
    Ok(HDK
        .with(|h| {
            h.borrow().call(vec![Call::new(
                CallTarget::NetworkAgent(agent),
                zome.into(),
                fn_name,
                cap_secret,
                payload,
            )])
        })?
        .into_iter()
        .next()
        .unwrap())
}
