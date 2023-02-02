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

* Examine whether our findings can be explained by dependency to the level of inequality

/*
Top 10 % share and capital share net of capital depreciation
*/

preserve
gen top10lvl=top10
replace top10=log(top10)
keep if mcap_gdp_high==1
qui xtreg y L.avg_log_gdppc L.top10 c.L.top10#c.L.top10lvl i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
qui margins, dydx(L.top10) at(L.top10lvl=(0.235(0.025)0.460))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP > 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-1.55 1)) ylabel(-1.5(0.5)1) xtitle("Top 10 % income share", size(medsmall)) ///
	xlabel(0.25(0.1)0.45) name(highfd, replace)
restore
preserve
gen top10lvl=top10
replace top10=log(top10)
keep if mcap_gdp_high==0
qui xtreg y L.avg_log_gdppc L.top10 c.L.top10#c.L.top10lvl i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
qui margins, dydx(L.top10) at(L.top10lvl=(0.235(0.025)0.460))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP < 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-1.55 1)) ylabel(-1.5(0.5)1) xtitle("Top 10 % income share", size(medsmall)) ///
	xlabel(0.25(0.1)0.45) name(lowfd, replace)
restore
gr combine highfd lowfd, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("A: Top 10 % income share") ysize(3) graphr(c(white)) name(top10_kshn, replace)
gr drop highfd lowfd

/*
Top 1 % share and capital share net of capital depreciation
*/

preserve
gen top1lvl=top1
replace top1=log(top1)
keep if mcap_gdp_high==1
qui xtreg y L.avg_log_gdppc L.top1 c.L.top1#c.L.top1lvl i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
qui margins, dydx(L.top1) at(L.top1lvl=(0.045(0.025)0.19))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP > 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-1.55 1)) ylabel(-1.5(0.5)1) xtitle("Top 1 % income share", size(medsmall)) ///
	xlabel(0.05(0.05)0.15) name(highfd, replace)
restore
preserve
gen top1lvl=top1
replace top1=log(top1)
keep if mcap_gdp_high==0
qui xtreg y L.avg_log_gdppc L.top1 c.L.top1#c.L.top1lvl i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
qui margins, dydx(L.top1) at(L.top1lvl=(0.045(0.025)0.19))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP < 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-1.55 1)) ylabel(-1.5(0.5)1) xtitle("Top 1 % income share", size(medsmall)) ///
	xlabel(0.05(0.05)0.15) name(lowfd, replace)
restore
gr combine highfd lowfd, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("B: Top 1 % income share") ysize(3) graphr(c(white)) name(top1_kshn, replace)
gr drop highfd lowfd
	
/*
Top 0.1 % share and capital share net of capital depreciation
*/

preserve
gen top01lvl=top01
replace top01=log(top01)
keep if mcap_gdp_high==1
qui xtreg y L.avg_log_gdppc L.top01 c.L.top01#c.L.top01lvl i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
qui margins, dydx(L.top01) at(L.top01lvl=(0.01(0.025)0.09))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP > 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-1.55 1)) ylabel(-1.5(0.5)1) xtitle("Top 0.1 % income share", size(medsmall)) ///
	xlabel(0.02(0.02)0.08) name(highfd, replace)
restore
preserve
gen top01lvl=top01
replace top01=log(top01)
keep if mcap_gdp_high==0
qui xtreg y L.avg_log_gdppc L.top01 c.L.top01#c.L.top01lvl i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
qui margins, dydx(L.top01) at(L.top01lvl=(0.01(0.025)0.09))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP < 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-1.55 1)) ylabel(-1.5(0.5)1) xtitle("Top 0.1 % income share", size(medsmall)) ///
	xlabel(0.02(0.02)0.08) name(lowfd, replace)
restore
gr combine highfd lowfd, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("C: Top 0.1 % income share") ysize(3) graphr(c(white)) name(top01_kshn, replace)
gr drop highfd lowfd

/*
Combine the three
*/

gr combine top10_kshn top1_kshn top01_kshn, col(1) scheme(s2mono) title("", size(medsmall)) ///
	ysize(6) graphr(c(white)) name(ineq2, replace)
