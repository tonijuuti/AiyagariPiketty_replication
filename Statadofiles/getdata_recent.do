cd "$loc\Data"

/*
Capital share directly from the WID, pre-tax national income
*/

wid, ind(wcapsh) clear
keep country year value
rename value Ksh_wid
save WID_capsh.dta, replace

/*
Top income shares, pre-tax national income
*/

wid, ind(sptinc) perc(p99p100) pop(j) clear // retrieves top 1 share, equal-splits as the unit
gen lngth=length(country) // keep only the nation states
drop if lngth>2
keep country year value
rename value p99p100
collapse p99p100, by(country year)
label var p99p100 "Top 1 % share (equal-splits)"
save WID_p99p100.dta, replace

wid, ind(sptinc) perc(p99.9p100) pop(j) clear // retrieves top 0.1 share, equal-splits as the unit
gen lngth=length(country) // keep only the nation states
drop if lngth>2
keep country year value
rename value p999p100
collapse p999p100, by(country year)
label var p999p100 "Top 0.1 % share (equal-splits)"
save WID_p999p100.dta, replace

wid, ind(sptinc) perc(p90p100) pop(j) clear // retrieves top 10 share, equal-splits as the unit
gen lngth=length(country) // keep only the nation states
drop if lngth>2
keep country year value
rename value p90p100
collapse p90p100, by(country year)
label var p90p100 "Top 10 % share (equal-splits)"
save WID_p90p100.dta, replace

wid, ind(sptinc) perc(p0p50) pop(j) clear // retrieves bottom 50 share, equal-splits as the unit
gen lngth=length(country) // keep only the nation states
drop if lngth>2
keep country year value
rename value p0p50
collapse p0p50, by(country year)
label var p0p50 "Bottom 50 % share (equal-splits)"
save WID_p0p50.dta, replace

wid, ind(gptinc) pop(j) clear // retrieves Gini, equal-splits as the unit
gen lngth=length(country) // keep only the nation states
drop if lngth>2
keep country year value
rename value gini
collapse gini, by(country year)
label var gini "Gini (equal-splits)"
save WID_gini.dta, replace

/*
Top income shares, post-tax national income
*/

wid, ind(sdiinc) perc(p99p100) pop(j) clear // retrieves top 1 share, equal-splits as the unit
gen lngth=length(country) // keep only the nation states
drop if lngth>2
keep country year value
rename value p99p100_dspi
collapse p99p100_dspi, by(country year)
label var p99p100_dspi "Top 1 % share (equal-splits)"
save WID_p99p100_dspi.dta, replace

wid, ind(sdiinc) perc(p99.9p100) pop(j) clear // retrieves top 0.1 share, equal-splits as the unit
gen lngth=length(country) // keep only the nation states
drop if lngth>2
keep country year value
rename value p999p100_dspi
collapse p999p100_dspi, by(country year)
label var p999p100_dspi "Top 0.1 % share (equal-splits)"
save WID_p999p100_dspi.dta, replace

wid, ind(sdiinc) perc(p90p100) pop(j) clear // retrieves top 10 share, equal-splits as the unit
gen lngth=length(country) // keep only the nation states
drop if lngth>2
keep country year value
rename value p90p100_dspi
collapse p90p100_dspi, by(country year)
label var p90p100_dspi "Top 10 % share (equal-splits)"
save WID_p90p100_dspi.dta, replace

wid, ind(sdiinc) perc(p0p50) pop(j) clear // retrieves bottom 50 share, equal-splits as the unit
gen lngth=length(country) // keep only the nation states
drop if lngth>2
keep country year value
rename value p0p50_dspi
collapse p0p50_dspi, by(country year)
label var p0p50_dspi "Bottom 50 % share (equal-splits)"
save WID_p0p50_dspi.dta, replace

wid, ind(gdiinc) pop(j) clear // retrieves Gini, equal-splits as the unit
gen lngth=length(country) // keep only the nation states
drop if lngth>2
keep country year value
rename value gini_dspi
collapse gini_dspi, by(country year)
label var gini_dspi "Gini (equal-splits)"
save WID_gini_dspi.dta, replace

/*
Open the Bachas et al. (2021) data and merge the other files
*/

cd "$loc\Data\Original"
use Bachasetal_data.dta, clear
cd "$loc\Data"
kountry country, from(iso3c) to(iso2c)
drop country
rename _ISO2C_ country
order country
keep country year imputed Ksh_nni Ksh_ndp Ksh_gdp
drop if country==""

