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
format Ksh_nni Ksh_ndp Ksh_gdp %9.0g
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
*erase temp.dta

gen xtremegrowth=0
replace xtremegrowth=1 if y<-0.05
replace xtremegrowth=1 if y>0.1

* Average financial market development in countries over time
foreach var of varlist mcap_gdp_wb cred_gdp_wb FD FI FM  {
	bysort country: egen `var'_mean = mean(`var')
}

xtset id year, delta(5)

********************************************************************************

* Examine whether our findings are robust to how capital shares are defined

/*
Top 10 % income share and capital share of net domestic product graphically
- emerging markets
- by financial development
*/

sum Ksh_ndp if imf_income=="EM"

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
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_ndp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_ndp
	*
	test L.Ksh_ndp L.lp90p100#L.Ksh_ndp
	*
	test L.lp90p100 L.Ksh_ndp L.lp90p100#L.Ksh_ndp
qui margins, dydx(L.lp90p100) at(L.Ksh_ndp=(0.2(0.025)0.7))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FD}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.7 0.65)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of net domestic product", size(medsmall)) ///
	xsc(range(0.2 0.7)) xlabel(0.2(0.1)0.7) name(em_fdh, replace)
restore
preserve
keep if imf_income=="EM" & FD_high_em==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_ndp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_ndp
	*
	test L.Ksh_ndp L.lp90p100#L.Ksh_ndp
	*
	test L.lp90p100 L.Ksh_ndp L.lp90p100#L.Ksh_ndp
qui margins, dydx(L.lp90p100) at(L.Ksh_ndp=(0.2(0.025)0.7))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FD}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.7 0.65)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of net domestic product", size(medsmall)) ///
	xsc(range(0.2 0.7)) xlabel(0.2(0.1)0.7) name(em_fdl, replace)
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
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_ndp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_ndp
	*
	test L.Ksh_ndp L.lp90p100#L.Ksh_ndp
	*
	test L.lp90p100 L.Ksh_ndp L.lp90p100#L.Ksh_ndp
qui margins, dydx(L.lp90p100) at(L.Ksh_ndp=(0.2(0.025)0.7))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FI}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.7 0.65)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of net domestic product", size(medsmall)) ///
	xsc(range(0.2 0.7)) xlabel(0.2(0.1)0.7) name(em_fih, replace)
restore
preserve
keep if imf_income=="EM" & FI_high_em==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_ndp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_ndp
	*
	test L.Ksh_ndp L.lp90p100#L.Ksh_ndp
	*
	test L.lp90p100 L.Ksh_ndp L.lp90p100#L.Ksh_ndp
qui margins, dydx(L.lp90p100) at(L.Ksh_ndp=(0.2(0.025)0.7))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FI}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.7 0.65)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of net domestic product", size(medsmall)) ///
	xsc(range(0.2 0.7)) xlabel(0.2(0.1)0.7) name(em_fil, replace)
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
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_ndp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_ndp
	*
	test L.Ksh_ndp L.lp90p100#L.Ksh_ndp
	*
	test L.lp90p100 L.Ksh_ndp L.lp90p100#L.Ksh_ndp
qui margins, dydx(L.lp90p100) at(L.Ksh_ndp=(0.2(0.025)0.7))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FM}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.7 0.65)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of net domestic product", size(medsmall)) ///
	xsc(range(0.2 0.7)) xlabel(0.2(0.1)0.7) name(em_fmh, replace)
restore
preserve
keep if imf_income=="EM" & FM_high_em==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_ndp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_ndp
	*
	test L.Ksh_ndp L.lp90p100#L.Ksh_ndp
	*
	test L.lp90p100 L.Ksh_ndp L.lp90p100#L.Ksh_ndp
qui margins, dydx(L.lp90p100) at(L.Ksh_ndp=(0.2(0.025)0.7))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FM}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.7 0.65)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of net domestic product", size(medsmall)) ///
	xsc(range(0.2 0.7)) xlabel(0.2(0.1)0.7) name(em_fml, replace)
restore

