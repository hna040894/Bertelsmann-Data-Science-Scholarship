#Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else?

WITH t1 AS (
	SELECT CASE WHEN LEFT(UPPER(name),1) IN ('A', 'E', 'I', 'O', 'U') THEN 1 ELSE 0 END AS vowel,
		CASE WHEN LEFT (UPPER(name),1) IN ('A', 'E', 'I', 'O', 'U') THEN 0 ELSE 1 END AS other
	FROM accounts)
	SELECT SUM(vowel) vowel, SUM(other) other
	FROM t1;

#Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc. 

SELECT STRPOS(primary_poc, ' ') AS space_pos,
	LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) AS first_name,
	RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS last_name
FROM accounts;

#The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.

WITH t1 AS (

		SELECT name, STRPOS(primary_poc, ' ') AS space_pos,
				LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) AS first_name,
				RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS last_name
		FROM accounts)
      
		SELECT CONCAT(first_name, '.', last_name, '@', name)
		FROM t1;

#We would also like to create an initial password, which they will change after their first log in. 
#The first password will be the first letter of the primary_poc's first name (lowercase), then the last letter of their first name (lowercase), 
#the first letter of their last name (lowercase), the last letter of their last name (lowercase), the number of letters in their first name, the number of letters in their last name, 
#and then the name of the company they are working with, all capitalized with no spaces.

WITH t1 AS (

		SELECT name, STRPOS(primary_poc, ' ') AS space_pos,
			LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) AS first_name,
			RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS last_name
		FROM accounts)
      
SELECT CONCAT(first_name, '.', last_name, '@', name), (LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name) , 1) || RIGHT(LOWER(last_name), 1) || LENGTH(first_name) || LENGTH(last_name) || REPLACE(UPPER(name), ' ',' ') ) AS password
FROM t1;
