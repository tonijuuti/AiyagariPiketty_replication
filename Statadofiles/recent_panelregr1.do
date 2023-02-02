use "$loc\Data\data_recent_5yr.dta", clear
egen long id = group(country)
xtset id year, delta(5)
gen topbottom=p99p100/p0p50
foreach var of varlist p99p100 p999p100 p90p100 p0p50 topbottom gini {
	gen l`var' = log(`var')
}
label var lp99p100 "Top 1 %"
label var lp999p100 "Top 0.1 %"
label var lp90p100 "Top 10 %"
label var lp0p50 "Bottom 50 %"
label var ltopbottom "Top 1 % / bottom 50%"
label var lgini "Gini"
format Ksh_nni %9.0g
preserve // IMF income groups and regions
use "$loc\Data\Original\Svirydzenka_all.dta", clear
kountry code, from(iso3c) to(iso2c)
keep _ISO2C_ imf_income imf_region
egen long region = group(imf_region)
rename _ISO2C_ country
drop if country==""
duplicates drop 
save "$loc\Data\temp.dta", replace
restore
merge m:1 country using "$loc\Data\temp.dta"
drop if _merge==2
drop _merge
*erase "$loc\Data\temp.dta"

gen xtremegrowth=0
replace xtremegrowth=1 if y<-0.05
replace xtremegrowth=1 if y>0.1

* Average financial market development in countries over time
foreach var of varlist mcap_gdp_wb cred_gdp_wb FD FI FM  {
	bysort country: egen `var'_mean = mean(`var')
}

xtset id year, delta(5)

********************************************************************************

/*
Top 10 % share and capital share of net national income graphically
- by income group
*/

* Advanced economies
preserve
keep if imf_income=="AM"
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Advanced economies}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.45)) ylabel(-0.4(0.2)0.4) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(am, replace)
restore

* Emerging markets
preserve
keep if imf_income=="EM"
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Emerging markets}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.45)) ylabel(-0.4(0.2)0.4) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em, replace)
restore

* Low-income countries
preserve
keep if imf_income=="LIC"
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low-income countries}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.45)) ylabel(-0.4(0.2)0.4) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(lic, replace)
restore

* Combine

gr combine am em lic, col(3) scheme(s2mono) title("", size(medium)) ///
	title("A: Top 10 % income share", size(medsmall)) ysize(3) graphr(c(white)) name(top10_kshnni, replace)
gr drop am em lic

/*
Gini and capital share of net national income graphically
- by income group
*/

* Advanced economies
preserve
keep if imf_income=="AM"
qui xtreg y L.avg_log_gdppc c.L.lgini##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lgini L.lgini#L.Ksh_nni
	*
	test L.Ksh_nni L.lgini#L.Ksh_nni
	*
	test L.lgini L.Ksh_nni L.lgini#L.Ksh_nni
qui margins, dydx(L.lgini) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Advanced economies}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.45)) ylabel(-0.4(0.2)0.4) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(am, replace)
restore

* Emerging markets
preserve
keep if imf_income=="EM"
qui xtreg y L.avg_log_gdppc c.L.lgini##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lgini L.lgini#L.Ksh_nni
	*
	test L.Ksh_nni L.lgini#L.Ksh_nni
	*
	test L.lgini L.Ksh_nni L.lgini#L.Ksh_nni
qui margins, dydx(L.lgini) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Emerging markets}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.45)) ylabel(-0.4(0.2)0.4) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em, replace)
restore

* Low-income countries
preserve
keep if imf_income=="LIC"
qui xtreg y L.avg_log_gdppc c.L.lgini##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lgini L.lgini#L.Ksh_nni
	*
	test L.Ksh_nni L.lgini#L.Ksh_nni
	*
	test L.lgini L.Ksh_nni L.lgini#L.Ksh_nni
qui margins, dydx(L.lgini) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low-income countries}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.45)) ylabel(-0.4(0.2)0.4) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(lic, replace)
restore

* Combine

gr combine am em lic, col(3) scheme(s2mono) title("", size(medium)) ///
	title("B: Gini coefficient", size(medsmall)) ysize(3) graphr(c(white)) name(gini_kshnni, replace)
gr drop am em lic

/*
Combine again
*/

gr combine top10_kshnni gini_kshnni, col(1) scheme(s2mono) title("", size(medium)) ///
	title("", size(medsmall)) ysize(3) graphr(c(white)) name(kshnni, replace)
