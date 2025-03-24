import { css, html, LitElement } from 'lit';
import { provide, consume } from '@lit/context';
import { customElement, property } from 'lit/decorators.js';
import { AppClient } from '@holochain/client';
import { appClientContext } from '@tnesh-stack/elements';

import { serviceProvidersStoreContext } from '../context.js';
import { ServiceProvidersStore } from '../service-providers-store.js';
import { ServiceProvidersClient } from '../service-providers-client.js';

/**
 * @element service-providers-context
 */
@customElement('service-providers-context')
export class ServiceProvidersContext extends LitElement {
  @consume({ context: appClientContext })
  private client!: AppClient;

  @provide({ context: serviceProvidersStoreContext })
  @property({ type: Object })
  store!: ServiceProvidersStore;

  @property()
  role!: string;

  @property()
  zome = 'service_providers';

  connectedCallback() {
    super.connectedCallback();
    if (this.store) return;
    if (!this.role) {
      throw new Error(`<service-providers-context> must have a role="YOUR_DNA_ROLE" property, eg: <service-providers-context role="role1">`);
    }
    if (!this.client) {
      throw new Error(`<service-providers-context> must either:
        a) be placed inside <app-client-context>
          or 
        b) receive an AppClient property (eg. <service-providers-context .client=\${client}>) 
          or 
        c) receive a store property (eg. <service-providers-context .store=\${store}>)
      `);
    }

    this.store = new ServiceProvidersStore(new ServiceProvidersClient(this.client, this.role, this.zome));
  }
  
  render() {
    return html`<slot></slot>`;
  }

  static styles = css`
    :host {
      display: contents;
    }
  `;
}

