# EASY LEVEL

--Show first name, last name, and gender of patients who's gender is 'M'
SELECT 
	  first_name
  , last_name
  , gender
FROM 
	patients
WHERE
	gender = 'M'
;

--Show first name and last name of patients who does not have allergies (null).
SELECT 
	  first_name
  , last_name
FROM
	patients
WHERE
	allergies IS NULL
;

--Show first name of patients that start with the letter 'C'
SELECT 
	first_name
FROM
	patients
WHERE
	first_name LIKE 'C%'
;

--Show first name and last name of patients that weight within the range of 100 to 120 (inclusive)
SELECT 
	  first_name
  , last_name
FROM
	patients
WHERE
	weight BETWEEN 100 AND 120
;

--Update the patients table for the allergies column. If the patient's allergies is null then replace it with 'NKA'
UPDATE patients
SET allergies = 'NKA'
WHERE
	allergies IS NULL
;

--Show first name and last name concatinated into one column to show their full name.
  SELECT
	CONCAT(first_name, ' ', last_name) AS Full_Name
FROM
	patients
;

--Show first name, last name, and the full province name of each patient.
--Example: 'Ontario' instead of 'ON'
SELECT
	  p.first_name
  , p.last_name
  , pn.province_name 
FROM
	patients p
JOIN province_names pn ON p.province_id = pn.province_id
;

--Show how many patients have a birth_date with 2010 as the birth year.
SELECT
	COUNT(birth_date) AS Patient
FROM
	patients
WHERE YEAR (birth_date) = 2010
;

--Show the first_name, last_name, and height of the patient with the greatest height.
SELECT
	  first_name
  , last_name
  , MAX(height) AS Height
FROM
	patients
;

--Show all columns for patients who have one of the following patient_ids:
1,45,534,879,1000
  SELECT
	  patient_id
  , first_name
  , last_name
  , gender
  , birth_date
  , city
  , province_id
  , allergies
  , height
  , weight
FROM
	patients
WHERE
	patient_id IN (1, 45, 534, 879, 1000)
;

--Show the total number of admissions
SELECT
	COUNT(*) AS total_admissions
FROM
	admissions
;

--Show all the columns from admissions where the patient was admitted and discharged on the same day.
SELECT
	  patient_id
  , admission_date
  , discharge_date
  , diagnosis
  , attending_doctor_id
FROM
	admissions
WHERE
	admission_date = discharge_date
;

--Show the patient id and the total number of admissions for patient_id 579.
SELECT
	  patient_id
  , COUNT(admission_date) as Total_Admissions
FROM
	admissions
WHERE
	patient_id = 579
;

--Based on the cities that our patients live in, show unique cities that are in province_id 'NS'?
SELECT 
  DISTINCT city
FROM
	patients
WHERE
	province_id = 'NS'
;

--Write a query to find the first_name, last name and birth date of patients who has height greater than 160 and weight greater than 70
SELECT
	  first_name
  , last_name
  , birth_date
FROM
	patients
WHERE
	height > 160 AND weight > 70
;

--Write a query to find list of patients first_name, last_name, and allergies from Hamilton where allergies are not null
SELECT
	  first_name
  , last_name
  , allergies
FROM
	patients
WHERE
	city = 'Hamilton' AND allergies IS NOT NULL
;

--Based on cities where our patient lives in, write a query to display the list of unique city starting with a vowel (a, e, i, o, u). Show the result order in ascending by city.
SELECT 
  DISTINCT city
FROM
	patients
WHERE city LIKE 'a%'
OR city LIKE 'e%'
OR city lIKE 'i%'
OR city lIKE 'o%'
OR city LIKE 'u%'
ORDER BY 
	city ASC
;


# MEDIUM LEVEL


--Show unique birth years from patients and order them by ascending.
SELECT 
	DISTINCT YEAR (birth_date) AS birth_year
FROM
	patients
ORDER BY 
	birth_year
;

