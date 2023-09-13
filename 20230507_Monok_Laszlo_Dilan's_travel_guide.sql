-- Creating tables and loading data into SQL
--
CREATE TABLE readers 
(
  my_date      DATE,
  my_time      TIME,
  event_type   TEXT,
  country      TEXT,
  user_id      TEXT,
  source       TEXT,
  topic        TEXT
);
--
CREATE TABLE subscribers 
(
  my_date      DATE,
  my_time      TIME,
  event_type   TEXT,
  user_id      TEXT
);
--
CREATE TABLE purchases 
(
  my_date      DATE,
  my_time      TIME,
  event_type   TEXT,
  user_id      TEXT,
  price        INTEGER
);
--
CREATE TABLE new_readers 
(
  my_date      DATE,
  my_time      TIME,
  event_type   TEXT,
  country      TEXT,
  user_id      TEXT,
  source       TEXT,
  topic        TEXT
);
--
CREATE TABLE returning_readers 
(
  my_date      DATE,
  my_time      TIME,
  event_type   TEXT,
  country      TEXT,
  user_id      TEXT,
  topic        TEXT
);
--
COPY readers
FROM '/home/laca/dilan/readers.csv' DELIMITER ';';
--
COPY subscribers
FROM '/home/laca/dilan/subscribers.csv' DELIMITER ';';
--
COPY purchases
FROM '/home/laca/dilan/purchases.csv' DELIMITER ';';
--
COPY new_readers
FROM '/home/laca/dilan/new_readers.csv' DELIMITER ';';
--
COPY returning_readers
FROM '/home/laca/dilan/returning_readers.csv' DELIMITER ';';
--
SELECT * FROM readers LIMIT 1000;
SELECT COUNT(*) FROM readers;
SELECT * FROM subscribers LIMIT 100;
SELECT COUNT(*) FROM subscribers;
SELECT * FROM purchases LIMIT 100;
SELECT COUNT(*) FROM purchases;
--
SELECT * FROM new_readers LIMIT 100;
SELECT COUNT(*) FROM new_readers;
SELECT * FROM returning_readers LIMIT 100;
SELECT COUNT(*) FROM returning_readers;
SELECT COUNT(DISTINCT user_id) FROM returning_readers;
--
--
COMMIT;
--
--
-- Exploratory analysis
--
SELECT * FROM readers LIMIT 1000;
SELECT COUNT(*) FROM readers;
-- Readers from each country
SELECT country, COUNT(*) FROM readers GROUP BY country;
-- Readers of each topics
SELECT topic, COUNT(*) FROM readers GROUP BY topic;
-- Readers from each source
SELECT source, COUNT(*) FROM readers WHERE source != '' GROUP BY source;
--
-- Subscribers from each country
SELECT country, COUNT(DISTINCT subscribers.user_id) FROM readers JOIN subscribers ON readers.user_id = subscribers.user_id GROUP BY country;
-- Subscribers from each source
SELECT source, COUNT(*) FROM readers JOIN subscribers ON readers.user_id = subscribers.user_id WHERE source != '' GROUP BY source;
--
-- Number of paying users from each country
SELECT country, COUNT(DISTINCT purchases.user_id) FROM readers JOIN purchases ON readers.user_id = purchases.user_id GROUP BY country;
-- Number of purchases from each country
SELECT country, COUNT(*) FROM purchases JOIN (SELECT DISTINCT user_id, country FROM readers) AS readers ON readers.user_id = purchases.user_id GROUP BY country;
-- Revenue from each country
SELECT country, SUM(price) FROM purchases JOIN (SELECT DISTINCT user_id, country FROM readers) AS readers ON readers.user_id = purchases.user_id GROUP BY country;
SELECT SUM(sum) FROM (SELECT country, SUM(price) FROM purchases JOIN (SELECT DISTINCT user_id, country FROM readers) AS readers ON readers.user_id = purchases.user_id GROUP BY country) AS subq;
-- Number of purchases from each source
SELECT source, COUNT(*) FROM readers JOIN purchases ON readers.user_id = purchases.user_id WHERE source != '' GROUP BY source;
-- Number of paying users from each source
SELECT source, COUNT(DISTINCT purchases.user_id) FROM purchases JOIN (SELECT DISTINCT user_id, source FROM readers WHERE source != '') AS readers ON readers.user_id = purchases.user_id GROUP BY source;
-- Revenue from each source
SELECT source, SUM(price) FROM readers JOIN purchases ON readers.user_id = purchases.user_id WHERE source != '' GROUP BY source;
SELECT SUM(sum) FROM (SELECT source, SUM(price) FROM readers JOIN purchases ON readers.user_id = purchases.user_id WHERE source != '' GROUP BY source) AS subq;
-- Total revenue
SELECT SUM(price) FROM purchases;
--
-- Readers timeseries
SELECT my_date, country, source, topic, COUNT(*) FROM readers GROUP BY my_date, country, source, topic ORDER BY my_date;
--
-- At this point, I realized that the separation of the 'readers' table to 'new_readers' and 'returning_readers' would be beneficial. 
--
-- New readers of each topics
SELECT topic, COUNT(*) FROM new_readers GROUP BY topic;
--
-- 1. In which country should he prioritise his effort and why?
-- Number of article reads by country
SELECT country, COUNT(*) FROM readers GROUP BY country;
-- Number of new readers by country
SELECT country, COUNT(*) FROM new_readers GROUP BY country;
-- Number of returning readers by country
SELECT country, COUNT(DISTINCT user_id) FROM returning_readers GROUP BY country;
-- Articles read per returning user by country
SELECT country, AVG(subq.articles_read) AS avg_articles
FROM
  (SELECT user_id, country, COUNT(*)+1 AS articles_read FROM returning_readers GROUP BY user_id, country) AS subq
