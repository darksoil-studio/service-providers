use hdk::prelude::*;
use service_providers_integrity::*;

use crate::utils::{create_link_relaxed, delete_link_relaxed};

fn providers_for_service_path(service_id: &ServiceId) -> ExternResult<TypedPath> {
    let mut path = Path::from(format!("all_providers"));
    path.append_component(Component::from(service_id.clone()));
    path.typed(LinkTypes::AllProvidersPath)
}

fn all_providers_path() -> ExternResult<TypedPath> {
    Path::from(format!("all_providers")).typed(LinkTypes::AllProvidersPath)
}

#[hdk_extern]
pub fn announce_as_provider(service_id: ServiceId) -> ExternResult<()> {
    let agent_info = agent_info()?;
    let dna_info = dna_info()?;

    info!(
        "Announcing as provider for service {service_id:?} in DNA {}",
        dna_info.hash
    );

    let path = providers_for_service_path(&service_id)?;
    path.ensure()?;

    create_link(
        path.path_entry_hash()?,
        agent_info.agent_initial_pubkey,
        LinkTypes::ServiceProvider,
        (),
    )?;

    let functions = GrantedFunctions::Listed(BTreeSet::from([(
        zome_info()?.name,
        FunctionName::from("available_as_provider"),
    )]));

    create_cap_grant(CapGrantEntry {
        tag: "".into(),
        access: CapAccess::Unrestricted,
        functions,
    })?;

    schedule("scheduled_remove_inactive_providers")?;

    Ok(())
}

#[hdk_extern]
pub fn get_providers_for_service(service_id: ServiceId) -> ExternResult<Vec<AgentPubKey>> {
    let links = get_links(
        GetLinksInputBuilder::try_new(
            providers_for_service_path(&service_id)?.path_entry_hash()?,
            LinkTypes::ServiceProvider,
        )?
        .build(),
    )?;

    let providers_pub_keys = links
        .into_iter()
        .filter_map(|link| link.target.into_agent_pub_key())
        .collect();

    Ok(providers_pub_keys)
}

#[hdk_extern(infallible)]
fn scheduled_remove_inactive_providers(_: Option<Schedule>) -> Option<Schedule> {
    if let Err(err) = remove_inactive_providers() {
        error!("Failed to remove inactive providers: {err:?}");
    }

    Some(Schedule::Persisted("0 */5 * * * * *".into())) // Every 60 seconds
}

pub fn remove_inactive_providers() -> ExternResult<()> {
    debug!("[remove_inactive_providers] start.");

    let all_providers_path = all_providers_path()?;

    let children = all_providers_path.children_paths()?;

    for child in children {
        let Some(leaf) = child.leaf() else {
            continue;
        };

        let service_id: Vec<u8> = leaf.clone().into();
        remove_inactive_providers_for_service(service_id)?;
    }

    Ok(())
}

pub fn remove_inactive_providers_for_service(service_id: ServiceId) -> ExternResult<()> {
    let providers_links = get_links(
        GetLinksInputBuilder::try_new(
            providers_for_service_path(&service_id)?.path_entry_hash()?,
            LinkTypes::ServiceProvider,
        )?
        .build(),
    )?;

    let my_pub_key = agent_info()?.agent_initial_pubkey;

    for provider_link in providers_links.clone() {
        let Some(provider) = provider_link.target.into_agent_pub_key() else {
            continue;
        };
        if provider.eq(&my_pub_key) {
            continue;
        }

        info!(
            "[remove_inactive_providers] checking if provider is available: {}.",
            provider
        );
        let available = check_provider_is_available(provider.clone());

        if available.is_err() {
            warn!("Marking provider as not available: {provider}");
            get(provider_link.create_link_hash.clone(), Default::default())?;
            delete_link_relaxed(provider_link.create_link_hash)?;
        } else {
            info!(
                "[remove_inactive_providers] provider is available: {}.",
                provider
            );
        }
    }

    let providers: Vec<AgentPubKey> = providers_links
        .into_iter()
        .filter_map(|link| link.target.into_agent_pub_key())
        .collect();

    if !providers.contains(&my_pub_key) {
        let path = providers_for_service_path(&service_id)?;
        create_link_relaxed(
            path.path_entry_hash()?,
            my_pub_key,
            LinkTypes::ServiceProvider,
            (),
        )?;
    }

    Ok(())
}

#[hdk_extern]
pub fn check_provider_is_available(provider: AgentPubKey) -> ExternResult<()> {
    let response = call_remote(
        provider.clone(),
        zome_info()?.name,
        "available_as_provider".into(),
        None,
        (),
    )?;

    match response {
        ZomeCallResponse::Ok(bytes) => {
            let available: bool = bytes.decode().map_err(|err| wasm_error!(err))?;
            if !available {
                return Err(wasm_error!("Not available"));
            }
            Ok(())
        }
        _ => Err(wasm_error!(
            "Failed to check whether provider is available: {:?}",
            response
        )),
    }
}

#[hdk_extern]
pub fn available_as_provider() -> ExternResult<bool> {
    Ok(true)
}
