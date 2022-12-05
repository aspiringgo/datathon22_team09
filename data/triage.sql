with vital_raw as (
	select subject_id, hadm_id, stay_id, intime as charttime, heartrate, sbp, dbp 
	from yizhi.ugib
	left join mimiciv_ed.triage using(subject_id, stay_id)

	
	union all

	select subject_id, hadm_id, stay_id, charttime, heartrate, sbp, dbp
	from yizhi.vitalsign
	left join mimiciv_ed.edstays using(subject_id, stay_id)
	where hadm_id is not null
	
	order by subject_id, hadm_id, stay_id, charttime
)
, triage as (
	select *
	from vital_raw
	order by 
	subject_id, hadm_id, stay_id, charttime
)
select * from triage
where hadm_id is not null and subject_id = '10003019' and stay_id = '30480460'