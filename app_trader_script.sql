
SELECT *
FROM app_store_apps;


-- 7197 rows

-- app store and play store = true

-- 10840 rows

-- 18037 total rows

--Make CTE of both tables, then union them

(SELECT name, 'app' AS store, price::money::numeric, (price * 10000.00) AS purchase_price, review_count::integer, rating, content_rating, primary_genre
FROM app_store_apps)
UNION
(SELECT name, 'play' AS store, price::money::numeric, (price::money::numeric * 10000.00) AS purchase_price, review_count, rating, content_rating, genres
FROM play_store_apps);

-------------------------
-- 3a. Develop some general recommendations about the price range, genre, content rating, or any other app characteristics that the company 
-- should target.

WITH total_price AS (SELECT a.name as a_name, a.primary_genre AS a_genre, p.genres AS p_genre,a.rating AS a_rating, p.rating AS p_rating,
	   				ROUND(((a.rating + p.rating)/2),2) AS avg_rating,
					a.price AS a_price, p.price AS p_price, ROUND(((a.price + p.price::money::numeric)/2),2) AS avg_price,
	  				10000 AS avg_mth_gross, 1000 AS mth_marketing_cost,
					ROUND(CAST(ROUND(((a.rating + p.rating) / 2)/25, 2) * 25 as numeric(18,2)) / 0.25 * 6 + 12) AS app_lifespan_months,
						CASE WHEN p.price::money::numeric = 0 THEN 25000
	 						 WHEN p.price::money::numeric > 0 THEN ROUND((p.price::money::numeric * 10000.00),0) 
							 WHEN a.price = 0 THEN 25000
							 WHEN a.price > 0 THEN ROUND((a.price * 10000.00),0) END AS price_rights
					FROM app_store_apps AS a INNER JOIN play_store_apps AS p on a.name = p.name)

SELECT DISTINCT(a_name), a_rating, p_rating, avg_rating, avg_price, app_lifespan_months, (app_lifespan_months * avg_mth_gross)-(price_rights + (app_lifespan_months * mth_marketing_cost)) AS net_profit
FROM total_price
ORDER BY net_profit DESC NULLS LAST;
