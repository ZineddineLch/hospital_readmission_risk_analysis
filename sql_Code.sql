CREATE DATABASE hospital_readmissions;
USE hospital_readmissions;
SELECT patient_nbr ,count(*) FROM diabetic_data_raw group by patient_nbr order by count(*) DESC;
SELECT * FROM ids_mapping_raw;
alter table diabetic_data_raw
modify  diag_1 varchar(20); 
UPDATE diabetic_data_raw
SET
    race = NULLIF(race, '?'),
    weight = NULLIF(weight, '?'),
    payer_code = NULLIF(payer_code, '?'),
    medical_specialty = NULLIF(medical_specialty, '?'),
    diag_1=NULLIF(diag_1,'?'),
	diag_2=NULLIF(diag_2,'?'),
	diag_3=NULLIF(diag_3,'?')
WHERE
    race = '?'
    OR weight = '?'
    OR payer_code = '?'
    OR medical_specialty = '?'
    OR diag_1='?'
    OR diag_2='?'
    OR diag_3='?';
    SET SQL_SAFE_UPDATES = 0;
    
    
SELECT round(sum(weight is null)*100/count(*)) AS pct_missing_weights ,
 round(sum( race is null)*100/count(*)) AS pct_missing_races,
  round(sum( payer_code is null)*100/count(*)) AS pct_missing_payer_codes,
  round(sum( medical_specialty is null)*100/count(*)) AS pct_missing_medical_specialties,
  round(sum( diag_1 is null)*100/count(*)) AS pct_missing_diag_1,
  round(sum( diag_2 is null)*100/count(*)) AS pct_missing_diag_2,
   round(sum( diag_3 is null)*100/count(*)) AS pct_missing_diag_3
 FROM diabetic_data_raw;
 
 -- step 2
 SELECT patient_nbr,count(*)
 from diabetic_data_raw
 GROUP BY  patient_nbr
 having count(*)>1;
 -- take only the first visite of the patients to the hospital
 CREATE TABLE diabetic_data_raw_dedup AS 
 SELECT t.* FROM diabetic_data_raw as t INNER JOIN
 ( 
 SELECt patient_nbr, MIN(encounter_id) as encounter_id from diabetic_data_raw
 GROUP by patient_nbr
 ORDER BY min(encounter_id) ASC
 ) AS S 
 ON S.patient_nbr=t.patient_nbr 
 AND S.encounter_id=t.encounter_id;
 SELECT * FROM  diabetic_data_raw_dedup;
 SELECT COUNT(*) FROM diabetic_data_raw_dedup;
 -- step3
 -- delete the cases where the patient died , we are not just writing queries we are analysing data
 SELECT * from ids_mapping_raw where description like '%deceased%';
 
 DELETE from diabetic_data_raw_dedup WHERE discharge_disposition_id 
 IN (SELECT admission_type_id FROM ids_mapping_raw WHERE 
 description LIKE '%hospice%' or description LIKE '%expired%' or description LIKE '%deceased%');
 select * from diabetic_data_raw_dedup;
 -- step4 creating two table discharge_disposition_map and admission_source_map
 CREATE TABLE discharge_disposition_map(
  discharge_disposition_id INT,
  description VARCHAR(150));
  CREATE TABLE admission_source_map(
  admission_source_id INT,
  description VARCHAR(150)
  );
  select * from discharge_disposition_map;
  DESCRIBE discharge_disposition_map;
  insert INTO  discharge_disposition_map(discharge_disposition_id,description)values 
  (1, 'Discharged to home'),
