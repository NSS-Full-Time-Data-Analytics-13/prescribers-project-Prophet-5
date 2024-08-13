---------------------MVP---------MVP-------------------------------
--Question 1a-- provider NPI 1881634483
SELECT  
	npi,
	SUM(total_claim_count) AS claim_total
FROM prescriber
JOIN prescription USING (npi)
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name,npi
ORDER BY claim_total DESC;

--Question 1b-- Bruce Pendley
SELECT nppes_provider_first_name,
	nppes_provider_last_org_name,
	specialty_description,
	SUM(total_claim_count) AS claim_total
FROM prescriber
JOIN prescription USING (npi)
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name,specialty_description
ORDER BY claim_total DESC;

--Question 2a-- Family Practice
SELECT 
	specialty_description,
	SUM(total_claim_count) AS total_claim
FROM prescriber
JOIN prescription USING (npi)
GROUP BY specialty_description
ORDER BY total_claim DESC;

--Question 2b-- Nurse Practitioner
SELECT 
	specialty_description,
	SUM(total_claim_count) AS total_claim
FROM prescriber
JOIN prescription USING (npi)
JOIN drug USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY total_claim DESC;

--QUESTION 2c --+Yes+--92
SELECT DISTINCT 
	specialty_description, 
	total_claim_count AS precriptions
FROM prescriber
FULL JOIN prescription USING (npi)	
WHERE total_claim_count IS NULL;

--Question 2d--
SELECT 
	specialty_description,
	SUM(total_claim_count) AS total_claim
FROM prescriber
JOIN prescription USING (npi)
JOIN drug USING (drug_name)
WHERE opioid_drug_flag = 'Y' 
GROUP BY specialty_description


SELECT 
	 specialty_description,
	SUM(total_claim_count) AS total_claim
FROM prescriber 
JOIN prescription USING (npi)
JOIN drug USING (drug_name)
WHERE opioid_drug_flag = 'N' 
GROUP BY specialty_description



--Question 3a-- PIRFENIDONE
SELECT 
	generic_name,
	SUM(total_drug_cost) :: money AS total_cost
FROM prescription
JOIN drug USING (drug_name)
GROUP BY generic_name
ORDER BY total_cost DESC
LIMIT 1;

--Question 3b--PIRFENIDONE
SELECT 
	generic_name,
	total_drug_cost :: money/365 AS daily_drug_cost 
FROM drug
JOIN prescription USING (drug_name)
ORDER BY daily_drug_cost DESC;


--Question 4a --
SELECT drug_name,CASE WHEN opioid_drug_flag ='Y' THEN 'Opioid'
	WHEN antibiotic_drug_flag ='Y' THEN 'Antibiotic'
	ELSE 'Neither' END AS drug_type
FROM drug;

--Question 4b--OPIOID

SELECT 
	SUM(total_drug_cost):: money,
	CASE WHEN opioid_drug_flag ='Y' THEN 'Opioid'
	WHEN antibiotic_drug_flag ='Y' THEN 'Antibiotic'
	ELSE 'Neither' END AS drug_type
FROM drug
JOIN prescription USING (drug_name)
WHERE antibiotic_drug_flag ='Y' OR opioid_drug_flag ='Y'
GROUP BY drug_type,opioid_drug_flag,antibiotic_drug_flag;
	
--Question 5a--	10 cbsa's
SELECT 
	COUNT(DISTINCT cbsaname) AS TN_cbsa_total
FROM cbsa
JOIN fips_county USING (fipscounty)
WHERE fips_county.state ='TN';

--Question 5b--
(SELECT 
	cbsaname,
	SUM(population) AS pop_sum, 'Largest' AS size
FROM cbsa
JOIN population USING (fipscounty)
GROUP BY cbsaname
ORDER BY pop_sum DESC
LIMIT 1)
UNION
(SELECT 
	cbsaname,
	SUM(population) AS pop_sum, 'Smallest' AS size
FROM cbsa
JOIN population USING (fipscounty)
GROUP BY cbsaname
ORDER BY pop_sum ASC
LIMIT 1)
	
