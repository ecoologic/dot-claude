---
name: http-apis
description: MUST use for writing HTTP APIs, ALWAYS produce RESTful APIs
---

# How to write HTTP APIs

1. ALWAYS apply RESTful standards for JSON APIs
1. ALWAYS keep the handler/controller focused on HTTP and authentication, delegate the rest (particularly domain logic)
1. ALWAYS respect HTTP (eg: implement the required headers like `location, retry-after`)

## Security

1. ALWAYS consider authentication needs
1. NEVER trust outside data, always sanitise and normalize here at the edge
1. ALWAYS validate user input here at the edge, then type it confidently

## Service layer

1. Service layer extract the domain logic alone, it never talks HTTP or authentication
1. Let the route handler be the only one that knows about HTTP and authentication


## Error handling

1. ALWAYS map internal errors to user friendly errors here at the edge
1. 500 errors are reserved to un-handled errors, never code to throw them, find a more specific error code

## Conventions

1. Use plural for nouns
1. Use `kebab-case` for separating words in paths
1. Use `camelCase` for params and JSON body
1. Two words in the english dictionary, two words in the code (eg: `YES firstName, NO firstname`)
1. Do not implement pagination unless required, limit to 200 elements
1. Pagination is implemented with cursor, not offset

## Endpoint usage format

Examples:

```sh
GET /users?filter[firstName]="${firstName}"
POST /users Body: { "firstName": "${firstName}" }
```

Include `headers` section only when relevant (eg: most of the times auth, accepts etc can be ignored).
