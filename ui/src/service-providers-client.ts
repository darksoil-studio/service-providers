import { 
  SignedActionHashed,
  CreateLink,
  Link,
  DeleteLink,
  Delete,
  AppClient, 
  Record, 
  ActionHash, 
  EntryHash, 
  AgentPubKey,
} from '@holochain/client';
import { EntryRecord, ZomeClient } from '@tnesh-stack/utils';

import { ServiceProvidersSignal } from './types.js';

export class ServiceProvidersClient extends ZomeClient<ServiceProvidersSignal> {

  constructor(public client: AppClient, public roleName: string, public zomeName = 'service_providers') {
    super(client, roleName, zomeName);
  }
}
