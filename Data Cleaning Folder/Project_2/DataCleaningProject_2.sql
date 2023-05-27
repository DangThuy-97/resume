select * from club_member_info

EXEC sp_rename 'club_member_info', 'clubinfo'

select * from clubinfo;

/*A survey was done of current club members and we would like to restructure the data to a more organized and usable form.

In this project, we will 

1. Check for duplicate entries and remove them.
2. Remove extra spaces and/or other invalid characters.
3. Separate or combine values as needed.
4. Ensure that certain values (age, dates...) are within certain range.
5. Check for outliers.
6. Correct incorrect spelling or inputted data.
7. Adding new and relevant rows or columns to the new dataset.
8. Check for null or empty values.

*/
select * into clubinfo2 from clubinfo;
select * from clubinfo


------------ NAME COLUMN -----------
select full_name from clubinfo
UPDATE clubinfo
set full_name = replace(full_name,'?','')

select 
PARSENAME(replace(full_name,' ','.'),1) as first_name,
PARSENAME(replace(full_name,' ','.'),2) as last_name,
PARSENAME(replace(full_name,' ','.'),3) as aaa,
PARSENAME(replace(full_name,' ','.'),4) as bbb
from clubinfo

ALTER TABLE clubinfo
ADD first_name nvarchar(255)

ALTER TABLE clubinfo
ADD last_name nvarchar(255)

ALTER TABLE clubinfo
ADD third nvarchar(255),
    fourth nvarchar(255)

update clubinfo
set third = PARSENAME(replace(full_name,' ','.'),3),
    fourth = PARSENAME(replace(full_name,' ','.'),4)

update clubinfo
set fourth = CONCAT(UPPER(left(fourth,1)),
                    LOWER(right(fourth,len(fourth)-1))
)

update clubinfo
set first_name = PARSENAME(replace(full_name,' ','.'),1),
    last_name = PARSENAME(replace(full_name,' ','.'),2)

select first_name, last_name, third, fourth from clubinfo

update clubinfo
set last_name = CONCAT(UPPER(left(last_name,1)),LOWER(RIGHT(last_name,len(last_name)-1)))

update clubinfo
set last_name = CONCAT(last_name,' ',third,' ',fourth)
---------------------


-------------AGE----
select * from clubinfo
where age is NULL
---- seem like there's an additional number in age column----

select
age, adj_age = left(age,2)
FROM clubinfo
where len(age)>2

update clubinfo
set age = left(age,2)
where len(age) >2
-----------------------


---------------marital_status
select distinct martial_status from clubinfo

Update clubinfo
set martial_status =
    CASE    WHEN martial_status is null then 'other'
            WHEN martial_status = 'divored' then 'divorced'
            ELSE martial_status
    END;

update clubinfo
set martial_status = trim(martial_status)
---------------------


-----------------email
update clubinfo
set email = trim(email)
---------------------


------------phone------
select * from clubinfo

update clubinfo
set phone = trim(phone)

select phone from clubinfo
where phone is null

update clubinfo
set phone =
    CASE    WHEN len(phone) < 12 THEN null
            ELSE phone
    END;
------------------------------



-----------full_address------
ALTER TABLE clubinfo
ADD address1 nvarchar(255),
    city nvarchar(255),
    state nvarchar(255)

select 
PARSENAME(REPLACE(full_address,',','.'),4) as a
from clubinfo

update clubinfo
set address1 = PARSENAME(REPLACE(full_address,',','.'),3),
    city = PARSENAME(REPLACE(full_address,',','.'),2),
    state = PARSENAME(REPLACE(full_address,',','.'),1)

select address1, city, state from clubinfo
-------------------------------------------


--------------job title ----------
select * from clubinfo
where trim(job_title) =''

select job_title from clubinfo

ALTER TABLE clubinfo
add job_title2 nvarchar(255)

update clubinfo
set job_title =
    CASE    WHEN PARSENAME(REPLACE(job_title,' ','.'),1) = 'I' THEN replace(job_title,'I','Level 1')
            WHEN PARSENAME(REPLACE(job_title,' ','.'),1) = 'II' THEN replace(job_title,'II','Level 2')
            WHEN PARSENAME(REPLACE(job_title,' ','.'),1) = 'III' THEN replace(job_title,'III','Level 3')
            WHEN PARSENAME(REPLACE(job_title,' ','.'),1) = 'IV' THEN replace(job_title,'IV','Level 4')
    ELSE job_title
    END;
    

Alter TABLE clubinfo
add job_level NVARCHAR(255)

update clubinfo
set job_level =
	CASE	when len(substring(reverse(job_title),1,charindex(' ',reverse(job_title)))) > 3 then null
			Else substring(reverse(job_title),1,charindex(' ',reverse(job_title)))
	END;

select job_level from clubinfo

update clubinfo
set 
	 job_level = Case 	when job_level = ' ' then null
						else job_level
				end;

select job_title, len(substring(reverse(job_title),1,charindex(' ',reverse(job_title))))
from clubinfo

update clubinfo
set job_title = 
				CASE 	when len(substring(reverse(job_title),1,charindex(' ',reverse(job_title)))) > 3 then job_title
						ELSE left(job_title,len(job_title)-len(substring(reverse(job_title),1,charindex(' ',reverse(job_title))))) 
				END;


select job_title from clubinfo

select * from clubinfo

update clubinfo
set clubinfo.job_title = clubinfo2.job_title
FROM clubinfo
join clubinfo2
on clubinfo.email = clubinfo2.email
------------------------------------------


---------------------remove unused columns
Alter table clubinfo
DROP column full_name, full_address, third, fourth, job_title2

select * from clubinfo
-----------------------------------------


-----------------------------------------------membership_date
select day(membership_date) from clubinfo
where year(membership_date) <2000

update clubinfo
set membership_date = 
					CASE when year(membership_date) <2000 then CONCAT(day(membership_date),'/',month(membership_date),'/',replace(year(membership_date),'19','20'))
						ELSE membership_date
						end;
--------------------------------


-------------------------remove Duplicates
select email, count(*)
from clubinfo
group by email
having count(*) >1


ALTER TABLE clubinfo
ADD id INT IDENTITY(1,1)

select email from clubinfo

update clubinfo
DELETE FROM clubinfo
WHERE id not in (
	SELECT max(id)
	FROM clubinfo
	group by email	)
--------------------------

select * from clubinfo
exec sp_rename 'clubinfo','cleaned_clubinfo'

select * from cleaned_clubinfo