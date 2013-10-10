
*Definitions, tables 50-54




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
	
	
	
	

	
	
	
	
	
************************************************************************************************************************************************************	
************************************************************************************************************************************************************
************************************************************************************************************************************************************
************************************************************************************************************************************************************
************************************************************************************************************************************************************
************************************************************************************************************************************************************
************************************************************************************************************************************************************
************************************************************************************************************************************************************
*Below: tablemaking





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
	
	


	
	
	