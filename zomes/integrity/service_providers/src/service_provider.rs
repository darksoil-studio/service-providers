use hdi::prelude::*;
use roles_types::validate_agent_had_undeleted_role_claim_at_the_time;

use crate::PROVIDER_ROLE;

pub fn validate_create_link_service_provider(
    action_hash: ActionHash,
    action: CreateLink,
    base_address: AnyLinkableHash,
    target_address: AnyLinkableHash,
    _tag: LinkTag,
) -> ExternResult<ValidateCallbackResult> {
    validate_agent_had_undeleted_role_claim_at_the_time(
        &action.author,
        &action_hash,
        &String::from(PROVIDER_ROLE),
        &ZomeName::from("roles_integrity"),
    )
}

pub fn validate_delete_link_service_provider(
    action_hash: ActionHash,
    action: DeleteLink,
    _original_action: CreateLink,
    _base: AnyLinkableHash,
    _target: AnyLinkableHash,
    _tag: LinkTag,
) -> ExternResult<ValidateCallbackResult> {
    validate_agent_had_undeleted_role_claim_at_the_time(
        &action.author,
        &action_hash,
        &String::from(PROVIDER_ROLE),
        &ZomeName::from("roles_integrity"),
    )
}
