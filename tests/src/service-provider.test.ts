import { runScenario } from '@holochain/tryorama';
import { assert, test } from 'vitest';

import { setup, waitUntil } from './setup.js';

test('make service request', async () => {
	await runScenario(async scenario => {
		const { provider, consumer } = await setup(scenario);

		const serviceId = new Uint8Array([0, 1, 2]);

		await waitUntil(async () => {
			const providers =
				await consumer.store.client.getProvidersForService(serviceId);

			return providers.length === 1;
		}, 40_000);

		const response = await consumer.store.client.makeServiceRequest(
			serviceId,
			'ping',
			undefined,
		);

		assert.equal(response, 'pong');
	});
});
