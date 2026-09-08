---
name: testing
description: "MUST use when writing, reviewing, or refactoring automated tests"
---

# How to write automated tests

1. Tests are documentation written in code
1. Use black-box testing: Don't mock the behaviour that the test is trying to verify
1. DO NOT write tests _solely_ to validate logging, skip if nothing more important
1. Let the structure follow the real code structure
1. ALWAYS express domain logic and UX in tests, even unit tests
1. ALWAYS assert return values and thrown errors, which MUST be in the title of the test
1. If a test feels hard to write without poking internals, the test is probably violating black-box style, offer the user to change the production code
1. NEVER test endpoints return 500 error, if you found a bug, raise the issue, and we'll fix it separately

## Test format

Strict format order (nested):

1. Describe the parent
1. Describe the function
1. Describe the context
1. Describe the return value/error

Note how this format acts as internal documentation, which is the goal.

### API test format

```ts
describe('POST /users', () => {
  describe('when the email already exists', () => {
    it('returns Conflict', async () => {
      const response = await request(app)
        .post('/users')
        .send(existingEmailPayload);

      expect(response.status).toBe(409);
      // Then test response body...
    });
  });
});
```

### Functions test

```ts
describe('createUser', () => {
  describe('when the email already exists', () => {
    it('returns email validation error', async () => {
      const user = await createUser(userData);

      expect(user.errors).toEqual(["Email already present"]);
    });
  });
});
```

### Error testing

```ts
describe('createUser', () => {
  describe('when the email already exists', () => {
    it('throws email validation error', async () => {
      await expect(createUser(userData)).rejects.toThrow('Email already present');
    });
  });
});
```
