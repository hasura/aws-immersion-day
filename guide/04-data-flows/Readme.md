# Actions and Events

Actions are exposed as root level queries or mutations in the GraphQL API. Events are triggers that execute under conditional changes for inserts and updates.

## Adding Actions

Create a series of action called Signup and we'll use this URL

{{AWS_LAMBDA_HOST}}/api/v1/auth/login
{{AWS_LAMBDA_HOST}}/api/v1/auth/signup
{{AWS_LAMBDA_HOST}}/api/v1/auth/verify
{{AWS_LAMBDA_HOST}}/api/v1/auth/signout

## Add Event Triggers

Create an event trigger for inserts on the table User. Use this URL {{EVENT_TRIGGER_BASE}}/<YOUR_MAGIC_NAMESPACE>

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
