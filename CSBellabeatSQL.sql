/* Create database */
CREATE DATABASE CSBellabeat;
GO

/* Change to the CaseStudyBellabeat database */
USE CSBellabeat;
GO

/* Check that all datasets are added correctly */
SELECT *
FROM CSBellabeat.dbo.dailyActivity

SELECT *
FROM CSBellabeat.dbo.hourlyCalories

SELECT *
FROM CSBellabeat.dbo.hourlyIntensities

SELECT *
FROM CSBellabeat.dbo.hourlySteps

/* Check all IDs are 10 characters - output 0 rows, so there all IDs are equal to 10*/

--dailyActivity, output 0 rows
SELECT * 
FROM CSBellabeat.dbo.dailyActivity
WHERE LEN(CAST(Id as VARCHAR(10))) <> 10;

--hourlyCalories, output 0 rows
SELECT *
FROM CSBellabeat.dbo.hourlyCalories
WHERE LEN(CAST(Id as VARCHAR(10))) <> 10;

--hourlyIntensities, output 0 rows
SELECT *
FROM CSBellabeat.dbo.hourlyIntensities
WHERE LEN(CAST(Id as VARCHAR(10))) <> 10;

--hourlySteps, output 0 rows
SELECT *
FROM CSBellabeat.dbo.hourlySteps
WHERE LEN(CAST(Id as VARCHAR(10))) <> 10;

/*Check that hourly data isn't more than 24 hours daily by doing a rolling count of hours logged per day, 
using subqueries - output 0 rows, all data is not more than 24 hours*/

--hourlyCalories, output 0 rows
SELECT
   Id,
   ActivityDateCal,
   COUNT(*) AS HoursLogged
FROM
  (SELECT 
     Id, 
     CAST(ActivityHour as Date) AS ActivityDateCal,
     DATEPART(Hour, ActivityHour) AS ActivityTimeCal
  FROM CSBellabeat.dbo.hourlyCalories) AS subCal
GROUP BY
   Id, ActivityDateCal
HAVING
   COUNT(*) > 24;

--hourlyIntensities, output 0 rows
SELECT
   Id,
   ActivityDateInt,
   COUNT(*) AS HoursLogged
FROM
  (SELECT 
     Id, 
     CAST(ActivityHour as Date) AS ActivityDateInt,
     DATEPART(Hour, ActivityHour) AS ActivityTimeInt
  FROM CSBellabeat.dbo.hourlyIntensities) AS subInt
GROUP BY
   Id, ActivityDateInt
HAVING
   COUNT(*) > 24;


--hourlySteps, output 0 rows
SELECT
   Id,
   ActivityDateSt,
   COUNT(*) AS HoursLogged
FROM
  (SELECT 
     Id, 
     CAST(ActivityHour as Date) AS ActivityDateSt,
     DATEPART(Hour, ActivityHour) AS ActivityTimeSt
  FROM CSBellabeat.dbo.hourlySteps) AS subSt
GROUP BY
   Id, ActivityDateSt
HAVING
   COUNT(*) > 24;


/* Checking for duplicate data */

--dailyActivity, no duplicates
SELECT Id, ActivityDate, COUNT(*) AS Duplicate
FROM CSBellabeat.dbo.dailyActivity
GROUP BY Id, ActivityDate
HAVING COUNT(*) > 1

--hourlyCalories, no duplicates
SELECT Id, ActivityHour, COUNT(*) AS Duplicate
FROM CSBellabeat.dbo.hourlyCalories
GROUP BY Id, ActivityHour
HAVING COUNT(*) > 1

--hourlyIntensities, no duplicates
SELECT Id, ActivityHour, COUNT(*) AS Duplicate
FROM CSBellabeat.dbo.hourlyIntensities
GROUP BY Id, ActivityHour
HAVING COUNT(*) > 1

--hourlySteps, no duplicates
SELECT Id, ActivityHour, COUNT(*) AS Duplicate
FROM CSBellabeat.dbo.hourlySteps
GROUP BY Id, ActivityHour
HAVING COUNT(*) > 1

/* Checking for 0 values and null data then adding to a new table*/
SELECT ID, TotalSteps
FROM CSBellabeat.dbo.dailyActivity
WHERE TotalSteps = 0;

SELECT ID, TotalSteps
FROM CSBellabeat.dbo.dailyActivity
WHERE ID IS NULL;

SELECT *
FROM CSBellabeat.dbo.hourlyCalories
WHERE ID IS NULL

SELECT *
FROM CSBellabeat.dbo.hourlySteps
WHERE ID IS NULL

SELECT *
FROM CSBellabeat.dbo.hourlyIntensities
WHERE ID IS NULL

WITH CTE AS (
    SELECT *
    FROM CSBellabeat.dbo.dailyActivity
    WHERE TotalSteps > 0
)
SELECT ID, ActivityDate AS nActivityDate, TotalSteps AS nTotalSteps,
    VeryActiveMinutes AS nVeryActiveMinutes, FairlyActiveMinutes AS nFairlyActiveMinutes, 
    LightlyActiveMinutes AS nLightlyActiveMinutes, SedentaryMinutes AS nSedentaryMinutes,
    Calories as nCalories
INTO newDailyActivity
FROM CTE 

SELECT *
FROM CSBellabeat.dbo.newDailyActivity
WHERE nTotalSteps = 0


/*Analysis*/
--Averages for DailyActivity
SELECT AVG(nTotalSteps) AS AVGSteps, AVG(nVeryActiveMinutes) AS AVGVery, AVG(nFairlyActiveMinutes) AS AVGFairly, AVG(nLightlyActiveMinutes) AS AVGLightly,
 AVG(nSedentaryMinutes) AS AVGSedentary, AVG(nCalories) AS AVGCalories
