
	set more off

**********************************************************                          
*MAIN REPORT
************************************************************************************

*************Table 1. Targeted and Actual Sample
***************************************
	
	*this actually requires a fuller version of the dataset without the incomplete interviews
	*dropped out. One is now created in the SHPS cleaning process.
                          
	
*************Table 2. Basic Demographic Information on Heads of Households
***************************************
	
	*Sex of Household Head male = 1, female = 0
		*## q2_5_* 8888/9999 - needs to be changed; added var label; also what are vars q2_15_*_coded?
		*## 100% of hh heads from darkhan and erdenet are female and the rest are coded as 8888 - so weird!!! bring up with MEC
		gen hh_head_male = .
		lab var hh_head_male "Sex of household head"
		forvalues i = 1(1)14 {
			replace q2_5_`i' = "0" if q2_5_`i' == "F" | q2_5_`i' == "f"
			replace q2_5_`i' = "1" if q2_5_`i' == "M" | q2_5_`i' == "m"
			destring q2_5_`i', replace
			replace q2_5_`i' = .d if q2_5_`i' == 8888
			replace q2_5_`i' = .r if q2_5_`i' == 9999
			replace q2_5_`i' = 1 if q2_5_`i'==.d & ( district=="Erdenet" | district=="Darkhan" )
			label val q2_5_`i' sex
			replace hh_head_male = q2_5_`i' if q2_4_`i' == 1
		}
		label val hh_head_male sex

	*HH Head Marital Status 2.9
		*## var q2_9_3 has the option "8" which doesnt exist. there are only 6 options in the survey.
		label def marlab 1 "Not married" 2 "Officially married" 3 "Non-married partners" 4 "Separated" 5 "Divorced" 6 "Widowed" .d "Don't Know" .r "Refused to Answer"
		gen hh_head_mar = .
		forvalues i = 1(1)13 {
			replace q2_9_`i' = .d if q2_9_`i' == 8888
			replace q2_9_`i' = .r if q2_9_`i' == 9999
			label val q2_9_`i' marlab 
			replace hh_head_mar = q2_9_`i' if q2_4_`i' == 1
		}
		label val hh_head_mar marlab
		gen hh_head_married=hh_head_mar
		replace hh_head_married=0 if inlist(hh_head_married,1,3,4,5,6)
		replace hh_head_married=1 if hh_head_married==2

	*Migration HH head lived in current home since birth
		*## q2_17_* not formatted the same way. some are numeric with numbers while some are str. 9999, 8888, "y", "n" all possible options
		*## q2_17_* are not ordered numerically in the variable window of stata
		*## following variables are entered as "Y" "N" as string: q2_17_3 q2_17_4 q2_17_5 q2_17_6 q2_17_7 q2_17_14
		*## following variabels are entered as 1, 0 numerically: q2_17_1 q2_17_2 q2_17_8 q2_17_9 q2_17_10 q2_17_11 q2_17_12 q2_17_13
		gen hh_head_lasthome = .
		global lasthome_vars_str "q2_17_3 q2_17_4 q2_17_5 q2_17_6 q2_17_7 q2_17_14"
		global lasthome_vars_num "q2_17_1 q2_17_2 q2_17_8 q2_17_9 q2_17_10 q2_17_11 q2_17_12 q2_17_13"
		foreach var in $lasthome_vars_str {
			replace `var' = "1" if `var' == "Y" | `var' == "y"
			replace `var' = "0" if `var' == "N" | `var' == "n"
			destring `var', replace
			replace `var' = .d if `var' == 8888
			replace `var' = .r if `var' == 9999
			label val `var' yesno
		}
		forvalues i = 1(1)14 {
			replace q2_17_`i' = .d if q2_17_`i'==8888
			replace q2_17_`i' = .r if q2_17_`i'==9999
			replace hh_head_lasthome = q2_17_`i' if q2_4_`i' == 1
		}
		label val hh_head_lasthome yesno

	*Age of HH Head
		*## 
		gen hh_head_age = .
		forvalues i = 1(1)14 {
			replace q2_6_`i' = .d if q2_6_`i' == 8888
			replace q2_6_`i' = .r if q2_6_`i' == 9999
			replace hh_head_age = 2012 - q2_6_`i' if q2_4_`i' == 1
		}

	*Mean # of HH members (HH size)
		egen hh_size=rownonmiss(q2_3_*) , strok

		
