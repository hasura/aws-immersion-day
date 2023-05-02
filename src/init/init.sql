DROP DATABASE IF EXISTS accounts WITH (FORCE);
DROP DATABASE IF EXISTS crypto WITH (FORCE);
DROP DATABASE IF EXISTS historical_prices WITH (FORCE);
DROP DATABASE IF EXISTS investments WITH (FORCE);
DROP DATABASE IF EXISTS trades WITH (FORCE);
DROP DATABASE IF EXISTS transactions WITH (FORCE);
DROP DATABASE IF EXISTS users WITH (FORCE);

CREATE DATABASE accounts;
CREATE DATABASE crypto;
CREATE DATABASE historical_prices;
CREATE DATABASE investments;
CREATE DATABASE trades;
CREATE DATABASE transactions;
CREATE DATABASE users;


\c accounts

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = TG_TABLE_NAME
        AND column_name = 'updated'
    ) THEN
        NEW.updated = now();
    ELSE
        NEW.date = now();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TYPE account_type AS ENUM (
    'Brokerage',
    'Checking',
    'Crypto',
    'Savings'
);
CREATE TYPE currency_type AS ENUM (
    'ARS', 'AUD', 'BRL', 'CAD', 'CHF', 'CNY', 'EUR', 'GBP', 'HKD', 'IDR',
    'INR', 'JPY', 'KRW', 'MXN', 'NZD', 'RUB', 'SAR', 'TRY', 'USD', 'ZAR'
);
CREATE TABLE accounts (
    account_id INTEGER PRIMARY KEY DEFAULT (floor(((random() * (((999999999 - 100000000) + 1))::DOUBLE PRECISION) + (100000000)::DOUBLE PRECISION)))::INTEGER,
    name CHARACTER VARYING(64),
    type account_type NOT NULL,
    balance NUMERIC(12, 2) DEFAULT '0.00'::NUMERIC NOT NULL,
    currency currency_type DEFAULT 'USD'::currency_type NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON accounts
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE TABLE account_users (
    account_id INTEGER REFERENCES accounts(account_id) ON UPDATE CASCADE ON DELETE CASCADE,
    user_id UUID,
    PRIMARY KEY (account_id, user_id)
);

CREATE SEQUENCE history_id_seq RESTART WITH 2000 INCREMENT BY 1;
CREATE TABLE history (
    history_id INTEGER PRIMARY KEY DEFAULT nextval('history_id_seq'::regclass),
    account_id INTEGER REFERENCES accounts(account_id) ON UPDATE CASCADE ON DELETE CASCADE,
    description CHARACTER VARYING(256) NOT NULL,
    begin_balance NUMERIC(12, 2) NOT NULL,
    end_balance NUMERIC(12, 2) NOT NULL,
    date TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON history
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();


\c crypto

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_total()
RETURNS TRIGGER AS $$
BEGIN
    NEW.cost_basis = NEW.quantity * NEW.price;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE wallet_id_seq RESTART WITH 2000 INCREMENT BY 1;
CREATE TABLE wallets (
    account_id INTEGER PRIMARY KEY,
    wallet_id INTEGER UNIQUE DEFAULT nextval('wallet_id_seq'::regclass) NOT NULL,
    name CHARACTER VARYING(64),
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON wallets
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE SEQUENCE crypto_id_seq RESTART WITH 2000 INCREMENT BY 1;
CREATE TABLE crypto (
    crypto_id INTEGER PRIMARY KEY DEFAULT nextval('crypto_id_seq'::regclass),
    wallet_id INTEGER REFERENCES wallets(wallet_id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    name CHARACTER VARYING(64) NOT NULL,
    symbol CHARACTER VARYING(7) NOT NULL,
    quantity NUMERIC(14, 4) NOT NULL,
    price NUMERIC(12, 2) NOT NULL,
    cost_basis NUMERIC(12, 2) NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON crypto
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();
CREATE TRIGGER update_total
BEFORE INSERT OR UPDATE ON crypto
FOR EACH ROW
EXECUTE PROCEDURE update_total();


\c historical_prices

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = TG_TABLE_NAME
        AND column_name = 'updated'
    ) THEN
        NEW.updated = now();
    ELSE
        NEW.date = now();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TYPE type AS ENUM (
    'Bond',
    'Crypto',
    'ETF',
    'Mutual Fund',
    'Stock'
);
CREATE SEQUENCE security_id_seq RESTART WITH 1 INCREMENT BY 1;
CREATE TABLE securities (
    security_id INTEGER PRIMARY KEY DEFAULT nextval('security_id_seq'::regclass),
    type type NOT NULL,
    symbol CHARACTER VARYING(7) NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON securities
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE TABLE prices (
    security_id INTEGER REFERENCES securities(security_id) ON UPDATE CASCADE ON DELETE CASCADE,
    date TIMESTAMP WITHOUT TIME ZONE,
    price NUMERIC(12, 2) NOT NULL,
    ask NUMERIC(12, 2) NOT NULL,
    bid NUMERIC(12, 2) NOT NULL,
    volume NUMERIC(15, 8) NOT NULL,
    size NUMERIC(9, 8),
    PRIMARY KEY (security_id, date)
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON prices
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();


\c investments

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_total()
RETURNS TRIGGER AS $$
BEGIN
    NEW.cost_basis = NEW.quantity * NEW.price;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE portfolio_id_seq RESTART WITH 2000 INCREMENT BY 1;
CREATE TABLE portfolios (
    account_id INTEGER PRIMARY KEY,
    portfolio_id INTEGER UNIQUE DEFAULT nextval('portfolio_id_seq'::regclass) NOT NULL,
    name CHARACTER VARYING(64),
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON portfolios
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE SEQUENCE asset_id_seq RESTART WITH 2000 INCREMENT BY 1;
CREATE TYPE asset_type AS ENUM (
    'Bond',
    'ETF',
    'Mutual Fund',
    'Stock'
);
CREATE TABLE assets (
    asset_id INTEGER PRIMARY KEY DEFAULT nextval('asset_id_seq'::regclass),
    portfolio_id INTEGER REFERENCES portfolios(portfolio_id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    type asset_type NOT NULL,
    name CHARACTER VARYING(64) NOT NULL,
    symbol CHARACTER VARYING(4),
    cusip CHARACTER VARYING(9),
    quantity NUMERIC(12, 2) NOT NULL,
    price NUMERIC(12, 2) NOT NULL,
    cost_basis NUMERIC(12, 2) NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    CONSTRAINT cusip_not_null CHECK (type != 'Bond' OR cusip IS NOT NULL),
    CONSTRAINT symbol_not_null CHECK (type = 'Bond' OR symbol IS NOT NULL)
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON assets
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();
CREATE TRIGGER update_total
BEFORE INSERT OR UPDATE ON assets
FOR EACH ROW
EXECUTE PROCEDURE update_total();


\c trades

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = TG_TABLE_NAME
        AND column_name = 'updated'
    ) THEN
        NEW.updated = now();
    ELSE
        NEW.date = now();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_total()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT type FROM trades WHERE trade_id = NEW.trade_id) = 'Buy' THEN
        NEW.total = 0 - (NEW.quantity * NEW.price);
    ELSE
        NEW.total = NEW.quantity * NEW.price;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE trade_id_seq RESTART WITH 2000 INCREMENT BY 1;
CREATE TYPE trade_type AS ENUM (
    'Buy',
    'Sell'
);
CREATE TABLE trades (
    trade_id INTEGER PRIMARY KEY DEFAULT nextval('trade_id_seq'::regclass),
    account_id INTEGER NOT NULL,
    type trade_type NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON trades
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE SEQUENCE asset_id_seq RESTART WITH 2000 INCREMENT BY 1;
CREATE TYPE asset_type AS ENUM (
    'Bond',
    'Crypto',
    'ETF',
    'Mutual Fund',
    'Stock'
);
CREATE TABLE assets (
    asset_id INTEGER PRIMARY KEY DEFAULT nextval('asset_id_seq'::regclass),
    type asset_type NOT NULL,
    name CHARACTER VARYING(128) NOT NULL,
    symbol CHARACTER VARYING(7),
    cusip CHARACTER VARYING(9),
    CONSTRAINT cusip_not_null CHECK (type != 'Bond' OR cusip IS NOT NULL),
    CONSTRAINT symbol_not_null CHECK (type = 'Bond' OR symbol IS NOT NULL) 
);

CREATE TABLE attributes (
    trade_id INTEGER PRIMARY KEY REFERENCES trades(trade_id) ON UPDATE CASCADE ON DELETE CASCADE,
    asset_id INTEGER UNIQUE REFERENCES assets(asset_id) ON UPDATE CASCADE ON DELETE CASCADE,
    description CHARACTER VARYING(256),
    quantity NUMERIC(12, 2) NOT NULL,
    price NUMERIC(12, 2) NOT NULL,
    total NUMERIC(12, 2) NOT NULL,
    date TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON attributes
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();
CREATE TRIGGER update_total
BEFORE INSERT OR UPDATE ON attributes
FOR EACH ROW
EXECUTE PROCEDURE update_total();


\c transactions

CREATE OR REPLACE FUNCTION check_constraints()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT type FROM transactions WHERE transaction_id = NEW.transaction_id) = 'Deposit' AND NEW.deposit_type IS NULL THEN
        RAISE EXCEPTION 'deposit_type is null';
    ELSEIF (SELECT type FROM transactions WHERE transaction_id = NEW.transaction_id) != 'Deposit' AND NEW.destination IS NULL THEN
        RAISE EXCEPTION 'destination is null';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_balance()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT type FROM transactions WHERE transaction_id = NEW.transaction_id) = 'Deposit' THEN
        NEW.end_balance = NEW.begin_balance + NEW.total;
    ELSE
        NEW.end_balance = NEW.begin_balance - NEW.total;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = TG_TABLE_NAME
        AND column_name = 'updated'
    ) THEN
        NEW.updated = now();
    ELSE
        NEW.date = now();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE transaction_id_seq RESTART WITH 2000 INCREMENT BY 1;
CREATE TYPE transaction_type AS ENUM (
    'Deposit',
    'Payment',
    'Transfer',
    'Withdrawl'
);
CREATE TABLE transactions (
    transaction_id INTEGER PRIMARY KEY DEFAULT nextval('transaction_id_seq'::regclass),
    account_id INTEGER NOT NULL,
    type transaction_type NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON transactions
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE TYPE deposit_type AS ENUM (
    'ACH',
    'Cash',
    'Cashiers Check',
    'Check',
    'Money Order',
    'Payment',
    'Transfer',
    'Wire Transfer'
);
CREATE TABLE attributes (
    transaction_id INTEGER PRIMARY KEY REFERENCES transactions(transaction_id) ON UPDATE CASCADE ON DELETE CASCADE,
    deposit_type deposit_type,
    description CHARACTER VARYING(256) NOT NULL,
    destination CHARACTER VARYING(128),
    total NUMERIC(12, 2) NOT NULL,
    begin_balance NUMERIC(12, 2) NOT NULL,
    end_balance NUMERIC(12, 2) NOT NULL,
    date TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE TRIGGER check_constraints
BEFORE INSERT OR UPDATE ON attributes
FOR EACH ROW
EXECUTE PROCEDURE check_constraints();
CREATE TRIGGER update_balance
BEFORE INSERT OR UPDATE ON attributes
FOR EACH ROW
EXECUTE PROCEDURE update_balance();
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON attributes
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();


\c users

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE users (
    user_id UUID PRIMARY KEY,
    username CHARACTER VARYING(32) NOT NULL,
    national_id CHARACTER VARYING(32),
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE SEQUENCE profile_id_seq RESTART WITH 2000 INCREMENT BY 1;
CREATE TABLE profiles (
    user_id UUID PRIMARY KEY REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
    profile_id INTEGER UNIQUE DEFAULT nextval('profile_id_seq'::regclass) NOT NULL,
    first_name CHARACTER VARYING(64) NOT NULL,
    last_name CHARACTER VARYING(64) NOT NULL,
    nickname CHARACTER VARYING(64),
    birthday DATE,
    email CHARACTER VARYING(256) NOT NULL,
    avatar TEXT,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    CHECK (((email)::text ~~ '%@%'::CHARACTER VARYING))
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON profiles
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE SEQUENCE address_id_seq RESTART WITH 2000 INCREMENT BY 1;
CREATE TYPE address_type AS ENUM (
    'APO/FPO/DPO',
    'Business',
    'Other'
    'PO Box',
    'Residence'
);
CREATE TABLE addresses (
    address_id INTEGER PRIMARY KEY DEFAULT nextval('address_id_seq'::regclass),
    profile_id INTEGER REFERENCES profiles(profile_id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    type address_type DEFAULT 'Residence'::address_type NOT NULL,
    address_1 CHARACTER VARYING(64) NOT NULL,
    address_2 CHARACTER VARYING(64),
    city CHARACTER VARYING(64) NOT NULL,
    state CHARACTER VARYING(64),
    postal_code CHARACTER VARYING(16) NOT NULL,
    country CHARACTER VARYING(64) DEFAULT 'United States'::TEXT NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON addresses
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE SEQUENCE phone_id_seq RESTART WITH 2000 INCREMENT BY 1;
CREATE TYPE phone_type AS ENUM (
    'Business',
    'Fax',
    'Mobile',
    'Residence',
    'Other'
);
CREATE TABLE phones (
    phone_id INTEGER PRIMARY KEY DEFAULT nextval('phone_id_seq'::regclass),
    profile_id INTEGER REFERENCES profiles(profile_id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    type phone_type DEFAULT 'Mobile'::phone_type NOT NULL,
    country_code SMALLINT DEFAULT 1 NOT NULL,
    phone_number BIGINT NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    CHECK (((country_code > 0) AND (country_code < 999))),
    CHECK (((char_length((phone_number)::text) > 3) AND (char_length((phone_number)::text) < 16)))
);
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON phones
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();


-- User Activity --

\c users

INSERT INTO users (user_id, username, national_id, created, updated) VALUES
  ('<tommy.callahan>', 'tommy.callahan', '453-98-7261', '2023-01-02 10:05:0.128', '2023-01-02 10:05:0.128'),
  ('<richard.hayden>', 'richard.hayden', '862-23-0179', '2023-01-02 10:12:0.256', '2023-01-02 10:12:0.256');

INSERT INTO profiles (user_id, profile_id, first_name, last_name, email, created, updated) VALUES
  ('<tommy.callahan>', '1000', 'Tommy', 'Callahan', 'tommy@callahanautoparts.com', '2023-01-02 10:05:0.128', '2023-01-02 10:05:0.128'),
  ('<richard.hayden>', '1001', 'Richard', 'Hayden', 'richard@callahanautoparts.com', '2023-01-02 10:12:0.256', '2023-01-02 10:12:0.256');

INSERT INTO addresses (address_id, profile_id, type, address_1, city, state, postal_code, country, created, updated) VALUES
  ('1000', '1000', 'Business', '145 Provence Boulevard', 'Sandusky', 'OH', '44870', 'United States', '2023-01-02 10:05:0.128', '2023-01-02 10:05:0.128'),
  ('1001', '1001', 'Business', '145 Provence Boulevard', 'Sandusky', 'OH', '44870', 'United States', '2023-01-02 10:12:0.256', '2023-01-02 10:12:0.256');

INSERT INTO phones (phone_id, profile_id, type, country_code, phone_number, created, updated) VALUES
  ('1000', '1000', 'Business', '1', '5551234560', '2023-01-02 10:05:0.128', '2023-01-02 10:05:0.128'),
  ('1001', '1001', 'Business', '1', '5551234561', '2023-01-02 10:12:0.256', '2023-01-02 10:12:0.256');

\c accounts

INSERT INTO accounts (account_id, name, type, balance, currency, created, updated) VALUES
  ('732959224', 'Checking Account', 'Checking', '50000.00', 'USD', '2023-01-02 10:06:0.032', '2023-01-05 14:17:0.056'),
  ('362929485', 'Savings Account', 'Savings', '250000.00', 'USD', '2023-01-02 10:06:0.064', '2023-01-02 10:08:0.128'),
  ('993804711', 'Investment Account', 'Brokerage', '337.00', 'USD', '2023-01-02 10:06:0.096', '2023-03-10 14:01:0.016'),
  ('693787850', 'Crypto Account', 'Crypto', '0.00', 'USD', '2023-01-02 10:06:0.128', '2023-01-02 10:06:0.128'),
  ('762551510', 'Checking Account', 'Checking', '10000.00', 'USD', '2023-01-02 10:13:0.032', '2023-01-18 11:23:0.244'),
  ('145302955', 'Savings Account', 'Savings', '40000.00', 'USD', '2023-01-02 10:13:0.064', '2023-01-02 10:15:0.128'),
  ('126941757', 'Investment Account', 'Brokerage', '11.05', 'USD', '2023-01-02 10:13:0.096', '2023-03-17 11:42:0.250'),
  ('554436372', 'Crypto Account', 'Crypto', '0.00', 'USD', '2023-01-02 10:13:0.128', '2023-01-02 10:13:0.128');

INSERT INTO account_users (account_id, user_id) VALUES
  ('732959224', '<tommy.callahan>'),
  ('362929485', '<tommy.callahan>'),
  ('993804711', '<tommy.callahan>'),
  ('693787850', '<tommy.callahan>'),
  ('762551510', '<richard.hayden>'),
  ('145302955', '<richard.hayden>'),
  ('126941757', '<richard.hayden>'),
  ('554436372', '<richard.hayden>');

INSERT INTO history (history_id, account_id, description, begin_balance, end_balance, date) VALUES
  ('1000', '732959224', 'New Account', '0.00', '0.00', '2023-01-02 10:06:0.032'),
  ('1001', '362929485', 'New Account', '0.00', '0.00', '2023-01-02 10:06:0.064'),
  ('1002', '993804711', 'New Account', '0.00', '0.00', '2023-01-02 10:06:0.096'),
  ('1003', '693787850', 'New Account', '0.00', '0.00', '2023-01-02 10:06:0.128'),
  ('1004', '732959224', 'Initial Deposit', '0.00', '100000.00', '2023-01-02 10:08:0.064'),
  ('1005', '362929485', 'Initial Deposit', '0.00', '250000.00', '2023-01-02 10:08:0.128'),
  ('1006', '762551510', 'New Account', '0.00', '0.00', '2023-01-02 10:13:0.032'),
  ('1007', '145302955', 'New Account', '0.00', '0.00', '2023-01-02 10:13:0.064'),
  ('1008', '126941757', 'New Account', '0.00', '0.00', '2023-01-02 10:13:0.096'),
  ('1009', '554436372', 'New Account', '0.00', '0.00', '2023-01-02 10:13:0.128'),
  ('1010', '762551510', 'Initial Deposit', '0.00', '25000.00', '2023-01-02 10:15:0.064'),
  ('1011', '145302955', 'Initial Deposit', '0.00', '40000.00', '2023-01-02 10:15:0.128'),
  ('1012', '732959224', 'Transfer to Brokerage', '100000.00', '50000.00', '2023-01-05 14:17:0.056'),
  ('1013', '993804711', 'Transfer from Checking', '0.00', '50000.00', '2023-01-05 14:17:0.056'),
  ('1014', '993804711', 'Stock Purchase', '50000.00', '31247.00', '2023-01-05 14:32:0.064'),
  ('1015', '993804711', 'Stock Purchase', '31247.00', '7324.00', '2023-01-13 11:17:0.096'),
  ('1016', '762551510', 'Transfer to Brokerage', '25000.00', '10000.00', '2023-01-18 11:23:0.244'),
  ('1017', '126941757', 'Transfer from Checking', '0.00', '15000.00', '2023-01-18 11:23:0.244'),
  ('1018', '126941757', 'Stock Purchase', '15000.00', '12009.50', '2023-01-18 11:49:0.512'),
  ('1019', '126941757', 'Stock Purchase', '12009.50', '3909.50', '2023-01-30 15:23:0.208'),
  ('1020', '126941757', 'Stock Sale', '3909.50', '8048.00', '2023-02-02 09:19:0.412'),
  ('1021', '993804711', 'Stock Purchase', '7324.00', '171.40', '2023-02-06 09:36:0.384'),
  ('1022', '126941757', 'Stock Purchase', '8048.00', '510.25', '2023-02-09 10:02:0.224'),
  ('1023', '993804711', 'Stock Sale', '171.40', '7595.40', '2023-02-21 13:21:0.768'),
  ('1024', '993804711', 'Stock Purchase', '7595.40', '337.00', '2023-03-10 14:01:0.016'),
  ('1025', '126941757', 'Stock Purchase', '510.25', '11.05', '2023-03-17 11:42:0.250');

\c crypto

INSERT INTO wallets (account_id, wallet_id, name, created, updated) VALUES
  ('693787850', '1000', 'Tommy''s Crypto Wallet', '2023-01-02 10:06:0.128', '2023-01-02 10:06:0.128'),
  ('554436372', '1001', 'Richard''s Crypto Wallet', '2023-01-02 10:13:0.128', '2023-01-02 10:13:0.128');

\c investments

INSERT INTO portfolios (account_id, portfolio_id, name, created, updated) VALUES
  ('993804711', '1000', 'Tommy''s Investments', '2023-01-02 10:06:0.096', '2023-01-02 10:06:0.096'),
  ('126941757', '1001', 'Richard''s Investments', '2023-01-02 10:13:0.096', '2023-01-02 10:13:0.096');

\c transactions

INSERT INTO transactions (transaction_id, account_id, type, created, updated) VALUES
  ('1000', '732959224', 'Deposit', '2023-01-02 10:08:0.064', '2023-01-02 10:08:0.064'),
  ('1001', '362929485', 'Deposit', '2023-01-02 10:08:0.128', '2023-01-02 10:08:0.128'),
  ('1002', '762551510', 'Deposit', '2023-01-02 10:15:0.064', '2023-01-02 10:15:0.064'),
  ('1003', '145302955', 'Deposit', '2023-01-02 10:15:0.128', '2023-01-02 10:15:0.128'),
  ('1004', '732959224', 'Transfer', '2023-01-05 14:17:0.056', '2023-01-05 14:17:0.056'),
  ('1005', '993804711', 'Deposit', '2023-01-05 14:17:0.056', '2023-01-05 14:17:0.056'),
  ('1006', '993804711', 'Withdrawl', '2023-01-05 14:32:0.064', '2023-01-05 14:32:0.064'),
  ('1007', '993804711', 'Withdrawl', '2023-01-13 11:17:0.096', '2023-01-13 11:17:0.096'),
  ('1008', '762551510', 'Transfer', '2023-01-18 11:23:0.244', '2023-01-18 11:23:0.244'),
  ('1009', '126941757', 'Deposit', '2023-01-18 11:23:0.244', '2023-01-18 11:23:0.244'),
  ('1010', '126941757', 'Withdrawl', '2023-01-18 11:49:0.512', '2023-01-18 11:49:0.512'),
  ('1011', '126941757', 'Withdrawl', '2023-01-30 15:23:0.208', '2023-01-30 15:23:0.208'),
  ('1012', '126941757', 'Deposit', '2023-02-02 09:19:0.412', '2023-02-02 09:19:0.412'),
  ('1013', '993804711', 'Withdrawl', '2023-02-06 09:36:0.384', '2023-02-06 09:36:0.384'),
  ('1014', '126941757', 'Withdrawl', '2023-02-09 10:02:0.224', '2023-02-09 10:02:0.224'),
  ('1015', '993804711', 'Deposit', '2023-02-21 13:21:0.768', '2023-02-21 13:21:0.768'),
  ('1016', '993804711', 'Withdrawl', '2023-03-10 14:01:0.016', '2023-03-10 14:01:0.016'),
  ('1017', '126941757', 'Withdrawl', '2023-03-17 11:42:0.250', '2023-03-17 11:42:0.250');

INSERT INTO attributes (transaction_id, deposit_type, description, destination, total, begin_balance, end_balance, date) VALUES
  ('1000', 'Wire Transfer', 'Wire Transfer from Bank of Sandusky', NULL, '100000.00', '0.00', '100000.00', '2023-01-02 10:08:0.064'),
  ('1001', 'Wire Transfer', 'Wire Transfer from Bank of Sandusky', NULL, '250000.00', '0.00', '250000.00', '2023-01-02 10:08:0.128'),
  ('1002', 'Wire Transfer', 'Wire Transfer from Bank of Sandusky', NULL, '25000.00', '0.00', '25000.00', '2023-01-02 10:15:0.064'),
  ('1003', 'Wire Transfer', 'Wire Transfer from Bank of Sandusky', NULL, '40000.00', '0.00', '40000.00', '2023-01-02 10:15:0.128'),
  ('1004', NULL, 'Transfer to Brokerage', 'Investment Account', '50000.00', '100000.00', '50000.00', '2023-01-05 14:17:0.056'),
  ('1005', 'Transfer', 'Transfer from Checking', NULL, '50000.00', '0.00', '50000.00', '2023-01-05 14:17:0.056'),
  ('1006', NULL, 'Purchase 150 Shares of AAPL', 'Tommy''s Investments', '18753.00', '50000.00', '31247.00', '2023-01-05 14:32:0.064'),
  ('1007', NULL, 'Purchase 100 Shares of MSFT', 'Tommy''s Investments', '23923.00', '31247.00', '7324.00', '2023-01-13 11:17:0.096'),
  ('1008', NULL, 'Transfer to Brokerage', 'Investment Account', '15000.00', '25000.00', '10000.00', '2023-01-18 11:23:0.244'),
  ('1009', 'Transfer', 'Transfer from Checking', NULL, '15000.00', '0.00', '15000.00', '2023-01-18 11:23:0.244'),
  ('1010', NULL, 'Purchase 50 Shares of KO', 'Richard''s Investments', '2990.50', '15000.00', '12009.50', '2023-01-18 11:49:0.512'),
  ('1011', NULL, 'Purchase 50 Shares of JNJ', 'Richard''s Investments', '8100.00', '12009.50', '3909.50', '2023-01-30 15:23:0.208'),
  ('1012', 'Transfer', 'Sell 25 Shares of JNJ', 'Investment Account', '4138.50', '3909.50', '8048.00', '2023-02-02 09:19:0.412'),
  ('1013', NULL, 'Purchase 70 Shares of AMZN', 'Tommy''s Investments', '7152.60', '7324.00', '171.40', '2023-02-06 09:36:0.384'),
  ('1014', NULL, 'Purchase 55 Shares of PG', 'Richard''s Investments', '7537.75', '8048.00', '510.25', '2023-02-09 10:02:0.224'),
  ('1015', 'Transfer', 'Sell 50 Shares of AAPL', 'Investment Account', '7424.00', '171.40', '7595.40', '2023-02-21 13:21:0.768'),
  ('1016', NULL, 'Purchase 80 Shares of AMZN', 'Tommy''s Investments', '7258.40', '7595.40', '337.00', '2023-03-10 14:01:0.016'),
  ('1017', NULL, 'Purchase 5 Shares of XOM', 'Richard''s Investments', '499.20', '510.25', '11.05', '2023-03-17 11:42:0.250');

\c trades

INSERT INTO trades (trade_id, account_id, type, created, updated) VALUES
  ('1000', '993804711', 'Buy', '2023-01-05 14:32:0.064', '2023-01-05 14:32:0.064'),
  ('1001', '993804711', 'Buy', '2023-01-13 11:17:0.096', '2023-01-13 11:17:0.096'),
  ('1002', '126941757', 'Buy', '2023-01-18 11:49:0.512', '2023-01-18 11:49:0.512'),
  ('1003', '126941757', 'Buy', '2023-01-30 15:23:0.208', '2023-01-30 15:23:0.208'),
  ('1004', '126941757', 'Sell', '2023-02-02 09:19:0.412', '2023-02-02 09:19:0.412'),
  ('1005', '993804711', 'Buy', '2023-02-06 09:36:0.384', '2023-02-06 09:36:0.384'),
  ('1006', '126941757', 'Buy', '2023-02-09 10:02:0.224', '2023-02-09 10:02:0.224'),
  ('1007', '993804711', 'Sell', '2023-02-21 13:21:0.768', '2023-02-21 13:21:0.768'),
  ('1008', '993804711', 'Buy', '2023-03-10 14:01:0.016', '2023-03-10 14:01:0.016'),
  ('1009', '126941757', 'Buy', '2023-03-17 11:42:0.250', '2023-03-17 11:42:0.250');

INSERT INTO assets (asset_id, type, name, symbol) VALUES
  ('1000', 'Stock', 'Apple, Inc.', 'AAPL'),
  ('1001', 'Stock', 'Microsoft Corp.', 'MSFT'),
  ('1002', 'Stock', 'Coca-Cola, Co.', 'KO'),
  ('1003', 'Stock', 'Johnson & Johnson', 'JNJ'),
  ('1004', 'Stock', 'Johnson & Johnson', 'JNJ'),
  ('1005', 'Stock', 'Amazon.com, Inc.', 'AMZN'),
  ('1006', 'Stock', 'Procter & Gamble, Co.', 'PG'),
  ('1007', 'Stock', 'Apple, Inc.', 'AAPL'),
  ('1008', 'Stock', 'Amazon.com, Inc.', 'AMZN'),
  ('1009', 'Stock', 'Exxon Mobil Corp.', 'XOM');

INSERT INTO attributes (trade_id, asset_id, description, quantity, price, date) VALUES
  ('1000', '1000', 'Buy 150 shares of AAPL at $125.02', '150', '125.02', '2023-01-05 14:32:0.064'),
  ('1001', '1001', 'Buy 100 shares of MSFT at $239.23', '100', '239.23', '2023-01-13 11:17:0.096'),
  ('1002', '1002', 'Buy 50 shares of KO at $59.81', '50', '59.81', '2023-01-18 11:49:0.512'),
  ('1003', '1003', 'Buy 50 shares of JNJ at $162.00', '50', '162.00', '2023-01-30 15:23:0.208'),
  ('1004', '1004', 'Sell 25 shares of JNJ at $165.54', '25', '165.54', '2023-02-02 09:19:0.412'),
  ('1005', '1005', 'Buy 70 shares of AMZN at $102.18', '70', '102.18', '2023-02-06 09:36:0.384'),
  ('1006', '1006', 'Buy 55 shares of PG at $137.05', '25', '137.05', '2023-02-09 10:02:0.224'),
  ('1007', '1007', 'Sell 50 shares of AAPL at $148.48', '50', '148.48', '2023-02-21 13:21:0.768'),
  ('1008', '1008', 'Buy 80 shares of AMZN at $90.73', '80', '90.73', '2023-03-10 14:01:0.016'),
  ('1009', '1009', 'Buy 5 shares of XOM at $99.84', '5', '99.84', '2023-03-17 11:42:0.250');

\c investments

INSERT INTO assets (asset_id, portfolio_id, type, name, symbol, quantity, price, cost_basis, created, updated) VALUES
  ('1000', '1000', 'Stock', 'Apple, Inc', 'AAPL', '100', '125.02', '12502.00', '2023-01-05 14:32:0.064', '2023-02-21 13:21:0.768'), -- sale
  ('1001', '1000', 'Stock', 'Microsoft, Corp.', 'MSFT', '100', '239.23', '23923.00', '2023-01-13 11:17:0.096', '2023-01-13 11:17:0.096'),
  ('1002', '1001', 'Stock', 'Coca-Cola, Co.', 'KO', '50', '59.81', '2990.50', '2023-01-18 11:49:0.512', '2023-01-18 11:49:0.512'),
  ('1003', '1001', 'Stock', 'Johnson & Johnson', 'JNJ', '25', '165.54', '4138.50', '2023-01-30 15:23:0.208', '2023-02-02 09:19:0.412'), -- sale
  ('1004', '1000', 'Stock', 'Amazon.com, Inc.', 'AMZN', '70', '102.18', '7152.60', '2023-02-06 09:36:0.384', '2023-02-06 09:36:0.384'),
  ('1005', '1001', 'Stock', 'Procter & Gamble, Co.', 'PG', '55', '137.05', '3426.25', '2023-02-09 10:02:0.224', '2023-02-09 10:02:0.224'),
  ('1006', '1000', 'Stock', 'Amazon.com, Inc.', 'AMZN', '80', '90.73', '7258.40', '2023-03-10 14:01:0.016', '2023-03-10 14:01:0.016'),
  ('1007', '1001', 'Stock', 'Exxon Mobil Corp.', 'XOM', '5', '99.84', '499.20', '2023-03-17 11:42:0.250', '2023-03-17 11:42:0.250');