FROM CSBellabeat.dbo.newDailyActivity

--Averages per day of the week for Daily Activity
SELECT 
   DATENAME(WEEKDAY, nActivityDate) AS DayOfWeek, 
   AVG(nTotalSteps) AS AvgSteps,
   AVG(nVeryActiveMinutes) AS AvgVeryActiveMinutes,
   AVG(nFairlyActiveMinutes) AS AvgFairlyActiveMinutes,
   AVG(nLightlyActiveMinutes) AS AvgLightlyActiveMinutes,
   AVG(nSedentaryMinutes) AS AvgSedentaryMinutes,
   AVG(nCalories) AS AvgCalories
FROM CSBellabeat.dbo.newDailyActivity
GROUP BY DATENAME(WEEKDAY, nActivityDate)
ORDER BY 
  CASE DATENAME(WEEKDAY, nActivityDate)
    WHEN 'Sunday' THEN 1
    WHEN 'Monday' THEN 2
    WHEN 'Tuesday' THEN 3
    WHEN 'Wednesday' THEN 4
    WHEN 'Thursday' THEN 5
    WHEN 'Friday' THEN 6
    WHEN 'Saturday' THEN 7
  END;

/*What times are people most active?*/

-- Left join hourly calories, hourly intensities, and hourly steps
SELECT hrInt.Id, hrInt.ActivityHour, hrInt.TotalIntensity, hrInt.AverageIntensity, hrSt.StepTotal, hrCal.Calories
INTO HourlyActivity
FROM CSBellabeat.dbo.hourlyIntensities hrInt
LEFT JOIN CSBellabeat.dbo.hourlySteps hrSt ON hrInt.Id = hrSt.Id AND hrInt.ActivityHour = hrSt.ActivityHour
LEFT JOIN CSBellabeat.dbo.hourlyCalories hrCal ON hrInt.Id = hrCal.Id AND hrInt.ActivityHour = hrCal.ActivityHour

-- What time do people have the most steps, intensities, and calories
SELECT ActivityHour, AVG(StepTotal) AS AvgStepTotal
FROM CSBellabeat.dbo.HourlyActivity
GROUP BY ActivityHour
ORDER BY 2 DESC

SELECT 
   DATEPART(hour, CONVERT(datetime, ActivityHour)) AS Hour,
   AVG(StepTotal) AS AvgStepTotal,
   AVG(TotalIntensity) AS AvgTotalInt,
   AVG(Calories) AS AvgCal
FROM CSBellabeat.dbo.HourlyActivity 
GROUP BY DATEPART(hour, CONVERT(datetime, ActivityHour))
ORDER BY 2 DESC


/*What type of people are more likely to track their activity?*/
--Average amount of times each user logged data
SELECT AVG(NumofLogs) AS AvgLogs
FROM (
    SELECT COUNT(ID) AS NumofLogs
    FROM CSBellabeat.dbo.newDailyActivity
    GROUP BY ID
) AvgLogs

--User log activity broken down into Infrequent, Consistent, and Frequent
SELECT 
  CASE 
    WHEN numOfLogs BETWEEN 0 AND 10 THEN 'Infrequent'
    WHEN numOfLogs BETWEEN 11 AND 20 THEN 'Consistent'
    WHEN numOfLogs BETWEEN 21 AND 31 THEN 'Frequent'
  END AS Frequency,
  COUNT(*) AS FrequencyCount
FROM 
  (
    SELECT 
      Id, 
      COUNT(*) AS numOfLogs
    FROM 
      CSBellabeat.dbo.newDailyActivity
    GROUP BY 
      Id
  ) AS subquery
GROUP BY 
  CASE 
    WHEN numOfLogs BETWEEN 0 AND 10 THEN 'Infrequent'
    WHEN numOfLogs BETWEEN 11 AND 20 THEN 'Consistent'
    WHEN numOfLogs BETWEEN 21 AND 31 THEN 'Frequent'
  END
ORDER BY 
  FrequencyCount;
--on average users logged 26 times during the month of data collection with most users being frequent users

--Average activity of each frequency category for each activity column
SELECT Frequency,
   COUNT(*) AS FrequencyCount,
   AVG(Steps) AS AvgSteps,
   AVG(VeryActiveMinutes) AS AvgVeryActiveMinutes,
   AVG(FairlyActiveMinutes) AS AvgFairlyActiveMinutes,
   AVG(LightlyActiveMinutes) AS AvgLightlyActiveMinutes,
   AVG(SedentaryMinutes) AS AvgSedentaryMinutes,
   AVG(Calories) AS AvgCalories
FROM (
   SELECT ID,
       CASE
         WHEN COUNT(*) BETWEEN 0 AND 10 THEN 'Infrequent'
         WHEN COUNT(*) BETWEEN 11 AND 20 THEN 'Consistent'
         WHEN COUNT(*) BETWEEN 21 AND 31 THEN 'Frequent'
       END AS Frequency,
       AVG(nTotalSteps) AS Steps,
       AVG(nVeryActiveMinutes) AS VeryActiveMinutes,
       AVG(nFairlyActiveMinutes) AS FairlyActiveMinutes,
       AVG(nLightlyActiveMinutes) AS LightlyActiveMinutes,
       AVG(nSedentaryMinutes) AS SedentaryMinutes,
       AVG(nCalories) AS Calories
   FROM CSBellabeat.dbo.newDailyActivity
   GROUP BY ID
) AS sum
GROUP BY Frequency
ORDER BY FrequencyCount;