*************Table 3. Highest Education-Level Achieved by Heads of Households (%)
***************************************

	*Household head education
		gen hh_head_educ=.
		forvalues k=1/15 {
			replace hh_head_educ=q2_11_`k' if q2_4_`k' == 1
		}
		lab val hh_head_educ q2_11_label


*************Table 4. Household Head's Residential Status (%)
***************************************
	
	*HH head Residential Status 2.16
		gen hh_head_resstatus = .
		forvalues i = 1(1)14 {
			replace q2_4_`i' = .d if q2_4_`i' == 8888
			replace q2_4_`i' = .r if q2_4_`i' == 9999
			replace hh_head_resstatus = q2_16_`i' if q2_4_`i' == 1
		}
		label val hh_head_resstatus q2_16_label
	
	
*************Table 5. Average Household Income in Last 12 Months
***************************************
	
	*work income: 3.5.x (primary job income) + 3.15.x (2ndry job) + 3.18.x (other jobs) 
		forval i = 1(1)15 {
			replace q3_5_`i' = .d if q3_5_`i' == 8888
			replace q3_5_`i' = .r if q3_5_`i' == 9999
			replace q3_15_`i' = .d if q3_15_`i' == 8888
			replace q3_15_`i' = .r if q3_15_`i' == 9999
			replace q3_18_`i' = .d if q3_18_`i' == 8888
			replace q3_18_`i' = .r if q3_18_`i' == 9999
			label val q3_5_`i' q3_15_`i' q3_18_`i' dontknow
		}
		egen hh_inc_jobtotal = rowtotal(q3_5_* q3_15_* q3_18_*)

	*pension/allowance, transfers: 3.19-3.27, 3.28, 3.33-35	
	*asset-related income and other: 3.29-3.32, 3.36
		forval i = 1(1)15 {
			forval qq = 19/36 {
				replace q3_`qq'_`i' = .d if q3_`qq'_`i' == 8888
				replace q3_`qq'_`i' = .r if q3_`qq'_`i' == 9999
				label val q3_`qq'_`i'  dontknow 
			}
		}	
		egen hh_inc_transfer=rowtotal(q3_19_* q3_20_* q3_21_* q3_22_* q3_23_* q3_24_* q3_25_* q3_26_* q3_27_* q3_28_* q3_33_* q3_34_* q3_35_*)
		egen hh_inc_asset=rowtotal(q3_29_* q3_30_* q3_31_* q3_32_* q3_36_*)
			
	*Total income: 
		egen hh_inc_total=rowtotal(hh_inc_jobtotal hh_inc_transfer hh_inc_asset)


*************Table 6. Average Number of Household Members Employed
***************************************

	*Employment Status 3.1, 3.2.
		*## q3_1_* are not ordered numerically in the variable window of stata
		*## following vars are entered as "Y" "N" as string: q3_1_1 q3_1_2 q3_1_3 q3_1_4 q3_1_5 q3_1_10 q3_1_12 q3_1_13
		global employed_vars_num "q3_1_6 q3_1_7 q3_1_8 q3_1_9 q3_1_14 q3_1_15 q3_1_6 q3_1_7 q3_1_8 q3_1_9 q3_1_11"
		global employed_vars_str "q3_1_1 q3_1_2 q3_1_3 q3_1_4 q3_1_5 q3_1_10 q3_1_12 q3_1_13" 
		foreach var in $employed_vars_str {
			replace `var' = "1" if `var' == "Y"
			replace `var' = "1" if `var' == "y"
			replace `var' = "0" if `var' == "N"
			replace `var' = "0" if `var' == "n"
			destring `var', replace
			replace `var' = .d if `var' == 8888
			replace `var' = .r if `var' == 9999
			label var `var' yesno
		}
		foreach var in $employed_vars_num {
			replace `var' = .d if `var' == 8888
			replace `var' = .r if `var' == 9999
		}
		egen hh_employed = rowtotal(q3_1_*)

	
*************Table 7. Household Vehicle Ownership
***************************************

	*Total amount invested in vehicles (Section 4C) 
		gen hh_vehicle_num = q4_c_2
		replace hh_vehicle_num = 0 if hh_vehicle_num == .
		
		replace q4_c_3 = .d if q4_c_3 == 8888
		replace q4_c_3 = .r if q4_c_3 == 9999
		gen hh_vehicle_valtot = q4_c_3
		replace hh_vehicle_valtot = 0 if hh_vehicle_valtot==.


