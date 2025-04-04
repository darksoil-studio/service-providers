use hdi::prelude::*;

pub type ServiceId = Vec<u8>;

#[derive(Serialize, Deserialize, Debug)]
pub struct MakeServiceRequestInput {
    pub service_id: ServiceId,
    pub service_provider: AgentPubKey,
    pub fn_name: FunctionName,
    pub payload: ExternIO,
}
