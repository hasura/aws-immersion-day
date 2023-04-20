# Setting up the infrastructure

You need to provision two key parts of the infrastructure. An AWS ecosystem of functions and databases, and the Hasura Cloud console.

---

## Setting up AWS

To set up your AWS accounts, you need to go to the following link.

https://dashboard.eventengine.run/login?hash=cba7-1e6c027654-d0

![The rough architectural diagram of what we are building today.](/guide/assets/aws-arch.png)

### Looking at the services

1. RDS
2. Athena
3. Cognito
4. Lambda

---

## Set up Hasura Cloud

Signup at https://cloud.hasura.io

### Copying Stack outputs to env vars

![Env vars to copy.](/guide/assets/env-vars.png)

Also, add the EVENT_TRIGGER_URL: https://echo-server.hasura.app/api/rest/postify

---

## House Keeping:

1. Seed Cognito users
2. Lock down RDS
3. Add environment variables to lambdas

---

### Cognito hook sequence

```mermaid
sequenceDiagram
    participant RDS
    participant Hasura
    participant Cognito
    participant PostConfirmHook


    Hasura->>Cognito: Request for user confirmation with code
    Cognito->>PostConfirmHook: Sends confirmation event with user data
    PostConfirmHook->>Hasura: Writes user data to Hasura via GraphQL
    Hasura->>RDS: Writes user data to RDS via SQL
```

---

### Coinbase sequence

```mermaid
sequenceDiagram
    participant RDS
    participant Hasura
    participant Lambda
    participant Coinbase

    loop Every 1 minute
        Hasura->>Lambda: Initiates Lambda function call
        Lambda->>Coinbase: Fetches data from Coinbase API
        Coinbase-->>Lambda: Returns data from Coinbase API
        Lambda->>Hasura: Returns data from Coinbase API via GraphQL
        Hasura->>RDS: Writes data from Coinbase API to RDS via SQL
    end

```

---

### Login Flow

```mermaid
sequenceDiagram
    participant Client
    participant Hasura
    participant Lambda
    participant Cognito
    participant PostAuthenticateHook


    Client->>Hasura: Sends login mutation request
    Hasura->>Lambda: Sends user authentication Action
    Lambda->>Cognito: Sends user authentication request
    Cognito-->>PostAuthenticateHook: Sends JWT with Cognito claims
    PostAuthenticateHook->>Cognito: Adds Hasura claims to JWT
    Cognito->>Lambda: Responds with enhanced JWT
    Lambda-->>Hasura: Returns JWT with Hasura claims
    Hasura-->>Client: Returns authenticated user with JWT Payload

```

### ENV Secrets

AWS_LAMBDA_HOST
RDS_DB_1
RDS_DB_2
HASURA_GRAPHQL_UNAUTHORIZED_ROLE
HASURA_GRAPHQL_JWT_SECRET
EVENT_TRIGGER_BASE: https://echo-server.hasura.app/api/rest/postify

### Dashboard run through

### Console run through

## Now it's time to [connect all the pieces](/guide/03-data-joins/Readme.md)