*************Table 8. Household Livestock Ownership
***************************************

	forval i = 1(1)7 {
		replace q4_23_`i' = 0 if q4_23_`i' == .
		replace q4_23_`i' = .d if q4_23_`i' == 8888
		replace q4_23_`i' = .r if q4_23_`i' == 9999
		replace q4_24_`i' = 0 if q4_24_`i' == .
		replace q4_24_`i' = .d if q4_24_`i' == 8888
		replace q4_24_`i' = .r if q4_24_`i' == 9999
	}

	
*************Table 9. Market Value of Household Appliances Owned (1,000 MNT)
***************************************

	forval i = 1(1)18 {
		replace q4_27_`i' = .d if q4_27_`i' == 8888
		replace q4_27_`i' = .r if q4_27_`i' == 9999
		label val q4_27_`i' dontknow
		replace q4_27_`i' = 0 if q4_27_`i' == .
	}
	egen hh_appliance_tot = rowtotal(q4_27_*)


*************Table 10. Average Household Expenditure (1,000 MNT)
***************************************

	*Household expenditures
		foreach var of varlist q12_* {
			replace `var'=.d if `var'==8888
			replace `var'=.r if `var'==9999
		}
		
	*Food and nonfood in past 30 days
		cap drop total_expend30
		cap drop total_expendyr1
		tempvar qq
		forvalues x=1/18 {
			gen `qq'`x'=q12_`x'
		}
		egen total_expend30=rowtotal(`qq'*)
		drop `qq'*
		gen total_expendyr1=12*total_expend30
		
	*Other expenditures in last year
		cap drop total_expendyr
		cap drop total_expendyr2
		tempvar ww
		forval x=19/26 {
			gen `ww'`x'=q12_`x'
		}
		egen total_expendyr2=rowtotal(`ww'*)
		drop `ww'*
		gen total_expendyr=total_expendyr1+total_expendyr2


*************Table 11. Types of Infrastructure (%)
***************************************

	/*
	Latrine: Pit Toilet outside a Household Structure
	Sewage System: Hashaa has Sewage Point
	Sewage System: Use Latrine in the Hashaa as Sewage Point
	Solid Waste System: Collection by a Garbage Truck 
	Main Heating System : Regular Coal and Wood Heating 
	Main Electrical System: Centralized System
	Main Drinking Water Source: Mobile Water Distribution
	Main Drinking Water Source: Deep Well
	Telephone Network: Mobile Telephone
	*/
	gen latrine_outside=q11_1==3
	gen sewage_point=q11_2==2
	gen sewage_latrine=q11_2==4
	gen garbage_truck=q11_3==2
	gen heat_coalwood=q11_4==6
	gen elect_central=q11_5==1
	gen water_mobile=q11_6==2
	gen water_well=q11_6==3
	gen tel_mobile=q11_7==3
	

*************Table 12. Household Business Engagement
***************************************

	*No Definitions necessary, it is just q13_1
	

*************Table 13. Summary Statistics on Average Business Revenue, Costs, and Profit per Household from the Last Year of Business
***************************************

	forval x=1/5 {
		replace q13_3_5_`x'=.d if q13_3_5_`x'==8888
		replace q13_3_5_`x'=.r if q13_3_5_`x'==9999
		replace q13_3_6_`x'=.d if q13_3_6_`x'==8888
		replace q13_3_6_`x'=.r if q13_3_6_`x'==9999
	}
	
	*Average Revenue per Business (1,000 MNT)
		cap drop business_reven
		egen business_reven=rowtotal(q13_3_5_*)
	*Average Expense per Business (1,000 MNT)
		cap drop business_cost
		egen business_cost=rowtotal(q13_3_6_*)
	*Average Profit per Business (1,000 MNT)
		cap drop business_profit
		gen business_profit=business_reven-business_cost

		
*************Table 14. Real Estate Transactions
***************************************

	*Respondents’ Who Knew Someone on Their Street Who Tried to Sell a Hashaa Plot
	*q10_1
	
	*Households on a Respondents’ Street Who Attempted to Sell Their Hashaa Plot during the Last Year
	gen num_hashaas_selling=q10_2
	replace num_hashaas_selling=0 if q10_1=="N"
	bys district: egen total_hashaas_selling=total(num_hashaas_selling)
	
	*Households on Respondents Street Who Sold Their Hashaa Plot during the Last Year
	gen num_hashaas_sold=q10_3
	replace num_hashaas_sold=0 if q10_1=="N"
	bys district: egen total_hashaas_sold=total(num_hashaas_sold)
	

*************Table 15. Households Average Investment in Hashaa Plots (1,000 MNT)
***************************************

	*Investment in Land (last 5 years)
		*Here we will leave the ones who do not own the land as zero
		cap drop land_invest
		gen land_invest=0
		forval i = 1(1)5 {
			replace q4_11_`i' = .d if q4_11_`i' == 8888 
			replace q4_11_`i' = .r if q4_11_`i' == 9999
			replace q4_10_`i' = .d if q4_10_`i' == 8888 
			replace q4_10_`i' = .r if q4_10_`i' == 9999
			replace q4_12_`i' = .d if q4_12_`i' == 8888
			replace q4_12_`i' = .r if q4_12_`i' == 9999
			
			replace land_invest=land_invest+q4_11_`i' if  q4_4_`i'==1 & q4_10_`i'>0 & q4_10_`i'<.
		}

	*Investment in Structures (last year)
		*Here we will leave the ones who do not own the land as zero
		cap drop struct_invest
		gen struct_invest=0
		forval i = 1(1)5 {
			replace q4_20_`i' = .d if q4_20_`i' == 8888 
			replace q4_20_`i' = .r if q4_20_`i' == 9999
			replace struct_invest=struct_invest+q4_20_`i' if  q4_17_`i'==1 & q4_19_`i'>0 & q4_19_`i'<.
		}
		*NOW: project this to the previous 5 years
		gen struct_invest_5yr=struct_invest*5
		
	*All Planned Investments by HH (next 5 years)
		*We'll just summarize the total value of investments planned ON THE HASHAA
		foreach var of varlist q5_5_* q5_7_* {
			replace `var'=.d if `var'==8888
			replace `var'=.r if `var'==9999
		}
		*Let's also do this for only plans within the next 5 years
		cap drop total_invest_plan
		gen double total_invest_plan=0
		forvalues num=1/5 {
			replace total_invest_plan=total_invest_plan+q5_5_`num' if  q5_7_`num'==1  & q5_6_`num'<=60
		}

		
*************Table 16. Households with Loans in the Last 5 Years
***************************************

	*Had any loans in past 5 years (%)
		gen had_loan=q15_1
		replace had_loan="" if inlist(q15_1,"9999","8888")
	
	*Average Number of Loans in Last 5 Years
		gen num_loans=q15_2
		replace num_loans=0 if q15_1=="N"
	
	*Average Principal on Loans in Last 5 Years (1,000 MNT)
		mvdecode q15_3_2_*, mv(8888=.d \ 9999=.r)
		egen loan_princ_tot=rowtotal(q15_3_2_*)
		replace loan_princ_tot=. if q15_1!="Y"
	
	
*************Table 17. Loan Purpose
***************************************

	/*Business Activities
	Building or Purchasing of a Dwelling Unit
	Consumption/Livelihood Purposes 
	Educational Purposes
	Other */
	replace q15_3_1_1=. if !inlist(q15_3_1_1,1,2,3,4,5,.,.d,.r)
	// the rest don't need modification


*************Table 18. Loan Sources
***************************************

	*no additional processing required for q15_3_4_*


*************Table 19. Types of Loan Collateral (%)
***************************************

	*no additional processing required for q15_3_8_*
	

*************Table 20. Average Monthly Minimum Payments Required per Household, Summed Over All Loans (1,000s of MNT)
***************************************

	*Minimum monthly payment, by type
	mvdecode q15_3_12_* , mv(8888=.d \ 9999=.r)
	egen min_payment=rowtotal(q15_3_12_*)


*************Table 21. Households that were Unsuccessful at Obtaining a Loan in the Past and the Reasons Why they were Unsuccessful (%)
***************************************

	gen loan_unsucc=q15_4
	replace loan_unsucc="" if loan_unsucc=="8888"

	gen loan_unsucc_reas=q15_5
	replace loan_unsucc_reas=. if !inlist(q15_5,1,2,3,4,5,.,.d,.r)

	
*************Table 22. Financial Assets
***************************************

	mvdecode q4_30_* , mv(8888=.d \ 9999=.r)
	egen financ_assets=rowtotal(q4_30_*)
	

*************Table 23. Land Disputes
***************************************

	gen had_dispute=q9_1
	replace had_dispute="" if had_dispute=="8888"


*************Table 24. Nature of Land Dispute
***************************************

	*specific types of disputes (since 2003) (sect 9) // boundary_issue
		*mapping error or boundary conflict, illegal extension or subdivision (border issue)
		*information error (name or address)
		*sold or bought illegally
		cap drop boundary_issue
		cap drop info_issue
		cap drop sell_issue
		egen boundary_issue=anymatch(q9_3_1_*) , values(1 4 6) 
		replace boundary_issue=. if had_dispute!="Y"
		egen info_issue=anymatch(q9_3_1_*) , values(2 3) 
		replace info_issue=. if had_dispute!="Y"
		egen sell_issue=anymatch(q9_3_1_*) , values(5)
		replace sell_issue=. if had_dispute!="Y"
		egen other_issue=anymatch(q9_3_1_*) , values(7)
		replace other_issue=. if had_dispute!="Y"
	

*************Table 25. Average Hashaa Plot Value and Size
***************************************

	*Now do it for all land on the hashaa plot	
	*This loop gives a missing value to the area if any of the pieces of land 
		*that are listed as "on the plot" are missing. This is what we want. 
		cap drop hashaa_area
		gen hashaa_area=0
		forval i = 1(1)5 {
			replace q4_5_`i' = .d if q4_5_`i' == 8888
			replace q4_5_`i' = .r if q4_5_`i' == 9999
			replace hashaa_area=hashaa_area+q4_5_`i' if  q4_4_`i'==1
		}
		*make it missing if they did not own any land on the hashaa (renters, e.g.)
		egen own_land_onhashaa=anymatch(q4_4_*), values(1)
		replace hashaa_area=. if own_land_onhashaa==0

	*Self-reported hashaa value
		cap drop hashaa_value
		gen hashaa_value=0
		forval i = 1(1)5 {
			replace q4_13_`i' = .d if q4_13_`i' == 8888
			replace q4_13_`i' = .r if q4_13_`i' == 9999
			replace hashaa_value=hashaa_value+q4_13_`i' if  q4_4_`i'==1
		}
		replace hashaa_value=. if own_land_onhashaa==0

	*Price per square meter
		gen hashaa_price_msq = hashaa_value/hashaa_area


*************Table 26. Acquisition Method of Hashaa Plot (%)
***************************************

	*no additional processing required for q4_6_1. This is counting only
		*the first piece of land listed as "on the hashaa plot"

		
*************Table 27. Average Plots of Land Owned by Household at Time of Survey
***************************************

	*no additional processing required for q4a

	
*************Table 28. Hashaa Plot Ownership Status
***************************************

	gen owner_status=reg_status
	replace owner_status="Possession" if q6_1==2
	replace owner_status="Gov. Decision" if q6_1==3
	
	
*************Table 29. Inheritor of Hashaa Plot (%)
***************************************

	*c.	Who will inherit the land (could be a gender question) 4.9. Note this is only
		*looking at the first piece of land.
	/*
		1	household member
		2	other male family member outside current household
		3	Other female family member outside current household
		4	other non-family member outside household
		5	Other
		.d	Don't Know
		.r  Refused
	*/
	*## q4_9_1 has a value of 0 and 6 which shouldn't exist
		egen hh_land_inherit_1 = anymatch(q4_9_1), v(1)
		egen hh_land_inherit_2 = anymatch(q4_9_1), v(2)
		egen hh_land_inherit_3 = anymatch(q4_9_1), v(3)
		egen hh_land_inherit_4 = anymatch(q4_9_1), v(4)
		egen hh_land_inherit_5 = anymatch(q4_9_1), v(5)
	

*************Table 30.  Average Money Spent on Possession Certificate by Process (1,000 MNT)
***************************************

	*## how much spent on getting cert of possession with cert of possession
		mvdecode q6_16_* , mv(8888=.d \ 9999=.r)
		forval x=1/6 {
			gen poss_cost_`x'=q6_16_`x'
			replace poss_cost_`x'=0 if q6_16_`x'==. & q6_1==2
		}
		

*************Table 31. Average Money Spent on Obtaining Property Registration Certificate (1,000 MNT)
***************************************

	*NOTE: only for those with full registration. We skip those with Governor's decision only 
		*(they don't have a dedicated table)
	mvdecode q6_50_* , mv(8888=.d \ 9999=.r)
	forval x=1/6 {
		gen own_cost_`x'=q6_50_`x'
		replace own_cost_`x'=0 if q6_50_`x'==. & q6_1==4
	}


*************Table 32. Time Needed to Obtain Property Registration Certificate (%)
***************************************

	*no additional processing required for q6_48


*************Table 33. Paying to Speed up Process for Obtaining Property Registration Certificate
***************************************

	gen paid_to_speed=q6_51
	replace paid_to_speed="" if inlist(paid_to_speed,"8888","9999")
	
	*no additional processing required for q6_52

	
*************Table 34. Households’ Perceptions of Security with Property Registration Certificate (%)
***************************************

	gen cert_secure=q6_54
	replace cert_secure="" if inlist(cert_secure,"8888","9999")
	
	*% of households that feel secure against expropriation of their land
		gen secure=q8_3
		replace secure=0 if secure==2
		lab val secure yesno


*************Table 35. Land Fee and Collateral with Property Registration Certificate (%)
***************************************

	gen more_tax=q6_56
	replace more_tax="" if inlist(more_tax,"8888","9999")
	gen use_ascollat=q6_57
	replace use_ascollat="" if inlist(use_ascollat,"8888","9999")


*************Table 36. Sufficient Information on the Following Processes
***************************************

	*no additional processing required for q8_1_*


*************Table 37. Attitudes toward Government Effectiveness
***************************************

	forval x=1/4 {
		gen gov_`x'=q16_`x'
		replace gov_`x'="" if inlist(gov_`x',"8888","9999")
	}
	

*************Table 38. Percent of People Who Have Medical, Social and Other Insurances (%)
***************************************

	foreach x in 1 2 5 7 8 9 10 12 {
		gen insur_`x'=q14_`x'
		replace insur_`x'="" if inlist(insur_`x',"8888","9999")
	}


*************Table 39. Demographics of Household Heads by Gender 
***************************************

	*all variables are defined above except two:
	gen bus_activ=q13_1=="Y"
	
	recode hh_head_educ (1=0) (2=4) (3=8) (4=10) (5=10) (6=10) (7=14) (8=16) (nonmissing=0) , gen(hh_head_edyrs) 
	lab var hh_head_edyrs "Years of schooling: household head"


	
*************Table 40. Gender of Interview Participant
***************************************

	*The definitions are created in the table making file


*************Table 41. Name on Property Registration Certificate
***************************************

	*Whose name is the plot in? Female or male
		/* q2_5_ is sex
		q4_4_ is location of land (in hashaa/not)
		q4_3 is who is it registered under?
		q4a_2_* gives the code of co-owners
		*/
		
		*q4a_2_* give information about co-owners
		*q4a_2_4 and q4a_2_5 are empty
		*q4a_2_3 has only 2 entries and they are both 77, and it is numeric
		cap drop co_owner*
		replace q4a_2_1="01 05" if q4a_2_1=="105"
		replace q4a_2_1="02 03" if q4a_2_1=="203"
		split q4a_2_1, gen(co_owner1_)
		split q4a_2_2, gen(co_owner2_)
		gen co_owner3_1=q4a_2_3
			
		foreach var of varlist co_owner1* co_owner2* {
			replace `var'="1" if `var'=="01"
			replace `var'="2" if `var'=="02"
			replace `var'="3" if `var'=="03"
			replace `var'="4" if `var'=="04"
			replace `var'="5" if `var'=="05"
			replace `var'="6" if `var'=="06"
			replace `var'="7" if `var'=="07"
			replace `var'="8" if `var'=="08"
		}
		destring co_owner1* co_owner2*, replace
		
		cap drop male_name
		gen male_name=0
		forval memb = 1/15 {
			forval land = 1(1)5 {
				replace male_name=1 if q2_5_`memb'==1 & q4_4_`land'==1 & q4_3_`land'==`memb' & inlist(q4_1_`land',2,3,4) & inlist(reg_status,"Partial","Title")
				
				forval conum=1/6 {
					cap confirm var co_owner`land'_`conum'
					if _rc==0 replace male_name=1 if q2_5_`memb'==1 & q4_4_`land'==1 & co_owner`land'_`conum'==`memb' & inlist(q4_1_`land',2,3,4) & inlist(reg_status,"Partial","Title")
				}
				
				replace male_name=1 if q2_5_`memb'==1 & q4_4_`land'==1 & q4_3_`land'==`memb' & inlist(q4_1_`land',2,3,4) & inlist(reg_status,"Partial","Title")

			}
		}
		
		cap drop fem_name
		gen fem_name=0
		forval memb = 1/15 {
			forval land = 1(1)5 {
				replace fem_name=1 if q2_5_`memb'==0 & q4_4_`land'==1 & q4_3_`land'==`memb' & inlist(q4_1_`land',2,3,4) & inlist(reg_status,"Partial","Title")
				
				forval conum=1/6 {
					cap confirm var co_owner`land'_`conum'
					if _rc==0 replace fem_name=1 if q2_5_`memb'==0 & q4_4_`land'==1 & co_owner`land'_`conum'==`memb' & inlist(q4_1_`land',2,3,4) & inlist(reg_status,"Partial","Title")
				}
			}
		}
		
		cap drop whose_name
		gen whose_name=.
		replace whose_name=1 if male_name==1 & fem_name==0
		replace whose_name=2 if male_name==0 & fem_name==1
		replace whose_name=3 if male_name==1 & fem_name==1
		lab def namelab 1 male 2 female 3 both 
		lab val whose_name namelab
		/* br q4_1_1 q4_1_2 q6_1 q4_4_1 q4_3_1 reg_status whose_name q2_1_1 q2_2_1 q2_3_1 q2_4_1 q2_5_1 q2_1_2 ///
			q2_2_2 q2_3_2 q2_4_2 q2_5_2  if inlist(reg_status,"Partial","Title") & whose_name==. */


*************Table 42. How Hashaa was acquired, by Gender of Title Holder
***************************************

	*no additional processing required for q4_6_1


*************Table 43. Gender of Respondents who inherited Their Hashaa
***************************************

	gen hh_land_inherited = q4_6_1==2
	replace hh_land_inherited=. if mi(q4_6_1)


*************Table 44. Gender of Individual in Charge of Registration for Households Registering (%)
***************************************

	cap drop male_registers
	gen male_registers=.
	replace male_registers=0 if !mi(q6_12) | !mi(q6_30) | !mi(q6_46)
	forval x=1/15 {
		replace male_registers=1 if q6_12==`x' & q2_5_`x'==1
		replace male_registers=1 if q6_30==`x' & q2_5_`x'==1
		replace male_registers=1 if q6_46==`x' & q2_5_`x'==1
	}
	
	cap drop female_registers
	gen female_registers=.
	replace female_registers=0 if !mi(q6_12) | !mi(q6_30) | !mi(q6_46)
	forval x=1/15 {
		replace female_registers=1 if q6_12==`x' & q2_5_`x'==0
		replace female_registers=1 if q6_30==`x' & q2_5_`x'==0
		replace female_registers=1 if q6_46==`x' & q2_5_`x'==0
	}
	
	cap drop who_registers
	gen who_registers=0 if female_registers==1
	replace who_registers=1 if male_registers==1
	label val who_registers sex
	
	
*************Table 45. Control of Loans by Gender (Number of Loans)
***************************************

	forval x=1/10 {
		forval y=13/15 {
			replace q15_3_`y'_`x' = . if q15_3_`y'_`x'>10
		}
	}
	
	cap drop fem_loans_name
	cap drop fem_loans_spend
	cap drop fem_loans_pay
	gen fem_loans_name=0
	gen fem_loans_spend=0
	gen fem_loans_pay=0
	forval x=1/10 {
		forval fam =1/15 {
			replace fem_loans_name=fem_loans_name+1 if q2_5_`fam'==0 & q15_3_13_`x'==`fam'
			replace fem_loans_spend=fem_loans_spend+1 if  q2_5_`x'==0 & q15_3_14_`x'==`fam'
			replace fem_loans_pay=fem_loans_pay+1 if q2_5_`x'==0 & q15_3_15_`x'==`fam'
		}
	}
		
	cap drop male_loans_name
	cap drop male_loans_spend
	cap drop male_loans_pay
	gen male_loans_name=0
	gen male_loans_spend=0
	gen male_loans_pay=0
	forval x=1/10 {
		forval fam =1/15 {
			replace male_loans_name=male_loans_name+1 if q2_5_`fam'==1 & q15_3_13_`x'==`fam'
			replace male_loans_spend=male_loans_spend+1 if  q2_5_`x'==1 & q15_3_14_`x'==`fam'
			replace male_loans_pay=male_loans_pay+1 if q2_5_`x'==1 & q15_3_15_`x'==`fam'
		}
	}
	
	gen total_loans=q15_2
	replace total_loans=0 if q15_1!="Y"
	

*************Table 46. Unsuccessful Attempt at Obtaining a Loan by Gender (%)
***************************************

	*Defined in Table 21
	

*************Table 47. Household Assets, by Gender of Household Head
***************************************

	*HH has any structures? q4_b_1
	replace q4_b_1="Y" if q4_b_1=="y"
	replace q4_b_1="" if q4_b_1=="9999"
	gen has_struct=.
	replace has_struct=0 if q4_b_1=="N"
	replace has_struct=1 if q4_b_1=="Y"
	
	*Structures // total structures an value of structures (q4_14_1-5 type, q4_21_1-5 market value)
	egen tot_struct=rownonmiss(q4_14_*)
	gen struct_plusone=tot_struct>1
	
	*Value of all structures
	mvdecode q4_21_* , mv(8888=.d \ 9999=.r)
	egen struct_val=rowtotal(q4_21_*)
	
	*HH has any vehicles? 
	replace q4_c_1="Y" if q4_c_1=="y"
	gen has_vehicle=.
	replace has_vehicle=0 if q4_c_1=="N"
	replace has_vehicle=1 if q4_c_1=="Y"
	

*************Table 48. Household Expenditures, by Gender of Household Head
***************************************

*This is expenditure in one month
*Let's compare expenditure and proportional expenditure on (be sure to scale year/month correctly):
	*food + drinking water + winter meat consumption (q12_1 +q12_2 +q12_19/12)
	*cigarettes + alcohol (q12_4 + q12_8)
	*shoes and other clothing (q12_6)
	*school supplies + tuition fees (q12_7 + q12_22/12)
	*medical expenses (q12_21/12)
	
	mvdecode q12_* , mv(8888=.d \ 9999=.r)

	gen food_exp=q12_1 +q12_2 +q12_19/12
	gen sin_exp=q12_4 + q12_8
	gen clothing_exp=q12_6
	gen educ_exp=q12_7 + q12_22/12
	gen medic_exp=q12_21/12
	
	egen total_exp_mo=rowtotal(q12_1-q12_18)
	egen total_exp_yr=rowtotal(q12_19-q12_26)
	gen total_exp=total_exp_mo+total_exp_yr/12
	
	foreach x in food sin clothing educ medic {
		gen `x'_prop=`x'_exp/total_exp
	}


*************Table 49. Satisfaction Level with Services Received during the Registration Process by Gender (%)
***************************************

	gen possess_satis=q8_2_1
	replace possess_satis=. if q8_2_1==4
	gen gov_satis=q8_2_2
	replace gov_satis=. if q8_2_2==4
	gen title_satis=q8_2_3
	replace title_satis=. if q8_2_3==4
	lab val *_satis q8_2_label


*************Table 50. Kheseg Distribution and Rate of Privatization by City and District
***************************************

	gen num_hesegs1=0
	bys district fin_heseg: replace num_hesegs1=1 if _n==1
	bys district: egen num_hesegs=total(num_hesegs1)
	
	*av_ownership4	--defined in 4b // this was used for matching hesegs based on similar initial levels of 
		*registration during the randomization.
		cap drop *ownership*
		tab q6_1, generate(ownership)
		egen av_ownership4 = mean(ownership4), by(fin_heseg)

	*Average number of plots per kheseg by district
		bys fin_heseg: egen num_plots=total(1)
		bys fin_heseg: gen firstplot=_n==1
		


*************Table 51. Alterations Made to Kheseg Units
***************************************
	*This table was created separately from the SHPS dataset


*************Table 52. Distribution of Treatment and Control Households
***************************************
	gen city="UB"
	replace city="Darkhan" if district=="Darkhan"
	replace city="Erdenet" if district=="Erdenet"


*************Table 53. Balance Test
***************************************
	*This table is created in do-file "5 SHPS Baseline Report Balance Tests"


*************Table 54. Timeline for Formalization Contractors and SHPS Data Collection
***************************************
	*This table was created separately from the SHPS dataset
	







