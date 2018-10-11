SELECT 
	SPatient.PatientSSN,
	COUNT(SPatient.PatientSSN) AS OutpatientEncounterInYear
FROM
	LSV.BISL_R1VX.AR3Y_SPatient_SPatient AS SPatient
	INNER JOIN LSV.BISL_R1VX.AR3Y_Outpat_Visit AS Visit
		ON SPatient.PatientSID = Visit.PatientSID
		AND SPatient.Sta3n = Visit.Sta3n
	LEFT JOIN LSV.Dim.StopCode AS DimStopCode
		ON Visit.PrimaryStopCodeSID = DimStopCode.StopCodeSID
		AND Visit.Sta3n = DimStopCode.Sta3n
	INNER JOIN LSV.Outpat.Problemlist AS ProblemList 
		ON Visit.PatientSID = ProblemList.PatientSID
		AND Visit.Sta3n = ProblemList.Sta3n
	INNER JOIN LSV.Dim.ICD10 AS DimICD10
		ON ProblemList.ICD10SID = DimICD10.ICD10SID
		AND ProblemList.Sta3n = DimICD10.Sta3n
WHERE
	SPatient.Sta3n = '612'
	AND DimStopCode.StopCode = '415'
	AND DimICD10.ICD10Code LIKE '%I71.[4,9]%'
	AND Visit.VisitDateTime >= CONVERT(Datetime2(0), DATEADD(YEAR, -1, GETDATE()))
	AND SPatient.PatientName not like 'ZZ%'
	AND SPatient.DeceasedFlag != 'Y'
GROUP BY
	SPatient.PatientSSN
ORDER BY
	SPatient.PatientSSN
