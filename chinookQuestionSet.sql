#Question 1: Which countries have the most Invoices?

select count(total) invoices, BillingCountry from invoice
group by BillingCountry
order by invoices DESC;

#Question 2: Which city has the best customers?

select sum(total) total_invoice, BillingCity from invoice
group by BillingCity
order by invoices DESC
limit 1;

#Question 3: Who is the best customer?

select c.CustomerID, sum(il.UnitPrice * il.Quantity) total_money_spent
from Customer c JOIN Invoice i 
ON c.CustomerId = i.CustomerID 
JOIN InvoiceLine il
ON i.InvoiceID = il.InvoiceID
Group by 1
ORDER by 2 desc
LIMIT 1;

#Q1 Set 2: 
#Use your query to return the email, first name, last name, and Genre of all Rock Music listeners. 
#Return your list ordered alphabetically by email address starting with A. 
#Can you find a way to deal with duplicate email addresses so no one receives multiple emails?

select c.firstname, c.lastname, c.email, g.name 
	from Genre g
		join track t
			on t.GenreId = g.GenreId
		join InvoiceLine l
			on t.TrackId = l.TrackId
		join Invoice i
			on i.InvoiceId = l.Invoiceid
		join Customer c
			on i.CustomerId = c.CustomerId
WHERE g.name = "Rock"
group by c.email 
Order by c.email asc;

#Q2 Set 2:
#Lets invite the artists who have written the most rock music in our dataset. 
#Write a query that returns the Artist name and total track count of the top 10 rock bands.

select at.ArtistID, at.Name, count(t.name) songs
	from genre g
		join Track t
			on g.genreid = t.genreid
		join Album a
			on t.albumid = a.albumid
		join artist at
			on a.artistid = at.artistid
where g.name = "Rock"
group by 2
order by 3 desc
limit 10;

#Q2 Set 2
#First, find which artist has earned the most according to the InvoiceLines?
#Now use this artist to find which customer spent the most on this artist.

select ar.name, sum(il.quantity*il.unitprice) AmountSpent, c.customerid, c.firstname, c.lastname
	from Artist ar join Album a
		on ar.Artistid = a.Artistid
	join track t
		on t.albumid = a.albumid
	join InvoiceLine il
		on t.TrackId = il.Trackid JOIN Invoice i 
		on c.CustomerId = i.CustomerId 
WHERE ar.Name = 'Iron Maiden' 
GROUP BY c.CustomerId 
ORDER BY AmountSpent DESC;

#Q1 Set 3

#We determine the most popular genre as the genre with the highest amount of purchases. 
#Write a query that returns each country along with the top Genre. 
#For countries where the maximum number of purchases is shared return all Genres.

with t1 as(
	select count(i.invoiceid) Purchases, c.country Country, g.name, g.genreid
			from Genre g join Track t on g.Genreid = t.Genreid
						join InvoiceLine il on t.Trackid = il.Trackid
						join Invoice i on il.Invoiceid = i.Invoiceid
						join Customer c on i.Customerid = c.Customerid	
			group by 2,3
			order by 1 desc
	),


t2 as (
		select MAX(Purchases) as MaxPurchases, Name, Country, GenreID
		from t1
		group by 3)
		
select t1.Purchases, t1.Country, t1.Name, t1.GenreID
			from t1 join t2 on t1.country = t2.country

#Q2 Set 3
#Return all the track names that have a song length longer than the average song length. 

select Name, Milliseconds from (
	select t.name, t.milliseconds,(select avg(milliseconds) from Track) as averagelength
	from track t
	where t.milliseconds > averagelength
	order by t.milliseconds desc
	);

#Q3 Set 3
#Write a query that returns the country along with the top customer and how much they spent. 
#For countries where the top amount spent is shared, provide all customers who spent this amount.

with t1 as(
			select c.CustomerID, sum(i.Total) TotalSpent, c.lastname Lastname, c.firstname Firstname, c.country Country
			from invoice i
			join Customer c
			on i.Customerid = c.Customerid
			group by 1
			),
t2 as (
	select CustomerID, Lastname, Firstname, max(TotalSpent) MaxSpent, Country
	from t1
	group by Country)

select t1.Country, t1.Firstname, t1.Lastname, t1.TotalSpent, t1.CustomerID
from t1 join t2
on t1.customerID = t2.CustomerID
where t1.totalspent = t2.maxspent
order by 4 desc;	