DROP DATABASE IF EXISTS credit_data WITH (FORCE);
DROP DATABASE IF EXISTS crypto_data WITH (FORCE);
DROP DATABASE IF EXISTS user_data WITH (FORCE);
CREATE DATABASE credit_data;
CREATE DATABASE crypto_data;
CREATE DATABASE user_data;

\c credit_data

CREATE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE bureau_id_seq RESTART WITH 1 INCREMENT BY 1;
CREATE TABLE bureau (
    bureau_id INTEGER PRIMARY KEY DEFAULT nextval('bureau_id_seq'::regclass) NOT NULL,
    name TEXT NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON bureau
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE SEQUENCE history_id_seq RESTART WITH 1 INCREMENT BY 1;
CREATE TABLE history (
    credit_id INTEGER PRIMARY KEY DEFAULT nextval('history_id_seq'::regclass) NOT NULL,
    user_id INTEGER NOT NULL,
    bureau_id INTEGER NOT NULL,
    score INTEGER NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON history
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

INSERT INTO bureau VALUES
  (1, 'Equifax', '1970-01-01 00:00:00.0000', '1970-01-01 00:00:00.0000'),
  (2, 'Experian', '1970-01-01 00:00:00.0000', '1970-01-01 00:00:00.0000'),
  (3, 'TransUnion', '1970-01-01 00:00:00.0000', '1970-01-01 00:00:00.0000');

INSERT INTO history (user_id, bureau_id, score, created, updated) VALUES
  (1, 1, 560, '2023-01-01 01:00:00.00', '2023-01-01 01:00:00.00'),
  (1, 2, 580, '2023-01-01 02:00:00.00', '2023-01-01 02:00:00.00'),
  (1, 3, 570, '2023-01-01 03:00:00.00', '2023-01-01 03:00:00.00'),
  (1, 1, 555, '2023-02-01 01:00:00.00', '2023-02-01 01:00:00.00'),
  (1, 2, 575, '2023-02-01 02:00:00.00', '2023-02-01 02:00:00.00'),
  (1, 3, 565, '2023-02-01 03:00:00.00', '2023-02-01 03:00:00.00'),
  (1, 1, 550, '2023-03-01 01:00:00.00', '2023-03-01 01:00:00.00'),
  (1, 2, 570, '2023-03-01 02:00:00.00', '2023-03-01 02:00:00.00'),
  (1, 3, 560, '2023-03-01 03:00:00.00', '2023-03-01 03:00:00.00'),
  (2, 1, 760, '2023-01-01 01:00:00.00', '2023-01-01 01:00:00.00'),
  (2, 2, 780, '2023-01-01 02:00:00.00', '2023-01-01 02:00:00.00'),
  (2, 3, 790, '2023-01-01 03:00:00.00', '2023-01-01 03:00:00.00'),
  (2, 1, 765, '2023-02-01 01:00:00.00', '2023-02-01 01:00:00.00'),
  (2, 2, 785, '2023-02-01 02:00:00.00', '2023-02-01 02:00:00.00'),
  (2, 3, 795, '2023-02-01 03:00:00.00', '2023-02-01 03:00:00.00'),
  (2, 1, 770, '2023-03-01 01:00:00.00', '2023-03-01 01:00:00.00'),
  (2, 2, 790, '2023-03-01 02:00:00.00', '2023-03-01 02:00:00.00'),
  (2, 3, 800, '2023-03-01 03:00:00.00', '2023-03-01 03:00:00.00');

\c crypto_data

CREATE TABLE btc (
    time TIMESTAMP WITHOUT TIME ZONE PRIMARY KEY NOT NULL,
    symbol CHARACTER VARYING(8) NOT NULL,
    ask NUMERIC NOT NULL,
    bid NUMERIC NOT NULL,
    volume NUMERIC NOT NULL,
    trade_id INTEGER NOT NULL,
    price NUMERIC NOT NULL,
    size NUMERIC
);

CREATE TABLE eth (
    time TIMESTAMP WITHOUT TIME ZONE PRIMARY KEY NOT NULL,
    symbol CHARACTER VARYING(8) NOT NULL,
    ask NUMERIC NOT NULL,
    bid NUMERIC NOT NULL,
    volume NUMERIC NOT NULL,
    trade_id INTEGER NOT NULL,
    price NUMERIC NOT NULL,
    size NUMERIC
);

\c user_data

CREATE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TABLE users (
    user_id UUID PRIMARY KEY NOT NULL,
    username TEXT NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE SEQUENCE profile_id_seq RESTART WITH 1 INCREMENT BY 1;
CREATE TYPE profile_type AS ENUM (
    'Business',
    'Home',
    'Other'
);
CREATE TYPE phone_type AS ENUM (
    'Business',
    'Home',
    'Mobile',
    'Other'
);
CREATE TABLE profiles (
    profile_id INTEGER PRIMARY KEY DEFAULT nextval('profile_id_seq'::regclass) NOT NULL,
    user_id UUID REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    type profile_type DEFAULT 'Home'::profile_type NOT NULL,
    country_code SMALLINT DEFAULT 1 NOT NULL,
    phone_number BIGINT NOT NULL,
    phone_type phone_type DEFAULT 'Mobile'::phone_type NOT NULL,
    email TEXT NOT NULL,
    avatar TEXT,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    CHECK (((country_code > 0) AND (country_code < 999))),
    CHECK (((email)::text ~~ '%@%'::text)),
    CHECK (((char_length((phone_number)::text) > 3) AND (char_length((phone_number)::text) < 16)))
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON profiles
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE SEQUENCE address_id_seq RESTART WITH 1 INCREMENT BY 1;
CREATE TYPE address_type AS ENUM (
    'Mailing',
    'Physical'
);
CREATE TABLE addresses (
    address_id INTEGER DEFAULT nextval('address_id_seq'::regclass) NOT NULL,
    user_id UUID REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    type address_type DEFAULT 'Physical'::address_type NOT NULL,
    address_1 TEXT NOT NULL,
    address_2 TEXT,
    city TEXT NOT NULL,
    state TEXT,
    zip_code TEXT,
    country TEXT DEFAULT 'United States'::TEXT NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON addresses
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE TYPE account_type AS ENUM (
    'Checking',
    'Crypto',
    'Investment',
    'Savings'
);
CREATE TABLE accounts (
    account_id INTEGER PRIMARY KEY DEFAULT (floor(((random() * (((999999999 - 100000000) + 1))::DOUBLE PRECISION) + (100000000)::DOUBLE PRECISION)))::INTEGER NOT NULL,
    user_id UUID REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    type account_type DEFAULT 'Savings'::account_type NOT NULL,
    balance NUMERIC(12, 2) DEFAULT '0.00'::NUMERIC NOT NULL,
    currency CHARACTER VARYING(3) DEFAULT 'USD'::CHARACTER VARYING NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
 );
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON accounts
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE SEQUENCE investment_id_seq RESTART WITH 1 INCREMENT BY 1;
CREATE TABLE investments (
    investment_id INTEGER PRIMARY KEY DEFAULT nextval('investment_id_seq'::regclass) NOT NULL,
    account_id INTEGER REFERENCES accounts(account_id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    symbol CHARACTER VARYING(4) NOT NULL,
    quantity DOUBLE PRECISION NOT NULL,
    unit_price NUMERIC(12, 2) NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    CHECK ((account_id > 99999999 AND account_id < 1000000000)),
    CHECK ((quantity >= 0)),
    CHECK ((unit_price >= 0::NUMERIC))
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON investments
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE SEQUENCE wallet_id_seq RESTART WITH 1 INCREMENT BY 1;
CREATE TABLE wallets (
    wallet_id INTEGER PRIMARY KEY DEFAULT nextval('wallet_id_seq'::regclass) NOT NULL,
    account_id INTEGER REFERENCES accounts(account_id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    symbol CHARACTER VARYING(8) NOT NULL,
    quantity DOUBLE PRECISION NOT NULL,
    unit_price NUMERIC(12, 2) NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    CHECK ((account_id > 99999999 AND account_id < 1000000000)),
    CHECK ((quantity >= 0)),
    CHECK ((unit_price >= 0::NUMERIC))
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON wallets
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE SEQUENCE balance_id_seq RESTART WITH 1 INCREMENT BY 1;
CREATE TABLE balances (
    balance_id INTEGER PRIMARY KEY DEFAULT nextval('balance_id_seq'::regclass) NOT NULL,
    account_id INTEGER REFERENCES accounts(account_id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    type account_type NOT NULL,
    balance NUMERIC(12, 2) NOT NULL,
    date TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    CHECK ((account_id > 99999999 AND account_id < 1000000000))
);

CREATE SEQUENCE statement_id_seq RESTART WITH 1 INCREMENT BY 1;
CREATE TABLE statements (
    statement_id INTEGER PRIMARY KEY DEFAULT nextval('statement_id_seq'::regclass) NOT NULL,
    account_id INTEGER REFERENCES accounts(account_id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    type account_type NOT NULL,
    file TEXT NOT NULL,
    date TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    CHECK ((account_id > 99999999 AND account_id < 1000000000))
);

CREATE SEQUENCE transactions_id_seq RESTART WITH 1 INCREMENT BY 1;
CREATE TABLE transactions (
    transactions_id INTEGER PRIMARY KEY DEFAULT nextval('transactions_id_seq'::regclass) NOT NULL,
    account_id INTEGER REFERENCES accounts(account_id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    type account_type NOT NULL,
    description TEXT NOT NULL,
    investment_id INTEGER REFERENCES investments(investment_id) ON UPDATE CASCADE ON DELETE CASCADE,
    wallet_id INTEGER REFERENCES wallets(wallet_id) ON UPDATE CASCADE ON DELETE CASCADE,
    quantity DOUBLE PRECISION,
    unit_price NUMERIC(12, 2),
    total_price NUMERIC(12, 2) NOT NULL,
    pre_balance NUMERIC(12, 2),
    post_balance NUMERIC(12, 2),
    date TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    CHECK ((account_id > 99999999 AND account_id < 1000000000)),
    CHECK ((investment_id) > 0),
    CHECK ((wallet_id) > 0)
);

INSERT INTO users (user_id, username, first_name, last_name, created, updated) VALUES
  ('<tommy.callahan>', 'tommy.callahan', 'Tommy', 'Callahan', '2023-01-02 10:00:00.00', '2022-01-02 10:00:00.00'),
  ('<richard.hayden>', 'richard.hayden', 'Richard', 'Hayden', '2023-01-02 10:00:00.00', '2022-01-02 10:00:00.00');

INSERT INTO profiles (user_id, type, country_code, phone_number, phone_type, email, created, updated) VALUES
  ('<tommy.callahan>', 'Business', 1, 5551234561, 'Business', 'tommy@callahanautoparts.com', '2022-01-02 10:00:00.00', '2022-01-02 10:00:00.00'),
  ('<richard.hayden>', 'Business', 1, 5551234562, 'Business', 'richard@callahanautoparts.com', '2022-01-02 10:00:00.00', '2022-01-02 10:00:00.00');

INSERT INTO addresses (user_id, type, address_1, city, state, zip_code, country, created, updated) VALUES
  ('<tommy.callahan>', 'Physical', '145 Provence Boulevard', 'Sandusky', 'OH', 44870, 'United States', '2022-05-01 00:00:00.00', '2022-05-01 00:00:00.00'),
  ('<richard.hayden>', 'Physical', '145 Provence Boulevard', 'Sandusky', 'OH', 44870, 'United States', '2022-05-01 00:00:00.00', '2022-05-01 00:00:00.00');

INSERT INTO accounts (account_id, user_id, type, balance, currency, created, updated) VALUES
  (732959224, '<tommy.callahan>', 'Checking', 75000.00, 'USD', '2023-01-02 10:00:00.00', '2023-04-05 01:00:00.00'),
  (362929485, '<tommy.callahan>', 'Savings', 250000.00, 'USD', '2023-01-02 10:00:00.00', '2023-04-05 01:00:00.00'),
  (993804711, '<tommy.callahan>', 'Investment', 9478.20, 'USD', '2023-01-02 10:00:00.00', '2023-04-05 01:00:00.00'),
  (693787850, '<tommy.callahan>', 'Crypto', 0.00, 'USD', '2023-01-02 10:00:00.00', '2023-04-05 01:00:00.00'),
  (762551510, '<richard.hayden>', 'Checking', 40000.00, 'USD', '2023-01-02 10:00:00.00', '2023-04-05 01:00:00.00'),
  (145302955, '<richard.hayden>', 'Savings', 90000.00, 'USD', '2023-01-02 10:00:00.00', '2023-04-05 01:00:00.00'),
  (126941757, '<richard.hayden>', 'Investment', 1327.85, 'USD', '2023-01-02 10:00:00.00', '2023-04-05 01:00:00.00'),
  (554436372, '<richard.hayden>', 'Crypto', 0.00, 'USD', '2023-01-02 10:00:00.00', '2023-04-05 01:00:00.00');

INSERT INTO balances (account_id, type, balance, date) VALUES
  (732959224, 'Checking', 75000.00, '2023-02-01 01:00:00.00'),
  (362929485, 'Savings', 250000.00, '2023-02-01 01:00:00.00'),
  (993804711, 'Investment', 12768.25, '2023-02-01 01:00:00.00'),
  (693787850, 'Crypto', 0.00, '2023-02-01 01:00:00.00'),
  (762551510, 'Checking', 40000.00, '2023-02-01 01:00:00.00'),
  (145302955, 'Savings', 90000.00, '2023-02-01 01:00:00.00'),
  (126941757, 'Investment', 2183.80, '2023-02-01 01:00:00.00'),
  (554436372, 'Crypto', 0.00, '2023-02-01 01:00:00.00'),
  (732959224, 'Checking', 75000.00, '2023-03-01 01:00:00.00'),
  (362929485, 'Savings', 250000.00, '2023-03-01 01:00:00.00'),
  (993804711, 'Investment', 15458.45, '2023-03-01 01:00:00.00'),
  (693787850, 'Crypto', 0.00, '2023-03-01 01:00:00.00'),
  (762551510, 'Checking', 40000.00, '2023-03-01 01:00:00.00'),
  (145302955, 'Savings', 90000.00, '2023-03-01 01:00:00.00'),
  (126941757, 'Investment', 2326.25, '2023-03-01 01:00:00.00'),
  (554436372, 'Crypto', 0.00, '2023-03-01 01:00:00.00'),
  (732959224, 'Checking', 75000.00, '2023-04-01 01:00:00.00'),
  (362929485, 'Savings', 250000.00, '2023-04-01 01:00:00.00'),
  (993804711, 'Investment', 13190.20, '2023-04-01 01:00:00.00'),
  (693787850, 'Crypto', 0.00, '2023-04-01 01:00:00.00'),
  (762551510, 'Checking', 40000.00, '2023-04-01 01:00:00.00'),
  (145302955, 'Savings', 90000.00, '2023-04-01 01:00:00.00'),
  (126941757, 'Investment', 1327.85, '2023-04-01 01:00:00.00'),
  (554436372, 'Crypto', 0.00, '2023-04-01 01:00:00.00');

INSERT INTO investments (account_id, name, symbol, quantity, unit_price, created, updated) VALUES
  (993804711, 'Apple Inc', 'AAPL', 25, 125.02, '2023-01-05 14:00:00.00', '2023-02-21 13:00:00.00'),  -- Sell
  (993804711, 'Microsoft Corp', 'MSFT', 25, 239.23, '2023-01-13 11:00:00.00', '2023-01-13 11:00:00.00'),
  (126941757, 'Coca-Cola Co', 'KO', 20, 59.81, '2023-01-18 12:00:00.00', '2023-01-18 12:00:00.00'),
  (126941757, 'Johnson & Johnson', 'JNJ', 5, 162.00, '2023-01-30 16:00:00.00', '2023-02-02 09:00:00.00'),  -- Sell
  (993804711, 'Amazon.com, Inc.', 'AMZN', 10, 102.18, '2023-02-06 09:00:00.00', '2023-02-06 09:00:00'),
  (126941757, 'Procter & Gamble Co', 'PG', 5, 137.05, '2023-02-09 10:00:00.00', '2023-02-09 10:00:00.00'),
  (993804711, 'Amazon.com, Inc.', 'AMZN', 25, 90.73, '2023-03-10 15:00:00.00', '2023-03-10 15:00:00'),
  (126941757, 'Exxon Mobile Corp', 'XOM', 10, 99.84, '2023-03-17 13:00:00.00', '2023-03-17 13:00:00.00');

INSERT INTO transactions (account_id, type, description, investment_id, quantity, unit_price, total_price, pre_balance, post_balance, date) VALUES
  (732959224, 'Checking', 'Initial Deposit', NULL, NULL, NULL, 100000.00, 0.00, 100000.00, '2023-01-02 10:00:00.00'),
  (762551510, 'Checking', 'Initial Deposit', NULL, NULL, NULL, 45000.00, 0.00, 45000.00, '2023-01-02 10:00:00.00'),
  (362929485, 'Savings', 'Initial Deposit', NULL, NULL, NULL, 250000.00, 0.00, 250000.00, '2023-01-02 10:00:00.00'),
  (145302955, 'Savings', 'Initial Deposit', NULL, NULL, NULL, 90000.00, 0.00, 90000.00, '2023-01-02 10:00:00.00'),
  (732959224, 'Checking', 'Transfer to Investment', NULL, NULL, NULL, -25000.00, 100000.00, 75000.00, '2023-01-05 13:00:00.00'),
  (993804711, 'Investment', 'Purchase AAPL', 1, 25, 125.02, -6251.00, 25000.00, 18749.00, '2023-01-05 14:00:00.00'),
  (993804711, 'Investment', 'Purchase MSFT', 2, 25, 239.23, -5980.75, 18749.00, 12768.25, '2023-01-13 11:00:00.00'),
  (762551510, 'Checking', 'Transfer to Investment', NULL, NULL, NULL, -5000.00, 45000.00, 40000.00, '2023-01-18 11:00:00.00'),
  (126941757, 'Investment', 'Purchase KO', 3, 20, 59.81, -1196.20, 5000, 3803.80, '2023-01-18 12:00:00.00'),
  (126941757, 'Investment', 'Purchase JNJ', 4, 10, 162.00, -1620.00, 3803.80, 2183.80, '2023-01-30 16:00:00.00'),
  (126941757, 'Investment', 'Sell JNJ', 4, 5, 165.54, 827.70, 2183.80, 3011.50, '2023-02-02 09:00:00.00'),
  (993804711, 'Investment', 'Purchase AMZN', 5, 10, 102.18, -1021.80, 12768.25, 11746.45, '2023-02-06 09:00:00.00'),
  (126941757, 'Investment', 'Purchase PG', 6, 5, 137.05, -685.25, 3011.50, 2326.25, '2023-02-09 10:00:00.00'),
  (993804711, 'Investment', 'Sell AAPL', 1, 25, 148.48, 3712.00, 11746.45, 15458.45, '2023-02-21 13:00:00.00'),
  (993804711, 'Investment', 'Purchase AMZN', 7, 25, 90.73, -2268.25, 15458.45, 13190.20, '2023-03-10 15:00:00.00'),
  (126941757, 'Investment', 'Purchase XOM', 8, 10, 99.84, -998.40, 2326.25, 1327.85, '2023-03-17 13:00:00.00');

INSERT INTO statements (account_id, type, file, date) VALUES
  (732959224, 'Checking', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-02-01 01:00:00.00'),
  (362929485, 'Savings', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-02-01 01:00:00.00'),
  (993804711, 'Investment', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-02-01 01:00:00.00'),
  (693787850, 'Crypto', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-02-01 01:00:00.00'),
  (732959224, 'Checking', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-03-01 01:00:00.00'),
  (362929485, 'Savings', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-03-01 01:00:00.00'),
  (993804711, 'Investment', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-03-01 01:00:00.00'),
  (693787850, 'Crypto', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-03-01 01:00:00.00'),
  (732959224, 'Checking', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-04-01 01:00:00.00'),
  (362929485, 'Savings', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-04-01 01:00:00.00'),
  (993804711, 'Investment', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-04-01 01:00:00.00'),
  (693787850, 'Crypto', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-04-01 01:00:00.00'),
  (762551510, 'Checking', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-02-01 01:00:00.00'),
  (145302955, 'Savings', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-02-01 01:00:00.00'),
  (126941757, 'Investment', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-02-01 01:00:00.00'),
  (554436372, 'Crypto', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-02-01 01:00:00.00'),
  (762551510, 'Checking', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-03-01 01:00:00.00'),
  (145302955, 'Savings', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-03-01 01:00:00.00'),
  (126941757, 'Investment', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-03-01 01:00:00.00'),
  (554436372, 'Crypto', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-03-01 01:00:00.00'),
  (762551510, 'Checking', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-04-01 01:00:00.00'),
  (145302955, 'Savings', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-04-01 01:00:00.00'),
  (126941757, 'Investment', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-04-01 01:00:00.00'),
  (554436372, 'Crypto', 'https://hasura-aws-immersion-day.s3.amazonaws.com/pdf/sample_statement.pdf', '2023-04-01 01:00:00.00');