# Look at the data sources

## Database 1

Our primary transactional database lives in RDS.

## Databse 2

Our credit report data from the big three.

## Database 3

Static file processing with Athena.

## Connecting the data sources

Use the environment variables

## Adding feautures

Beyond this basic data model, we're going to add support for selling Credit Cards to users.

```sql
CREATE TABLE c_application_status_enum (
  value VARCHAR(255) NOT NULL PRIMARY KEY,
  description VARCHAR(255)
);

CREATE TABLE credit_products (
  id SERIAL PRIMARY KEY,
  annual_fee DECIMAL(10,2) NOT NULL,
  interest_rate DECIMAL(10,2) NOT NULL
);

CREATE TABLE credit_product_applications (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(user_id),
  credit_product_id INTEGER NOT NULL REFERENCES credit_products(id),
  date_applied DATE NOT NULL,
  status VARCHAR(255) NOT NULL REFERENCES c_application_status_enum(value)
);
```

Insert data:

```sql
INSERT INTO credit_products (annual_fee, interest_rate) VALUES (0.00, 15.99);
INSERT INTO credit_products (annual_fee, interest_rate) VALUES (99.00, 18.99);
INSERT INTO credit_products (annual_fee, interest_rate) VALUES (59.00, 12.99);
INSERT INTO credit_products (annual_fee, interest_rate) VALUES (29.00, 21.99);
INSERT INTO credit_products (annual_fee, interest_rate) VALUES (149.00, 14.99);
```

## Adding Remote Schemas

Now that we've added a product to our mobile banking offering, we want to bring in our CMS data. Since we are a cutting edge bank, of course our CMS is headless and offers a GraphQL API.

We're going to add this remote schema.

https://us-east-1-shared-usea1-02.cdn.hygraph.com/content/clg39oqud10xw01szfm8m5wln/master

You'll need to provide a namespace for remote schemas.
