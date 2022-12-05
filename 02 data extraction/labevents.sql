with ugib as (
	select subject_id, hadm_id, stay_id, intime, outtime from yizhi.ugib
)

, base_excess_raw_hosp as (
	select hadm_id, itemid, charttime as base_excess_time, valuenum as base_excess_val
	from mimiciv_hosp.labevents
	where itemid = 50802 and hadm_id is not null
)
, base_excess_raw_icu as (
	select hadm_id, itemid, charttime as base_excess_time, valuenum as base_excess_val
	from mimiciv_icu.chartevents
	where itemid = 224828 and hadm_id is not null
)

, base_excess_stg0 as (
	select *
	from ugib 
	left join base_excess_raw_hosp using(hadm_id)
	-- where base_excess_time <= (intime + interval '24' hour)
	
	union all
	
	select *
	from ugib 
	left join base_excess_raw_icu using(hadm_id)
	-- where base_excess_time <= (intime + interval '24' hour)
	
	order by subject_id, hadm_id, stay_id, base_excess_time
)
, base_excess_stg1 as (
	select *, row_number() over (partition by hadm_id order by base_excess_time) as n
	from base_excess_stg0
	
)
, base_excess as (
	select hadm_id, base_excess_time, base_excess_val 
	from base_excess_stg1
	where n = 1
)

, ph_raw_hosp as (
	select hadm_id, itemid, charttime as ph_time, valuenum as ph_val
	from mimiciv_hosp.labevents
	where itemid = 50820 and hadm_id is not null
)
, ph_raw_icu as (
	select hadm_id, itemid, charttime as ph_time, valuenum as ph_val
	from mimiciv_icu.chartevents
	where itemid in (220274, 223830) and hadm_id is not null
)

, ph_stg0 as (
	select *
	from ugib 
	left join ph_raw_hosp using(hadm_id)
	-- where ph_time <= (intime + interval '24' hour)
	
	union all
	
	select *
	from ugib 
	left join ph_raw_icu using(hadm_id)
	-- where ph_time <= (intime + interval '24' hour)
	
	order by subject_id, hadm_id, stay_id, ph_time
)
, ph_stg1 as (
	select *, row_number() over (partition by hadm_id order by ph_time) as n
	from ph_stg0
	
)
, ph as (
	select hadm_id, ph_time, ph_val 
	from ph_stg1
	where n = 1
)

, hemoglobin_raw_hosp as (
	select hadm_id, itemid, charttime as hemoglobin_time, valuenum as hemoglobin_val
	from mimiciv_hosp.labevents
	where itemid in (50811, 51640, 51222, 52129, 51645, 52157) and hadm_id is not null
)
, hemoglobin_raw_icu as (
	select hadm_id, itemid, charttime as hemoglobin_time, valuenum as hemoglobin_val
	from mimiciv_icu.chartevents
	where itemid in (220228) and hadm_id is not null
)

, hemoglobin_stg0 as (
	select *
	from ugib 
	left join hemoglobin_raw_hosp using(hadm_id)
	-- where hemoglobin_time <= (intime + interval '24' hour)
	
	union all
	
	select *
	from ugib 
	left join hemoglobin_raw_icu using(hadm_id)
	-- where hemoglobin_time <= (intime + interval '24' hour)
	
	order by subject_id, hadm_id, stay_id, hemoglobin_time
)
, hemoglobin_stg1 as (
	select *, row_number() over (partition by hadm_id order by hemoglobin_time) as n
	from hemoglobin_stg0
	
)
, hemoglobin as (
	select hadm_id, hemoglobin_time, hemoglobin_val 
	from hemoglobin_stg1
	where n = 1
)

, lactate_raw as (
	select hadm_id, itemid, charttime as lactate_time, valuenum as lactate_val
	from mimiciv_hosp.labevents
	where itemid in (50813, 52442) and hadm_id is not null
)
, lactate_stg0 as (
	select *, row_number() over (partition by hadm_id order by lactate_time) as n
	from ugib 
	left join lactate_raw using(hadm_id)
	-- where lactate_time <= (intime + interval '24' hour)
	order by subject_id, hadm_id, stay_id, lactate_time
)
, lactate as (
	select hadm_id, lactate_time, lactate_val 
	from lactate_stg0
	where n = 1
)

, pt_raw_hosp as (
	select hadm_id, itemid, charttime as pt_time, valuenum as pt_val
	from mimiciv_hosp.labevents
	where itemid in (51274, 52921, 52164) and hadm_id is not null
)
, pt_raw_icu as (
	select hadm_id, itemid, charttime as pt_time, valuenum as pt_val
	from mimiciv_icu.chartevents
	where itemid = 220560 and hadm_id is not null
)