gr combine em_fmh em_fml, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("C: Development of financial markets", size(medsmall)) ysize(3) graphr(c(white)) name(fm, replace)

* Combine

gr combine fd fi fm, col(1) scheme(s2mono) title("", size(medium)) ///
	title("", size(medsmall)) ysize(6) graphr(c(white)) name(kshndp_byfd_em, replace)
gr drop em_fdh em_fdl em_fih em_fil em_fmh em_fml fd fi fm
graph export "$loc\Figures\Recent\pregr_kshndp_fe_byfd_em.eps", as(eps) preview(off) replace

/*
Top 10 % income share and capital share of net domestic product graphically
- advanced economies
- by financial development
*/

sum Ksh_ndp if imf_income=="AM"

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
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_ndp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_ndp
	*
	test L.Ksh_ndp L.lp90p100#L.Ksh_ndp
	*
	test L.lp90p100 L.Ksh_ndp L.lp90p100#L.Ksh_ndp
qui margins, dydx(L.lp90p100) at(L.Ksh_ndp=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FD}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.6)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net domestic product", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fdh, replace)
restore
preserve
keep if imf_income=="AM" & FD_high_am==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_ndp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_ndp
	*
	test L.Ksh_ndp L.lp90p100#L.Ksh_ndp
	*
	test L.lp90p100 L.Ksh_ndp L.lp90p100#L.Ksh_ndp
qui margins, dydx(L.lp90p100) at(L.Ksh_ndp=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FD}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.6)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net domestic product", size(medsmall)) ///
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
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_ndp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_ndp
	*
	test L.Ksh_ndp L.lp90p100#L.Ksh_ndp
	*
	test L.lp90p100 L.Ksh_ndp L.lp90p100#L.Ksh_ndp
qui margins, dydx(L.lp90p100) at(L.Ksh_ndp=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FI}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.6)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net domestic product", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fih, replace)
restore
preserve
keep if imf_income=="AM" & FI_high_am==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_ndp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_ndp
	*
	test L.Ksh_ndp L.lp90p100#L.Ksh_ndp
	*
	test L.lp90p100 L.Ksh_ndp L.lp90p100#L.Ksh_ndp
qui margins, dydx(L.lp90p100) at(L.Ksh_ndp=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FI}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.6)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net domestic product", size(medsmall)) ///
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
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_ndp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_ndp
	*
	test L.Ksh_ndp L.lp90p100#L.Ksh_ndp
	*
	test L.lp90p100 L.Ksh_ndp L.lp90p100#L.Ksh_ndp
qui margins, dydx(L.lp90p100) at(L.Ksh_ndp=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FM}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.6)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net domestic product", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fmh, replace)
restore
preserve
keep if imf_income=="AM" & FM_high_am==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_ndp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_ndp
	*
	test L.Ksh_ndp L.lp90p100#L.Ksh_ndp
	*
	test L.lp90p100 L.Ksh_ndp L.lp90p100#L.Ksh_ndp
qui margins, dydx(L.lp90p100) at(L.Ksh_ndp=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FM}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 0.6)) ylabel(-0.3(0.3)0.6) xtitle("Capital share of net domestic product", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fml, replace)
restore

gr combine em_fmh em_fml, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("C: Development of financial markets", size(medsmall)) ysize(3) graphr(c(white)) name(fm, replace)

* Combine

gr combine fd fi fm, col(1) scheme(s2mono) title("", size(medium)) ///
	title("", size(medsmall)) ysize(6) graphr(c(white)) name(kshndp_byfd_am, replace)
gr drop em_fdh em_fdl em_fih em_fil em_fmh em_fml fd fi fm
graph export "$loc\Figures\Recent\pregr_kshndp_fe_byfd_am.eps", as(eps) preview(off) replace

/*
Top 10 % income share and capital share of gross domestic product graphically
- emerging markets
- by financial development
*/

sum Ksh_gdp if imf_income=="EM"

* Aggregate index

preserve
keep if imf_income=="EM" & FD_high_em==1
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_gdp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_gdp
	*
	test L.Ksh_gdp L.lp90p100#L.Ksh_gdp
	*
	test L.lp90p100 L.Ksh_gdp L.lp90p100#L.Ksh_gdp