gr drop top10_kshnni gini_kshnni
graph export "$loc\Figures\Recent\pregr_kshnni_fe.eps", as(eps) preview(off) replace

********************************************************************************

/*
Top 10 % share and capital share of net national income graphically
- emerging markets
- by financial development
*/

* Aggregate index

preserve
keep if imf_income=="EM"
collapse FD_mean, by(country)
sort FD_mean
list
restore
gen FD_high_em=0 if imf_income=="EM"
replace FD_high_em=1 if FD_mean>0.25 & imf_income=="EM"
xtset id year, delta(5)
preserve
keep if imf_income=="EM" & FD_high_em==1
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FD}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fdh, replace)
restore
preserve
keep if imf_income=="EM" & FD_high_em==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FD}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fdl, replace)
restore

gr combine em_fdh em_fdl, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("A: Aggregate financial development", size(medsmall)) ysize(3) graphr(c(white)) name(fd, replace)

* Development of financial institutions

preserve
keep if imf_income=="EM"
collapse FI_mean, by(country)
sort FI_mean
list
restore
gen FI_high_em=0 if imf_income=="EM"
replace FI_high_em=1 if FI_mean>0.30 & imf_income=="EM"
xtset id year, delta(5)
preserve
keep if imf_income=="EM" & FI_high_em==1
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FI}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fih, replace)
restore
preserve
keep if imf_income=="EM" & FI_high_em==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FI}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fil, replace)
restore

gr combine em_fih em_fil, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("B: Development of financial institutions", size(medsmall)) ysize(3) graphr(c(white)) name(fi, replace)

* Development of financial markets

preserve
keep if imf_income=="EM"
collapse FM_mean, by(country)
sort FM_mean
list
restore
gen FM_high_em=0 if imf_income=="EM"
replace FM_high_em=1 if FM_mean>0.175 & imf_income=="EM"
xtset id year, delta(5)
preserve
keep if imf_income=="EM" & FM_high_em==1
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FM}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fmh, replace)
restore
preserve
keep if imf_income=="EM" & FM_high_em==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FM}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fml, replace)
restore

gr combine em_fmh em_fml, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("C: Development of financial markets", size(medsmall)) ysize(3) graphr(c(white)) name(fm, replace)

* Combine

gr combine fd fi fm, col(1) scheme(s2mono) title("", size(medium)) ///
	title("", size(medsmall)) ysize(6) graphr(c(white)) name(kshnni_byfd, replace)
gr drop em_fdh em_fdl em_fih em_fil em_fmh em_fml fd fi fm
graph export "$loc\Figures\Recent\pregr_kshnni_fe_byfd_em.eps", as(eps) preview(off) replace

/*
Examine how the development of institutions correlates w/ credit to GDP
and how the development of markets correlates w/ stock market cap to GDP
*/

preserve
keep if imf_income=="EM"
collapse cred_gdp_wb_mean, by(country)
sort cred_gdp_wb_mean
list
restore
gen cred_high_em=0 if imf_income=="EM" & cred_gdp_wb!=.
replace cred_high_em=1 if cred_gdp_wb_mean>39 & imf_income=="EM"
preserve
keep if imf_income=="EM"
collapse mcap_gdp_wb_mean, by(country)
sort mcap_gdp_wb_mean
list
restore
gen mcap_high_em=0 if imf_income=="EM" & mcap_gdp_wb!=.
replace mcap_high_em=1 if mcap_gdp_wb_mean>31 & imf_income=="EM"

* Correlation between the variables
pwcorr cred_gdp_wb FI
pwcorr mcap_gdp_wb FM

* Correlation between the groupings
pwcorr FI_high_em cred_high_em
pwcorr FM_high_em mcap_high_em


********************************************************************************

/*
Top 10 % share and capital share of net national income graphically
- advanced economies and low-income countries
- by financial development
*/

*****
* Advanced economies

* Aggregate index

preserve
keep if imf_income=="AM"
collapse FD_mean, by(country)
sort FD_mean
list
restore
gen FD_high_am=0 if imf_income=="AM"
replace FD_high_am=1 if FD_mean>0.595 & imf_income=="AM"
xtset id year, delta(5)
preserve
keep if imf_income=="AM" & FD_high_am==1
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FD}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fdh, replace)
restore
preserve
keep if imf_income=="AM" & FD_high_am==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FD}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fdl, replace)
restore

gr combine em_fdh em_fdl, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("A: Aggregate financial development", size(medsmall)) ysize(3) graphr(c(white)) name(fd, replace)

* Development of financial institutions