GROUP BY country
ORDER BY country;
-- Number of subscribers by country
SELECT country, COUNT(*)
FROM subscribers
JOIN new_readers
ON subscribers.user_id = new_readers.user_id
GROUP BY country;
-- Number of customers
SELECT country, COUNT(DISTINCT  subq.user_id) AS customers
FROM 
  (SELECT purchases.user_id, country, COUNT(*)
  FROM purchases
  JOIN new_readers
  ON purchases.user_id = new_readers.user_id
  GROUP BY purchases.user_id, country) AS subq
GROUP BY country;
-- Number of purchases by country
SELECT country, COUNT(*)
FROM purchases
JOIN new_readers
ON purchases.user_id = new_readers.user_id
GROUP BY country;
-- Revenue by country
SELECT country, SUM(price)
FROM purchases
JOIN new_readers
ON purchases.user_id = new_readers.user_id
GROUP BY country;
-- Average spent money per purchase by country
SELECT country, AVG(price)
FROM purchases
JOIN new_readers
ON purchases.user_id = new_readers.user_id
GROUP BY country;
-- E-books sold by country
SELECT country, price, COUNT(*)
FROM purchases
JOIN new_readers
ON purchases.user_id = new_readers.user_id
WHERE price = 8
GROUP BY country, price;
-- Video courses sold by country
SELECT country, price, COUNT(*)
FROM purchases
JOIN new_readers
ON purchases.user_id = new_readers.user_id
WHERE price = 80
GROUP BY country, price;
-- Money spent per customers
SELECT country, AVG(subq.spend)
FROM
  (SELECT purchases.user_id, country, SUM(price) AS spend
  FROM purchases
  JOIN new_readers
  ON purchases.user_id = new_readers.user_id
  GROUP BY purchases.user_id, country) AS subq
GROUP BY country
ORDER BY country;
--
--
-- 2. Any other advice to Dilan on how to be smart with his investments based on the data from the last 3 months?
-- Number of article reads by source
SELECT new_readers.source, COUNT(*) FROM readers FULL JOIN new_readers ON readers.user_id = new_readers.user_id GROUP BY new_readers.source;
-- Number of new readers by source
SELECT source, COUNT(*) FROM new_readers GROUP BY source;
-- Number of returning readers by source
SELECT source, COUNT(DISTINCT returning_readers.user_id) FROM returning_readers JOIN new_readers ON returning_readers.user_id = new_readers.user_id GROUP BY source;
-- Articles read per returning user by source
SELECT source, AVG(subq.articles_read) AS avg_articles
FROM
  (SELECT returning_readers.user_id, source, COUNT(*)+1 AS articles_read 
  FROM returning_readers 
  JOIN new_readers 
  ON returning_readers.user_id = new_readers.user_id 
  GROUP BY returning_readers.user_id, source) AS subq
