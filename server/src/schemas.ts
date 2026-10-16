import { Type } from '@fastify/type-provider-typebox';
import type { TSchema } from '@fastify/type-provider-typebox';

// Every request and response model, named by $id so the OpenAPI spec has
// one component per model and the Dart client one class per model (D3).

/** Most changes one push may carry. */
export const MAX_BATCH = 1000;

/** A string enum, rendered as one `enum` so generated clients get one type. */
const StringEnum = <T extends string>(values: readonly T[], description?: string) =>
  Type.Unsafe<T>({ type: 'string', enum: [...values], ...(description ? { description } : {}) });

const Op = StringEnum(['upsert', 'delete'] as const);
const Row = Type.Record(Type.String(), Type.Unknown(), {
  description: 'Payload columns in snake_case, as in the app database. Absent on a delete.',
});

export const Health = Type.Object(
  { status: Type.String(), version: Type.String() },
  { $id: 'Health' },
);

export const ErrorBody = Type.Object({ error: Type.String() }, { $id: 'Error' });

export const User = Type.Object({ id: Type.String(), email: Type.String() }, { $id: 'User' });

export const AuthGoogleRequest = Type.Object(
  { idToken: Type.String({ minLength: 1, description: 'A Google ID token for the Web client id.' }) },
  { $id: 'AuthGoogleRequest' },
);

export const Session = Type.Object(
  {
    token: Type.String({ description: 'Opaque bearer token; only its hash is stored.' }),
    expiresAt: Type.String({ format: 'date-time' }),
    user: Type.Ref('User'),
  },
  { $id: 'Session' },
);

export const ChangeDto = Type.Object(
  {
    table: Type.String(),
    id: Type.String(),
    op: Op,
    updatedAt: Type.Optional(Type.String({ description: 'Required on an upsert of a mutable table.' })),
    deletedAt: Type.Optional(Type.String()),
    row: Type.Optional(Row),
  },
  { $id: 'ChangeDto' },
);

export const PushRequest = Type.Object(
  {
    deviceId: Type.String({ minLength: 1, maxLength: 64 }),
    changes: Type.Array(Type.Ref('ChangeDto'), { maxItems: MAX_BATCH }),
  },
  { $id: 'PushRequest' },
);

export const PushResult = Type.Object(
  {
    table: Type.String(),
    id: Type.String(),
    status: StringEnum(['applied', 'ignored', 'rejected'] as const),
    reason: Type.Optional(StringEnum(['clock', 'malformed'] as const)),
    message: Type.Optional(Type.String()),
  },
  { $id: 'PushResult' },
);

export const PushResponse = Type.Object(
  { results: Type.Array(Type.Ref('PushResult')) },
  { $id: 'PushResponse' },
);

export const PulledChangeDto = Type.Object(
  {
    table: Type.String(),
    id: Type.String(),
    op: Op,
    seq: Type.Integer(),
    deviceId: Type.String(),
    updatedAt: Type.Optional(Type.String()),
    deletedAt: Type.Optional(Type.String()),
    row: Type.Optional(Row),
  },
  { $id: 'PulledChangeDto' },
);

export const PullResponse = Type.Object(
  {
    changes: Type.Array(Type.Ref('PulledChangeDto')),
    cursor: Type.Integer(),
    hasMore: Type.Boolean(),
  },
  { $id: 'PullResponse' },
);

/** Registered with Fastify in this order, so every $ref resolves. */
export const SCHEMAS: TSchema[] = [
  Health,
  ErrorBody,
  User,
  AuthGoogleRequest,
  Session,
  ChangeDto,
  PushRequest,
  PushResult,
  PushResponse,
  PulledChangeDto,
  PullResponse,
];

/** A reference to a registered model, for route schemas. */
export const ref = (schema: TSchema) => ({ $ref: `${(schema as { $id: string }).$id}#` });

