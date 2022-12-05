create table yizhi.transfusion as
with transfusion as (
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
select hadm_id, min(starttime) as trans_time -- if trans_time is not null then have transfusion
from transfusion
group by hadm_id