GROUP BY source
ORDER BY source;
-- Number of subscribers by source
SELECT source, COUNT(*)
FROM subscribers
JOIN new_readers
ON subscribers.user_id = new_readers.user_id
GROUP BY source;
-- Number of customers
SELECT source, COUNT(DISTINCT  subq.user_id) AS customers
FROM 
  (SELECT purchases.user_id, source, COUNT(*)
  FROM purchases
  JOIN new_readers
  ON purchases.user_id = new_readers.user_id
  GROUP BY purchases.user_id, source) AS subq
GROUP BY source;
-- Number of purchases by source
SELECT source, COUNT(*)
FROM purchases
JOIN new_readers
ON purchases.user_id = new_readers.user_id
GROUP BY source;
-- Revenue by source
SELECT source, SUM(price)
FROM purchases
JOIN new_readers
ON purchases.user_id = new_readers.user_id
GROUP BY source;
-- Average spent money per purchase by source
SELECT source, AVG(price)
FROM purchases
JOIN new_readers
ON purchases.user_id = new_readers.user_id
GROUP BY source;
-- E-books sold by source
SELECT source, price, COUNT(*)
FROM purchases
JOIN new_readers
ON purchases.user_id = new_readers.user_id
WHERE price = 8
GROUP BY source, price;
-- Video courses sold by source
SELECT source, price, COUNT(*)
FROM purchases
JOIN new_readers
ON purchases.user_id = new_readers.user_id
WHERE price = 80
GROUP BY source, price;
-- Money spent per customers
SELECT source, AVG(subq.spend)
FROM
  (SELECT purchases.user_id, source, SUM(price) AS spend
  FROM purchases
  JOIN new_readers
  ON purchases.user_id = new_readers.user_id
  GROUP BY purchases.user_id, source) AS subq
GROUP BY source
ORDER BY source;
--
--
-- 3. Can you see any more interesting information (beyond the above 2 questions) in the data from which Dilan could profit?
--
-- Connection between returning readers and subscribers. Does anyone subscribe, but never return?
--
SELECT DISTINCT (subscribers.user_id) FROM subscribers JOIN new_readers ON subscribers.user_id = new_readers.user_id;
SELECT DISTINCT (subscribers.user_id) FROM subscribers JOIN returning_readers ON subscribers.user_id = returning_readers.user_id;
SELECT event_type, user_id FROM subscribers;
--
SELECT subscribers.user_id,
       subscribers.event_type,
       returning_subscribers.user_id,
       returning_subscribers.event_type
FROM 
  (SELECT event_type, user_id FROM subscribers) AS subscribers
FULL JOIN
  (SELECT DISTINCT (subscribers.user_id), returning_readers.event_type FROM subscribers JOIN returning_readers ON subscribers.user_id = returning_readers.user_id) AS returning_subscribers
ON subscribers.user_id = returning_subscribers.user_id
WHERE returning_subscribers.user_id IS NULL;
--
-- Connection between purchases and subscribers. Does anyone purchase, but doesn't subscribe?
--
SELECT DISTINCT (purchases.user_id) FROM purchases;-- JOIN subscribers ON purchases.user_id = subscribers.user_id;
SELECT DISTINCT (purchases.user_id) FROM purchases JOIN subscribers ON purchases.user_id = subscribers.user_id;
--
SELECT purchases.user_id, SUM(price) FROM purchases JOIN subscribers ON purchases.user_id = subscribers.user_id GROUP BY purchases.user_id;
-- Average money spent by subscribed customers
SELECT AVG(sum)
FROM
  (SELECT purchases.user_id, SUM(price) FROM purchases JOIN subscribers ON purchases.user_id = subscribers.user_id GROUP BY purchases.user_id) AS subq;
--
SELECT purchases.user_id, price FROM purchases LEFT JOIN subscribers ON purchases.user_id = subscribers.user_id WHERE subscribers.user_id IS NULL;
SELECT DISTINCT (purchases.user_id), SUM(price) FROM purchases LEFT JOIN subscribers ON purchases.user_id = subscribers.user_id WHERE subscribers.user_id IS NULL GROUP BY purchases.user_id;
--
-- Average money spent by customers without subscription
SELECT AVG(sum)
FROM
  (SELECT DISTINCT (purchases.user_id), SUM(price) 
  FROM purchases 
  LEFT JOIN subscribers 
  ON purchases.user_id = subscribers.user_id 
  WHERE subscribers.user_id IS NULL 
  GROUP BY purchases.user_id) AS subq;