gr drop top1_kshn top10_kshn top01_kshn
graph export "$loc\Figures\Historical\pregr_ineq2_fe.eps", as(eps) preview(off) replace

********************************************************************************

* Examine whether our findings are robust to how capital depreciation is addressed

/*
Top 10 % share and capital share gross of capital depreciation: the main result graphically
*/

preserve
replace top10=log(top10)
keep if mcap_gdp_high==1
qui xtreg y L.avg_log_gdppc c.L.top10##c.L.capsh_gross i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	*
	test L.top10 L.top10#L.capsh_gross
	*
	test L.capsh_gross L.top10#L.capsh_gross
	*
	test L.top10 L.capsh_gross L.top10#L.capsh_gross
qui margins, dydx(L.top10) at(L.capsh_gross=(0.1825(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP > 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.2 0.2)) ylabel(-0.2(0.1)0.2) xtitle("Capital share gross of depreciation", size(medsmall)) ///
	xlabel(0.2(0.1)0.5) name(highfd, replace)
restore
preserve
replace top10=log(top10)
keep if mcap_gdp_high==0
qui xtreg y L.avg_log_gdppc c.L.top10##c.L.capsh_gross i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	*
	test L.top10 L.top10#L.capsh_gross
	*
	test L.capsh_gross L.top10#L.capsh_gross
	*
	test L.top10 L.capsh_gross L.top10#L.capsh_gross
qui margins, dydx(L.top10) at(L.capsh_gross=(0.1825(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP < 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.2 0.2)) ylabel(-0.2(0.1)0.2) xtitle("Capital share gross of depreciation", size(medsmall)) ///
	xlabel(0.2(0.1)0.5) name(lowfd, replace)
restore
gr combine highfd lowfd, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("A: Top 10 % income share", size(medsmall)) ysize(3) graphr(c(white)) name(top10_kshg, replace)
gr drop highfd lowfd

/*
Top 1 % share and capital share gross of capital depreciation
*/

preserve
replace top1=log(top1)
keep if mcap_gdp_high==1
qui xtreg y L.avg_log_gdppc c.L.top1##c.L.capsh_gross i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	*
	test L.top1 L.top1#L.capsh_gross
	*
	test L.capsh_gross L.top1#L.capsh_gross
	*
	test L.top1 L.capsh_gross L.top1#L.capsh_gross
qui margins, dydx(L.top1) at(L.capsh_gross=(0.1825(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP > 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.2 0.2)) ylabel(-0.2(0.1)0.2) xtitle("Capital share gross of depreciation", size(medsmall)) ///
	xlabel(0.2(0.1)0.5) name(highfd, replace)
restore
preserve
replace top1=log(top1)
keep if mcap_gdp_high==0
qui xtreg y L.avg_log_gdppc c.L.top1##c.L.capsh_gross i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	*
	test L.top1 L.top1#L.capsh_gross
	*
	test L.capsh_gross L.top1#L.capsh_gross
	*
	test L.top1 L.capsh_gross L.top1#L.capsh_gross
qui margins, dydx(L.top1) at(L.capsh_gross=(0.1825(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP < 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.2 0.2)) ylabel(-0.2(0.1)0.2) xtitle("Capital share gross of depreciation", size(medsmall)) ///
	xlabel(0.2(0.1)0.5) name(lowfd, replace)
restore
gr combine highfd lowfd, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("B: Top 1 % income share", size(medsmall)) ysize(3) graphr(c(white)) name(top1_kshg, replace)
gr drop highfd lowfd
	
/*
Top 0.1 % share and capital share gross of capital depreciation
*/

preserve
replace top01=log(top01)
keep if mcap_gdp_high==1
qui xtreg y L.avg_log_gdppc c.L.top01##c.L.capsh_gross i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	*
	test L.top01 L.top01#L.capsh_gross
	*
	test L.capsh_gross L.top01#L.capsh_gross
	*
	test L.top01 L.capsh_gross L.top01#L.capsh_gross
qui margins, dydx(L.top01) at(L.capsh_gross=(0.1825(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP > 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.2 0.2)) ylabel(-0.2(0.1)0.2) xtitle("Capital share gross of depreciation", size(medsmall)) ///
	xlabel(0.2(0.1)0.5) name(highfd, replace)
restore
preserve
replace top01=log(top01)
keep if mcap_gdp_high==0
qui xtreg y L.avg_log_gdppc c.L.top01##c.L.capsh_gross i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
	*
	test L.top01 L.top01#L.capsh_gross
	*
	test L.capsh_gross L.top01#L.capsh_gross
	*
	test L.top01 L.capsh_gross L.top01#L.capsh_gross
qui margins, dydx(L.top01) at(L.capsh_gross=(0.1825(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP < 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.2 0.2)) ylabel(-0.2(0.1)0.2) xtitle("Capital share gross of depreciation", size(medsmall)) ///
	xlabel(0.2(0.1)0.5) name(lowfd, replace)
restore
gr combine highfd lowfd, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("C: Top 0.1 % income share", size(medsmall)) ysize(3) graphr(c(white)) name(top01_kshg, replace)
gr drop highfd lowfd

/*
Combine the three
*/

gr combine top10_kshg top1_kshg top01_kshg, col(1) scheme(s2mono) title("", size(medsmall)) ///
	ysize(6) graphr(c(white)) name(kshg, replace)
gr drop top1_kshg top10_kshg top01_kshg
graph export "$loc\Figures\Historical\pregr_kshg_fe.eps", as(eps) preview(off) replace

********************************************************************************

* Examine whether our findings are robust to addressing dependency to the extent of inequality and factor shares simultaneously

* Change x for further sensitivity analysis
replace top10=log(top10)
replace top1=log(top1)
replace top01=log(top01)
local x=50
local y=100-`x'
foreach Z in top10 top1 top01 {
	qui gen t`x'`Z' = 0 if `Z'~=.
	qui gen b`y'`Z' = 0 if `Z'~=.
	qui centile `Z', c(`y')
	qui replace t`x'`Z' = 1 if `Z' >= r(c_1) & `Z'~=.
	qui centile `Z', c(`y')
	qui replace b`y'`Z' = 1 if `Z' < r(c_1) & `Z'~=.
	qui gen int_`Z'_t`x' = 0 if `Z'~=.
	qui gen int_`Z'_b`y' = 0 if `Z'~=.
	qui replace int_`Z'_t`x' = `Z' * t`x'`Z' 
	qui replace int_`Z'_b`y' = `Z' * b`y'`Z'
}

/*
Top 10 % share
*/

preserve
keep if mcap_gdp_high==1
qui xtreg y L.avg_log_gdppc c.L.int_top10_t`x'##c.L.capsh_net ///
	c.L.int_top10_b`x'##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
qui margins, dydx(L.int_top10_t`x') at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP > 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.4)) ylabel(-0.4(0.2)0.4) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(highfd_t, replace)
qui margins, dydx(L.int_top10_b`x') at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP > 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.4)) ylabel(-0.4(0.2)0.4) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(highfd_b, replace)
restore
preserve
keep if mcap_gdp_high==0
qui xtreg y L.avg_log_gdppc c.L.int_top10_t`x'##c.L.capsh_net ///
	c.L.int_top10_b`x'##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
qui margins, dydx(L.int_top10_t`x') at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP < 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.4)) ylabel(-0.4(0.2)0.4) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(lowfd_t, replace)
qui margins, dydx(L.int_top10_b`x') at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP < 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.4)) ylabel(-0.4(0.2)0.4) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(lowfd_b, replace)
restore
gr combine highfd_t lowfd_t, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("A: Top 10 % income share, high level of inequality", size(medsmall)) ysize(3) graphr(c(white)) name(top10_t, replace)
gr combine highfd_b lowfd_b, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("B: Top 10 % income share, low level of inequality", size(medsmall)) ysize(3) graphr(c(white)) name(top10_b, replace)
gr drop highfd_t lowfd_t highfd_b lowfd_b
gr combine top10_t top10_b, col(1) scheme(s2mono) title("", size(medsmall)) ysize(5.5) graphr(c(white)) name(kshntop10, replace)
graph export "$loc\Figures\Historical\pregr_kshntop10_fe.eps", as(eps) preview(off) replace
gr drop top10_t top10_b

/*
Top 1 % share
*/

preserve
keep if mcap_gdp_high==1
qui xtreg y L.avg_log_gdppc c.L.int_top1_t`x'##c.L.capsh_net ///
	c.L.int_top1_b`x'##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
qui margins, dydx(L.int_top1_t`x') at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP > 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.4)) ylabel(-0.4(0.2)0.4) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(highfd_t, replace)
qui margins, dydx(L.int_top1_b`x') at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP > 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.4)) ylabel(-0.4(0.2)0.4) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(highfd_b, replace)
restore
preserve
keep if mcap_gdp_high==0
qui xtreg y L.avg_log_gdppc c.L.int_top1_t`x'##c.L.capsh_net ///
	c.L.int_top1_b`x'##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
qui margins, dydx(L.int_top1_t`x') at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP < 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.4)) ylabel(-0.4(0.2)0.4) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(lowfd_t, replace)
qui margins, dydx(L.int_top1_b`x') at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP < 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.4)) ylabel(-0.4(0.2)0.4) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(lowfd_b, replace)
restore
gr combine highfd_t lowfd_t, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("A: Top 1 % income share, high level of inequality", size(medsmall)) ysize(3) graphr(c(white)) name(top1_t, replace)
gr combine highfd_b lowfd_b, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("B: Top 1 % income share, low level of inequality", size(medsmall)) ysize(3) graphr(c(white)) name(top1_b, replace)
gr drop highfd_t lowfd_t highfd_b lowfd_b
gr combine top1_t top1_b, col(1) scheme(s2mono) title("", size(medsmall)) ysize(5.5) graphr(c(white)) name(kshntop1, replace)
graph export "$loc\Figures\Historical\pregr_kshntop1_fe.eps", as(eps) preview(off) replace
gr drop top1_t top1_b

/*
Top 0.1 % share
*/

preserve
keep if mcap_gdp_high==1
qui xtreg y L.avg_log_gdppc c.L.int_top01_t`x'##c.L.capsh_net ///
	c.L.int_top01_b`x'##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
qui margins, dydx(L.int_top01_t`x') at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP > 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.4)) ylabel(-0.4(0.2)0.4) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(highfd_t, replace)
qui margins, dydx(L.int_top01_b`x') at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP > 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.4)) ylabel(-0.4(0.2)0.4) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(highfd_b, replace)
restore
preserve
keep if mcap_gdp_high==0
qui xtreg y L.avg_log_gdppc c.L.int_top01_t`x'##c.L.capsh_net ///
	c.L.int_top01_b`x'##c.L.capsh_net i.year ///
	L.csh_i L.csh_g L.d_pop L.lhc, ///
	fe vce(cl id)
qui margins, dydx(L.int_top01_t`x') at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP < 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.4)) ylabel(-0.4(0.2)0.4) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(lowfd_t, replace)
qui margins, dydx(L.int_top01_b`x') at(L.capsh_net=(0.055(0.025)0.4025))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Stock market cap to GDP < 50 %}", size(medium)) ysize(3) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.4)) ylabel(-0.4(0.2)0.4) xtitle("Capital share net of depreciation", size(medsmall)) ///
	xlabel(0.1(0.1)0.4) name(lowfd_b, replace)
restore
gr combine highfd_t lowfd_t, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("A: Top 0.1 % income share, high level of inequality", size(medsmall)) ysize(3) graphr(c(white)) name(top01_t, replace)
gr combine highfd_b lowfd_b, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("B: Top 0.1 % income share, low level of inequality", size(medsmall)) ysize(3) graphr(c(white)) name(top01_b, replace)
gr drop highfd_t lowfd_t highfd_b lowfd_b
gr combine top01_t top01_b, col(1) scheme(s2mono) title("", size(medsmall)) ysize(5.5) graphr(c(white)) name(kshntop01, replace)
graph export "$loc\Figures\Historical\pregr_kshntop01_fe.eps", as(eps) preview(off) replace
gr drop top01_t top01_b
