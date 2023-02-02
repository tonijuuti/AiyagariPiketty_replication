use "$loc\Data\data_historical_5yr.dta", clear
rename p99p100 top1
rename p90p100 top10
rename p999p100 top01
egen long id = group(country)
xtset id year, delta(5)
format capsh_net %9.0g
format capsh_gross %9.0g
drop if year<1950
drop if country=="NZ"

********************************************************************************

/*
Top 10 % share and capital share net of capital depreciation: regression table
*/

cd "$loc\Tables"

preserve // High stock market cap to GDP
replace top10=log(top10)
keep if mcap_gdp_high==1
* Convergence year dummies and controls only
qui xtreg y L.avg_log_gdppc i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdhigh_top10kshn_fe, replace dta dec(4)
* The previous and top10 share
qui xtreg y L.avg_log_gdppc L.top10 i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdhigh_top10kshn_fe, append dta dec(4)
* The previous and capital share, no interaction yet
qui xtreg y L.avg_log_gdppc L.top10 L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdhigh_top10kshn_fe, append dta dec(4)
* The main regression
qui xtreg y L.avg_log_gdppc c.L.top10##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdhigh_top10kshn_fe, append dta dec(4)
	test L.top10 L.top10#L.capsh_net
	test L.capsh_net L.top10#L.capsh_net
	test L.top10 L.capsh_net L.top10#L.capsh_net
restore
preserve // Low stock market cap to GDP
replace top10=log(top10)
keep if mcap_gdp_high==0
* Convergence year dummies and controls only
qui xtreg y L.avg_log_gdppc i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdlow_top10kshn_fe, replace dta dec(4)
* The previous and top 10 share
qui xtreg y L.avg_log_gdppc L.top10 i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdlow_top10kshn_fe, append dta dec(4)
* The previous and capital share, no interaction yet
qui xtreg y L.avg_log_gdppc L.top10 L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdlow_top10kshn_fe, append dta dec(4)
* The main regression
qui xtreg y L.avg_log_gdppc c.L.top10##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdlow_top10kshn_fe, append dta dec(4)
	test L.top10 L.top10#L.capsh_net
	test L.capsh_net L.top10#L.capsh_net
	test L.top10 L.capsh_net L.top10#L.capsh_net
restore

preserve
use fdlow_top10kshn_fe_dta, clear
gen nr=_n
drop v1
rename v2 v6
rename v3 v7
rename v4 v8
rename v5 v9
save fdlow_top10kshn_fe_dta, replace
use fdhigh_top10kshn_fe_dta, clear
gen nr=_n
merge 1:1 nr using fdlow_top10kshn_fe_dta
drop _merge
drop if nr>=12 & nr<=48
replace v1="Controls and year and country dummies" if nr==52
foreach var of varlist v2 v3 v4 v5 v6 v7 v8 v9 {
	replace `var' = "Yes" if nr==52
}
replace v1="Standard errors are clustered at the country level. Significance levels: *** p<0.01, ** p<0.05, * p<0.1" ///
	if nr==53
drop if nr==3
replace nr=0 if nr==2
foreach var of varlist v2 v3 v4 v5 v6 v7 v8 v9 {
	replace `var' = "" if nr==0
}
replace v2="High FD" if nr==0
replace v6="Low FD" if nr==0
replace nr=48 if nr==51
sort nr
replace v6="(5)" if nr==1
replace v7="(6)" if nr==1
replace v8="(7)" if nr==1
replace v9="(8)" if nr==1
replace v1="Per capita GDP" if nr==4
replace v1="Top 10 % share" if nr==6
replace v1="Capital share" if nr==8
replace v1="Top 10 % share * Capital share" if nr==10
replace v1="Number of countries" if nr==48
replace v1="Number of growth windows" if nr==49
drop nr
export excel using top10kshn_fe.xlsx, replace
restore
erase fdhigh_top10kshn_fe_dta.dta
erase fdhigh_top10kshn_fe.txt
erase fdlow_top10kshn_fe_dta.dta
erase fdlow_top10kshn_fe.txt

