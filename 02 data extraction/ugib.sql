-- create table yizhi.ugib as
with ugib_raw as (
  select subject_id, stay_id
  from mimiciv_ed.diagnosis
	--from mimiciv_hosp.diagnoses_icd
  where 1=1
	and (icd_version = 9 and 
  (icd_code like ('5310%') or
  icd_code like ('5312%') or
  icd_code like ('5314%') or
  icd_code like ('5316%') or
  icd_code like ('5320%') or
  icd_code like ('5322%') or
  icd_code like ('5324%') or
  icd_code like ('5326%') or
  icd_code like ('5330%') or
  icd_code like ('5332%') or
  icd_code like ('5334%') or
  icd_code like ('5336%') or
  icd_code like ('5340%') or
  icd_code like ('5342%') or
  icd_code like ('5344%') or
  icd_code like ('5346%') or
  icd_code like ('5780%') or
  icd_code like ('5781%') or
  icd_code like( '5789%')
	))
	or 
	(icd_version = 10 and 
  	(
    -- ICD 10 codes for upper gastrointestinal bleeding 
    lower(icd_code) like('k920%') or
    lower(icd_code) like('k921%') or
    lower(icd_code) like('i850%') or
    lower(icd_code) like('i9820%') or
    lower(icd_code) like('i983%') or
    lower(icd_code) like('k2210%') or
    lower(icd_code) like('k2212%') or
    lower(icd_code) like('k2214%') or
    lower(icd_code) like('k2216%') or
    lower(icd_code) like('k250%') or
    lower(icd_code) like('k252%') or
    lower(icd_code) like('k254%') or
    lower(icd_code) like('k256%') or
    lower(icd_code) like('k260%') or
    lower(icd_code) like('k262%') or
    lower(icd_code) like('k264%') or
    lower(icd_code) like('k266%') or
    lower(icd_code) like('k270%') or
    lower(icd_code) like('k272%') or
    lower(icd_code) like('k274%') or
    lower(icd_code) like('k276%') or
    lower(icd_code) like('k280%') or
    lower(icd_code) like('k282%') or
    lower(icd_code) like('k284%') or
    lower(icd_code) like('k286%') or
    lower(icd_code) like('k290%') or
    lower(icd_code) like('k6380%') or
    lower(icd_code) like('k3180%')
	  )
  )
)
, ugib_stg0 as (
	select subject_id, hadm_id, stay_id, intime, outtime, gender, race
	from ugib_raw
	left join edstays using(subject_id, stay_id)
	where hadm_id is not null
)
, ugib_stg1 as (
	select subject_id, hadm_id, stay_id, intime, outtime, gender, race, age  
	from ugib_stg0
	left join mimiciv_derived.age using (subject_id, hadm_id)
)
, ugib as (
	select distinct * from ugib_stg1
)


, transfusion_raw as (
	-- icu transfusion
	select hadm_id, starttime 
	from mimiciv_icu.procedureevents
	where itemid in (229620) -- massive transfusion
	union all
	select hadm_id, starttime
	from mimiciv_icu.inputevents
	where itemid in (225168, 221013, 227070, 225168, 226368)
	union all
	
	-- hosp transfusion (no time just date)
	select  hadm_id, chartdate
	from mimiciv_hosp.procedures_icd
	where icd_code ilike('990%') or icd_code ilike('%30233n1%')
)
, transfusion as (
	select hadm_id, min(starttime) as trans_time -- if trans_time is not null then have transfusion
	from transfusion_raw
	group by hadm_id
)
, final as (
	select *, case when trans_time is not null then 1 else 0 end as trans 
	from ugib
	left join transfusion using(hadm_id)
)
select * from final 