, pt_stg0 as (
	select *
	from ugib 
	left join pt_raw_hosp using(hadm_id)
	-- where pt_time <= (intime + interval '24' hour)
	
	union all
	
	select *
	from ugib 
	left join pt_raw_icu using(hadm_id)
	-- where pt_time <= (intime + interval '24' hour)
	
	order by subject_id, hadm_id, stay_id, pt_time
)
, pt_stg1 as (
	select *, row_number() over (partition by hadm_id order by pt_time) as n
	from pt_stg0
	
)
, pt as (
	select hadm_id, pt_time, pt_val 
	from pt_stg1
	where n = 1
)

, ptt_raw_hosp as (
	select hadm_id, itemid, charttime as ptt_time, valuenum as ptt_val
	from mimiciv_hosp.labevents
	where itemid in (51275, 52923) and hadm_id is not null
)
, ptt_raw_icu as (
	select hadm_id, itemid, charttime as ptt_time, valuenum as ptt_val
	from mimiciv_icu.chartevents
	where itemid in (220562, 227466) and hadm_id is not null
)

, ptt_stg0 as (
	select *
	from ugib 
	left join ptt_raw_hosp using(hadm_id)
	-- where ptt_time <= (intime + interval '24' hour)
	
	union all
	
	select *
	from ugib 
	left join ptt_raw_icu using(hadm_id)
	-- where ptt_time <= (intime + interval '24' hour)
	
	order by subject_id, hadm_id, stay_id, ptt_time
)
, ptt_stg1 as (
	select *, row_number() over (partition by hadm_id order by ptt_time) as n
	from ptt_stg0
	
)
, ptt as (
	select hadm_id, ptt_time, ptt_val 
	from ptt_stg1
	where n = 1
)
, inr_raw_hosp as (
	select hadm_id, itemid, charttime as inr_time, valuenum as inr_val
	from mimiciv_hosp.labevents
	where itemid in (51237, 51675) and hadm_id is not null
)
, inr_raw_icu as (
	select hadm_id, itemid, charttime as inr_time, valuenum as inr_val
	from mimiciv_icu.chartevents
	where itemid in (220561, 227467) and hadm_id is not null
)

, inr_stg0 as (
	select *
	from ugib 
	left join inr_raw_hosp using(hadm_id)
	-- where inr_time <= (intime + interval '24' hour)
	
	union all
	
	select *
	from ugib 
	left join inr_raw_icu using(hadm_id)
	-- where inr_time <= (intime + interval '24' hour)
	
	order by subject_id, hadm_id, stay_id, inr_time
)
, inr_stg1 as (
	select *, row_number() over (partition by hadm_id order by inr_time) as n
	from inr_stg0
	
)
, inr as (
	select hadm_id, inr_time, inr_val 
	from inr_stg1
	where n = 1
)

, urea_nitrogen_raw_hosp as (
	select hadm_id, itemid, charttime as urea_nitrogen_time, valuenum as urea_nitrogen_val
	from mimiciv_hosp.labevents
	where itemid in (51006) and hadm_id is not null
)
, urea_nitrogen_raw_icu as (
	select hadm_id, itemid, charttime as urea_nitrogen_time, valuenum as urea_nitrogen_val
	from mimiciv_icu.chartevents
	where itemid in (225624) and hadm_id is not null
)

, urea_nitrogen_stg0 as (
	select *
	from ugib 
	left join urea_nitrogen_raw_hosp using(hadm_id)
	-- where urea_nitrogen_time <= (intime + interval '24' hour)
	
	union all
	
	select *
	from ugib 
	left join urea_nitrogen_raw_icu using(hadm_id)
	-- where urea_nitrogen_time <= (intime + interval '24' hour)
	
	order by subject_id, hadm_id, stay_id, urea_nitrogen_time
)
, urea_nitrogen_stg1 as (
	select *, row_number() over (partition by hadm_id order by urea_nitrogen_time) as n
	from urea_nitrogen_stg0
	
)
, urea_nitrogen as (
	select hadm_id, urea_nitrogen_time, urea_nitrogen_val 
	from urea_nitrogen_stg1
	where n = 1
)

, creatinine_raw_hosp as (
	select hadm_id, itemid, charttime as creatinine_time, valuenum as creatinine_val
	from mimiciv_hosp.labevents
	where itemid in (50912) and hadm_id is not null
)
, creatinine_raw_icu as (
	select hadm_id, itemid, charttime as creatinine_time, valuenum as creatinine_val
	from mimiciv_icu.chartevents
	where itemid in (220615, 229761) and hadm_id is not null
)

