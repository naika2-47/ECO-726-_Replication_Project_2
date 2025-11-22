* Naika Jean Baptiste
* Replication Project Figure 1 

set more off
cap log close _all
clear all

global proj "/Users/naikajeanbaptiste/Documents/Eco 726/Project 2"
global raw    "$proj"              // raw_data.dta is here
global figs   "$proj/figures"
global logs   "$proj/logs"

* Create folders if they don't exist
capture mkdir "$figs"
capture mkdir "$logs"


log using "$logs/figures.log", name(figs) replace 

use "$raw/raw_data.dta", clear
export delimited using "$raw/raw_data.csv", replace


rename v4  educ
rename v18 qob
rename v27 yob

* Treat year as just the last two digits
replace yob = yob - 1900 if yob >= 1900

* Keep 1930–1939 births, nonmissing
keep if inrange(yob, 30, 39)
drop if missing(yob, qob, educ)

* Collapse: mean years of education for each year × quarter cell
collapse (mean) mean_educ = educ, by(yob qob)

* Create a continuous x-axis: turns each year's 4 quarters into 4 evenly spaced points
gen x = yob + (qob - 1)/4

* Quarter label as text
gen qlabel = string(qob)

* Plot: line through all 40 points + quarter numbers
twoway ///
    (line mean_educ x, lcolor(black) lwidth(medthick) msymbol(none)) ///
    (scatter mean_educ x, ///
        msymbol(square) msize(medsmall) mcolor(black) ///
        mlabel(qlabel) mlabpos(6) mlabgap(4) ///
        mlabsize(medium) mlabcolor(black)) ///
    , ///
    xtitle("Year of Birth") ///
    ytitle("Years of Completed Education") ///
    xscale(range(30 40)) ///
    xlabel(30(1)40) ///
    ylabel(12.2(0.2)13.2, nogrid) ///
    legend(off) ///
    graphregion(color(white)) ///
    title("Years of Education and Season of Birth, 1980 Census") ///
    note("Quarter of birth is listed below each observation")
graph export "$figs/figure1.pdf", replace
	
log close fig1
