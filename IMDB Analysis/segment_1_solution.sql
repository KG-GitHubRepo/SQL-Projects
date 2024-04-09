-- Segment 1:


-- Q1. Find the total number of rows in each table of the schema?
-- CODE:

SELECT table_name, table_rows
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'IMDB';
    


-- Q2. Which columns in the movie table have null values?
-- CODE:

select 'ID', SUM(CASE WHEN ID IS NULL THEN 1 ELSE 0 END ) AS NULL_COUNT FROM MOVIE
UNION
select 'TITLE', SUM(CASE WHEN TITLE IS NULL THEN 1 ELSE 0 END ) AS NULL_COUNT FROM MOVIE
UNION
select 'YEAR', SUM(CASE WHEN YEAR IS NULL THEN 1 ELSE 0 END ) AS NULL_COUNT FROM MOVIE
UNION
select 'DATE PUBLISHED', SUM(CASE WHEN DATE_PUBLISHED IS NULL THEN 1 ELSE 0 END ) AS NULL_COUNT FROM MOVIE
UNION
select 'DURATION', SUM(CASE WHEN DURATION IS NULL THEN 1 ELSE 0 END ) AS NULL_COUNT FROM MOVIE
UNION
select 'COUNTRY', SUM(CASE WHEN COUNTRY IS NULL THEN 1 ELSE 0 END ) AS NULL_COUNT FROM MOVIE
UNION
select 'WORLDWIDE GROSS INCOME', SUM(CASE WHEN WORLWIDE_GROSS_INCOME IS NULL THEN 1 ELSE 0 END ) AS NULL_COUNT FROM MOVIE
UNION
select 'LANGUAGES', SUM(CASE WHEN LANGUAGES IS NULL THEN 1 ELSE 0 END ) AS NULL_COUNT FROM MOVIE
UNION
select 'PRODUCTION COMPANY', SUM(CASE WHEN PRODUCTION_COMPANY IS NULL THEN 1 ELSE 0 END ) AS NULL_COUNT FROM MOVIE;




-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- CODE:

Select year as 'Year', count(*) as Number_of_Movies from movie
group by 1
order by 1;

select month(date_published) as Month_num, count(*) as number_of_movies from movie
group by 1
order by 1;




-- Q4. How many movies were produced in the USA or India in the year 2019??
-- CODE:

Select count(*) as number_of_movies from movie
where country regexp 'USA|India' and year = 2019;



-- Q5. Find the unique list of the genres present in the data set?
-- CODE:

select distinct genre from genre;



-- Q6.Which genre had the highest number of movies produced overall?
-- CODE:

SELECT GENRE FROM GENRE g
join movie m on g.movie_id=m.id
group by 1
order by count(id) desc limit 1;



-- Q7. How many movies belong to only one genre?
-- CODE:

select sum(no_of_movies) as movies_belong_one_genre from ( select count(*) as 'no_of_movies' from genre
group by movie_id
having count(movie_id)=1
) as t ; 



-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Code:

select genre, avg(duration) as avg_duration from movie m
join genre g on m.id=g.movie_id
group by 1;



-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- CODE:

select genre, count(distinct id) as movie_count , rank() over( order by count(distinct id) desc ) as genre_rank from movie m
join genre g on m.id=g.movie_id
where genre = 'Thriller'
group by 1;

