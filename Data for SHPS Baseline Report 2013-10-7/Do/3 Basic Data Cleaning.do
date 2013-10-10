
	set more off
	
*This do-file was created by IPA-Mongolia for use in the MCA-M Property Rights Project

*Name: 05 Basic Data Cleaning.do
*Description: clean missing values, recode binary variables, and other data cleaning 
	*associated with the SHPS baseline survey.
	
*Created by: Matthew Bombyk
*Date Created: October 5, 2012
*Modified By (List all): MB
*Last modified by: Matthew Bombyk
*Date Last Modified: October 26, 2012

*Log of major changes:
	*

*Uses data: 
	*

*Creates data: 
	*
	*
	
	
********************************************************************************
*Notes and overview:

*SHPS comes as essentially a cross-sectional dataset with each plot as the unit of analysis. There is a
*slight deviation in that multiple individuals were sometimes interviewed at the same plot. I'll fill in the
*details when I get a better understanding. I'm also not sure how prevalent the double-interviews are,
*or if there are triple interviews.  -- REVIEW the completion report for info on this.

*"target_fid" and "q1_16" together uniquely identify respondents

*We need to redo the section in the appending do-file so that we don't erroneously make numeric
*variable into strings 

********************************************************************************
*Outline





********************************************************************************

	use "temp/SHPS_MergedWithTrtStatus_PreCleaning.dta",replace


/*
*Possible ID's:
	no // serial number
	q1_16 // status of residency
	target_id // I think this is the plot ID -- only 50 obs away from being a unique identifier
	status
	
*/



*********************************************************************************************
*Fun with labels!
	
	
*Drop ones that didn't match in the merging process, for now
	drop if _gis_survey_merge==1 | _gis_survey_merge==2
	
	
	

*Create value labels that will be used frequently
	cap label drop yesno
	label def yesno 1 "Yes" 0 "No" .a "Don't Know" .b "Refused to Answer" 
	label def dontknow .a "Don't Know" .b "Refused to Answer"
	
	*label def genderlab 0 "Female" 1 "Male" .a "Don't Know" .b "Refused to Answer"

	lab def sex 0 Female 1 Male .a "Don't Know" .b "Refused to Answer"
	

	
*********************************************************************************************
*Fix Data Entry Errors
*********************************************************************************************

/*
. edit q15_3_1_1 if  q15_3_1_1>3 &  q15_3_1_1<4
- preserve
- replace q15_3_1_1 = 3 in 5465


. edit q15_5 if  q15_5>1 &  q15_5<2
- preserve
- replace q15_5 = 1 in 3511

. edit q15_5 if  q15_5>2 &  q15_5<3
- preserve
- replace q15_5 = 2 in 1189
- replace q15_5 = 2 in 4214

. edit  q7_1
- preserve
- sort q7_1
- replace q7_1 = "Y" in 5813
*/



	
*********************************************************************************************
*Recode missing values
*********************************************************************************************


*List all vars that have 8888
	qui ds, not(type string)
	gl nonstrings `r(varlist)'
	qui ds, has(type string)
	gl strings `r(varlist)'

/*
	foreach var of global nonstrings {
		qui count if `var'==8888
		loc nn=r(N)
		qui inspect `var'
		loc un=r(N_unique)
		if `un'==5 {
			di `"`var' `nn' `un'"' 
		}
	}
*/

*I think the most effective way to do this is to first replace the 8888 and 9999 
*using the extended missing values, and then go back and determine for each variable
*whether it makes sense to have removed them. For example, look at whether the post-
*replacement distribution is entirely below 8888 or 88. That should get most. To begin
*with, and for the purpose of this exercise, code 88, 99, 8888, 9999 all separately.

*88 .a 
*99 .b
*8888 .c
*9999 .d


*Variables that have <10 categories are basically certain to have these as actual codes. 

