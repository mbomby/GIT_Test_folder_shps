

*This do-file creates Tables 1-49 in the SHPS baseline report. Balance test regression tables are
*produced in file "5 SHPS Baseline Report Balance Tests 2013-10-7.do"
	*Through table 38 is everyone, 39-49 are gender tables
	
	
	
	set more off
	cd "C:\IPA\2Urban\Reports & Analysis\SHPS Baseline Report\Revision Sept 2013/Data for SHPS Baseline Report 2013-10-7"
	global anlys_dir "C:\IPA\2Urban\Reports & Analysis\SHPS Baseline Report\Revision Sept 2013"
	
	*use "Final/SHPS_Temp_Cleaned_2013-9-10.dta", clear
	use "Final/SHPS_Temp_Cleaned.dta", replace
	

*Cut down sample to one household per plot, since some plot have multiple associated interviews.
*The overall effect is to keep one household per plot. The priority is: 1 (owner-resident) > 2 (owner-nonresident) > 3 (resident-nonowner)
	cap drop keep_sample
	cap drop priority
	cap drop pri
	gen priority=1 if res_status==1 | res_status==2
	replace priority=2 if inlist(res_status,3,4)
	replace priority=3 if inlist(res_status,5,6)
	duplicates report priority plot_id // no duplicates, so we have a unique ordering
	bys plot_id: egen pri=min(priority)
	gen keep_sample=0
	replace keep_sample=1 if pri==priority
	drop priority pri
	count if keep_sample // 5722 which is right

	keep if keep_sample==1
	
	
*Make the correct geographic breakdown
	cap drop area
	gen area=0
	replace area=1 if inlist(district,"Darkhan","Erdenet")
	lab def area 0 "UB" 1 "Da/Er", modify
	lab val area area
	
*Make a "has title" binary variable
	cap drop title
	gen title=0
	replace title=1 if q6_1==4
	lab def register 0 "No title" 1 "Title", modify
	
