-- Count of Customer Service Requests with Missing Order IDs
SELECT COUNT(*) AS missing_orderid_count
FROM cs.CustomerServiceRequests
WHERE orderid IS NULL;


-- Count of Credit Cards with Incorrect Format
SELECT COUNT(*) AS invalid_creditcard_format_count
FROM usr.creditcards
WHERE CreditCardNumber NOT SIMILAR TO '[0-9]{16}';


-- Count of Listings with Missing Shoe Type
SELECT COUNT(*) AS missing_shoetype_count
FROM li.listings
WHERE ShoeType IS NULL;


-- Count of Expired Credit Cards
SELECT COUNT(*) AS expired_creditcards_count
FROM usr.creditcards
WHERE CreditCardExpirationDate < CURRENT_DATE;


-- Count of valid orderid in CustomerServiceRequests
SELECT COUNT(*) FROM cs.CustomerServiceRequests
WHERE OrderID IS NOT NULL;


-- Count of valid credit card numbers
SELECT COUNT(*) FROM usr.CreditCards
WHERE CreditCardNumber ~ '^\d{16}$';


-- Count of valid shoetype in Listings
SELECT COUNT(*) FROM li.Listings
WHERE ShoeType IS NOT NULL;


-- Count of valid credit card expiration dates
SELECT COUNT(*) FROM usr.CreditCards
WHERE CreditCardExpirationDate >= CURRENT_DATE;
