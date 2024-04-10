-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- CODE:

select genre, round(avg(duration),2) as avg_duration,
round(sum(avg(duration)) over ( order by genre),2) as running_total_duration,
round(avg(avg(duration)) OVER(ORDER BY genre ROWS BETWEEN unbounded PRECEDING AND CURRENT ROW ),2) as moving_avg_duration
from movie m1
join genre g on m1.id=g.movie_id
group by 1;



-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- CODE:

with top3genre_year as(
select genre, year from (select genre, year, count(movie_id), 
rank() over(partition by year order by count(movie_id) desc) as mrank from movie m 
join genre g on m.id=g.movie_id
group by 2,1) as top3_genre
where mrank<4)

select * from (
select genre, year, title as movie_name, worlwide_gross_income as worldwide_gross_income,
dense_rank() over(partition by year order by worlwide_gross_income desc) as movie_rank
from movie m
join genre g on m.id=g.movie_id
where (genre, year) in (select * from top3genre_year) and worlwide_gross_income is not null) as t
where movie_rank<6;




-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- CODE:

select production_company, count(m.id) as movie_count,
rank() over( order by count(movie_id) desc) as prod_comp_rank
from movie m
join ratings r on m.id=r.movie_id
where median_rating >= 8 and production_company is not null 
AND Position(',' IN languages) > 0
group by 1
limit 2;



-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- CODE:

select name as actress_name, sum(total_votes) as total_votes, count(r.movie_id), 
Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) as actress_avg_rating,
rank() over( order by count(movie_id) desc) as actress_rank
from names n
join role_mapping rm on rm.name_id=n.id
join ratings r on r.movie_id=rm.movie_id
join genre g on g.movie_id=r.movie_id
where avg_rating > 8 and genre='Drama' and category = 'actress'
group by 1
limit 3;




/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- CODE:

with summary as( 
select *, Datediff(lead_date, date_published) as date_difference from
( select d.name_id as director_id, name as director_name, d.movie_id, total_votes, avg_rating,duration,
date_published, 
lead(date_published,1) over(partition by d.name_id order by date_published, d.movie_id) as lead_date 
from names as n
join director_mapping d on n.id= d.name_id
join ratings r on r.movie_id=d.movie_id
join movie m on m.id=r.movie_id) as new)

SELECT  director_id  AS director_id,director_name,Count(movie_id)  AS number_of_movies,
Round(Avg(date_difference),2) AS avg_inter_movie_days,
Round(Avg(avg_rating),2)  AS avg_rating,
Sum(total_votes) AS total_votes,
Min(avg_rating) AS min_rating,
Max(avg_rating) AS max_rating,
Sum(duration) AS total_duration
FROM summary
GROUP BY director_id
ORDER BY Count(movie_id) DESC limit 9;