qui margins, dydx(L.lp90p100) at(L.Ksh_gdp=(0.3(0.025)0.7))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FD}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of gross domestic product", size(medsmall)) ///
	xsc(range(0.3 0.7)) xlabel(0.3(0.1)0.7) name(em_fdh, replace)
restore
preserve
keep if imf_income=="EM" & FD_high_em==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_gdp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_gdp
	*
	test L.Ksh_gdp L.lp90p100#L.Ksh_gdp
	*
	test L.lp90p100 L.Ksh_gdp L.lp90p100#L.Ksh_gdp
qui margins, dydx(L.lp90p100) at(L.Ksh_gdp=(0.3(0.025)0.7))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FD}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of gross domestic product", size(medsmall)) ///
	xsc(range(0.3 0.7)) xlabel(0.3(0.1)0.7) name(em_fdl, replace)
restore

gr combine em_fdh em_fdl, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("A: Aggregate financial development", size(medsmall)) ysize(3) graphr(c(white)) name(fd, replace)

* Development of financial institutions

preserve
keep if imf_income=="EM" & FI_high_em==1
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_gdp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_gdp
	*
	test L.Ksh_gdp L.lp90p100#L.Ksh_gdp
	*
	test L.lp90p100 L.Ksh_gdp L.lp90p100#L.Ksh_gdp
qui margins, dydx(L.lp90p100) at(L.Ksh_gdp=(0.3(0.025)0.7))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FI}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of gross domestic product", size(medsmall)) ///
	xsc(range(0.3 0.7)) xlabel(0.3(0.1)0.7) name(em_fih, replace)
restore
preserve
keep if imf_income=="EM" & FI_high_em==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_gdp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_gdp
	*
	test L.Ksh_gdp L.lp90p100#L.Ksh_gdp
	*
	test L.lp90p100 L.Ksh_gdp L.lp90p100#L.Ksh_gdp
qui margins, dydx(L.lp90p100) at(L.Ksh_gdp=(0.3(0.025)0.7))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FI}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of gross domestic product", size(medsmall)) ///
	xsc(range(0.3 0.7)) xlabel(0.3(0.1)0.7) name(em_fil, replace)
restore

gr combine em_fih em_fil, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("B: Development of financial institutions", size(medsmall)) ysize(3) graphr(c(white)) name(fi, replace)

* Development of financial markets

preserve
keep if imf_income=="EM" & FM_high_em==1
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_gdp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_gdp
	*
	test L.Ksh_gdp L.lp90p100#L.Ksh_gdp
	*
	test L.lp90p100 L.Ksh_gdp L.lp90p100#L.Ksh_gdp
qui margins, dydx(L.lp90p100) at(L.Ksh_gdp=(0.3(0.025)0.7))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FM}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of gross domestic product", size(medsmall)) ///
	xsc(range(0.3 0.7)) xlabel(0.3(0.1)0.7) name(em_fmh, replace)
restore
preserve
keep if imf_income=="EM" & FM_high_em==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_gdp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_gdp
	*
	test L.Ksh_gdp L.lp90p100#L.Ksh_gdp
	*
	test L.lp90p100 L.Ksh_gdp L.lp90p100#L.Ksh_gdp
qui margins, dydx(L.lp90p100) at(L.Ksh_gdp=(0.3(0.025)0.7))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FM}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of gross domestic product", size(medsmall)) ///
	xsc(range(0.3 0.7)) xlabel(0.3(0.1)0.7) name(em_fml, replace)
restore

gr combine em_fmh em_fml, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("C: Development of financial markets", size(medsmall)) ysize(3) graphr(c(white)) name(fm, replace)

* Combine

gr combine fd fi fm, col(1) scheme(s2mono) title("", size(medium)) ///
	title("", size(medsmall)) ysize(6) graphr(c(white)) name(kshgdp_byfd_em, replace)
