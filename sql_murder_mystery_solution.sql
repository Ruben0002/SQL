-- Solution to SQL Murdery Mystery on https://mystery.knightlab.com/

-- Prompt
/*
A crime has taken place and the detective needs your help. The detective gave you the crime scene report, but you somehow lost it. You vaguely remember that the crime was a ​murder​ that 
occurred sometime on ​Jan.15, 2018​ and that it took place in ​SQL City​. Start by retrieving the corresponding crime scene report from the police department’s database.
*/

-- Retrieving crime scene report

SELECT * 
FROM 
  crime_scene_report 
WHERE 
  type = 'murder' 
  AND city = 'SQL City'
  AND date = '20180115';

-- Crime Scene Report Description
/* 
Security footage shows that there were 2 witnesses. The first witness lives at the last house on "Northwestern Dr". 
The second witness, named Annabel, lives somewhere on "Franklin Ave".
*/
---------------------------------------------------------

-- Identify the witnesses

-- Witness #1 (id: 14887, name: Morty Schapiro, license_id: 118009)
SELECT *
FROM 
  person
WHERE 
  address_street_name LIKE '%Northwestern Dr%' -- street name of witness 1 thats missing a name
ORDER BY 
  address_number DESC -- lives in the last house on northwestern dr
LIMIT 1
;

-- Witness #2 (id: 16371, name: Annabel Miller, license_id: 490173)
SELECT *
FROM 
  person
WHERE 
  name LIKE '%Annabel%' -- witness 2 first name, wildcard to help link to entire record without knowing lastname
  AND address_street_name LIKE '%Franklin Ave%'
;

---------------------------------------------------------
-- Find the interview transcripts for the two witnesses identified

SELECT 
  i.person_id
, p.name
, transcript
FROM
  person p
JOIN interview i
ON p.id = i.person_id
WHERE 
  id = 14887
  OR name = 'Annabel Miller'
;

-- Witness #1
/*
I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z".
Only gold members have those bags. The man got into a car with a plate that included "H42W".
*/

-- Witness #2
/*
I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.
*/

---------------------------------------------------------
-- Digging Deeper

-- Using the first clues from the witness statements to find more information on potential suspects.

SELECT 
    member.id
  , member.person_id
  , member.name
  , member.membership_status
  , chckin.check_in_date
FROM 
	get_fit_now_member member
JOIN get_fit_now_check_in chckin
  ON chckin.membership_id = member.id
WHERE 
  member.id LIKE '48Z%' -- witness 1 saw membership id on gym bag started with "48Z"
  AND chckin.check_in_date = '20180109' -- witness 2 recognized the suspect from the gym on Jan 9th 2018
;

-- Result: Jeremy Bowers & Joe Germuska

---------------------------------------------------------
-- Joining the "Person" table to the "drivers_license" table to retrieve plate number information

SELECT 
  p.id
, p.name
, p.license_id
, dl.plate_number
FROM 
  person p
JOIN drivers_license dl
ON p.license_id = dl.id
WHERE 
  p.name = 'Jeremy Bowers'
  OR p.name = 'Joe Germuska'
  AND dl.plate_number LIKE '%H42W%'
;

/*
No records found for Joe. Jeremy on the other hand is matching all clues as the suspect who committed the crime.
*/

INSERT INTO solution VALUES (1, "Jeremy Bowers");

SELECT value FROM solution;

/*
Congrats, you found the murderer! But wait, there's more... 
If you think you're up for a challenge, try querying the interview transcript of the murderer to find the real villian behind this crime.
If you feel especially confident in your SQL skills, try to complete this final step with no more than 2 queries.
*/

---------------------------------------------------------
-- Deeper investigation

SELECT * 
FROM 
  interview
WHERE 
  person_id = 67318
;

/*
I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). 
She has red hair and she drives a Tesla Model S. I know that she attended the SQL Symphony Concert 3 times in December 2017.
*/

-- creating a query using JOIN's to help retrieve a suspect that matches some of the clues(female, event attended 3x in Dec) mentioned above^
SELECT 
  fb.person_id
, p.name
, dl.id
, dl.gender
, fb.event_name
FROM 
  facebook_event_checkin fb
JOIN person p
  ON fb.person_id = p.id
JOIN drivers_license dl
  ON p.license_id = dl.id
WHERE 
  fb.date BETWEEN 20171201 AND 20171231
  AND event_name LIKE '%SQL%'
GROUP BY 
  fb.person_id
HAVING 
  COUNT(*) =3
;

---------------------------------------------------------
-- Matching the suspect with the rest of the clues (height, hair, car make and model)

SELECT 
  p.id
, p.name
, dl.id AS license_id
, dl.height
, dl.hair_color
, dl.gender
, dl.car_make
, dl.car_model
FROM 
  person p
JOIN drivers_license dl
  ON p.license_id = dl.id
  WHERE dl.id = 202298
;
-- Results
/*
 id	  |      name	       | license_id |	height |	hair_color |	gender	|  car_make	| car_model
99716	| Miranda Priestly |	 202298	  |  66	   |     red	   |  female	|   Tesla	  |  Model S

Congrats, you found the brains behind the murder! Everyone in SQL City hails you as the greatest SQL detective of all time. Time to break out the champagne!
*/
