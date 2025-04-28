import { createContext } from '@lit/context';

import { ServiceProvidersStore } from './service-providers-store.js';

export const serviceProvidersStoreContext =
	createContext<ServiceProvidersStore>('service_providers/store');