gr drop em_fdh em_fdl em_fih em_fil em_fmh em_fml fd fi fm
graph export "$loc\Figures\Recent\pregr_kshgdp_fe_byfd_em.eps", as(eps) preview(off) replace

/*
Top 10 % income share and capital share of gross domestic product graphically
- advanced economies
- by financial development
*/

sum Ksh_gdp if imf_income=="AM"

*****
* Advanced economies

* Aggregate index

preserve
keep if imf_income=="AM" & FD_high_am==1
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_gdp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_gdp
	*
	test L.Ksh_gdp L.lp90p100#L.Ksh_gdp
	*
	test L.lp90p100 L.Ksh_gdp L.lp90p100#L.Ksh_gdp
qui margins, dydx(L.lp90p100) at(L.Ksh_gdp=(0.3(0.025)0.6))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FD}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of gross domestic product", size(medsmall)) ///
	xsc(range(0.3 0.6)) xlabel(0.3(0.1)0.6) name(em_fdh, replace)
restore
preserve
keep if imf_income=="AM" & FD_high_am==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_gdp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_gdp
	*
	test L.Ksh_gdp L.lp90p100#L.Ksh_gdp
	*
	test L.lp90p100 L.Ksh_gdp L.lp90p100#L.Ksh_gdp
qui margins, dydx(L.lp90p100) at(L.Ksh_gdp=(0.3(0.025)0.6))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FD}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of gross domestic product", size(medsmall)) ///
	xsc(range(0.3 0.6)) xlabel(0.3(0.1)0.6) name(em_fdl, replace)
restore

gr combine em_fdh em_fdl, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("A: Aggregate financial development", size(medsmall)) ysize(3) graphr(c(white)) name(fd, replace)

* Development of financial institutions

preserve
keep if imf_income=="AM" & FI_high_am==1
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_gdp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_gdp
	*
	test L.Ksh_gdp L.lp90p100#L.Ksh_gdp
	*
	test L.lp90p100 L.Ksh_gdp L.lp90p100#L.Ksh_gdp
qui margins, dydx(L.lp90p100) at(L.Ksh_gdp=(0.3(0.025)0.6))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FI}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of gross domestic product", size(medsmall)) ///
	xsc(range(0.3 0.6)) xlabel(0.3(0.1)0.6) name(em_fih, replace)
restore
preserve
keep if imf_income=="AM" & FI_high_am==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_gdp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_gdp
	*
	test L.Ksh_gdp L.lp90p100#L.Ksh_gdp
	*
	test L.lp90p100 L.Ksh_gdp L.lp90p100#L.Ksh_gdp
qui margins, dydx(L.lp90p100) at(L.Ksh_gdp=(0.3(0.025)0.6))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FI}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of gross domestic product", size(medsmall)) ///
	xsc(range(0.3 0.6)) xlabel(0.3(0.1)0.6) name(em_fil, replace)
restore

gr combine em_fih em_fil, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("B: Development of financial institutions", size(medsmall)) ysize(3) graphr(c(white)) name(fi, replace)

* Development of financial markets

preserve
keep if imf_income=="AM" & FM_high_am==1
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_gdp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_gdp
	*
	test L.Ksh_gdp L.lp90p100#L.Ksh_gdp
	*
	test L.lp90p100 L.Ksh_gdp L.lp90p100#L.Ksh_gdp
qui margins, dydx(L.lp90p100) at(L.Ksh_gdp=(0.3(0.025)0.6))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FM}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of gross domestic product", size(medsmall)) ///
	xsc(range(0.3 0.6)) xlabel(0.3(0.1)0.6) name(em_fmh, replace)
restore
preserve
keep if imf_income=="AM" & FM_high_am==0
qui xtreg y L.avg_log_gdppc c.L.lp90p100##c.L.Ksh_gdp ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
	*
	test L.lp90p100 L.lp90p100#L.Ksh_gdp
	*
	test L.Ksh_gdp L.lp90p100#L.Ksh_gdp
	*
	test L.lp90p100 L.Ksh_gdp L.lp90p100#L.Ksh_gdp
