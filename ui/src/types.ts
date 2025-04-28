import { ActionCommittedSignal } from '@darksoil-studio/holochain-utils';
import {
	ActionHash,
	AgentPubKey,
	Create,
	CreateLink,
	Delete,
	DeleteLink,
	DnaHash,
	EntryHash,
	Record,
	SignedActionHashed,
	Update,
} from '@holochain/client';

export type ServiceProvidersSignal = ActionCommittedSignal<
	EntryTypes,
	LinkTypes
>;

export type EntryTypes = never;

export type LinkTypes = string;

export type ServiceId = Uint8Array;