merge 1:1 country year using WID_capsh.dta
drop if _merge==2
drop _merge
merge 1:1 country year using WID_p99p100.dta
drop if _merge==2
drop _merge
merge 1:1 country year using WID_p999p100.dta
drop if _merge==2
drop _merge
merge 1:1 country year using WID_p90p100.dta
drop if _merge==2
drop _merge
merge 1:1 country year using WID_p0p50.dta
drop if _merge==2
drop _merge
merge 1:1 country year using WID_gini.dta
drop if _merge==2
drop _merge
keep if p99p100!=. & p999p100!=. & p90p100!=. & p0p50!=. & gini!=.
merge 1:1 country year using WID_p99p100_dspi.dta
drop if _merge==2
drop _merge
merge 1:1 country year using WID_p999p100_dspi.dta
drop if _merge==2
drop _merge
merge 1:1 country year using WID_p90p100_dspi.dta
drop if _merge==2
drop _merge
merge 1:1 country year using WID_p0p50_dspi.dta
drop if _merge==2
drop _merge
merge 1:1 country year using WID_gini_dspi.dta
drop if _merge==2
drop _merge

erase WID_capsh.dta
erase WID_p99p100.dta
erase WID_p999p100.dta
erase WID_p90p100.dta
erase WID_p0p50.dta
erase WID_gini.dta
erase WID_p99p100_dspi.dta
erase WID_p999p100_dspi.dta
erase WID_p90p100_dspi.dta
erase WID_p0p50_dspi.dta
erase WID_gini_dspi.dta

/*
Collapse the data into 5-year non-overlapping windows, proceed with a balanced panel,
label variables and save
*/

gen period = 5 * floor(year/5)
collapse imputed-gini_dspi, by(country period)
rename period year
tab year // data for very few countries pre-1980
drop if year<1980

bysort country: gen nobs = _N // balanced panel: 8 windows for 142 countries
keep if nobs==8
drop nobs

*label var capsh ""

save Bachasetal_WID_merged_5yr.dta, replace

/*
Real GDP per capita and capital stock
*/

cd "$loc\Data\Original"
use pwt100.dta, clear
cd "$loc\Data"
egen long id = group(country)
xtset id year, yearly
gen rgdpe_pc = rgdpe / pop
keep countrycode id year rgdpe_pc cn
gen l_rgdpe_pc = log(rgdpe_pc)
gen y = (F4.l_rgdpe_pc-l_rgdpe_pc)/4
gen l_rgdpe_pc_tminus1 = L.l_rgdpe_pc
gen avg_log_gdppc = (l_rgdpe_pc+F1.l_rgdpe_pc+F2.l_rgdpe_pc+F3.l_rgdpe_pc+F4.l_rgdpe_pc)/5
gen l_cn = log(cn)
gen d_cn = (F4.l_cn-l_cn)/4
gen avg_log_cn = (l_cn+F1.l_cn+F2.l_cn+F3.l_cn+F4.l_cn)/5
drop if year<1980
drop if year==1981
drop if year==1982
drop if year==1983
drop if year==1984
drop if year==1986
drop if year==1987
drop if year==1988
drop if year==1989
drop if year==1991
drop if year==1992
drop if year==1993
drop if year==1994
drop if year==1996
drop if year==1997
drop if year==1998
drop if year==1999
drop if year==2001
drop if year==2002
drop if year==2003
drop if year==2004
drop if year==2006
drop if year==2007
drop if year==2008
drop if year==2009
drop if year==2011
drop if year==2012
drop if year==2013
drop if year==2014
drop if year>=2016
drop id
kountry countrycode, from(iso3c) to(iso2c)
drop countrycode
rename _ISO2C_ country
order country year
duplicates drop
drop if country==""
save PWT_80to15_5yr.dta, replace

/*
Controls
*/

cd "$loc\Data\Original"
use pwt100.dta, clear
cd "$loc\Data"
egen long id = group(country)
xtset id year, yearly
gen log_pop = log(pop) // population growth
gen d_pop = log_pop - L.log_pop
keep countrycode year d_pop csh_i csh_g
kountry countrycode, from(iso3c) to(iso2c)
drop countrycode
rename _ISO2C_ country
order country year
duplicates drop
drop if country==""
gen period = 5 * floor(year/5)
collapse csh_i csh_g d_pop, by(country period)
rename period year
save PWT_cntrls_5yr.dta, replace

/*
World Bank data on stock market capitalization to GDP
*/

cd "$loc\Data"
wbopendata, indicator(GFDD.DI.01; GFDD.DM.01) long clear 
kountry countrycode, from(iso3c) to(iso2c)
rename _ISO2C_ country
rename gfdd_di_01 mcap_gdp_wb
rename gfdd_dm_01 cred_gdp_wb
drop if country==""
gen period = 5 * floor(year/5)
collapse mcap_gdp_wb cred_gdp_wb, by(country period)
rename period year
save WBFindev_5yr.dta, replace