qui margins, dydx(L.lp90p100) at(L.Ksh_gdp=(0.3(0.025)0.6))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FM}", size(medium) color(gs2)) ///
	ytitle("Log points", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("Capital share of gross domestic product", size(medsmall)) ///
	xsc(range(0.3 0.6)) xlabel(0.3(0.1)0.6) name(em_fml, replace)
restore

gr combine em_fmh em_fml, col(2) scheme(s2mono) title("", size(medsmall)) ///
	title("C: Development of financial markets", size(medsmall)) ysize(3) graphr(c(white)) name(fm, replace)

* Combine

gr combine fd fi fm, col(1) scheme(s2mono) title("", size(medium)) ///
	title("", size(medsmall)) ysize(6) graphr(c(white)) name(kshgdp_byfd_am, replace)
gr drop em_fdh em_fdl em_fih em_fil em_fmh em_fml fd fi fm
graph export "$loc\Figures\Recent\pregr_kshgdp_fe_byfd_am.eps", as(eps) preview(off) replace

********************************************************************************

* Examine whether our findings are robust to addressing dependency to the extent of inequality and factor shares simultaneously

* Change x for further sensitivity analysis
preserve
keep if imf_income=="EM"
local x=50
local y=100-`x'
foreach Z in lp90p100 {
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
keep country year int_lp90p100_t50 int_lp90p100_b50
save "$loc\Data\int_temp_em.dta", replace
restore
preserve
keep if imf_income=="AM"
local x=50
local y=100-`x'
foreach Z in lp90p100 {
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
keep country year int_lp90p100_t50 int_lp90p100_b50
save "$loc\Data\int_temp_am.dta", replace
restore

/*
Top 10 % share and capital share of net national income graphically
- emerging markets
- by financial development
- top / bottom half inequality
*/

merge 1:1 country year using "$loc\Data\int_temp_em.dta"
drop _merge
xtset id year, delta(5)

* Aggregate index

preserve
keep if imf_income=="EM" & FD_high_em==1
qui xtreg y L.avg_log_gdppc c.L.int_lp90p100_t`x'##c.L.Ksh_nni c.L.int_lp90p100_b`x'##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
qui margins, dydx(L.int_lp90p100_t`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FD & High inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 1.2)) ylabel(-0.4(0.4)1.2) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fdh_ineqt, replace)
qui margins, dydx(L.int_lp90p100_b`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FD & Low inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 1.2)) ylabel(-0.4(0.4)1.2) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fdh_ineqb, replace)
restore
preserve
keep if imf_income=="EM" & FD_high_em==0
qui xtreg y L.avg_log_gdppc c.L.int_lp90p100_t`x'##c.L.Ksh_nni c.L.int_lp90p100_b`x'##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
qui margins, dydx(L.int_lp90p100_t`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FD & High inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 1.2)) ylabel(-0.4(0.4)1.2) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fdl_ineqt, replace)
qui margins, dydx(L.int_lp90p100_b`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FD & Low inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 1.2)) ylabel(-0.4(0.4)1.2) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fdl_ineqb, replace)
restore

gr combine em_fdh_ineqt em_fdl_ineqt em_fdh_ineqb em_fdl_ineqb, col(4) scheme(s2mono) title("", size(medsmall)) ///
	title("A: Aggregate financial development", size(medsmall)) ysize(2) graphr(c(white)) name(fd_em, replace)

* Development of financial institutions

preserve
keep if imf_income=="EM" & FI_high_em==1
qui xtreg y L.avg_log_gdppc c.L.int_lp90p100_t`x'##c.L.Ksh_nni c.L.int_lp90p100_b`x'##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
qui margins, dydx(L.int_lp90p100_t`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FI & High inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 1.2)) ylabel(-0.4(0.4)1.2) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fih_ineqt, replace)
qui margins, dydx(L.int_lp90p100_b`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FI & Low inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 1.2)) ylabel(-0.4(0.4)1.2) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fih_ineqb, replace)
restore
preserve
keep if imf_income=="EM" & FI_high_em==0
qui xtreg y L.avg_log_gdppc c.L.int_lp90p100_t`x'##c.L.Ksh_nni c.L.int_lp90p100_b`x'##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
qui margins, dydx(L.int_lp90p100_t`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FI & High inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 1.2)) ylabel(-0.4(0.4)1.2) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fil_ineqt, replace)
qui margins, dydx(L.int_lp90p100_b`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FI & Low inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 1.2)) ylabel(-0.4(0.4)1.2) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fil_ineqb, replace)
restore

