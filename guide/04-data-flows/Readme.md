# Actions and Events

Actions are exposed as root level queries or mutations in the GraphQL API. Events are triggers that execute under conditional changes for inserts and updates.

Skip if you imported metadata.

## Adding Actions

Create a series of action called Signup and we'll use this URL

## Login

`{{LAMBDA_URL}}/api/v1/auth/login`

### Type Definition

```graphql
type Mutation {
  login(username: String!, password: String!): TokenOutput
}
```

### Types

```graphql
type TokenOutput {
  id_token: String!
  access_token: String!
}
```

### Body Transform

```json
{
  "username": {{$body.input.username}},
  "password": {{$body.input.password}}
}
```

## Signup

`{{LAMBDA_URL}}/api/v1/auth/signup`

### Type Definition

```graphql
type Mutation {
  signup(
    username: String!
    password: String!
    email: String!
    first_name: String!
    last_name: String!
  ): json
}
```

### Body Transform

```json
{
    "username": {{$body.input.username}},
    "password": {{$body.input.password}},
    "email": {{$body.input.email}},
    "first_name": {{$body.input.first_name}},
    "last_name": {{$body.input.last_name}},
    "phone_number": "5555"
}
```

## Verify

`{{LAMBDA_URL}}/api/v1/auth/signup/confirm`

### Type Definition

```graphql
type Mutation {
  """
  Signup Confirm
  """
  signupConfirm(code: String!, username: String!): json
}
```

### body

```json
{
    "username": {{$body.input.username}},
    "code": {{$body.input.code}}
}

```

## Add Event Triggers

Create an event trigger for inserts on the table User. Use this URL:  
`{{EVENT_TRIGGER_BASE}}/<YOUR_MAGIC_NAMESPACE>`

Post transform

```json
{"body": {{$body}}}
```

Browser to https://postify-theta.vercel.app/<YOUR_NAMESPACE>

---

## Add Permissions

1. User Role
2. Anonymous Role
3. Decode JWT tokens
4. Default values

## [Mooar](/guide/05-advanced-patterns/Readme.md)
