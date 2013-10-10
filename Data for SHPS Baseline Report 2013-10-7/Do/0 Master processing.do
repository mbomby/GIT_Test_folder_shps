
*This do-file was created by IPA-Mongolia for use in the MCA-M Property Rights Project

*Name: SHPS Master Processing.do
*Description: Append UB and Darhan/Erdenet datasets, merge in trt/ctrl status, clean missing values,
	*recode binary variables, and other data cleaning associated with the SHPS baseline survey.
	
*Created by: Matthew Bombyk and Ken Lee
*Date Created: October 5, 2012
*Modified By (List all): MB, KL
*Last modified by: Matthew Bombyk
*Date Last Modified: Sept 20, 2013

*Log of major changes:
	*

*Uses data: 
	*shps_baseline_pii_removed.dta

*Creates data: 
	*
	*
	

********************************************************************************

	set more off
	cd "C:\IPA\2Urban\Reports & Analysis\SHPS Baseline Report\Revision Sept 2013\Data for SHPS Baseline Report 2013-10-7" 
	gl gis "Original/GIS Sample"
	gl treat "Original/Treatment Status"
	gl dopath "Do"
	cap erase "temp/SHPS_GISsample_merged.dta"
	cap erase "temp/SHPS_MergedWithTrtStatus_PreCleaning.dta"	

	cap mkdir temp
	

	
********************************************************************************

*1. Merge in heseg ID's from GIS sample dataset

	do "$dopath/1 Merge in heseg IDs.do"
	
	
*2. Merge in treatment/control status and related variables

	do "$dopath/2 Merge in treatment status.do"
	
	
*3. Basic data cleaning (recoding (esp binary and string); modifying, fixing and renaming value 
	*labels or variable labels; identifying and fixing logical errors; flagging and checking outliers;
	*fixing unintended missing values)
	*Eventually once I've done this enough, some of these especially the logic check should
	*get their own section.
	
	do "$dopath/3 Basic Data Cleaning.do"
	// saves ____.dta
	

*4. Create new variables for analysis and create tables for baseline report.

	do "$dopath/4a SHPS Baseline Report Table Making 2013-9-23.do"
	
	
*5. Create balance test regression tables for baseline report.

	do "$dopath/5 SHPS Baseline Report Balance Tests 2013-10-7.do"

	
*Erase temporary files
	cap erase "temp/SHPS_GISsample_merged.dta"
	cap erase "temp/SHPS_MergedWithTrtStatus_PreCleaning.dta"	
	



	cap rmdir temp

	cap log close