--Show unique first names from the patients table which only occurs once in the list.
--For example, if two or more people are named 'John' in the first_name column then don't include their name in the output list. If only 1 person is named 'Leo' then include them in the output.
SELECT
	first_name
FROM
	patients
GROUP BY 
	first_name
HAVING COUNT(first_name) = 1
;

--Show patient_id and first_name from patients where their first_name start and ends with 's' and is at least 6 characters long.
SELECT
	  patient_id
  , first_name
FROM
	patients
WHERE
	first_name lIKE 'S%s'
    AND LEN(first_name) >= 6
;

--Show patient_id, first_name, last_name from patients whos diagnosis is 'Dementia'.
  SELECT
	  p.patient_id
  , p.first_name
  , p.last_name
FROM
	patients p
JOIN admissions a ON p.patient_id = a.patient_id
WHERE
	diagnosis = 'Dementia'
;

--Display every patient's first_name.
--Order the list by the length of each name and then by alphbetically
SELECT
	first_name
FROM
	patients
ORDER BY
	  LEN(first_name)
  , first_name
;

--Show the total amount of male patients and the total amount of female patients in the patients table.
--Display the two results in the same row.
SELECT
	(SELECT COUNT(*) FROM patients WHERE gender = 'M') as total_males
, (SELECT COUNT(*) FROM patients WHERE gender = 'F') AS total_females
;

--Show first and last name, allergies from patients which have allergies to either 'Penicillin' or 'Morphine'. 
--Show results ordered ascending by allergies then by first_name then by last_name.
SELECT
	  first_name
  , last_name
  , allergies
FROM
	patients
WHERE
	allergies IN ('Penicillin', 'Morphine')
ORDER BY
	  allergies
  , first_name
  , last_name
;

--Show patient_id, diagnosis from admissions. 
--Find patients admitted multiple times for the same diagnosis.
SELECT
	  patient_id
  , diagnosis
FROM
	admissions
GROUP BY
	  patient_id
  , diagnosis
HAVING COUNT(admission_date) > 1
;

--Show the city and the total number of patients in the city.
--Order from most to least patients and then by city name ascending.
SELECT
	  city
  , COUNT(*) AS total_patients
FROM
	patients
GROUP BY
	city
ORDER BY
	  total_patients DESC
  , city
;

--Show first name, last name and role of every person that is either patient or doctor.
--The roles are either "Patient" or "Doctor"
SELECT
      first_name
    , last_name
    , 'Patient' AS Role
  FROM
      patients
      
UNION ALL 

SELECT
      first_name
    , last_name
    , 'Doctor'
  FROM
      doctors
;

--Show all allergies ordered by popularity. Remove NULL values from query.
SELECT
	  allergies
  , COUNT(*) AS total_diagnosis
FROM
	patients
WHERE
	allergies IS NOT NULL
GROUP BY
	allergies
ORDER BY
	total_diagnosis DESC
;

--Show all patient's first_name, last_name, and birth_date who were born in the 1970s decade. Sort the list starting from the earliest birth_date.
SELECT
	  first_name
  , last_name
  , birth_date
FROM
	patients
WHERE
	YEAR(birth_date) BETWEEN 1970 AND 1979
ORDER BY
	birth_date ASC
;

--We want to display each patient's full name in a single column. Their last_name in all upper letters must appear first, then first_name in all lower case letters. 
--Separate the last_name and first_name with a comma. Order the list by the first_name in decending order
SELECT
	CONCAT(UPPER(last_name), ',', LOWER(first_name)) AS Full_Name
FROM
	patients
ORDER BY
	first_name DESC
;

--Show the province_id(s), sum of height; where the total sum of its patient's height is greater than or equal to 7,000.
SELECT
	  province_id
  , SUM(height) AS total_sum_height
FROM
	patients
GROUP BY
	province_id
HAVING
	total_sum_height >= 7000
;

--Show the difference between the largest weight and smallest weight for patients with the last name 'Maroni'
SELECT
	MAX(weight) - MIN(weight) AS Weight_Difference
