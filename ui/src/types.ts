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
import { ActionCommittedSignal } from '@tnesh-stack/utils';

export type ServiceProvidersSignal = ActionCommittedSignal<
	EntryTypes,
	LinkTypes
>;

export type EntryTypes = never;

export type LinkTypes = string;

export type ServiceId = Uint8Array;