*Max=9999 or 8888 or 88 or 99 are surefire bets. The only exception would be proportions,
*but those should be reasonably easy to identify. In particular, just pull out all the vars
*that have only values between 0 and 100 hmmm this will be a lot. 
*"

	gl max9999
	gl max8888
	gl max99
	gl max88
	foreach var of global nonstrings {
		foreach x in 88 99 8888 9999 {
			qui summ `var'
			if r(max)==`x' gl max`x' ${max`x'} `var'
		}
	}
		
		
		
		

	foreach var of varlist $max8888 $max9999 {
		mvdecode `var' , mv(8888=.a\9999=.b)
		loc labb : val l `var'
		loc donea : label (`var') .a , strict
		loc doneb : label (`var') .b , strict
		
		if "`labb'"!="" & ("`donea'"=="" | "`doneb'"=="") {
			*di "`labb'"
			lab def `labb' .a `"Don't Know"' .b `"Refused"' , modify // this just adds .a and .b compatibility to existing labels
		}
	}
		
		
		
*Ok now we need to do essentially the same thing for string variables. Must do this before recoding the Y/N
*vars below.
/*
	foreach var of global strings {
		qui levelsof `var', clean l(`var'm)
		loc eight "8888"
		loc nine "9999"
		loc with8 : list `var'm & eight
		loc with9 : list `var'm & nine
		if "`with8'"=="8888" di "`var' -- 8"
		if "`with9'"=="9999" di "`var' -- 9"
		
		*if "`with9'"=="9999" | "`with8'"=="8888" levelsof `var', clean
	}
	*/
	
	*This is manageable
		
		
		
		
		
*********************************************************************************************
*Recode binary variables
*********************************************************************************************
		
*Yes/No vars
/*	gl yesno 
	foreach var of global strings {
		qui levelsof `var' , clean l(`var'm)
		if "``var'm'"=="N Y" {
			*di "`var'"
			gl yesno $yesno `var'
		}
	}
*/
	#delimit;
	global yesno 
		q2_12_1
		q2_12_2
		q2_10_3
		q2_10_5
		q2_10_6
		q2_10_7
		q2_12_7
		q2_10_8
		q2_12_8
		q2_10_9
		q2_12_9
		q2_10_10
		q2_12_10
		q2_10_12
		q2_12_12
		q2_17_1
		q2_17_2
		q2_17_8
		q2_17_9
		q2_17_10
		q2_17_11
		q2_17_12
		q2_17_13
		q2_21_8
		q2_21_9
		q2_21_10
		q2_21_11
		q2_21_12
		q2_21_13
		q3_1_6
		q3_1_7
		q3_1_8
		q3_1_9
		q3_1_11
		q3_12_6
		q6_4
		q6_7
		q6_9
		q6_38_3
		q9_3_4_3
		q9_3_5_3
		q9_3_6_3
		q9_3_4_4
		q9_3_5_4
		q9_3_6_4
		q9_3_4_5
		q9_3_5_5
		q9_3_6_5
		q13_3_10_2
		q17_3_2_1
		q17_2_2
		q17_3_2_2
		q17_2_3
		q17_3_2_3
		q17_2_4
		q17_2_5 ;
	#delimit cr


	
	
	foreach var of global yesno {
		tempvar q
		gen `q'=.
		replace `q'=0 if `var'=="N"
		replace `q'=1 if `var'=="Y"
		drop `var'
		rename `q' `var'
		lab val `var' yesno
	}
		
*It looks like none of the yes/no variables are coded as numeric. (based on what?)

*We also have to deal with M/F which there are several of in this dataset. Note this version
*fails because there are some "don't know"s 
/*	gl sex
	foreach var of global strings {
		qui levelsof `var' , clean l(`var'm)
		if "``var'm'"=="F M" {
			*di "`var'"
			gl sex $sex `var'
		}
	}
	
	
	
	foreach var of global sex {
		tempvar q
		gen `q'=.
		replace `q'=0 if `var'=="F"
		replace `q'=1 if `var'=="M"
		drop `var'
		rename `q' `var'
		lab val `var' sex
	}
*/

	forvalues x=1/14 {
		gen sex`x'=.
		replace sex`x'=0 if q2_5_`x'=="F"
		replace sex`x'=1 if q2_5_`x'=="M"
		replace sex`x'=.a if q2_5_`x'=="8888"
		replace sex`x'=.b if q2_5_`x'=="9999"
		lab val sex`x' sex
		rename sex`x' q2_5_`x'_coded
	}
		
		


		

*generate a new plot id
	gen plot_id=target_fid2
	
*Drop incomplete surveys
*New variable indicating if an interview was completed
	cap drop complete
	gen complete=0
	replace complete=1 if status=="Completed" | status=="COMPLETED"
	
	*bys complete: tab has_owner has_resident, m
	*most have both, many have only resident, a few (78) have only owner
	*among complete interviews, all plots have either an owner or a resident (success!)
	*Using all residents will be the best option then, except for questions specifically dealing with owners
	
	drop if !complete
	
*q1_1 hashaa id is missing whenever the interview is not completed
*q1_2 household id is always missing
*Note that q1_16 gives codes for the relationship of the interviewee to the plot
*Code for 1.16: 
/*
1= Owns and reside on the hashaa: 
	1a: renting the space, 
	1b: not renting the space, 
2=Owns but not residing on the hashaa: 
	2a: renting the space, 
	2b: not renting the space, 
3= Does not own, but residing on land: 
	3a: paying rent, 
	3b: not paying rent  */
	
*Idea: sort by q1_16 and number the obs within a plot id, then tab out the resulting
*variable vs q1_16
	
*target_id status fin_heseg type -- need to get MEC to define these

*q6_1 indicates ownership status

*Section 6 owners only - part is only for those with a possession certificate, some with ownership cert, some with registration, some for those without
*Section 10 Residents only
*Q11.9, 11.10 resident only
*Section 17 community (resident only?)
	
/*
1a  1
1b  2
2a  3
2b  4
3a  5
3b  6
*/

	lab def res_status 1 "Owns and reside on the hashaa: renting the space" 2 "Owns and reside on the hashaa: not renting the space" ///
		3 "Owns but not residing on the hashaa: renting the space" 4 "Owns but not residing on the hashaa: not renting the space" ///
		5 "Does not own, but residing on land: paying rent" 6 "Does not own, but residing on land: not paying rent"
	
	gen res_status=.
	replace res_status=1 if q1_16=="1A"
	replace res_status=2 if q1_16=="1B"
	replace res_status=3 if q1_16=="2A"
	replace res_status=4 if q1_16=="2B"
	replace res_status=5 if q1_16=="3A"
	replace res_status=6 if q1_16=="3B"
	lab val res_status res_status

	*encode q1_16, gen(res_status) label(res_status)
	*replace res_status=.a if res_status==.

	gen hashaa_owner=0
	replace hashaa_owner=1 if inlist(q1_16,"1A","1B","2A","2B")



	
	
*1 dummy for an owner on the plot, 1 for a resident, and then a var giving combinations
	cap drop owner
	cap drop resident
	cap drop has_owner
	cap drop has_resident
	gen owner=0
	replace owner=1 if res_status==1 | res_status==2 | res_status==3 | res_status==4
	gen resident=0
	replace resident=1 if res_status==1 | res_status==2 | res_status==5 | res_status==6
	
	/*
	bys plot_id: egen has_owner=total(owner)
	cap drop has_owner2
	gen has_owner2=has_owner>0
	bys plot_id: egen has_resident=total(resident)
	cap drop has_resident2
	gen has_resident2=has_resident>0
	
*How many plots have >1 respondent?
	cap drop plotdup
	duplicates tag plot_id, gen(plotdup)
	
	cap drop tag
	egen tag=tag(plot_id)
	
*Do this stuff by plot:
	bys plotdup: tab has_owner2 has_resident2 if tag , m
	*This gives us everything we need
	
	*Of the 5722 plots:
	
	*860 resident only
	*70 owner only
	*4701 resident & owner are same
	*91 resident & owner are different
	
*Tag the obs to use for resident-analysis:

*Tag obs to use for owner-analysis:
	

*There are 4 plots that have owner-residents and someone else:
	*SKH-8406
	*OR-9211
	*OR-12561
	*CH-2539
	
	br if plot_id==SKH-8406
	
	*there are a handful of non-owners with data on q6, but it is very few
	*some (more than a few) nonresidents have data on q10, but I'll check to see what the final number is since there are only 3 questions
	*/
	
	
*Okay I'm ready to make three variables: one for respondents to use for general questions, 
*one for resident-only questions, one for owner-only questions.
*For now, residents will take priority for the general questions.
	cap drop genq
	cap drop priority
	cap drop pri
	gen priority=1 if res_status==1 | res_status==2
	replace priority=3 if inlist(res_status,3,4)
	replace priority=2 if inlist(res_status,5,6)
	duplicates report priority plot_id // no duplicates, so we have a unique ordering
	bys plot_id: egen pri=min(priority)
	gen genq=0
	replace genq=1 if pri==priority
	drop priority pri
	count if genq // 5722 which is right
	
	cap drop ownq
	cap drop priority
	cap drop pri
	gen priority=1 if res_status==1 | res_status==2
	replace priority=2 if inlist(res_status,3,4)
	replace priority=3 if inlist(res_status,5,6)
	duplicates report priority plot_id // no duplicates, so we have a unique ordering
	bys plot_id: egen pri=min(priority)
	gen ownq=0
	replace ownq=1 if pri==priority
	replace ownq=0 if !owner
	drop priority pri
	count if ownq // 4862 which is right
	
	cap drop residq
	cap drop priority
	cap drop pri
	gen priority=1 if res_status==1 | res_status==2
	replace priority=3 if inlist(res_status,3,4)
	replace priority=2 if inlist(res_status,5,6)
	duplicates report priority plot_id // no duplicates, so we have a unique ordering
	bys plot_id: egen pri=min(priority)
	gen residq=0
	replace residq=1 if pri==priority
	replace residq=0 if !resident
	drop priority pri
	count if residq // 5652 which is right
	
		
		
*Add some notes:
	notes _dta: ID Variables: "no" (respondent), "plot_id" (plot), "fin_heseg" (heseg)
	notes _dta: Sample Variables: "genq" (general questions), "residq" (resident-specific questions), "ownq" (owner-specific questions)
	notes _dta: Section 6 - Owners only, separated into: no certificate, possession certificate, ownership cert., full registration
	notes _dta: Section 10 - Residents only
		
		
*Since these string loops take forever to run, save the dataset at this point
	save "Final/SHPS_Temp_Cleaned.dta", replace


		
		
*Modify and add labels
	*q11_8 needs this label:
	/* 1=Owned by a member of the respondent household 
2=Owned by an individual outside the respondent household 
3=State/Government owned 
*/

	