gr combine em_fih_ineqt em_fil_ineqt em_fih_ineqb em_fil_ineqb, col(4) scheme(s2mono) title("", size(medsmall)) ///
	title("B: Development of financial institutions", size(medsmall)) ysize(2) graphr(c(white)) name(fi_em, replace)

* Development of financial markets

preserve
keep if imf_income=="EM" & FM_high_em==1
qui xtreg y L.avg_log_gdppc c.L.int_lp90p100_t`x'##c.L.Ksh_nni c.L.int_lp90p100_b`x'##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
qui margins, dydx(L.int_lp90p100_t`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FM & High inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 1.2)) ylabel(-0.4(0.4)1.2) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fmh_ineqt, replace)
qui margins, dydx(L.int_lp90p100_b`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FM & Low inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 1.2)) ylabel(-0.4(0.4)1.2) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fmh_ineqb, replace)
restore
preserve
keep if imf_income=="EM" & FM_high_em==0
qui xtreg y L.avg_log_gdppc c.L.int_lp90p100_t`x'##c.L.Ksh_nni c.L.int_lp90p100_b`x'##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
qui margins, dydx(L.int_lp90p100_t`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FM & High inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 1.2)) ylabel(-0.4(0.4)1.2) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fml_ineqt, replace)
qui margins, dydx(L.int_lp90p100_b`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FM & Low inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.4 1.2)) ylabel(-0.4(0.4)1.2) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(em_fml_ineqb, replace)
restore

gr combine em_fmh_ineqt em_fml_ineqt em_fmh_ineqb em_fml_ineqb, col(4) scheme(s2mono) title("", size(medsmall)) ///
	title("C: Development of financial markets", size(medsmall)) ysize(2) graphr(c(white)) name(fm_em, replace)

gr drop em_fdh_ineqt em_fdl_ineqt em_fdh_ineqb em_fdl_ineqb em_fih_ineqt em_fil_ineqt em_fih_ineqb em_fil_ineqb em_fmh_ineqt em_fml_ineqt em_fmh_ineqb em_fml_ineqb

/*
Top 10 % share and capital share of net national income graphically
- advanced economies
- by financial development
- top / bottom half inequality
*/

drop int_lp90p100_t50 int_lp90p100_b50
merge 1:1 country year using "$loc\Data\int_temp_am.dta"
drop _merge
xtset id year, delta(5)

* Aggregate index

