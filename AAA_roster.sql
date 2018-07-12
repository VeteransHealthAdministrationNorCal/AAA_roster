IF OBJECT_ID('tempdb..#rawData') IS NOT NULL 

DROP TABLE
  #rawData

SELECT 
  patient.PatientSSN,
  patient.PatientSID,
  patient.PatientFirstName,
  patient.PatientLastName,
  StopCode.StopCodeName,
  convert(varchar(10),VisitDateTime,101) AS VisitDate,
  PrimaryStopCodeSID,
  SecondaryStopCodeSID

INTO
  #rawData

FROM
  LSV.BISL_R1VX.AR3Y_Outpat_Visit AS visit
INNER JOIN LSV.dim.StopCode AS StopCode 
  ON visit.PrimaryStopCodeSID = StopCode.StopCodeSID
  AND visit.Sta3n = StopCode.Sta3n
INNER JOIN LSV.BISL_R1VX.AR3Y_SPatient_SPatient AS patient
  ON patient.PatientSID = visit.PatientSID

WHERE
  visit.Sta3n = '612'
  AND StopCode.StopCode = '415'
  AND visit.VisitDateTime >= CONVERT(Datetime2(0), DATEADD(YEAR, -1, GETDATE()))
  AND Patient.PatientLastName not like 'ZZ%'
  AND Patient.DeceasedFlag != 'Y'
ORDER BY
  patient.PatientSSN

SELECT
  a.PatientSSN,
  COUNT(a.PatientSSN) AS OutpatientEncounterInYear

FROM (
  SELECT DISTINCT
    t.PatientSSN,
    t.PatientFirstName,
    t.PatientLastName,
    t.VisitDate,
    icd10.ICD10code

  FROM
    #rawData AS t
    INNER JOIN LSV.Outpat.Problemlist AS pbl 
      ON pbl.PatientSID = t.PatientSID
    INNER JOIN LSV.dim.ICD10 AS icd10
      ON icd10.ICD10SID = pbl.ICD10SID
  
  WHERE
    icd10.ICD10Code LIKE '%I71.[4,9]%'
     ) AS a
  GROUP BY
    a.PatientSSN
  ORDER BY
    a.PatientSSN