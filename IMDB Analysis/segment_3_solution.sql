-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- CODE:

select sum(case when name is null then 1 else 0 end) as name_nulls,
sum(case when height is null then 1 else 0 end) as height_nulls,
sum(case when date_of_birth is null then 1 else 0 end) as date_of_birth_nulls,
sum(case when known_for_movies is null then 1 else 0 end) as known_for_movies_nulls
from names;



/* The director is the most important person in a movie crew.-- 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- CODE:

with top3_genre as (
select genre from genre
join ratings using(movie_id)
where avg_rating>8
group by 1
order by count(movie_id) desc limit 3)

select name as director_name, count(d.movie_id) as movie_count  from names n
join director_mapping d on n.id=d.name_id
join genre g on g.movie_id=d.movie_id
join ratings r on r.movie_id=d.movie_id
where genre in (select * from top3_genre) and avg_rating>8
group by 1
order by 2 desc limit 3;




-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

select name as actor_name, count(rm.movie_id) movie_count from names n 
join role_mapping rm on n.id=rm.name_id
join ratings r on r.movie_id=rm.movie_id
where median_rating >7 and category= 'Actor'
group by 1
order by 2 desc limit 2;



-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- CODE:

select * from (select production_company, sum(total_votes) as vote_count, 
dense_rank() over(order by sum(total_votes) desc) as prod_comp_rank from movie m
join ratings r on m.id=r.movie_id
where production_company is not null
group by 1) as pd_com
where prod_comp_rank <4;



-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- CODE:

select name as actor_name, sum(total_votes) as total_votes, 
count(r.movie_id) as movie_count, (Sum(avg_rating * total_votes) / Sum(total_votes)) as actor_avg_rating,
rank() over(order by Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2) desc) as actor_rank  from names n
join role_mapping rm on rm.name_id=n.id
join ratings r on r.movie_id=rm.movie_id
join movie m on m.id=r.movie_id
where category = 'Actor' and country regexp 'India'
group by 1
having count(r.movie_id) >4;



-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- CODE: 

select name as actor_name, sum(total_votes) as total_votes, 
count(r.movie_id) as movie_count, (Sum(avg_rating * total_votes) / Sum(total_votes)) as actor_avg_rating,
rank() over(order by Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2) desc) as actor_rank  from names n
join role_mapping rm on rm.name_id=n.id
join ratings r on r.movie_id=rm.movie_id
join movie m on m.id=r.movie_id
where category = 'actress' and country regexp 'India' and languages regexp 'hindi'
group by 1
having count(r.movie_id) >2
limit 5;



/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- CODE:

select title,avg_rating, case 
when avg_rating > 8 then "Superhit movies" 
when avg_rating <= 8 and avg_rating >=7 then "Hit movies" 
when avg_rating < 7 and avg_rating >=5 then "One-time-watch movies" 
when avg_rating < 5 then "Flop movies" 
end as classification from movie m
join ratings r on m.id=r.movie_id
join genre g on m.id=g.movie_id
where genre = 'thriller';