/*
Top 1 % share and capital share net of capital depreciation: regression table
*/

cd "$loc\Tables"

preserve // High stock market cap to GDP
replace top1=log(top1)
keep if mcap_gdp_high==1
* Convergence year dummies and controls only
qui xtreg y L.avg_log_gdppc i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdhigh_top1kshn_fe, replace dta dec(4)
* The previous and top1 share
qui xtreg y L.avg_log_gdppc L.top1 i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdhigh_top1kshn_fe, append dta dec(4)
* The previous and capital share, no interaction yet
qui xtreg y L.avg_log_gdppc L.top1 L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdhigh_top1kshn_fe, append dta dec(4)
* The main regression
qui xtreg y L.avg_log_gdppc c.L.top1##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdhigh_top1kshn_fe, append dta dec(4)
	test L.top1 L.top1#L.capsh_net
	test L.capsh_net L.top1#L.capsh_net
	test L.top1 L.capsh_net L.top1#L.capsh_net
restore
preserve // Low stock market cap to GDP
replace top1=log(top1)
keep if mcap_gdp_high==0
* Convergence year dummies and controls only
qui xtreg y L.avg_log_gdppc i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdlow_top1kshn_fe, replace dta dec(4)
* The previous and top 1 share
qui xtreg y L.avg_log_gdppc L.top1 i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdlow_top1kshn_fe, append dta dec(4)
* The previous and capital share, no interaction yet
qui xtreg y L.avg_log_gdppc L.top1 L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdlow_top1kshn_fe, append dta dec(4)
* The main regression
qui xtreg y L.avg_log_gdppc c.L.top1##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdlow_top1kshn_fe, append dta dec(4)
	test L.top1 L.top1#L.capsh_net
	test L.capsh_net L.top1#L.capsh_net
	test L.top1 L.capsh_net L.top1#L.capsh_net
restore

preserve
use fdlow_top1kshn_fe_dta, clear
gen nr=_n
drop v1
rename v2 v6
rename v3 v7
rename v4 v8
rename v5 v9
save fdlow_top1kshn_fe_dta, replace
use fdhigh_top1kshn_fe_dta, clear
gen nr=_n
merge 1:1 nr using fdlow_top1kshn_fe_dta
drop _merge
drop if nr>=12 & nr<=48
replace v1="Controls and year and country dummies" if nr==52
foreach var of varlist v2 v3 v4 v5 v6 v7 v8 v9 {
	replace `var' = "Yes" if nr==52
}
replace v1="Standard errors are clustered at the country level. Significance levels: *** p<0.01, ** p<0.05, * p<0.1" ///
	if nr==53
drop if nr==3
replace nr=0 if nr==2
foreach var of varlist v2 v3 v4 v5 v6 v7 v8 v9 {
	replace `var' = "" if nr==0
}
replace v2="High FD" if nr==0
replace v6="Low FD" if nr==0
replace nr=48 if nr==51
sort nr
replace v6="(5)" if nr==1
replace v7="(6)" if nr==1
replace v8="(7)" if nr==1
replace v9="(8)" if nr==1
replace v1="Per capita GDP" if nr==4
replace v1="Top 1 % share" if nr==6
replace v1="Capital share" if nr==8
replace v1="Top 1 % share * Capital share" if nr==10
replace v1="Number of countries" if nr==48
replace v1="Number of growth windows" if nr==49
drop nr
export excel using top1kshn_fe.xlsx, replace
restore
erase fdhigh_top1kshn_fe_dta.dta
erase fdhigh_top1kshn_fe.txt
erase fdlow_top1kshn_fe_dta.dta
erase fdlow_top1kshn_fe.txt

/*
Top 0.1 % share and capital share net of capital depreciation: regression table
*/

