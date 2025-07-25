import { runScenario } from '@holochain/tryorama';
import { assert, test } from 'vitest';

import { setup, waitUntil } from './setup.js';

test('inactive providers get removed', async () => {
	await runScenario(async scenario => {
		const { consumer, providers } = await setup(scenario, 2);

		const serviceId = new Uint8Array([0, 1, 2]);

		await waitUntil(async () => {
			const providers =
				await consumer.store.client.getProvidersForService(serviceId);

			return providers.length === 2;
		}, 40_000);

		await providers[1].player.conductor.shutDown();

		await waitUntil(async () => {
			const providers =
				await consumer.store.client.getProvidersForService(serviceId);

			return providers.length === 1;
		}, 6 * 60_000);
	});
});
