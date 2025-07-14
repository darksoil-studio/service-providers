use anyhow::anyhow;
use futures::{future::select_ok, FutureExt, TryFutureExt};
use holochain_client::{AgentPubKey, AppWebsocket, ExternIO, ZomeCallTarget};
use holochain_types::prelude::FunctionName;
use serde::{de::DeserializeOwned, Serialize};

use service_providers_types::{MakeServiceRequestInput, ServiceId};

const SERVICES_ROLE_NAME: &'static str = "services";

pub async fn make_service_request<P, R>(
    app_ws: &AppWebsocket,
    service_id: ServiceId,
    fn_name: FunctionName,
    payload: P,
) -> anyhow::Result<R>
where
    R: Serialize + DeserializeOwned + std::fmt::Debug,
    P: Serialize + DeserializeOwned + std::fmt::Debug,
{
    let providers: Vec<AgentPubKey> = app_ws
        .call_zome(
            ZomeCallTarget::RoleName(SERVICES_ROLE_NAME.into()),
            "service_providers".into(),
            "get_providers_for_service".into(),
            ExternIO::encode(service_id.clone()).unwrap(),
        )
        .await?
        .decode()?;

    if providers.is_empty() {
        return Err(anyhow!("No providers found."));
    }

    let (service_provider, _) = select_ok(providers.into_iter().map(|provider| {
        app_ws
            .call_zome(
                ZomeCallTarget::RoleName(SERVICES_ROLE_NAME.into()),
                "service_providers".into(),
                "check_provider_is_available".into(),
                ExternIO::encode(provider.clone()).unwrap(),
            )
            .map_ok(|_r| provider)
            .boxed()
    }))
    .await?;

    let result: ExternIO = app_ws
        .call_zome(
            ZomeCallTarget::RoleName(SERVICES_ROLE_NAME.into()),
            "service_providers".into(),
            "make_service_request".into(),
            ExternIO::encode(MakeServiceRequestInput {
                service_provider,
                service_id,
                fn_name,
                payload: ExternIO::encode(payload)?,
            })?,
        )
        .await?;
    let second_result: ExternIO = result.decode()?;
    Ok(second_result.decode()?)
}