cd "$loc\Tables"

preserve // High stock market cap to GDP
replace top01=log(top01)
keep if mcap_gdp_high==1
* Convergence year dummies and controls only
qui xtreg y L.avg_log_gdppc i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdhigh_top01kshn_fe, replace dta dec(4)
* The previous and top 0.1 share
qui xtreg y L.avg_log_gdppc L.top01 i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdhigh_top01kshn_fe, append dta dec(4)
* The previous and capital share, no interaction yet
qui xtreg y L.avg_log_gdppc L.top01 L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdhigh_top01kshn_fe, append dta dec(4)
* The main regression
qui xtreg y L.avg_log_gdppc c.L.top01##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdhigh_top01kshn_fe, append dta dec(4)
	test L.top01 L.top01#L.capsh_net
	test L.capsh_net L.top01#L.capsh_net
	test L.top01 L.capsh_net L.top01#L.capsh_net
restore
preserve // Low stock market cap to GDP
replace top01=log(top01)
keep if mcap_gdp_high==0
* Convergence year dummies and controls only
qui xtreg y L.avg_log_gdppc i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdlow_top01kshn_fe, replace dta dec(4)
* The previous and top01 share
qui xtreg y L.avg_log_gdppc L.top01 i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdlow_top01kshn_fe, append dta dec(4)
* The previous and capital share, no interaction yet
qui xtreg y L.avg_log_gdppc L.top01 L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdlow_top01kshn_fe, append dta dec(4)
* The main regression
qui xtreg y L.avg_log_gdppc c.L.top01##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	outreg2 using fdlow_top01kshn_fe, append dta dec(4)
	test L.top01 L.top01#L.capsh_net
	test L.capsh_net L.top01#L.capsh_net
	test L.top01 L.capsh_net L.top01#L.capsh_net
restore

preserve
use fdlow_top01kshn_fe_dta, clear
gen nr=_n
drop v1
rename v2 v6
rename v3 v7
rename v4 v8
rename v5 v9
save fdlow_top01kshn_fe_dta, replace
use fdhigh_top01kshn_fe_dta, clear
gen nr=_n
merge 1:1 nr using fdlow_top01kshn_fe_dta
drop _merge
drop if nr>=12 & nr<=48
replace v1="Controls and year and country dummies" if nr==52
foreach var of varlist v2 v3 v4 v5 v6 v7 v8 v9 {
	replace `var' = "Yes" if nr==52
}
replace v1="Standard errors are clustered at the country level. Significance levels: *** p<0.01, ** p<0.05, * p<0.1" ///
	if nr==53
drop if nr==3
replace nr=0 if nr==2
foreach var of varlist v2 v3 v4 v5 v6 v7 v8 v9 {
	replace `var' = "" if nr==0
}
replace v2="High FD" if nr==0
replace v6="Low FD" if nr==0
replace nr=48 if nr==51
sort nr
replace v6="(5)" if nr==1
replace v7="(6)" if nr==1
replace v8="(7)" if nr==1
replace v9="(8)" if nr==1
replace v1="Per capita GDP" if nr==4
replace v1="Top 0.1 % share" if nr==6
replace v1="Capital share" if nr==8
replace v1="Top 0.1 % share * Capital share" if nr==10
replace v1="Number of countries" if nr==48
replace v1="Number of growth windows" if nr==49
drop nr
export excel using top01kshn_fe.xlsx, replace
restore
erase fdhigh_top01kshn_fe_dta.dta
erase fdhigh_top01kshn_fe.txt
erase fdlow_top01kshn_fe_dta.dta
erase fdlow_top01kshn_fe.txt

********************************************************************************

/*
Top 10 % share and capital share net of capital depreciation: the main result graphically
*/

