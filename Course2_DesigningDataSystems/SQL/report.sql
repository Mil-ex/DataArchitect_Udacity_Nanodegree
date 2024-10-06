SELECT
    b.name,
    w.min,
    w.max,
    w.precipitation,
    r.stars
FROM
    business AS b
    JOIN review AS r ON b.business_id = r.business_id
    JOIN weather AS w ON r.date = w.date;