FROM
	patients
WHERE
	last_name = 'Maroni'
;

--Show all of the days of the month (1-31) and how many admission_dates occurred on that day. Sort by the day with most admissions to least admissions.
SELECT
	  DAY(admission_date) as day_number
  , COUNT(*) AS number_of_admissions
FROM
	admissions
GROUP BY
	day_number
ORDER BY
	number_of_admissions DESC
;

--Show all columns for patient_id 542's most recent admission_date.
SELECT
	  patient_id
  , admission_date
  , discharge_date
  , diagnosis
  , attending_doctor_id
FROM
	admissions
GROUP BY
	patient_id
HAVING 
	patient_id = 542
    AND admission_date = MAX(admission_date)
;

--Show patient_id, attending_doctor_id, and diagnosis for admissions that match one of the two criteria:
--1. patient_id is an odd number and attending_doctor_id is either 1, 5, or 19.
--2. attending_doctor_id contains a 2 and the length of patient_id is 3 characters.
SELECT
	  patient_id
  , attending_doctor_id
  , diagnosis
From
	admissions
WHERE
	  MOD(patient_id, 2) <> 0
    AND attending_doctor_id IN (1, 5, 19)
OR 
	attending_doctor_id LIKE '%2%'
  AND LEN(patient_id) = 3
;

--Show first_name, last_name, and the total number of admissions attended for each doctor.
SELECT
	  d.first_name
  , d.last_name
  , COUNT(a.attending_doctor_id) AS total_admissions
FROM
	admissions a
JOIN doctors d ON a.attending_doctor_id = d.doctor_id
GROUP BY
	first_name
;

--For each doctor, display their id, full name, and the first and last admission date they attended.
SELECT
	  d.doctor_id
  , CONCAT(d.first_name, ' ', d.last_name) AS Full_Name
  , MIN(a.admission_date) AS First_Admission_Date
  , MAX(a.admission_date) AS Last_Admission_Date
FROM
	doctors d
JOIN admissions a ON d.doctor_id = a.attending_doctor_id
GROUP BY
	doctor_id
;

--Display the total amount of patients for each province. Order by descending.
SELECT
	  pn.province_name
	, COUNT(*) AS Total_Patients
FROM
	patients p
JOIN province_names pn ON p.province_id = pn.province_id
GROUP BY
	pn.province_name
ORDER BY
	Total_Patients DESC
;

--For every admission, display the patient's full name, their admission diagnosis, and their doctor's full name who diagnosed their problem.
SELECT
	  p.first_name ||' '|| p.last_name AS Patient_Full_Name
  , a.diagnosis
  , d.first_name ||' '|| d.last_name AS Diagnosis_Doctor
FROM
	patients p
JOIN admissions a ON p.patient_id = a.patient_id
JOIN doctors d ON a.attending_doctor_id = d.doctor_id
;

--display the number of duplicate patients based on their first_name and last_name.
SELECT
	  first_name
  , last_name
  , COUNT (*) AS total_duplicates
FROM
	patients
GROUP BY
	  first_name
  , last_name
HAVING
	COUNT(*) > 1
;

--Display patient's full name, height in the units feet rounded to 1 decimal, weight in the unit pounds rounded to 0 decimals, birth_date, gender non abbreviated.
SELECT
	  first_name ||' '|| last_name AS Patient_Name
  , ROUND(Height/30.48,1) AS 'Height "Feet"'
  , ROUND(weight*2.205,0) AS 'Weight "Pounds"'
  , birth_date
,CASE
	WHEN gender = 'M' THEN 'MALE'
    ELSE 'FEMALE'
 END AS gender_type
FROM
	patients
;

--Show patient_id, first_name, last_name from patients whose does not have any records in the admissions table.
SELECT
	  p.patient_id
  , p.first_name
  , p.last_name
FROM
	patients p
WHERE
	patient_id NOT IN (SELECT admissions.patient_id
    				   FROM admissions
    				  )
;

# HARD LEVEL
