# Setting up the infrastructure

You need to provision two key parts of the infrastructure. An AWS ecosystem of functions and databases, and the Hasura Cloud console.

## Setting up AWS

To set up your AWS accounts, you need to go to the following link.

![The rough architectural diagram of what we are building today.](/guide/assets/aws-arch.png)

### Magic strings to write down:

RDS Host 1 (RdsEndpoint):
RDS Username 1: postgres
RDS Password 1: pgpassword
RDS Database 1:

RDS Host 2 (RdsEndpoint):
RDS Username 2: postgres
RDS Password 2: pgpassword
RDS Database 2:

Lambda Host:

### Looking at the services

## Set up Hasura Cloud

Signup at https://cloud.hasura.io

### ENV Secrets

AWS_LAMBDA_HOST
RDS_DB_1
RDS_DB_2
HASURA_GRAPHQL_UNAUTHORIZED_ROLE
HASURA_GRAPHQL_JWT_SECRET
EVENT_TRIGGER_BASE: https://echo-server.hasura.app/api/rest/postify

### Dashboard run through

### Console run through

## Now it's time to [connect all the pieces](../03-data-joins/Readme.md)
