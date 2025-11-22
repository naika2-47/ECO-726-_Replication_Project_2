* Naika Jean Baptiste
* Replication Project Table VI

set more off
capture log close _all
clear all

global proj "/Users/naikajeanbaptiste/Documents/Eco 726/Project 2"
global raw     "$proj"
global tables  "$proj/tables"
global logs    "$proj/logs"

* Create folders if they don't exist
capture mkdir "$tables"
capture mkdir "$logs"

* ---- OPTIONAL: log file for tables ----
log using "$logs/table.log", name(tbl) replace 

use "$raw/raw_data.dta", clear
export delimited using "$raw/raw_data.csv", replace


******************** Table 6

rename v1  age 
rename v2  ageq
rename v4  educ
rename v5  enocent
rename v6  esocent
rename v9  lwklywge
rename v10 married
rename v11 midatl
rename v12 mt
rename v13 neweng
rename v16 census
rename v18 qob
rename v19 race
rename v20 smsa
rename v21 soatl
rename v24 wnocent
rename v25 wsocent
rename v27 yob


* verifying the data 
keep if census==80
assert census==80 

replace yob = yob - 1900 if yob >= 1900

keep if inrange(yob, 40, 49)

drop if missing(lwklywge, educ, qob, yob)


* creating new variables
generate ageqsq = ageq^2
*** end part a

* Part b: Reproducing Angrist and Krueger's Table 6
eststo clear


* Model 1
regress lwklywge educ i.yob
eststo column_1

* Model 2
gen q1 = qob == 1
ivregress 2sls lwklywge (educ = q1) i.yob
eststo column_2
estat firststage


* Model 3
regress lwklywge educ ageq ageqsq ib49.yob
eststo column_3

* Model 4
ivregress 2sls lwklywge (educ = q1) ageq ageqsq i.yob
eststo column_4



* Model 5
regress lwklywge educ race smsa married ///
        neweng midatl enocent wnocent soatl esocent wsocent mt ///
        i.yob
eststo column_5

* Model 6
gen byte q2 = (qob==2)
gen byte q3 = (qob==3)
gen byte q4 = (qob==4)
ivregress 2sls lwklywge (educ = q2 q3 q4) ///
        race smsa married ///
        neweng midatl enocent wnocent soatl esocent wsocent mt ///
        i.yob, first
eststo column_6
estat firststage
estat overid

* Model 7
regress lwklywge educ ageq ageqsq race smsa married ///
        neweng midatl enocent wnocent soatl esocent wsocent mt ///
        i.yob
eststo column_7

* Model 8 
ivregress 2sls lwklywge (educ = q2 q3 q4) ///
        ageq ageqsq race smsa married ///
        neweng midatl enocent wnocent soatl esocent wsocent mt ///
        i.yob, first
eststo column_8
estat firststage

*** end part b


* Part c: Reproducing Angrist and Krueger's Table 6

*  Writing the reproduced table to log file
esttab column_1 column_2 column_3 column_4 ///
       column_5 column_6 column_7 column_8, ///
    b(%9.4f) se(%9.4f) ///
    stats(r2, labels("R^2")) ///
    nodepvars nostar obslast nobaselevels alignment(r) ///
    title("TABLE VI: OLS and TSLS Estimates") ///
    mtitles("OLS" "TSLS" "OLS" "TSLS" "OLS" "TSLS" "OLS" "TSLS") ///
    coeflabels(_cons   "Constant" ///
               educ    "Years of Education" ///
               race    "Race(1=Black)" ///
               smsa    "SMSA (1=Center City)" ///
               married "Married(1=Married)" ///
               ageq    "Age" ///
               ageqsq  "Age-Squared") ///
    indicate("Year-of-Birth dummies = *.yob" ///
             "Region dummies = neweng midatl enocent wnocent soatl esocent wsocent mt") ///
    order(_cons educ race smsa married *.yob ageq ageqsq) ///
	 addnotes("Standard errors in parentheses. Sample: men born 1940–1949 in the 1980 Census. TSLS uses quarter-of-birth × year-of-birth interactions as instruments. Models include a constant, year-of-birth dummies, and additional controls as indicated. Outcome is log weekly wages.") ///
    replace
   

* Writing the reproduced table to LaTex
esttab column_1 column_2 column_3 column_4 ///
       column_5 column_6 column_7 column_8 using ///
    "$tables/Table_6_Jean-Baptiste.tex", ///
    b(%9.4f) se(%9.4f) ///
    stats(r2, labels("R^2")) ///
    nodepvars nostar obslast nobaselevels alignment(r) ///
    title("TABLE VI: OLS and TSLS Estimates") ///
    mtitles("OLS" "TSLS" "OLS" "TSLS" "OLS" "TSLS" "OLS" "TSLS") ///
    coeflabels(_cons   "Constant" ///
               educ    "Years of Education" ///
               race    "Race(1=Black)" ///
               smsa    "SMSA (1=Center City)" ///
               married "Married(1=Married)" ///
               ageq    "Age" ///
               ageqsq  "Age-Squared") ///
    indicate("Year-of-Birth dummies = *.yob" ///
             "Region dummies = neweng midatl enocent wnocent soatl esocent wsocent mt") ///
    order(_cons educ race smsa married *.yob ageq ageqsq) ///
	 addnotes("Standard errors in parentheses. Sample: men born 1940–1949 in the 1980 Census. TSLS uses quarter-of-birth × year-of-birth interactions as instruments. Models include a constant, year-of-birth dummies, and additional controls as indicated. Outcome is log weekly wages.") ///
    replace
  
	
log close tbl
   
*** end part c