preserve
keep if imf_income=="AM"
collapse FI_mean, by(country)
sort FI_mean
list
restore
gen FI_high_am=0 if imf_income=="AM"
replace FI_high_am=1 if FI_mean>0.68 & imf_income=="AM"
xtset id year, delta(5)
preserve
keep if imf_income=="AM" & FI_high_am==1
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FI}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fih, replace)
restore
preserve
keep if imf_income=="AM" & FI_high_am==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FI}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fil, replace)
restore

gr combine em_fih em_fil, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("B: Development of financial institutions", size(medsmall)) ysize(3) graphr(c(white)) name(fi, replace)

* Development of financial markets

preserve
keep if imf_income=="AM"
collapse FM_mean, by(country)
sort FM_mean
list
restore
gen FM_high_am=0 if imf_income=="AM"
replace FM_high_am=1 if FM_mean>0.5 & imf_income=="AM"
xtset id year, delta(5)
preserve
keep if imf_income=="AM" & FM_high_am==1
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FM}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fmh, replace)
restore
preserve
keep if imf_income=="AM" & FM_high_am==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FM}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fml, replace)
restore

gr combine em_fmh em_fml, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("C: Development of financial markets", size(medsmall)) ysize(3) graphr(c(white)) name(fm, replace)

* Combine

gr combine fd fi fm, col(1) scheme(s2mono) title("", size(medium)) ///
	title("", size(medsmall)) ysize(6) graphr(c(white)) name(kshnni_byfd, replace)
gr drop em_fdh em_fdl em_fih em_fil em_fmh em_fml fd fi fm
graph export "$loc\Figures\Recent\pregr_kshnni_fe_byfd_am.eps", as(eps) preview(off) replace

*****
* Low-income countries

* Aggregate index

preserve
keep if imf_income=="LIC"
collapse FD_mean, by(country)
sort FD_mean
list
restore
gen FD_high_lic=0 if imf_income=="LIC"
replace FD_high_lic=1 if FD_mean>0.1 & imf_income=="LIC"
xtset id year, delta(5)
preserve
keep if imf_income=="LIC" & FD_high_lic==1
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FD}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fdh, replace)
restore
preserve
keep if imf_income=="LIC" & FD_high_lic==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FD}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fdl, replace)
restore

gr combine em_fdh em_fdl, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("A: Aggregate financial development", size(medsmall)) ysize(3) graphr(c(white)) name(fd, replace)

* Development of financial institutions

preserve
keep if imf_income=="LIC"
collapse FI_mean, by(country)
sort FI_mean
list
restore
gen FI_high_lic=0 if imf_income=="LIC"
replace FI_high_lic=1 if FI_mean>0.18 & imf_income=="LIC"
xtset id year, delta(5)
preserve
keep if imf_income=="LIC" & FI_high_lic==1
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FI}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fih, replace)
restore
preserve
keep if imf_income=="LIC" & FI_high_lic==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FI}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fil, replace)
restore

gr combine em_fih em_fil, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("B: Development of financial institutions", size(medsmall)) ysize(3) graphr(c(white)) name(fi, replace)

* Development of financial markets

preserve
keep if imf_income=="LIC"
collapse FM_mean, by(country)
sort FM_mean
list
restore
gen FM_high_lic=0 if imf_income=="LIC"
replace FM_high_lic=1 if FM_mean>0.05 & imf_income=="LIC"
xtset id year, delta(5)
preserve
keep if imf_income=="LIC" & FM_high_lic==1
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FM}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fmh, replace)
restore
preserve
keep if imf_income=="LIC" & FM_high_lic==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_nni
	*
	test L.Ksh_nni L.lp90p100#L.Ksh_nni
	*
	test L.lp90p100 L.Ksh_nni L.lp90p100#L.Ksh_nni
qui margins, dydx(L.lp90p100) at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FM}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.3 0.65)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net national income", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fml, replace)
restore

gr combine em_fmh em_fml, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("C: Development of financial markets", size(medsmall)) ysize(3) graphr(c(white)) name(fm, replace)

* Combine

gr combine fd fi fm, col(1) scheme(s2mono) title("", size(medium)) ///
	title("", size(medsmall)) ysize(6) graphr(c(white)) name(kshnni_byfd, replace)
gr drop em_fdh em_fdl em_fih em_fil em_fmh em_fml fd fi fm
graph export "$loc\Figures\Recent\pregr_kshnni_fe_byfd_lic.eps", as(eps) preview(off) replace