(2, 'Discharged/transferred to another short term hospital'),
(3, 'Discharged/transferred to SNF'),
(4, 'Discharged/transferred to ICF'),
(5, 'Discharged/transferred to another type of inpatient care institution'),
(6, 'Discharged/transferred to home with home health service'),
(7, 'Left AMA'),
(8, 'Discharged/transferred to home under care of Home IV provider'),
(9, 'Admitted as an inpatient to this hospital'),
(10, 'Neonate discharged to another hospital for neonatal aftercare'),
(11, 'Expired'),
(12, 'Still patient or expected to return for outpatient services'),
(13, 'Hospice / home'),
(14, 'Hospice / medical facility'),
(15, 'Discharged/transferred within this institution to Medicare approved swing bed'),
(16, 'Discharged/transferred/referred another institution for outpatient services'),
(17, 'Discharged/transferred/referred to this institution for outpatient services'),
(18, NULL),
(19,'expired at home, Medicate only, hospice'),
(20, 'Expired in a medical facility. Medicaid only, hospice.'),
(21, 'Expired, place unknown. Medicaid only, hospice.'),
(22, 'Discharged/transferred to another rehab fac including rehab units of a hospital .'),
(23, 'Discharged/transferred to a long term care hospital.'),
(24, 'Discharged/transferred to a nursing facility certified under Medicaid but not certified under Medicare.'),
(25, 'Not Mapped'),
(26, 'Unknown/Invalid'),
(27, 'Discharged/transferred to a federal health care facility.'),
(28, 'Discharged/transferred/referred to a psychiatric hospital of psychiatric distinct part unit of a hospital'),
(29, 'Discharged/transferred to a Critical Access Hospital (CAH).'),
(30, 'Discharged/transferred to another Type of Health Care Institution not Defined Elsewhere')
;
  INSERT INTO admission_source_map (admission_source_id,description) values 
  
(1, ' Physician Referral'),
(2, 'Clinic Referral'),
(3, 'HMO Referral'),
(4, 'Transfer from a hospital'),
(5, ' Transfer from a Skilled Nursing Facility (SNF)'),
(6, ' Transfer from another health care facility'),
(7, ' Emergency Room'),
(8, 'court/ Law Enforcement'),
(9, ' Not Available'),
(10, ' Transfer from critial access hospital'),
(11, 'Normal Delivery'),
(12, ' Premature Delivery'),
(13, ' Sick Baby'),
(14, ' Extramural Birth'),
(15, 'Not Available'),
(17, NULL),
(18, ' Transfer From Another Home Health Agency'),
(19, 'Readmission to Same Home Health Agency'),
(20, ' Not Mapped'),
(21, 'Unknown/Invalid'),
(22, ' Transfer from hospital inpt/same fac reslt in a sep claim'),
(23, ' Born inside this hospital'),
(24, ' Born outside this hospital'),
(25, ' Transfer from Ambulatory Surgery Center'),
(26, 'Transfer from Hospice')
;
select * from admission_source_map;
-- step 5 modfiy the table and the age column
ALTER TABLE diabetic_data_raw_dedup 
add column age_midpoint INT ;
UPDATE diabetic_data_raw_dedup 
set age_midpoint = case
WHEN age='[0-10)' then 5
WHEN age='[10-20)' then 15
when age ='[20-30)' then 25
when age ='[30-40)' then 35
when age ='[40-50)' then 45
when age ='[50-60)' then 55
when age ='[60-70)' then 65
when age ='[70-80)' then 75
when age ='[80-90)' then 85
when age ='[90-100)' then 95
END ;
select * from diabetic_data_raw_dedup;
-- cleaning is done and  now EXPLOratory ANALYSIS
-- THE PERCENTAGE OF each READMISSION
select readmitted, count(*) , ROUND(COUNT(*)/(SELECT COUNT(*) FROM diabetic_data_raw_dedup )*100,1) as PRCnt_of_readmission_type
FROM diabetic_data_raw_dedup 
group by readmitted;
-- the ages of people who are readmitted <30
SELECT age,age_midpoint, count(*) as total_encounters, sum( readmitted ='<30') as under_30_encounter, ROUND(sum( readmitted ='<30')*100/count(*),1) as readmission_rate_percentage 
FROM diabetic_data_raw_dedup
GROUP BY  age,age_midpoint
ORDER BY readmission_rate_percentage DESC;
-- just to see how many patients has been admitted due to a specefic problem(description)
SELECT 
    a.description AS admission_type,
    d.age, 
    d.age_midpoint,
    count(*) as total_persons_with_the_age_and_the_description,
    SUM(d.readmitted = '<30') AS early_readmissions,
     SUM(d.readmitted = '<30') *100/ count(*) as percentage_of_readmission_with_the_age_and_the_description
FROM diabetic_data_raw_dedup AS d 
INNER JOIN ids_mapping_raw AS a
  ON d.admission_type_id = a.admission_type_id
