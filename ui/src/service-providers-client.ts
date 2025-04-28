import { EntryRecord, ZomeClient } from '@darksoil-studio/holochain-utils';
import {
	ActionHash,
	AgentPubKey,
	AppClient,
	CreateLink,
	Delete,
	DeleteLink,
	EntryHash,
	Link,
	Record,
	SignedActionHashed,
} from '@holochain/client';
import { decode, encode } from '@msgpack/msgpack';

import { ServiceId, ServiceProvidersSignal } from './types.js';

export class ServiceProvidersClient extends ZomeClient<ServiceProvidersSignal> {
	constructor(
		public client: AppClient,
		public roleName: string,
		public zomeName = 'service_providers',
	) {
		super(client, roleName, zomeName);
	}

	getProvidersForService(serviceId: ServiceId): Promise<AgentPubKey[]> {
		return this.callZome('get_providers_for_service', serviceId);
	}

	async makeServiceRequest<P, R>(
		servideId: ServiceId,
		fnName: string,
		payload: P,
	): Promise<R> {
		const providers = await this.getProvidersForService(servideId);

		const provider = await Promise.race(
			providers.map(provider =>
				this.callZome('check_provider_is_available', provider).then(
					() => provider,
				),
			),
		);

		const result = await this.callZome('make_service_request', {
			service_id: servideId,
			service_provider: provider,
			fn_name: fnName,
			payload: encode(payload),
		});
		return decode(result) as R;
	}
}