--QUESTION 5c-- SEVIER
SELECT 
	county, 
	population
FROM cbsa
	FULL JOIN population USING (fipscounty)
	FULL JOIN fips_county USING (fipscounty)
WHERE population IS NOT NULL AND cbsa IS NULL
ORDER BY population DESC
LIMIT 1;

--Question 6a--
SELECT drug_name, SUM(total_claim_count) AS total_claims
FROM prescription
WHERE total_claim_count >=3000
GROUP BY drug_name
ORDER BY total_claims DESC;

--Question 6b--
SELECT drug_name, SUM(total_claim_count) AS total_claim_count, opioid_drug_flag
FROM prescription
JOIN drug USING (drug_name)
WHERE total_claim_count >=3000 
GROUP BY drug_name,opioid_drug_flag
ORDER BY total_claim_count DESC

--Question 6c--
SELECT 
	nppes_provider_first_name AS Provider_First_Name ,
	nppes_provider_last_org_name AS Provider_Last_Name,drug_name,
	SUM(total_claim_count) AS total_claim_count, opioid_drug_flag
FROM prescription
JOIN drug USING (drug_name)
JOIN prescriber USING (npi)
WHERE total_claim_count >=3000 
GROUP BY drug_name,opioid_drug_flag,Provider_First_Name, Provider_Last_Name
ORDER BY total_claim_count DESC;

--Question 7a--
SELECT npi,drug_name
FROM prescriber
CROSS JOIN drug
WHERE specialty_description = 'Pain Management' 
	AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag ='Y';

--Question 7b--
SELECT prescriber.npi,drug.drug_name,SUM(total_claim_count) AS total_claim_count 
FROM prescriber
CROSS JOIN drug 
LEFT JOIN prescription USING(drug_name)
WHERE specialty_description = 'Pain Management' 
	AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag ='Y'
GROUP BY prescriber.npi, drug.drug_name;

--Question 7c--
SELECT 
	prescriber.npi,
	drug.drug_name,
	COALESCE(SUM(total_claim_count),0) AS total_claim_count 
FROM prescriber
CROSS JOIN drug 
LEFT JOIN prescription USING(drug_name)
WHERE specialty_description = 'Pain Management' 
	AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag ='Y'
GROUP BY prescriber.npi, drug.drug_name;

-----------------------BONUS QUESTIONS--------------------------
--Question 1-- 4458
SELECT 
	COUNT(DISTINCT prescriber.npi) AS prescriber_npi,
	COUNT(DISTINCT prescription.npi) AS prescription_npi,
	COUNT(DISTINCT prescriber.npi)-COUNT(DISTINCT prescription.npi) AS difference
FROM prescriber
FULL JOIN prescription USING(npi);

--Question 2a--
--LEVOTHYROXINE SODIUM
--LISINOPRIL"
--ATORVASTATIN CALCIUM"
--AMLODIPINE BESYLATE"
--OMEPRAZOLE"

SELECT 
	specialty_description, 
	generic_name,
	SUM(total_claim_count)AS generic_count
FROM drug
	JOIN prescription USING (drug_name)
	JOIN prescriber USING (npi)
WHERE specialty_description ='Family Practice'
GROUP BY  specialty_description,generic_name
ORDER BY generic_count DESC
LIMIT 5;

--Question 2b--
--ATORVASTATIN CALCIUM"
--CARVEDILOL"
--METOPROLOL TARTRATE"
--CLOPIDOGREL BISULFATE"
--AMLODIPINE BESYLATE"
SELECT 
	specialty_description, 
	generic_name,
	SUM(total_claim_count)AS generic_count
FROM drug
	JOIN prescription USING (drug_name)
	JOIN prescriber USING (npi)
WHERE specialty_description ='Cardiology'
GROUP BY  specialty_description,generic_name
ORDER BY generic_count DESC
LIMIT 5;