preserve
replace top10=log(top10)
keep if mcap_gdp_high==1
qui xtreg y L.avg_log_gdppc c.L.top10##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	*
	test L.top10 L.top10#L.capsh_net
	*
	test L.capsh_net L.top10#L.capsh_net
	*
	test L.top10 L.capsh_net L.top10#L.capsh_net
qui margins, dydx(L.top10) at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP > 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.2 0.2)) ylabel(-0.2(0.1)0.2) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(highfd, replace)
restore
preserve
replace top10=log(top10)
keep if mcap_gdp_high==0
qui xtreg y L.avg_log_gdppc c.L.top10##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	*
	test L.top10 L.top10#L.capsh_net
	*
	test L.capsh_net L.top10#L.capsh_net
	*
	test L.top10 L.capsh_net L.top10#L.capsh_net
qui margins, dydx(L.top10) at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP < 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.2 0.2)) ylabel(-0.2(0.1)0.2) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(lowfd, replace)
restore
gr combine highfd lowfd, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("A: Top 10 % income share", size(medsmall)) ysize(3) graphr(c(white)) name(top10_kshn, replace)
gr drop highfd lowfd

/*
Top 1 % share and capital share net of capital depreciation
*/

preserve
replace top1=log(top1)
keep if mcap_gdp_high==1
qui xtreg y L.avg_log_gdppc c.L.top1##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	*
	test L.top1 L.top1#L.capsh_net
	*
	test L.capsh_net L.top1#L.capsh_net
	*
	test L.top1 L.capsh_net L.top1#L.capsh_net
qui margins, dydx(L.top1) at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP > 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.2 0.2)) ylabel(-0.2(0.1)0.2) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(highfd, replace)
restore
preserve
replace top1=log(top1)
keep if mcap_gdp_high==0
qui xtreg y L.avg_log_gdppc c.L.top1##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	*
	test L.top1 L.top1#L.capsh_net
	*
	test L.capsh_net L.top1#L.capsh_net
	*
	test L.top1 L.capsh_net L.top1#L.capsh_net
qui margins, dydx(L.top1) at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP < 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.2 0.2)) ylabel(-0.2(0.1)0.2) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(lowfd, replace)
restore
gr combine highfd lowfd, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("B: Top 1 % income share", size(medsmall)) ysize(3) graphr(c(white)) name(top1_kshn, replace)
gr drop highfd lowfd
	
/*
Top 0.1 % share and capital share net of capital depreciation
*/

preserve
replace top01=log(top01)
keep if mcap_gdp_high==1
qui xtreg y L.avg_log_gdppc c.L.top01##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	*
	test L.top01 L.top01#L.capsh_net
	*
	test L.capsh_net L.top01#L.capsh_net
	*
	test L.top01 L.capsh_net L.top01#L.capsh_net
qui margins, dydx(L.top01) at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP > 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.2 0.2)) ylabel(-0.2(0.1)0.2) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(highfd, replace)
restore
preserve
replace top01=log(top01)
keep if mcap_gdp_high==0
qui xtreg y L.avg_log_gdppc c.L.top01##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	*
	test L.top01 L.top01#L.capsh_net
	*
	test L.capsh_net L.top01#L.capsh_net
	*
	test L.top01 L.capsh_net L.top01#L.capsh_net
qui margins, dydx(L.top01) at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP < 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.2 0.2)) ylabel(-0.2(0.1)0.2) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(lowfd, replace)
restore
gr combine highfd lowfd, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("C: Top 0.1 % income share", size(medsmall)) ysize(3) graphr(c(white)) name(top01_kshn, replace)
gr drop highfd lowfd

/*
Combine the three
*/

gr combine top10_kshn top1_kshn top01_kshn, col(1) scheme(s2mono) title("", size(medsmall)) ///
	ysize(6) graphr(c(white)) name(kshn, replace)
gr drop top1_kshn top10_kshn top01_kshn
graph export "$loc\Figures\Historical\pregr_kshn_fe.eps", as(eps) preview(off) replace
