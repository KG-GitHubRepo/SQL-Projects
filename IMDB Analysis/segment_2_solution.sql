-- Segment 2:



-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- CODE:

select min(avg_rating) as min_avg_rating, max(avg_rating) as max_avg_rating,
min(total_votes) as min_total_votes, max(total_votes) as max_total_votes,
min(median_rating) as min_median_rating, max(median_rating) as max_median_rating from ratings;



-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- CODE:

select title, avg_rating , rank() over( order by avg_rating desc) as movie_rank from movie m 
join ratings r on r.movie_id=m.id
limit 10;



-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- CODE:
-- Order by is good to have

select median_rating , count(movie_id) from ratings
group by 1
order by 1 ;



-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- CODE:

select * from (select production_company, count(distinct id) as movie_count, rank() over(order by count(distinct id) desc) as prod_company_rank from movie m
join ratings r on r.movie_id=m.id
where avg_rating >8 and production_company is not null
group by 1) as t
where prod_company_rank=1;



-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- CODE:

select genre, count(g.movie_id) as movie_count from genre g
join ratings r using(movie_id)
join movie m on m.id=g.movie_id
where year=2017 and country regexp 'USA' and total_votes>1000 and month(date_published)=3
group by 1
order by 2 desc;



-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- CODE:

select distinct title , avg_rating, genre from movie m
join genre g on m.id=g.movie_id
join ratings r on m.id=r.movie_id
where title like "The%" and avg_rating>8;



-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- CODE:

select count(id) from movie m
join ratings r on m.id=r.movie_id
where date_published between '2018-04-01' AND '2019-04-01' and median_rating = 8;



-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- CODE:

Select if(germany>Italy,"Yes","No") as Germany_more_votes_than_Italy from 
(select sum(case when country regexp 'Germany' then total_votes end) as germany,
sum(case when country regexp 'Italy' then total_votes end) as Italy from movie m
join ratings r on m.id=r.movie_id) as t;