--Question 2c--
(SELECT 
	specialty_description, 
	generic_name,
	SUM(total_claim_count)AS generic_count
FROM drug
JOIN prescription USING (drug_name)
JOIN prescriber USING (npi)
WHERE specialty_description = 'Cardiology'  
GROUP BY  specialty_description,generic_name
ORDER BY generic_count DESC
LIMIT 5)
UNION ALL
(SELECT 
	specialty_description, 
	generic_name,
	SUM(total_claim_count)AS generic_count
FROM drug
JOIN prescription USING (drug_name)
JOIN prescriber USING (npi)
WHERE specialty_description ='Family Practice'
GROUP BY  specialty_description,generic_name
ORDER BY generic_count DESC
LIMIT 5);

--Question 3a--See Table
SELECT 
	npi,
	SUM(total_claim_count) 
	AS prescribed_drugs,
	nppes_provider_city 
FROM prescription
JOIN prescriber USING(npi)
WHERE nppes_provider_city = 'NASHVILLE'
GROUP BY npi,nppes_provider_city
ORDER BY prescribed_drugs DESC
LIMIT 5;
--Question 3b--
SELECT 
	npi,
	SUM(total_claim_count) 
	AS prescribed_drugs,
	nppes_provider_city 
FROM prescription
JOIN prescriber USING(npi)
WHERE nppes_provider_city = 'MEMPHIS'
GROUP BY npi,nppes_provider_city
ORDER BY prescribed_drugs DESC
LIMIT 5;

--Question 3c-- See Table:
(SELECT 
	npi,
	SUM(total_claim_count) 
	AS prescribed_drugs,
	nppes_provider_city 
FROM prescription
JOIN prescriber USING(npi)
WHERE nppes_provider_city = 'NASHVILLE'
GROUP BY npi,nppes_provider_city
ORDER BY prescribed_drugs DESC
LIMIT 5)
UNION
(SELECT 
	npi,
	SUM(total_claim_count) 
	AS prescribed_drugs,
	nppes_provider_city 
FROM prescription
JOIN prescriber USING(npi)
WHERE nppes_provider_city = 'MEMPHIS'
GROUP BY npi,nppes_provider_city
ORDER BY prescribed_drugs DESC
LIMIT 5)
UNION
(SELECT 
	npi,
	SUM(total_claim_count) 
	AS prescribed_drugs,
	nppes_provider_city 
FROM prescription
JOIN prescriber USING(npi)
WHERE nppes_provider_city = 'KNOXVILLE'
GROUP BY npi,nppes_provider_city
ORDER BY prescribed_drugs DESC
LIMIT 5)
UNION
(SELECT 
	npi,
	SUM(total_claim_count) 
	AS prescribed_drugs,
	nppes_provider_city 
FROM prescription
JOIN prescriber USING(npi)
WHERE nppes_provider_city = 'CHATTANOOGA'
GROUP BY npi,nppes_provider_city
ORDER BY prescribed_drugs DESC
LIMIT 5)
ORDER BY nppes_provider_city, prescribed_drugs DESC;

--Question 4-- See table:
SELECT 
	SUM(overdose_deaths) AS total_deaths,
	county
FROM overdose_deaths AS OD
JOIN fips_county AS fc ON (fc.fipscounty :: integer)= od.fipscounty
WHERE overdose_deaths > 
(SELECT AVG(overdose_deaths)
FROM overdose_deaths)
GROUP BY county
ORDER BY total_deaths DESC

	

--QUESTION 5a-- See Table:
SELECT 
	SUM(population) AS TN_total_pop
FROM population
JOIN fips_county USING (fipscounty)
WHERE state = 'TN'

--Question 5b--

SELECT 
	SUM(population) AS TN_total_pop,
	county,
	ROUND(SUM(population)/(SELECT 
	SUM(population) AS TN_total_pop
FROM population
JOIN fips_county USING (fipscounty))*100,2) AS percentage_of_nashville
FROM population
JOIN fips_county USING (fipscounty)
WHERE state = 'TN' 
GROUP BY county




