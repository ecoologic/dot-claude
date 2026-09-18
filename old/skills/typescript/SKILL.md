---
name: typescript
description: MUST use when reading or writing TypeScript files (.ts, .tsx, .js, tsconfig.json).
---

# How to use TypeScript

1. Type everything except return types
1. Be specific (eg: use a `userDbId` not strings alone), then compose types

## Prefer inferred return types

1. Define return types _only_ when they improve correctness or reinforce semantic intent
1. NEVER widen inferred return types

## Infer types from real sources of truth

Reduces duplication:

1. Infer types from stable concretions: schemas, constants, return values, config, fixtures with `as const`
1. NEVER infer domain types from arbitrary example objects
1. Avoid deep/chained utility types when a named type would be clearer
1. Prefer simple utilities: `typeof`, `ReturnType`, `Awaited`, `Pick`, `Omit`, `Partial`, `Extract`


## ALWAYS include type guards when you need duck-typing

```ts
const isAdmin = (user: User): user is Admin => user.role === "admin";
```

## NEVER use enums

Prefer union types derived from `as const` arrays; see "Const assertions for literal unions" below.

## Make Illegal States Un-representable

Use the type system to prevent invalid states at compile time.

### Discriminated unions for mutually exclusive states

```ts
// Good: only valid combinations possible
type RequestState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

// Bad: allows invalid combinations like { loading: true, error: Error }
type RequestState<T> = {
  loading: boolean;
  data?: T;
  error?: Error;
};
```

### Branded types for domain primitives

```ts
type UserId = string & { readonly __brand: 'UserId' };
type OrderId = string & { readonly __brand: 'OrderId' };

// Compiler prevents passing OrderId where UserId expected
function getUser(id: UserId): Promise<User> { /* ... */ }
```

### Const assertions for literal unions

```ts
const ROLES = ['admin', 'user', 'guest'] as const;
type Role = typeof ROLES[number]; // 'admin' | 'user' | 'guest'

// Array and type stay in sync automatically
function isValidRole(role: string): role is Role {
  return ROLES.includes(role as Role);
}
```

### Exhaustive switch with never check
```ts
type Status = "active" | "inactive";

function processStatus(status: Status): string {
  switch (status) {
    case "active":
      return "processing";
    case "inactive":
      return "skipped";
    default: {
      const _exhaustive: never = status;
      throw new Error(`unhandled status: ${_exhaustive}`);
    }
  }
}
```

## Runtime Validation with Zod 4

1. Define schemas as single source of truth; infer TypeScript types with `z.infer<>`. Avoid duplicating types and schemas.
1. Use `safeParse` for user input where failure is expected; use `parse` at trust boundaries where invalid data is a bug.
1. Compose schemas with `.extend()`, `.pick()`, `.omit()`, `.merge()` for DRY definitions.
1. Add `.transform()` for data normalization at parse time (trim strings, parse dates).

```ts
import { z } from "zod";

const UserSchema = z.object({
  id: z.uuid(),
  email: z.email(),
  name: z.string().min(1),
  createdAt: z.string().transform((s) => new Date(s)),
});

type User = z.infer<typeof UserSchema>;

// Strict parsing at trust boundaries — throws if API contract violated
export async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) {
    throw new Error(`fetch user ${id} failed: ${response.status}`);
  }
  return UserSchema.parse(await response.json());
}

// Caller handles both success and error from user input
const result = UserSchema.safeParse(formData);
if (!result.success) {
  setErrors(result.error.flatten().fieldErrors);
  return;
}
```
