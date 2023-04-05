# Advanced patterns with Hasura

Using role based tables for leaner data models

Create an Admin role table.

```
CREATE TABLE admin (
  id INTEGER PRIMARY KEY
);
```

## Order Products

#### Mutation

```graphql
mutation ApplyForCreditCard {
  insert_credit_product_applications_one(object: { credit_product_id: 1 }) {
    id
  }
}
```
