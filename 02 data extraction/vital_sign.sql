with vital_triagr_raw as (
	select subject_id, hadm_id, stay_id, intime as charttime, heartrate, sbp, dbp 
	from yizhi.ugib
	left join mimiciv_ed.triage using(subject_id, stay_id)
	order by subject_id, hadm_id, stay_id, intime
)
, vital_raw as (
	select subject_id, hadm_id, stay_id, charttime, heartrate, sbp, dbp
	from yizhi.vitalsign
	left join mimiciv_ed.edstays using(subject_id, stay_id)
	where hadm_id is not null
	order by subject_id, hadm_id, stay_id, charttime
)
, vital_raw1 as (
	select subject_id, hadm_id, stay_id, charttime, heartrate, sbp, dbp 
	from yizhi.ugib
	left join vital_raw using(subject_id, hadm_id, stay_id)
)
, vital_stg0 as (
	select * from vital_triagr_raw
	union all
	select * from vital_raw1
)


select *
from vital_stg0
order by subject_id, hadm_id, stay_id, charttime
