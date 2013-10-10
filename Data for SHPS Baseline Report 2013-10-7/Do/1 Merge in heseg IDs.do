
	set more off
	
********************************************************************************
*Prepare sampled datasets for merging** 

	
	tempfile d1 d2 e1 e2 ch bz skh
	
*Darkan 1
	insheet using "${gis}/Darkhan_Sample_1.out",clear
	keep target_fid district fin_kheseg horoo type 
	tostring target_fid, gen(target_fid2)
	replace target_fid2="DA-"+target_fid2
	sort target_fid2
	save `d1', replace
	
*Erdenet 1
	insheet using "${gis}/Erdenet_Sample_1.out",clear
	keep target_fid district fin_kheseg horoo type 
	tostring target_fid, gen(target_fid2)
	replace target_fid2="OR-"+target_fid2
	sort target_fid2
	save `e1', replace

*Darkhan 2
	insheet using "${gis}/Darkhan_Sample_12-15-11.out",clear
	keep target_fid district fin_kheseg horoo type 
	tostring target_fid, gen(target_fid2)
	replace target_fid2="DA-"+target_fid2
	sort target_fid2
	save `d2', replace
	
*Erdenet 2
	insheet using "${gis}/Erdenet_Sample_12-15-11.out",clear
	keep target_fid district fin_kheseg horoo type 
	tostring target_fid, gen(target_fid2)
	replace target_fid2="OR-"+target_fid2
	sort target_fid2
	save `e2', replace
	
*Chingeltei
	insheet using "${gis}/CH_Sample_12-15-11  - Final - 05_23_2012.txt" ,clear
	*keep target_fid district fin_kheseg horoo type 
	tostring target_fid, gen(target_fid2)
	replace target_fid2="CH-"+target_fid2
	sort target_fid2
	save `ch', replace 

*Bayanzurkh
	insheet using "${gis}/BZ_Sample_12-15-11_06_04_2012.txt" ,clear
	keep target_fid district fin_kheseg horoo type 
	tostring target_fid, gen(target_fid2)
	replace target_fid2="BZ-"+target_fid2
	sort target_fid2
	save `bz', replace 
	
*Songinokhairkhan
	insheet using "${gis}/SKH_Sample_12-15-11 - 06_22_2012.txt" ,clear
	*keep target_fid district fin_kheseg horoo type 
	tostring target_fid, gen(target_fid2)
	replace target_fid2="SKH-"+target_fid2
	sort target_fid2
	save `skh', replace 
	
	
*Load and append all these datasets
	use `d1', clear
	append using `e1'
	append using `d2'
	append using `e2'
	append using `ch'
	append using `bz'
	append using `skh'
	
	*We need to replace some plot ID's that should have been changed before merging (after communication with MEC)
	/* actually these are duplicates
	replace target_fid2="SKH-19237" if target_fid2=="CH-19237"
	replace target_fid2="SKH-19238" if target_fid2=="CH-19238"
	replace target_fid2="SKH-20088" if target_fid2=="CH-20088"
	drop if target_fid2=="OR-13301"
	*/
	drop if target_fid2=="OR-13301"
	drop if target_fid2=="CH-20088"
	drop if target_fid2=="CH-19238"
	drop if target_fid2=="CH-19237"
	
	
	sort target_fid2
	tempfile all_gis
	save `all_gis', replace
	

********************************************************************************
*Merge with SHPS dataset


*Load SHPS data
	use "Original/shps_baseline_pii_removed.dta" ,clear // This is the final dataset with all Districts/Cities appended
	drop if mi(target_id)

	/*
*A few ID's in SHSP were mis-entered, here are MEC's fixes:
no	fin_heseg	target_id	NO	Target ID	Fin_heseg
OR-8538-1B		8538	OR-8533-1B	8533	Erdenet_78
DA-1372-1B		1372	DA-1472-1B	1472	Darkhan_25
DA-3937-2B		3937	DA-1153-2B	1153	Darkhan_24


count if no=="DA-1372-1B"
count if no=="DA-3937-2B"
count if no=="OR-8533-1B"
count if no=="DA-1472-1B"
count if no=="DA-1153-2B"
*/

	replace no="DA-1472-1B" if no=="DA-1372-1B"
	replace target_id="1472" if no=="DA-1372-1B"
	replace no="DA-1153-2B" if no=="DA-3937-2B"
	replace target_id="1153" if no=="DA-3937-2B"
	

*Fix target_id // it lacks the district-prefix and is numeric in the sample datasets
	egen target_prefix=ends(no) , punct(-) head
	gen target_fid2=target_id
	replace target_fid2=target_prefix+"-"+target_fid2 if target_prefix=="DA" | target_prefix=="OR"

	rename  fin_heseg MEC_heseg 
	
	sort target_fid2
	

*Create a new status variable:
	cap drop status_simple
	gen status_simple="Completed" if inlist(status,"Completed","COMPLETED")
	replace status_simple="Refused" if inlist(status,"REFUSED","REFUSED HASHAA REGISTRATION","Refused to be interviewed","Refused to provide information")
	replace status_simple="Empty" if inlist(status,"EMPTY HASHAA","Empty hashaa","NO ONE STAYS IN HASHAA REGISTRATION ATTEMPTS")
	replace status_simple="Not present" if inlist(status,"NOT ALWAYS LIVE IN HASHAA","No one present at survey attempt","No one present at time of visit","Not always live occupant","SURVEY ATTEMPTS UNSUCCESSFUL")
	replace status_simple="Not valid plot" if inlist(status,"PUBLIC APARTMENT","COMPANY PROPERTY","DUPLICATED HASHAA OWNER")
	drop if status=="" // only one row, completely missing

	
		
*************************************************************************************************
*Now merge in the sampling data on plot id

	
	merge target_fid2 using `all_gis', uniqusing sort
	
	tab _merge
	set more on
	more
	rename _merge _gis_survey_merge
	
	rename fin_kheseg fin_heseg
	
	
	***************************************
	*Make a cut down dataset for checking the status of plots/ response rate
	preserve
	cap drop inelig_heseg
	gen inelig_heseg=0
	replace inelig_heseg=1 if inlist(fin_heseg,"Darkhan_101","Darkhan_102","Darkhan_103","Darkhan_104","Erdenet_86","Erdenet_87","Erdenet_102","Erdenet_103","SU-16-3" )
	cap drop dist
	gen dist=district
	replace dist="Darkhan" if mi(dist) & substr(no,1,2)=="DA"
	replace dist="Erdenet" if mi(dist) & substr(no,1,2)=="OR"
	replace dist="DA" if dist=="Darkhan"
	replace dist="ER" if dist=="Erdenet"
	keep no fin_heseg target_fid2 dist inelig_heseg status_simple status
	save "Final/Check_response_rate.dta", replace
	restore
	***************************************
	
	
	
**Drop Inelligible Khesegs** 
	drop if fin_heseg=="Darkhan_101" | fin_heseg=="Darkhan_102" | fin_heseg=="Darkhan_103" | fin_heseg=="Darkhan_104" 
	drop if fin_heseg=="Erdenet_86" | fin_heseg=="Erdenet_87" | fin_heseg=="Erdenet_102" | fin_heseg=="Erdenet_103" 

*For some reason, MEC interviewed a few plots that were actually located in SU District. These need to be 
*dropped as the project will not implement there 
	drop if fin_heseg=="SU-16-3" 
	
	tab _gis_survey_merge
	more
	set more off

	
	save "temp/SHPS_GISsample_merged.dta"
	
	
	


	
	