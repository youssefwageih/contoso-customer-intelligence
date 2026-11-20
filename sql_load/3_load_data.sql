-- 3. Load Seed Data

copy public.currencyexchange FROM 'csv_files/currencyexchange.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
copy public.customer FROM 'csv_files/customer.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
copy public.date FROM 'csv_files/date.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
copy public.product FROM 'csv_files/product.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
copy public.store FROM 'csv_files/store.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
copy public.sales FROM 'csv_files/sales.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Quick validation query to ensure records loaded correctly
SELECT 'sales' AS table_name, COUNT(*) AS row_count FROM public.sales
UNION ALL
SELECT 'customer', COUNT(*) FROM public.customer
UNION ALL
SELECT 'product', COUNT(*) FROM public.product
UNION ALL
SELECT 'store', COUNT(*) FROM public.store
UNION ALL
SELECT 'date', COUNT(*) FROM public.date
UNION ALL
SELECT 'currencyexchange', COUNT(*) FROM public.currencyexchange;
