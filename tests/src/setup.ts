import { EntryRecord } from '@darksoil-studio/holochain-utils';
import {
	ActionHash,
	AgentPubKey,
	AppBundleSource,
	AppWebsocket,
	EntryHash,
	NewEntryAction,
	Record,
	encodeHashToBase64,
	fakeActionHash,
	fakeAgentPubKey,
	fakeDnaHash,
	fakeEntryHash,
} from '@holochain/client';
import { Player, Scenario, dhtSync, pause } from '@holochain/tryorama';
import { encode } from '@msgpack/msgpack';
import { dirname } from 'path';
import { fileURLToPath } from 'url';

import { ServiceProvidersClient } from '../../ui/src/service-providers-client.js';
import { ServiceProvidersStore } from '../../ui/src/service-providers-store.js';

const providerHappUrl =
	dirname(fileURLToPath(import.meta.url)) +
	'/../../workdir/service_provider_test.happ';
const consumerHappUrl =
	dirname(fileURLToPath(import.meta.url)) +
	'/../../workdir/service_consumer_test.happ';

export async function setup(scenario: Scenario) {
	const progenitor = await fakeAgentPubKey();
	const provider = await addPlayer(scenario, providerHappUrl, progenitor);
	const consumer = await addPlayer(scenario, consumerHappUrl, progenitor);

	// Shortcut peer discovery through gossip and register all agents in every
	// conductor of the scenario.
	await scenario.shareAllAgents();

	await dhtSync(
		[consumer.player, provider.player],
		provider.player.cells[0].cell_id[0],
	);

	console.log('Setup completed!');

	return { consumer, provider };
}

async function addPlayer(
	scenario: Scenario,
	happPath: string,
	progenitor: AgentPubKey,
) {
	const player = await scenario.addPlayerWithApp(
		{ appBundleSource: { type: 'path', value: happPath } },
		{
			// rolesSettings: {
			// 	service_providers_test: {
			// 		type: 'Provisioned',
			// 		modifiers: {
			// 			properties: {
			// 				progenitors: [encodeHashToBase64(progenitor)],
			// 			},
			// 		},
			// 	},
			// },
		},
	);
	console.log(
		'Added player with DNA hash: ',
		encodeHashToBase64(player.cells[0].cell_id[0]),
	);

	// patchCallZome(player.appWs as AppWebsocket);
	// await player.conductor
	// 	.adminWs()
	// 	.authorizeSigningCredentials(player.cells[0].cell_id);
	const store = new ServiceProvidersStore(
		new ServiceProvidersClient(player.appWs as any, 'service_providers_test'),
	);
	await store.client.getProvidersForService(new Uint8Array([]));
	return {
		store,
		player,
		startUp: async () => {
			await player.conductor.startUp();
			const port = await player.conductor.attachAppInterface();
			const issued = await player.conductor
				.adminWs()
				.issueAppAuthenticationToken({
					installed_app_id: player.appId,
				});
			const appWs = await player.conductor.connectAppWs(issued.token, port);
			patchCallZome(appWs);
			store.client.client = appWs;
		},
	};
}

function patchCallZome(appWs: AppWebsocket) {
	const callZome = appWs.callZome;
	appWs.callZome = async req => {
		try {
			const result = await callZome(req);
			return result;
		} catch (e) {
			if (
				!e.toString().includes('Socket is not open') &&
				!e.toString().includes('ClientClosedWithPendingRequests')
			) {
				throw e;
			}
		}
	};
}

export async function waitUntil(
	condition: () => Promise<boolean>,
	timeout: number,
) {
	const start = Date.now();
	const isDone = await condition();
	if (isDone) return;
	if (timeout <= 0) throw new Error('timeout');
	await pause(1000);
	return waitUntil(condition, timeout - (Date.now() - start));
}
