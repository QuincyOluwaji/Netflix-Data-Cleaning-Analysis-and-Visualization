--- let us look at the data
select *
from netflix_titles$

---- to check for duplicate columns
select show_id, count(*)
from netflix_titles$
group by show_id
order by show_id

---- check for null values
SELECT COUNT(show_id) from netflix_titles$
where show_id is null

SELECT COUNT(*) from netflix_titles$
where type is null

SELECT COUNT(*) from netflix_titles$
where title is null

SELECT COUNT(*) from netflix_titles$
where director is null
---- director has 821 null rows

SELECT COUNT(*) from netflix_titles$
where cast is null
----825 null cast rows

SELECT COUNT(*) from netflix_titles$
where country is null
---- 831 null country row

SELECT COUNT(*) from netflix_titles$
where date_added is null
--- 10 null date_added rows

SELECT COUNT(*) from netflix_titles$
where release_year is null

SELECT COUNT(*) from netflix_titles$
where rating is null
---4 null rating rows

SELECT COUNT(*) from netflix_titles$
where duration is null
---3 null duration rows

SELECT COUNT(*) from netflix_titles$
where listed_in is null

SELECT COUNT(*) from netflix_titles$
where description is null

---updating null fields
UPDATE netflix_titles$ 
SET country = 'Not Given'
WHERE country is NULL

----- deleting null fields 
delete from netflix_titles$
where show_id in ( SELECT show_id from netflix_titles$
where director is null)

delete from netflix_titles$
where show_id in ( SELECT show_id from netflix_titles$
where duration is null)

delete from netflix_titles$
where show_id in ( SELECT show_id from netflix_titles$
where date_added is null)

delete from netflix_titles$
where show_id in ( SELECT show_id from netflix_titles$
where rating is null)

----- Quick exploratory analysis

---- How many movies entries do we have?
select count(type) as movies
from netflix_titles$
where type = 'Movie'
----answer is 6,126

select COUNT(type) as TV_Shows
from netflix_titles$
where type = 'Tv show'
--- Answer is 2,664

---- Total numbers of directors
select distinct COUNT(director) as Total_directors
from netflix_titles$
--- 4526

---- Top 10 directors
select top 10 director, count(director) as frequency
from netflix_titles$
group by director
order by frequency desc

---- Top 10 countries
select top 10 country, count(country) as frequency
from netflix_titles$
group by country
order by frequency desc

---- most popular genre
select distinct listed_in, count(listed_in) as frequency
from netflix_titles$
---where listed_in IN ('Dramas','Crime TV Shows', 'Docuseries') 
group by listed_in
order by frequency desc

---- to see if any cast worked with the same director more than once
select CAST, director, COUNT(*)
from netflix_titles$
group by cast, director
having count(*) > 1
order by cast

---- country column is concatenated and needs to be updated
WITH Source AS (
    SELECT
      t.show_id,
      t.title,
      country = TRIM(cat.value),
      rn = ROW_NUMBER() OVER (PARTITION BY show_id ORDER BY (SELECT NULL))
    FROM netflix_titles$ t
    CROSS APPLY STRING_SPLIT(t.country, ',') cat
)
MERGE netflix_titles$ t
USING Source s
ON s.show_id = t.show_id AND s.rn = 1
WHEN MATCHED THEN
  UPDATE
  SET country = s.country
WHEN NOT MATCHED THEN
  INSERT (show_id, title, country)
  VALUES (s.show_id, s.title, s.country);

---drop unnecessary columns
drop column cast
drop column description

