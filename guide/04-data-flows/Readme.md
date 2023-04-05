# Actions and Events

Actions are exposed as root level queries or mutations in the GraphQL API. Events are triggers that execute under conditional changes for inserts and updates.

## Adding Actions

Create a series of action called Signup and we'll use this URL

## Login

`{{AWS_LAMBDA_HOST}}/api/v1/auth/login`

### Type Definition

```graphql
type Mutation {
  login(username: String!, password: String!): TokenOutput
}
```

### Body Transform

```json
{
  "username": {{$body.input.username}},
  "password": {{$body.input.password}}
}
```

### Types

```graphql
type TokenOutput {
  id_token: String!
  access_token: String!
}
```

## Signup

`{{AWS_LAMBDA_HOST}}/api/v1/auth/signup`

### Type Definition

```graphql
type Mutation {
  """
  signup
  """
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

`{{AWS_LAMBDA_HOST}}/api/v1/auth/signup/confirm`

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

## Signout

`{{AWS_LAMBDA_HOST}}/api/v1/auth/signout`

### Type Definition

```graphql

```

### Types

```graphql

```

## Add Event Triggers

Create an event trigger for inserts on the table User. Use this URL:  
`{{EVENT_TRIGGER_BASE}}/<YOUR_MAGIC_NAMESPACE>`

Post transform

```json
{"body": {{$body}}}
```

Navigate to this endpoint
https://cloud.hasura.io/public/graphiql?endpoint=https://echo-server.hasura.app/v1/graphql

Use this query to subscribe to events. Change the channel to your own channel.

```graphql
subscription {
  posts_stream(
    cursor: { initial_value: { created_at: "2023-04-05 05:09:34.151181+00" } }
    batch_size: 10
  ) {
    channel
    payload
  }
}
```

## [Mooar](/guide/05-advanced-patterns/Readme.md)
