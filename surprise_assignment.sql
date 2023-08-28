DROP SCHEMA IF EXISTS report CASCADE;
CREATE SCHEMA report;

DROP TABLE IF EXISTS report.dim_customer;
CREATE TABLE report.dim_customer(

	customer_id integer,
	first_name text,
	last_name text

);


DROP INDEX IF EXISTS idx_dim_customer;
DROP TABLE IF EXISTS DIMENTION_CUSTOMER;
CREATE TEMP TABLE DIMENTION_CUSTOMER AS (
    SELECT 
		customer_id,
		first_name,
		last_name
    FROM public.customer
);
CREATE INDEX idx_dim_customer ON dimention_customer(customer_id);

INSERT INTO report.dim_customer
(
	SELECT 
		*
	FROM DIMENTION_CUSTOMER
)


DROP INDEX IF EXISTS idx_fact_rental_table;
DROP TABLE IF EXISTS TEMP_FACT_RENTAL;
CREATE TEMP TABLE TEMP_FACT_RENTAL AS (
    
	SELECT 
		se_rental.rental_id,
		se_rental.customer_id,
		se_rental.rental_date,
		se_rental.return_date,
		se_payment.amount
    FROM public.rental AS se_rental
	INNER JOIN public.payment AS se_payment
	ON se_rental.rental_id = se_payment.rental_id
	
		
);
CREATE INDEX idx_fact_rental_table ON temp_fact_rental(rental_id);

DROP TABLE IF EXISTS report.fact_rental;
CREATE TABLE report.fact_rental(

	rental_id integer,
	customer_id smallint,
	rental_date timestamp,
	return_date timestamp,
	amount numeric
);

INSERT INTO report.fact_rental
(
	SELECT 
		*
	FROM TEMP_FACT_RENTAL
)


DROP TABLE IF EXISTS report.agg_customer;
CREATE TABLE report.agg_customer(

	
	customer_id smallint,
	total_movies_rented integer,
	total_paid numeric,
	average_rental_duration numeric
);


INSERT INTO report.agg_customer
(

	SELECT 
		customer_dimension.customer_id,
		COUNT(rental_fact.rental_id),
		SUM(rental_fact.amount),
		ROUND(AVG ( EXTRACT(DAY FROM (rental_fact.return_date - rental_fact.rental_date))+ (EXTRACT(HOUR FROM (rental_fact.return_date - rental_fact.rental_date))/24)),2) AS duration_days
	FROM report.dim_customer AS customer_dimension 
	INNER JOIN report.fact_rental AS rental_fact
		ON customer_dimension.customer_id = rental_fact.customer_id
	GROUP BY customer_dimension.customer_id	
    
)

SELECT * FROM report.agg_customer
SELECT * FROM report.dim_customer
SELECT * FROM report.fact_rental










