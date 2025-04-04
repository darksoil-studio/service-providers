use hdk::prelude::*;
use service_providers_types::ServiceId;

// Called the first time a zome call is made to the cell containing this zome
#[hdk_extern]
pub fn init() -> ExternResult<InitCallbackResult> {
    let service_id: ServiceId = [0, 1, 2].to_vec();
    let response = call(
        CallTargetCell::Local,
        ZomeName::from("service_providers"),
        "announce_as_provider".into(),
        None,
        service_id,
    )?;
    let ZomeCallResponse::Ok(_) = response else {
        return Ok(InitCallbackResult::Fail(format!(
            "Failed to announce as provider: {response:?}"
        )));
    };

    let functions = GrantedFunctions::Listed(BTreeSet::from([(
        zome_info()?.name,
        FunctionName::from("ping"),
    )]));

    create_cap_grant(CapGrantEntry {
        tag: "".into(),
        access: CapAccess::Unrestricted,
        functions,
    })?;

    Ok(InitCallbackResult::Pass)
}

#[hdk_extern]
pub fn ping() -> ExternResult<String> {
    Ok(String::from("pong"))
}

// Don't modify this enum if you want the scaffolding tool to generate appropriate signals for your entries and links
#[derive(Serialize, Deserialize, Debug)]
#[serde(tag = "type")]
pub enum Signal {}

// Whenever an action is committed, we emit a signal to the UI elements to reactively update them
#[hdk_extern(infallible)]
pub fn post_commit(committed_actions: Vec<SignedActionHashed>) {
    // Don't modify the for loop if you want the scaffolding tool to generate appropriate signals for your entries and links
    for action in committed_actions {
        if let Err(err) = signal_action(action) {
            error!("Error signaling new action: {:?}", err);
        }
    }
}

// Don't modify this function if you want the scaffolding tool to generate appropriate signals for your entries and links
fn signal_action(action: SignedActionHashed) -> ExternResult<()> {
    Ok(())
}