/*
Multidimensional financial development
*/

cd "$loc\Data\Original"
use Svirydzenka_all.dta, clear
cd "$loc\Data"
kountry code, from(iso3c) to(iso2c)
drop ifs-imf_income
rename _ISO2C_ country
order country
drop FID-FME
sort country year
drop if country==""
gen period = 5 * floor(year/5)
collapse FD-FM, by(country period)
rename period year
save Svir_5yr.dta, replace

/*
Educational attainment from Barro & Lee
*/

cd "$loc\Data\Original"
use BarroLee.dta, clear
cd "$loc\Data"
kountry country, from(other) stuck marker
rename _ISO3N_ countrycode
kountry countrycode, from(iso3n) to(iso2c)
drop country
rename _ISO2C_ country
order country year
keep country year lu-yr_sch_ter
save BarroLee_5yr.dta, replace

/*
Disposable income inequality from the WIID
*/

cd "$loc\Data\Original"
use WIID_companion.dta, clear
cd "$loc\Data"
keep c2 year gini_std
rename c2 country
rename gini_std gini_wiid4
sort country year
drop if country==""
gen period = 5 * floor(year/5)
collapse gini_wiid4, by(country period)
rename period year
drop if year<1950
save WIID4Gini_5yr.dta, replace

/*
Combine the different data sets
*/

cd "$loc\Data"
use PWT_80to15_5yr, clear
merge 1:1 country year using Bachasetal_WID_merged_5yr.dta
keep if _merge==3
drop _merge
merge 1:1 country year using WBFindev_5yr.dta
drop if _merge==2
drop _merge
merge 1:1 country year using Svir_5yr.dta
keep if _merge==3
drop _merge
merge 1:1 country year using PWT_cntrls_5yr.dta
drop if _merge==2
drop _merge
merge 1:1 country year using BarroLee_5yr.dta
drop if _merge==2
drop _merge
merge 1:1 country year using WIID4Gini_5yr.dta
drop if _merge==2
drop _merge

/*
Find countries with clear data issues
*/

egen long id = group(country)
xtset id year, delta(5)
preserve // the distributional measures
gen tag=0
replace tag=1 if D.Ksh_nni<-0.1 & D.Ksh_nni!=.
replace tag=1 if D.Ksh_nni>0.1 & D.Ksh_nni!=.
replace tag=1 if D.p99p100<-0.05 & D.p99p100!=.
replace tag=1 if D.p99p100>0.05 & D.p99p100!=.
count if tag==1
bysort country: egen max_tag = max(tag)
drop if max_tag==0
collapse max_tag, by(country)
list
restore
/*foreach x in "AL" "AO" "BF" "BH" "BW" "CF" "CG" "CI" "CR" "CZ" "ET" "FI" "IS" "KE" "KM" "KW" "LK" "LS" "MM" "MR" "MV" "MW" "MZ" "NE" "NG" "PA" "PT" "QA" "SA" "SR" "SZ" "TT" "UY" {
preserve
keep if country=="`x'"
twoway line Ksh_nni year, lc(maroon) lp(solid) || line p99p100 year, lc(navy) lp(dash) || , ///
	graphr(c(white)) scheme(s2mono) ytitle("", col(gs2)) title("`x'", size(medium) color(black) nobox) ///
	xtitle("", size(medium) col(gs2)) legend(off) /// legend(order(1 "Capital share" 2 "Top 1 % income share") region(style(none)) cols(2)) ///
	xsc(range(1980 2015)) xlabel(1985(10)2015) ysc(range(0 0.8)) ylabel(0(0.2)0.8) name(tsdistr_`x', replace)
restore
}*/
preserve // growth
gen tag=0
replace tag=1 if y<-0.15
replace tag=1 if y>0.15
count if tag==1
bysort country: egen max_tag = max(tag)
drop if max_tag==0
sum y, d
collapse max_tag, by(country)
list
restore

/*
Drop the countries (17 in total) that show
- extreme growth rates or
- structural breaks in the distributional measures
*/
drop if country=="AR" | country=="CD" | country=="CI" | country=="CZ" | country=="CQ" | country=="KW" ///
	| country=="LB" | country=="LR" | country=="MV" | country=="MW" | country=="MZ" | country=="NG" ///
	| country=="PA" | country=="QA" | country=="RW" | country=="SL" | country=="SY" | country=="VE"
drop id
gr drop _all

save data_recent_5yr.dta, replace

erase PWT_80to15_5yr.dta
erase Bachasetal_WID_merged_5yr.dta
erase WBFindev_5yr.dta
erase Svir_5yr.dta
erase PWT_cntrls_5yr.dta
erase BarroLee_5yr.dta
erase WIID4Gini_5yr.dta
