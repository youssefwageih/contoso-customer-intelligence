-- Drop existing tables with cascade to avoid dependency errors
DROP TABLE IF EXISTS public.sales CASCADE;
DROP TABLE IF EXISTS public.customer CASCADE;
DROP TABLE IF EXISTS public.product CASCADE;
DROP TABLE IF EXISTS public.store CASCADE;
DROP TABLE IF EXISTS public.date CASCADE;
DROP TABLE IF EXISTS public.currencyexchange CASCADE;

-- Dimension: Currency Exchange
CREATE TABLE public.currencyexchange (
    date            DATE NOT NULL,
    fromcurrency    VARCHAR(10) NOT NULL,
    tocurrency      VARCHAR(10) NOT NULL,
    exchange        DOUBLE PRECISION,
    CONSTRAINT pk_currencyexchange PRIMARY KEY (date, fromcurrency, tocurrency)
);

-- Dimension: Customer
CREATE TABLE public.customer (
    customerkey     INTEGER NOT NULL PRIMARY KEY,
    geoareakey      INTEGER,
    startdt         DATE,
    enddt           DATE,
    continent       VARCHAR(50),
    gender          VARCHAR(10),
    title           VARCHAR(20),
    givenname       VARCHAR(50),
    middleinitial   VARCHAR(5),
    surname         VARCHAR(50),
    streetaddress   VARCHAR(100),
    city            VARCHAR(50),
    state           VARCHAR(50),
    statefull       VARCHAR(100),
    zipcode         VARCHAR(20),
    country         VARCHAR(50),
    countryfull     VARCHAR(100),
    birthday        DATE,
    age             INTEGER,
    occupation      VARCHAR(100),
    company         VARCHAR(100),
    vehicle         VARCHAR(100),
    latitude        DOUBLE PRECISION,
    longitude       DOUBLE PRECISION
);

-- Dimension: Date
CREATE TABLE public.date (
    date                DATE NOT NULL PRIMARY KEY,
    datekey             INTEGER,
    year                INTEGER,
    yearquarter         VARCHAR(20),
    yearquarternumber   INTEGER,
    quarter             VARCHAR(10),
    yearmonth           VARCHAR(20),
    yearmonthshort      VARCHAR(20),
    yearmonthnumber     INTEGER,
    month               VARCHAR(20),
    monthshort          VARCHAR(10),
    monthnumber         INTEGER,
    dayofweek           VARCHAR(20),
    dayofweekshort      VARCHAR(10),
    dayofweeknumber     INTEGER,
    workingday          INTEGER,
    workingdaynumber    INTEGER
);

-- Dimension: Product
CREATE TABLE public.product (
    productkey          INTEGER NOT NULL PRIMARY KEY,
    productcode         INTEGER,
    productname         VARCHAR(100),
    manufacturer        VARCHAR(100),
    brand               VARCHAR(50),
    color               VARCHAR(30),
    weightunit          VARCHAR(10),
    weight              DOUBLE PRECISION,
    cost                DOUBLE PRECISION,
    price               DOUBLE PRECISION,
    categorykey         INTEGER,
    categoryname        VARCHAR(50),
    subcategorykey      INTEGER,
    subcategoryname     VARCHAR(50)
);

-- Dimension: Store
CREATE TABLE public.store (
    storekey        INTEGER NOT NULL PRIMARY KEY,
    storecode       INTEGER,
    geoareakey      INTEGER,
    countrycode     VARCHAR(10),
    countryname     VARCHAR(50),
    state           VARCHAR(50),
    opendate        DATE,
    closedate       DATE,
    description     VARCHAR(100),
    squaremeters    DOUBLE PRECISION,
    status          VARCHAR(20)
);

-- Fact: Sales
CREATE TABLE public.sales (
    orderkey        INTEGER NOT NULL,
    linenumber      INTEGER NOT NULL,
    orderdate       DATE,
    deliverydate    DATE,
    customerkey     INTEGER REFERENCES public.customer(customerkey),
    storekey        INTEGER,
    productkey      INTEGER REFERENCES public.product(productkey),
    quantity        INTEGER,
    unitprice       DOUBLE PRECISION,
    netprice        DOUBLE PRECISION,
    unitcost        DOUBLE PRECISION,
    currencycode    VARCHAR(10),
    exchangerate    DOUBLE PRECISION,
    CONSTRAINT pk_sales PRIMARY KEY (orderkey, linenumber)
);