preserve
keep if imf_income=="AM" & FD_high_am==1
qui xtreg y L.avg_log_gdppc c.L.int_lp90p100_t`x'##c.L.Ksh_nni c.L.int_lp90p100_b`x'##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
qui margins, dydx(L.int_lp90p100_t`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FD & High inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(am_fdh_ineqt, replace)
qui margins, dydx(L.int_lp90p100_b`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FD & Low inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(am_fdh_ineqb, replace)
restore
preserve
keep if imf_income=="AM" & FD_high_am==0
qui xtreg y L.avg_log_gdppc c.L.int_lp90p100_t`x'##c.L.Ksh_nni c.L.int_lp90p100_b`x'##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
qui margins, dydx(L.int_lp90p100_t`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FD & High inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(am_fdl_ineqt, replace)
qui margins, dydx(L.int_lp90p100_b`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FD & Low inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(am_fdl_ineqb, replace)
restore

gr combine am_fdh_ineqt am_fdl_ineqt am_fdh_ineqb am_fdl_ineqb, col(4) scheme(s2mono) title("", size(medsmall)) ///
	title("A: Aggregate financial development", size(medsmall)) ysize(2) graphr(c(white)) name(fd_am, replace)

* Development of financial institutions

preserve
keep if imf_income=="AM" & FI_high_am==1
qui xtreg y L.avg_log_gdppc c.L.int_lp90p100_t`x'##c.L.Ksh_nni c.L.int_lp90p100_b`x'##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
qui margins, dydx(L.int_lp90p100_t`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FI & High inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(am_fih_ineqt, replace)
qui margins, dydx(L.int_lp90p100_b`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FI & Low inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(am_fih_ineqb, replace)
restore
preserve
keep if imf_income=="AM" & FI_high_am==0
qui xtreg y L.avg_log_gdppc c.L.int_lp90p100_t`x'##c.L.Ksh_nni c.L.int_lp90p100_b`x'##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
qui margins, dydx(L.int_lp90p100_t`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FI & High inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(am_fil_ineqt, replace)
qui margins, dydx(L.int_lp90p100_b`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FI & Low inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(am_fil_ineqb, replace)
restore

gr combine am_fih_ineqt am_fil_ineqt am_fih_ineqb am_fil_ineqb, col(4) scheme(s2mono) title("", size(medsmall)) ///
	title("B: Development of financial institutions", size(medsmall)) ysize(2) graphr(c(white)) name(fi_am, replace)

* Development of financial markets

preserve
keep if imf_income=="AM" & FM_high_am==1
qui xtreg y L.avg_log_gdppc c.L.int_lp90p100_t`x'##c.L.Ksh_nni c.L.int_lp90p100_b`x'##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.year i.xtremegrowth, ///
	fe vce(cl id)
qui margins, dydx(L.int_lp90p100_t`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FM & High inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(am_fmh_ineqt, replace)
qui margins, dydx(L.int_lp90p100_b`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:High FM & Low inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(am_fmh_ineqb, replace)
restore
preserve
keep if imf_income=="AM" & FM_high_am==0
qui xtreg y L.avg_log_gdppc c.L.int_lp90p100_t`x'##c.L.Ksh_nni c.L.int_lp90p100_b`x'##c.L.Ksh_nni ///
	L.d_pop L.csh_i L.csh_g L.lhc i.region i.year i.xtremegrowth, ///
	fe vce(cl id)
qui margins, dydx(L.int_lp90p100_t`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FM & High inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(am_fml_ineqt, replace)
qui margins, dydx(L.int_lp90p100_b`x') at(L.Ksh_nni=(0.1(0.025)0.5))
marginsplot, recast(line) recastci(rarea) scheme(s2mono) graphregion(fcolor(white)) ///
	title("{it:Low FM & Low inequality}", size(medium) color(gs2)) ///
	ytitle("", size(medsmall)) /// , orientation(horizontal)
	ysc(range(-0.6 0.6)) ylabel(-0.6(0.3)0.6) xtitle("", size(medsmall)) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) name(am_fml_ineqb, replace)
restore

gr combine am_fmh_ineqt am_fml_ineqt am_fmh_ineqb am_fml_ineqb, col(4) scheme(s2mono) title("", size(medsmall)) ///
	title("C: Development of financial markets", size(medsmall)) ysize(2) graphr(c(white)) name(fm_am, replace)

gr drop am_fdh_ineqt am_fdl_ineqt am_fdh_ineqb am_fdl_ineqb am_fih_ineqt am_fil_ineqt am_fih_ineqb am_fil_ineqb am_fmh_ineqt am_fml_ineqt am_fmh_ineqb am_fml_ineqb

/*
Combine the graphs once more
*/

gr combine fd_em fi_em fm_em, col(1) scheme(s2mono) title("", size(medsmall)) ysize(3.5) graphr(c(white)) name(em, replace)
graph export "$loc\Figures\Recent\pregr_kshnnitop10_fe_byfd_em.eps", as(eps) preview(off) replace
gr combine fd_am fi_am fm_am, col(1) scheme(s2mono) title("", size(medsmall)) ysize(3.5) graphr(c(white)) name(am, replace)
graph export "$loc\Figures\Recent\pregr_kshnnitop10_fe_byfd_am.eps", as(eps) preview(off) replace
