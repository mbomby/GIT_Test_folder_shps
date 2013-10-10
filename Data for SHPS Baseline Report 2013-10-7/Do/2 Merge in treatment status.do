
	set more off
	
*Append and cut down treatment status files

	tempfile trt1 trt2 trt3 trt4 trt5

	insheet using "$treat/Darkhan_Treatment_Status Final - 01_24_12.out",clear
	save `trt1', replace
	
	insheet using "$treat/Erdenet_Treatment_Status Final - 01_24_12.out",clear
	save `trt2', replace
	
	insheet using "$treat/Bayanzurkh_Treatment_Status_06_04_2012.out",clear
	tostring cluster, replace
	replace cluster=gis_district+"_"+cluster
	rename fin_kheseg fin_heseg
	save `trt3', replace
	
	insheet using "$treat/Chingeltei_Treatment_Status - Final - 05_23_2012.out",clear
	tostring cluster, replace
	replace cluster=gis_district+"_"+cluster
	rename fin_kheseg fin_heseg
	save `trt4', replace
	
	insheet using "$treat/Songinokhairkhan_Treatment_Status - 06_22_2012.out",clear
	tostring cluster, replace
	replace cluster=gis_district+"_"+cluster
	rename fin_kheseg fin_heseg
	// we need to drop one kheseg that was included in two different randomizations by mistake 
	//and got two treatment statuses
	drop if fin_heseg=="CH-7-11k"
	
	save `trt5', replace


	use `trt1',clear
	append using `trt2'
	append using `trt3'
	append using `trt4'
	append using `trt5'
	
	compare pair triplet
	
	tostring pair, gen(pair2)
	tostring triplet, gen(trip2)
	gen match_id =cluster+"_"+pair2 if !mi(pair)
	replace match_id=cluster+"_"+trip2 if !mi(triplet)
	
	keep gis_district cluster pair num_in_pair odd_pair triplet num_in_triplet odd_triplet match_id treatment fin_heseg
	sort fin_heseg
	
	tempfile trt_status
	save  `trt_status',replace


*************************************************************************************************
	
/**********
*** Merge Treatment Status
**********/

*Note CH-7-11k is duplicated


*Merge treatment status
	use "temp/SHPS_GISsample_merged", clear
	sort fin_heseg
	merge fin_heseg using `trt_status', uniqusing
	
	tab _merge
	set more on
	more
	set more off
	rename _merge _trt_survey_merge
	
	save "temp/SHPS_MergedWithTrtStatus_PreCleaning.dta"
	


	
	
	
	