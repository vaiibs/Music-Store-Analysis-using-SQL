--1. Who is the senior most employee based on job title?

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1



--2. Which countries have the most Invoices? 

SELECT billing_country , COUNT(*) AS c
FROM invoice
GROUP BY billing_country
ORDER BY c DESC



--3. What are top 3 values of total invoice? 

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3



--4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns
     one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals 

SELECT billing_city, SUM(total) AS invoice_total 
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC



--5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has
     spent the most money 

SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) AS total
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1



--6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting
     with A 

SELECT email, first_name, last_name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON genre.genre_id = track.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY customer.email


--7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the
     top 10 rock bands 

SELECT artist.name, COUNT(artist.artist_id) AS no_of_songs 
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.name
ORDER BY no_of_songs DESC
LIMIT 10


--8. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the
     song length with the longest songs listed first 

SELECT name,milliseconds 
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track)
ORDER BY milliseconds DESC




--9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

SELECT 
    c.first_name, 
    c.last_name, 
    a.name AS artist_name, 
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM 
    customer c
JOIN 
    invoice i ON c.customer_id = i.customer_id
JOIN 
    invoice_line il ON i.invoice_id = il.invoice_id
JOIN 
    track t ON t.track_id = il.track_id
JOIN 
    album al ON al.album_id = t.album_id
JOIN 
    artist a ON a.artist_id = al.artist_id
GROUP BY 
    c.first_name, 
    c.last_name, 
    a.name
ORDER BY 
    amount_spent DESC;




--10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
      with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
      the maximum number of purchases is shared return all Genres. */

WITH 
genre_purchases AS
(
	SELECT 
		c.country,
		g.name as genre,
		SUM(il.unit_price*il.quantity) AS total_sales
	FROM
		invoice i
	JOIN
		customer c ON i.customer_id = c.customer_id
	JOIN
		invoice_line il ON i.invoice_id = il.invoice_id
	JOIN
		track t ON il.track_id = t.track_id
	JOIN 
		genre g ON t.genre_id = g.genre_id
	GROUP BY 
		c.country, g.name
),
max_genre_sales AS
(
	SELECT 
		country,
		MAX(total_sales) AS max_sales
	FROM
		genre_purchases
	GROUP BY 
		country
)

SELECT 
	gp.country,
	gp.genre,
	gp.total_sales
FROM
	genre_purchases gp
JOIN
	max_genre_sales ms ON gp.country = ms.country AND gp.total_sales = ms.max_sales
ORDER BY
	gp.country, gp.genre





--11: Write a query that determines the customer that has spent the most on music for each country. 
      Write a query that returns the country along with the top customer and how much they spent. 
      For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH 
customer_with_country AS
(
	SELECT
		first_name,
		last_name,
		billing_country,
		SUM(total) AS total_spending,
		RANK() OVER (PARTITION BY billing_country ORDER BY SUM(total) DESC) AS rankno
	FROM invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY 1,2,3
)
SELECT *
FROM customer_with_country
Where rankno = 1