GROUP BY 
    a.description, 
    d.age, 
    d.age_midpoint
 ORDER BY early_readmissions DESC;
 SHOW TABLES;
with patient_risk_base AS (
SELECT 
  encounter_id,
  patient_nbr,
  age_midpoint,
  time_in_hospital,
  num_medications,
  num_lab_procedures,
  number_inpatient,
  number_emergency,
  number_outpatient,
  diag_1,
  readmitted,
  case when readmitted ='<30' then 1 else 0 end as is_admitted_30
  FROM diabetic_data_raw_dedup 
  )
  SELECT encounter_id,age_midpoint, num_medications,
  RANK() over (partition by age_midpoint order  by num_medications DESC) as med_rank_age_group
  FROM patient_risk_base
  ORDER BY age_midpoint,med_rank_age_group
  LIMIT 200;
  -- finding 1. does diagnonsis categories dribing readmission 
  -- finding 2.does medication change at discharge affect readmission?
  -- finding 3.Discharge disposition impact
  -- finding 4.A1C testing and readmission
  with patient_risk_base AS(
  select 
  encounter_id,number_inpatient,readmitted,
  case when readmitted='>30' then 1 else 0  END AS is_admitted_30
  from diabetic_data_raw_dedup
  
  )
  select encounter_id , number_inpatient, ntile(4) over(order by number_inpatient DESC ) AS risque_quartile
  from patient_risk_base;
  SELECT encounter_id,num_medications ,
  case 
    when num_medications <=10 then 'Low'
    when num_medications between 11 and 20 then 'Medium'
    else 'hight'
    END as medication_burden_tier,
case when number_diagnoses <=5 then 'Low complexity'
     when number_diagnoses between 6 and 9 THEN 'Moderate Complexity'
     else 'Hight Complexity'
     END as diagnoses_complexity_tier
FROM diabetic_data_raw_dedup;
WITH diag_categorized AS (
    SELECT
        encounter_id,
        readmitted,
        CASE
            WHEN diag_1 LIKE '250%' THEN 'Diabetes'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED)
                 BETWEEN 390 AND 459 THEN 'Circulatory'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED)
                 BETWEEN 460 AND 519 THEN 'Respiratory'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED)
                 BETWEEN 520 AND 579 THEN 'Digestive'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED)
                 BETWEEN 580 AND 629 THEN 'Genitourinary'
            ELSE 'Other'
        END AS diagnosis_category,
        CASE
            WHEN readmitted = '>30' THEN 1
            ELSE 0
        END AS is_readmitted_30
    FROM diabetic_data_raw_dedup
)
SELECT
    diagnosis_category,
    COUNT(*) AS total_encounters,
    ROUND(AVG(is_readmitted_30) * 100, 1)
        AS readmission_rate_percentage
FROM diag_categorized
GROUP BY diagnosis_category
HAVING AVG(is_readmitted_30) > (
    SELECT AVG(is_readmitted_30)
    FROM diag_categorized
)
ORDER BY readmission_rate_percentage DESC;
select 'change',
count(*) as total_encounters,
ROUND(avg(readmitted='<30')/count(*)*100,1) as readmission_rate_pct
FROM diabetic_data_raw_dedup
GROUP BY 'change';

-- finding 3. discharge Disposition impact
SELECT 
    m.description AS discharge_disposition,
    COUNT(*) AS total_encounters,
    ROUND(
        SUM(d.readmitted = '<30') * 100.0 / COUNT(*),
        1
    ) AS readmission_rate_pct
FROM diabetic_data_raw_dedup AS d
JOIN discharge_disposition_map AS m
    ON d.discharge_disposition_id = m.discharge_disposition_id
GROUP BY m.description
HAVING COUNT(*) > 100
ORDER BY readmission_rate_pct DESC
LIMIT 10;
-- FINDING 4.  a1c testing and readmission
SELECT
    A1Cresult,
    COUNT(*) AS total_encounters,
    ROUND(
        SUM(readmitted = '<30') * 100.0 / COUNT(*),
        1
    ) AS readmission_rate_pct
FROM diabetic_data_raw_dedup
GROUP BY A1Cresult
ORDER BY readmission_rate_pct DESC;