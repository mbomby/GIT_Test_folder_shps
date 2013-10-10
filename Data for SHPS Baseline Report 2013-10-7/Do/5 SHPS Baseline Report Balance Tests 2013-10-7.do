

*SHPS baseline report - simplified balance checks

/*
	clear all
	set mem 800m
	set maxvar 10000
	version 10.1
*/
	set more off

********************************************************************************

*This do-file was created by IPA-Mongolia for use in the MCA-M Property Rights Project
	
	
********************************************************************************
*Global Variables
********************************************************************************

	*global data_path "C:\IPA\2Urban\Reports & Analysis\SHPS Baseline Report\Revision Sept 2013\Data for SHPS Baseline Report 2013-10-7/SHPS_Temp_Cleaned.dta"
	global outpath "C:\IPA\2Urban\Reports & Analysis\SHPS Baseline Report\Revision Sept 2013"
	
*Format for all numeric output (needed for the program to work)
	global strformat "%9.2f"
	
	
	
********************************************************************************
*Programs
********************************************************************************

*Format Output for Tables: program "sig_p"

*NOTE: this requires the strformat global to be defined

		capture program drop sig_p 
		program sig_p 
		   args obj_var point_est_var point_sd_var p_val row_id_var row_num 
		   local point_est `point_est_var' 
		   local point_sd `point_sd_var' 
		   if `p_val' > 0.1 { 
			  replace `obj_var' = string(`point_est', "$strformat") if `row_id_var' == `row_num' 
			  } 
		   if `p_val' > 0.05 & `p_val' <= 0.1  { 
			  replace `obj_var' = string(`point_est', "$strformat")+"*" if `row_id_var' == `row_num' 
			  } 
		   if `p_val' > 0.01 & `p_val' <= 0.05  { 
			  replace `obj_var' = string(`point_est', "$strformat")+"**" if `row_id_var' == `row_num' 
			  } 
		   if `p_val' <= 0.01 { 
			  replace `obj_var' = string(`point_est', "$strformat")+"***" if `row_id_var' == `row_num' 
			  } 
		   *replace `obj_var' = "<" + string(`point_sd', "$strformat") + ">" + " " if `row_id_var' == `row_num' + 1 
		   replace `obj_var' = string(`point_sd', "$strformat")  if `row_id_var' == `row_num' + 1 

		end 
		
		
********************************************************************************
*Load and process dataset
********************************************************************************

	*use "${data_path}", replace

	
	
********************************************************************************
*Create secondary variables and recode existing variables for analysis
********************************************************************************

	*d. HH head Residential Status 2.16: 
	*hh_head_permanent
		gen hh_head_permanent=hh_head_resstatus==1

	*Attempted sales
	*sale_attempt
		gen sale_attempt=q10_1
		replace sale_attempt="1" if sale_attempt=="Y"
		replace sale_attempt="0" if sale_attempt=="N"
		destring sale_attempt, replace
		replace sale_attempt=.d if sale_attempt==8888
		replace sale_attempt=.r if sale_attempt==9999
		label val sale_attempt yesno		
		
	*Create dummy variables for registration status
	*full_reg -- now "title", defined in 4a
	*owner_cert -- now "partial_reg", defined in 4a
	
			
	*Total income from all sources 
	*tot_inc -- now "hh_inc_total", defined in 4b
		
	*Now we want total value of structures on the hashaa, q4_21_*
	*struct_value -- now "struct_val", defined in 4b
		
		
	*Section 5: investments. We'll just summarize the total value of investments planned
	*ON THE HASHAA
	*total_invest_5yr -- now "total_invest_plan", defined in 4b
	
	*Land disputes	
	*total_dispute	
		cap drop total_dispute
		gen total_dispute=q9_2
		replace total_dispute=0 if q9_1=="N"
	
	*av_ownership4	--defined in 4b // this was used for matching hesegs based on similar initial levels of 
		*registration during the randomization.

	
*Dummy variable coefficients (and proportions) are easier to report if they are in percentages, so we'll multiply by 100

	foreach var in hh_head_male hh_head_married hh_head_permanent sale_attempt title partial_reg av_ownership4 {
		replace `var'=`var'*100
	}

	
********************************************************************************
*Define the list of variables to check
********************************************************************************

	#delimit ;
	
	global balancevars
		
	hh_head_male
	hh_head_married

	hh_head_edyrs
	hh_head_permanent
	sale_attempt
	title
	partial_reg
	
	hh_head_age
	hh_size
	hh_inc_total
	hh_employed 

	hashaa_value
	hashaa_area
	hashaa_price_msq
	struct_val
	
	struct_invest 
	land_invest 
	total_invest_plan	
	
	total_loans
	min_payment
	
	total_expendyr
	total_dispute
	
	av_ownership4;
	
	#delimit cr
	
	
*Check which ones exist
	foreach var of global balancevars {
		cap confirm var `var'
		if _rc!=0 di "`var' does not exist"
	}

	
/*
*Some basic balance tests

*Tests for project versus comparison // these print out means, difference, 95% CI

	*cap log close
	*log using "simple-ttest-shps" , text replace

	ttest av_ownership4 if genq , by(treatment) unequal
	
	set more off
	foreach var of global balancevars {
		qui ttest `var' , by(treatment) unequal
		local tval=invttail(r(df_t),.025)
		loc pval: di %4.2f = r(p)
		di `"`var' `:di %14.3f = r(mu_2)' `:di %14.3f =r(mu_1)' `:di %14.3f =r(mu_2)-r(mu_1)' `:di %14.4f = r(p)' "' // "
	}
		
	*log close
*/
		
		/*
				local confhi: di %14.3f = r(mu_1)-r(mu_2)+`tval'*r(se)
		local conflo: di %14.3f = r(mu_1)-r(mu_2)-`tval'*r(se)
		*/
		
		
		
		
********************************************************************************
*Run the balance test regressions
********************************************************************************


	set more off 
	local row = 1 
	forvalues var = 0(1)60 { 
		cap drop col`var' 
	   qui gen col`var' = "" 
	   } 
	cap drop row_num 
	gen row_num=_n 


	
	set more off
	foreach var of global balancevars {
	
		qui replace col0 = "`var'" if row_num == `row' 
		
		qui summ `var'
		qui replace col1 = string(r(mean), "$strformat") if row_num == `row' 

		qui reg `var' treatment area, vce(cluster fin_heseg)  
		qui test treatment 
		qui sig_p col2 _b[treatment] _se[treatment] r(p) row_num `row' 

		local row = `row' + 2 
	}
	
	br col*
	sort row_num 
	outsheet col* using "${outpath}/shps balance test output_2013-10-7.csv" if row_num < `row', comma replace

			
			
			
			
			
			
			
			

*Variables:
/*	total_invest // plans in next five years
	total_collat // actually this is total loans
	min_payment
	hashaa_value // land value, only if price_msq<700
	hashaa_size // land size
	hashaa_price_msq
	hh_head_male
	hh_head_mar
	hh_head_educ // convert to years
	hh_head_resstatus
	hh_head_age
	hh_size
	hh_inc_tot
	hh_employed
	hashaa_value
	hashaa_area
	hashaa_price_msq
	struct_invest // in last year
	land_invest // in last year
	*registration status // q6_1 // need dummies
	//full_reg
	//any_reg
	total_expend30
	total_expendyr
	total_dispute
	// household assets, specifically value of buildings on hashaa
	struct_value
	// distance to city center
	// any attempted sales? sale_attempt
	full_reg
	any_reg */
	
	
	
	
			
			
			
			
			