, creatinine_stg0 as (
	select *
	from ugib 
	left join creatinine_raw_hosp using(hadm_id)
	-- where creatinine_time <= (intime + interval '24' hour)
	
	union all
	
	select *
	from ugib 
	left join creatinine_raw_icu using(hadm_id)
	-- where creatinine_time <= (intime + interval '24' hour)
	
	order by subject_id, hadm_id, stay_id, creatinine_time
)
, creatinine_stg1 as (
	select *, row_number() over (partition by hadm_id order by creatinine_time) as n
	from creatinine_stg0
	
)
, creatinine as (
	select hadm_id, creatinine_time, creatinine_val 
	from creatinine_stg1
	where n = 1
)

, platelet_count_raw_hosp as (
	select hadm_id, itemid, charttime as platelet_count_time, valuenum as platelet_count_val
	from mimiciv_hosp.labevents
	where itemid in (51704, 51265) and hadm_id is not null
)
, platelet_count_raw_icu as (
	select hadm_id, itemid, charttime as platelet_count_time, valuenum as platelet_count_val
	from mimiciv_icu.chartevents
	where itemid in (225170, 227457) and hadm_id is not null
)

, platelet_count_stg0 as (
	select *
	from ugib 
	left join platelet_count_raw_hosp using(hadm_id)
	-- where platelet_count_time <= (intime + interval '24' hour)
	
	union all
	
	select *
	from ugib 
	left join platelet_count_raw_icu using(hadm_id)
	-- where platelet_count_time <= (intime + interval '24' hour)
	
	order by subject_id, hadm_id, stay_id, platelet_count_time
)
, platelet_count_stg1 as (
	select *, row_number() over (partition by hadm_id order by platelet_count_time) as n
	from platelet_count_stg0
	
)
, platelet_count as (
	select hadm_id, platelet_count_time, platelet_count_val 
	from platelet_count_stg1
	where n = 1
)

, bilirubin_raw_hosp as (
	select hadm_id, itemid, charttime as bilirubin_time, valuenum as bilirubin_val
	from mimiciv_hosp.labevents
	where itemid in (53089, 50885) and hadm_id is not null
)
, bilirubin_raw_icu as (
	select hadm_id, itemid, charttime as bilirubin_time, valuenum as bilirubin_val
	from mimiciv_icu.chartevents
	where itemid in (225690) and hadm_id is not null
)

, bilirubin_stg0 as (
	select *
	from ugib 
	left join bilirubin_raw_hosp using(hadm_id)
	-- where bilirubin_time <= (intime + interval '24' hour)
	
	union all
	
	select *
	from ugib 
	left join bilirubin_raw_icu using(hadm_id)
	-- where bilirubin_time <= (intime + interval '24' hour)
	
	order by subject_id, hadm_id, stay_id, bilirubin_time
)
, bilirubin_stg1 as (
	select *, row_number() over (partition by hadm_id order by bilirubin_time) as n
	from bilirubin_stg0
	
)
, bilirubin as (
	select hadm_id, bilirubin_time, bilirubin_val 
	from bilirubin_stg1
	where n = 1
)

, albumin_raw_hosp as (
	select hadm_id, itemid, charttime as albumin_time, valuenum as albumin_val
	from mimiciv_hosp.labevents
	where itemid in (53085, 50862, 52022, 53138) and hadm_id is not null
)
, albumin_raw_icu as (
	select hadm_id, itemid, charttime as albumin_time, valuenum as albumin_val
	from mimiciv_icu.chartevents
	where itemid in (227456) and hadm_id is not null
)

, albumin_stg0 as (
	select *
	from ugib 
	left join albumin_raw_hosp using(hadm_id)
	-- where albumin_time <= (intime + interval '24' hour)
	
	union all
	
	select *
	from ugib 
	left join albumin_raw_icu using(hadm_id)
	-- where albumin_time <= (intime + interval '24' hour)
	
	order by subject_id, hadm_id, stay_id, albumin_time
)
, albumin_stg1 as (
	select *, row_number() over (partition by hadm_id order by albumin_time) as n
	from albumin_stg0
	
)
, albumin as (
	select hadm_id, albumin_time, albumin_val 
	from albumin_stg1
	where n = 1
)
select * 
from ugib
left join base_excess using(hadm_id)
left join ph using(hadm_id)
left join hemoglobin using(hadm_id)
left join lactate using(hadm_id)
left join pt using(hadm_id)
left join ptt using(hadm_id)
left join inr using(hadm_id)
left join urea_nitrogen using(hadm_id)
left join creatinine using(hadm_id)
left join platelet_count using(hadm_id)
left join bilirubin using(hadm_id)
left join albumin using(hadm_id)