*Make partial registration (possession certificate or governor's decision) variable
	cap drop partial_reg
	gen partial_reg= q6_1==2 | q6_1==3
	
*Make registration status variable:
	gen reg_status=""
	replace reg_status="None" if q6_1==1
	replace reg_status="Partial" if q6_1==2 | q6_1==3
	replace reg_status="Title" if q6_1==4
	replace reg_status="Non-owner resident" if inlist(q1_16,"3A","3B")
	
*Define the analysis variables:
	do "Do/4b SHPS Baseline Report Table Making_Defn 2013-9-23.do"


/*
**********************************************************                          
*EXECUTIVE SUMMARY
************************************************************************************


*DO IT AFTER THE MAIN BODY

*Hashaa area:
	summ hashaa_area
	

*/




**********************************************************                          
*MAIN REPORT
************************************************************************************

	*cap log close
	*log using "$anlys_dir/SHPS Baseline Tables Output 2013-9-16.log", text replace

	
*************Table 1. Targeted and Actual Sample
***************************************
	
	*this actually requires a fuller version of the dataset without the incomplete interviews
	*dropped out. One is now created in the SHPS cleaning process and we'll load it here.
	preserve
	use "Final/Check_response_rate.dta", clear
	drop if inelig_heseg==1
	drop if mi(no)
	
	tab  dist status_simple, m
	restore
                          
	
*************Table 2. Basic Demographic Information on Heads of Households
***************************************

	*This table was initially done with an incorrect sample - only based on surveys that
	*were answered by the household head.

	summ hh_head_male hh_head_married hh_head_lasthome hh_head_age hh_size // lasthome is correct, very few of the hh heads grew up on their hashaa
	

*************Table 3. Highest Education-Level Achieved by Heads of Households (%)
***************************************

	tab hh_head_educ district,  nofreq  col


*************Table 4. Household Head's Residential Status (%)
***************************************
	
	tab hh_head_resstatus district,  nofreq  col
	
	
*************Table 5. Average Household Income in Last 12 Months
***************************************
	
	tabstat hh_inc_jobtotal hh_inc_transfer hh_inc_asset hh_inc_total , by(district)
	

*************Table 6. Average Number of Household Members Employed
***************************************

	tabstat hh_employed, by(district)

	
*************Table 7. Household Vehicle Ownership
***************************************

	tabstat hh_vehicle_num hh_vehicle_valtot, by(district)

	
*************Table 8. Household Livestock Ownership
***************************************

	*Note: q4_y_x --> y: 23 is number, 24 is value;  x: 1=cattle 2=sheep 3=goat 4=horse
	tabstat q4_23_1 q4_24_1 q4_23_2 q4_24_2 q4_23_3 q4_24_3 q4_23_4 q4_24_4, by(district)


*************Table 9. Market Value of Household Appliances Owned (1,000 MNT)
***************************************

	tabstat hh_appliance_tot , by(district)

	
*************Table 10. Average Household Expenditure (1,000 MNT)
***************************************

	tabstat total_expendyr, by(district)


*************Table 11. Types of Infrastructure (%)
***************************************

	tabstat latrine_outside sewage_point sewage_latrine garbage_truck heat_coalwood elect_central ///
		water_mobile water_well tel_mobile , by(district)

	
*************Table 12. Household Business Engagement
***************************************

	tab q13_1 district, col nofreq

	
*************Table 13. Summary Statistics on Average Business Revenue, Costs, and Profit per Household from the Last Year of Business
***************************************

	tabstat business_reven business_cost business_profit , by(district)

	
*************Table 14. Real Estate Transactions
***************************************

	tab q10_1 district, col nofreq
	tabstat num_hashaas_selling, by(district)
	tabstat total_hashaas_selling, by(district) // note: need to add districts to get total
	tabstat num_hashaas_sold, by(district)
	tabstat total_hashaas_sold, by(district) // note: need to add districts to get total


*************Table 15. Households Average Investment in Hashaa Plots (1,000 MNT)
***************************************

	tabstat land_invest struct_invest_5yr total_invest_plan , by(district)


*************Table 16. Households with Loans in the Last 5 Years
***************************************

	tab had_loan district, col nofreq
	tabstat num_loans , by(district)
	bys district: summ loan_princ_tot
	summ loan_princ_tot
	

*************Table 17. Loan Purpose
***************************************

	*NOTE: Tables 17-19 give percentage of total loans so it is best to convert the 
		*dataset into one row per loan. 
	preserve
	keep no district q15_3_1_* q15_3_4_* q15_3_8_*
	reshape long q15_3_1_ q15_3_4_ q15_3_8_ , i(no) j(loan_no)

	tab q15_3_1_ district , col
	restore
	
	
*************Table 18. Loan Sources
***************************************

	*NOTE: Tables 17-19 give percentage of total loans so it is best to convert the 
		*dataset into one row per loan. 
	preserve
	keep no district q15_3_1_* q15_3_4_* q15_3_8_*
	reshape long q15_3_1_ q15_3_4_ q15_3_8_ , i(no) j(loan_no)
	
	tab q15_3_4_ district , col
	restore

	
*************Table 19. Types of Loan Collateral (%)
***************************************

	*NOTE: Tables 17-19 give percentage of total loans so it is best to convert the 
		*dataset into one row per loan. 
	preserve
	keep no district q15_3_1_* q15_3_4_* q15_3_8_*
	reshape long q15_3_1_ q15_3_4_ q15_3_8_ , i(no) j(loan_no)

	tab q15_3_8_ district , col 
	restore


*************Table 20. Average Monthly Minimum Payments Required per Household, Summed Over All Loans (1,000s of MNT)
***************************************

	tabstat min_payment , by(district)

		
*************Table 21. Households that were Unsuccessful at Obtaining a Loan in the Past and the Reasons Why they were Unsuccessful (%)
***************************************

	tab loan_unsucc district, col nofreq
	tab loan_unsucc_reas district, col nofreq


*************Table 22. Financial Assets
***************************************

	tabstat financ_assets , by(district)
	

*************Table 23. Land Disputes
***************************************

	tab had_dispute district, col nofreq
	tab had_dispute reg_status, col nofreq


*************Table 24. Nature of Land Dispute
***************************************

	tabstat boundary_issue info_issue sell_issue other_issue, by(district)

	
*************Table 25. Average Hashaa Plot Value and Size
***************************************

	tabstat hashaa_value hashaa_area hashaa_price_msq if hashaa_price_msq<700, by(district)
	tabstat hashaa_value hashaa_price_msq  if hashaa_price_msq<700 , by(reg_status)

	
*************Table 26. Acquisition Method of Hashaa Plot (%)
***************************************
	
	tab q4_6_1 district, col nofreq
	

*************Table 27. Average Plots of Land Owned by Household at Time of Survey
***************************************

	tabstat q4a, by(district)
	

*************Table 28. Hashaa Plot Ownership Status
***************************************

	tab owner_status district , col nofreq


*************Table 29. Inheritor of Hashaa Plot (%)
***************************************

	by district: summ hh_land_inherit_* if q4_4_1 == 1
	summ hh_land_inherit_* if q4_4_1 == 1


*************Table 30.  Average Money Spent on Possession Certificate by Process (1,000 MNT)
***************************************

	tabstat poss_cost_* , by(district) // 1 notary 2 cadastral 3 trasport 4 certificate 5 other 6 total
	*NOTE: the first five don't add to the last because there are so many "Don't Knows" here
	

*************Table 31. Average Money Spent on Obtaining Property Registration Certificate (1,000 MNT)
***************************************

	tabstat own_cost_* , by(district) // 1 notary 2 cadastral 3 trasport 4 certificate 5 other 6 total

	
*************Table 32. Time Needed to Obtain Property Registration Certificate (%)
***************************************

	tab q6_48 district, col nofreq
	
	
*************Table 33. Paying to Speed up Process for Obtaining Property Registration Certificate
***************************************

	tab paid_to_speed district , col nofreq
	tabstat q6_52, by(district)
	
	
*************Table 34. Households’ Perceptions of Security with Property Registration Certificate (%)
***************************************

	tab cert_secure district, nofreq col
	tab secure reg_status, nofreq col

	
*************Table 35. Land Fee and Collateral with Property Registration Certificate (%)
***************************************

	tab more_tax district, col nofreq
	tab use_ascollat district , col nofreq

	
*************Table 36. Sufficient Information on the Following Processes
***************************************

	tabstat q8_1_* , by(district) // 1 possession 2 governor decision 3 title
	
	
*************Table 37. Attitudes toward Government Effectiveness
***************************************

	*These are questions 16.1 through 16.4
	tab gov_1 district , nofreq col
	tab gov_2 district , nofreq col
	tab gov_3 district , nofreq col
	tab gov_4 district , nofreq col
	
	
*************Table 38. Percent of People Who Have Medical, Social and Other Insurances (%)
***************************************

	foreach x in 1 2 5 7 8 9 10 12 {
		tab insur_`x' district, col nofreq
	}


*************Table 39. Demographics of Household Heads by Gender 
***************************************

	tab hh_head_male
	tabstat hh_head_married hh_head_lasthome hh_head_age hh_size hh_head_edyrs hashaa_area bus_activ , by(hh_head_male)


*************Table 40. Gender of Interview Participant
***************************************

	*We need to convert the dataset to long form by family member for this table
			/* Question 2_3_1-7
		HH memberâ€™s participation level in the interview 
		1=Main respondent
		2=Contributing respondent  
		3=Did not participate 
		 */
		preserve
		keep no q2_3_* q2_5_*
		reshape long  q2_3_ q2_5_ , i(no) j(member_num)	 
		rename q2_3_ partic
		replace partic=. if partic==4
		rename q2_5_ sex
		
		tab partic sex if partic<3
		tab partic sex if partic<3, nofreq row
		*tab partic sex if partic<3,  m
		restore

	
*************Table 41. Name on Property Registration Certificate
***************************************

	*This is for anyone who has at least a possession certificate, and who was
	*considered an owner of the plot from question 1.16
		tab whose_name 


*************Table 42. How Hashaa was acquired, by Gender of Title Holder
***************************************

	*This is only reported for the first listed piece of land owned.
		tab q4_6_1 whose_name , col nofreq // q4_6_1 is how the first piece of land qas acquired

	
*************Table 43. Gender of Respondents who inherited Their Hashaa
***************************************

	*This is only reported for the first listed piece of land owned.
		tab hh_land_inherited whose_name , row nofreq

		
*************Table 44. Gender of Individual in Charge of Registration for Households Registering (%)
***************************************

	*This is only valid for those without full title over their property
		tab who_registers hh_head_male, col nofreq

	
*************Table 45. Control of Loans by Gender (Number of Loans)
***************************************

	tabstat *_loans_* , by(hh_head_male)
	tabstat total_loans , by(hh_head_male)

	
*************Table 46. Unsuccessful Attempt at Obtaining a Loan by Gender (%)
***************************************

	tab loan_unsucc hh_head_male, col nofreq
	tab loan_unsucc_reas hh_head_male, col nofreq

	
*************Table 47. Household Assets, by Gender of Household Head
***************************************

	tabstat struct_plusone struct_val has_vehicle, by(hh_head_male)


*************Table 48. Household Expenditures, by Gender of Household Head
***************************************

	tabstat total_exp *_prop, by(hh_head_male)
	
	
*************Table 49. Satisfaction Level with Services Received during the Registration Process by Gender (%)
***************************************

	tab possess_satis hh_head_male , nofreq col
	tab gov_satis hh_head_male , nofreq col
	tab title_satis hh_head_male , nofreq col


*************Table 50. Kheseg Distribution and Rate of Privatization by City and District
***************************************
	tabstat num_hesegs, by(district) // number of hesegs by district
	codebook fin_heseg,c // overall number of hesegs
	tabstat av_ownership4, by(district)
	tabstat num_plots if firstplot, by(district)

	
*************Table 51. Alterations Made to Kheseg Units
***************************************
	*This table was created separately from the SHPS dataset


*************Table 52. Distribution of Treatment and Control Plots
***************************************
	tab city if treatment==1
	tab city if treatment==0
	tab city
	

*************Table 53. Balance Test
***************************************
	*This table is created in do-file "5 SHPS Baseline Report Balance Tests"


*************Table 54. Timeline for Formalization Contractors and SHPS Data Collection
***************************************
	*This table was created separately from the SHPS dataset
	
	
	
	
***************************************
	
	capture log close
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
