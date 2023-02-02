use "$loc\Data\data_historical_5yr.dta", clear
format capsh_net %9.0g
format capsh_gross %9.0g

********************************************************************************

/*
Plot the time series
*/

* Top 10 share and capital share

preserve
drop if country=="NZ"
xtline p90p100, overlay i(country) t(year) graphr(c(white)) scheme(s2mono) legend(off) ///
	xsc(range(1900 2020)) xlabel(1900(20)2020) ysc(range(0.2 0.6)) ylabel(0.2(0.1)0.6, angle(horizontal)) ytitle("") xtitle("") ///
	title("{it:Top 10 % income share}", size(medium) ring(0) pos(12)) name(ts_p90p100, replace)
xtline capsh_net, overlay i(country) t(year) graphr(c(white)) scheme(s2mono) legend(off) ///
	xsc(range(1900 2020)) xlabel(1900(20)2020) ysc(range(0.1 0.51)) ylabel(0.1(0.1)0.5, angle(horizontal)) ytitle("") xtitle("") ///
	title("{it:Capital share}", size(medium) ring(0) pos(12)) name(ts_capsh, replace)
restore
gr combine ts_p90p100 ts_capsh, col(2) scheme(s2mono) title("", size(medium)) ///
	ysize(2.5) graphr(c(white)) name(tsdistr1, replace)
gr drop ts_p90p100 ts_capsh
graph export "$loc\Figures\Historical\tsdistr1.eps", as(eps) preview(off) replace

foreach x in "AU" "CA" "DE" "DK" "ES" "FI" "FR" "GB" "IT" "JP" "NL" "NO" "SE" "US" {
preserve
keep if country=="`x'" & year>=1950
replace capsh_net=0.4 if capsh_net>0.4
twoway line capsh_net year, lc(maroon) lp(solid) || line p90p100 year, lc(navy) lp(dash) yaxis(2) || , ///
	graphr(c(white)) scheme(s2mono) ytitle("", col(gs2)) title("`x'", size(medium) ring(0) pos(12) color(black) nobox) ///
	xtitle("", size(medium) col(gs2)) legend(off) /// legend(order(1 "Capital share" 2 "Top 1 % income share") region(style(none)) cols(2)) ///
	xsc(range(1950 2015)) xlabel(1950(20)2010) ysc(range(0 0.4)) ylabel(0(0.1)0.4, angle(horizontal)) ///
	ysc(range(0.2 0.6) axis(2)) ylabel(0.2(0.1)0.6, angle(horizontal) axis(2)) ytitle("", axis(2)) name(tsdistr_`x', replace)
restore
}
/*preserve
keep if country=="AU"
twoway line capsh_net year, lc(maroon) lp(solid) mlabsize(*4) mlabpos(0) msym(i) yscale(off noline) xscale(off noline) plotregion(style(none)) ///
	|| line p90p100 year, lc(navy) lp(dash) mlabsize(*4) mlabpos(0) msym(i) yscale(off noline) xscale(off noline) plotregion(style(none)) ///
	graphr(c(white)) scheme(s2mono) legend(order(1 "Capital share (left)" 2 "Top 1 % share (right)") region(style(none)) cols(1)) ///
	name(empty, replace)
restore*/
* use graph editor to hide the graph
graph use "$loc\Figures\Historical\empty.gph"

gr combine tsdistr_AU tsdistr_CA tsdistr_DE tsdistr_DK tsdistr_ES tsdistr_FI tsdistr_FR ///
	tsdistr_GB tsdistr_IT tsdistr_JP tsdistr_NL tsdistr_NO tsdistr_SE tsdistr_US empty, ///
	col(3) scheme(s2mono) title("", size(medium)) ///
	ysize(4.25) graphr(c(white)) name(tsdistr2, replace)
gr drop tsdistr_AU tsdistr_CA tsdistr_DE tsdistr_DK tsdistr_ES tsdistr_FI tsdistr_FR ///
	tsdistr_GB tsdistr_IT tsdistr_JP tsdistr_NL tsdistr_NO tsdistr_SE tsdistr_US empty
graph export "$loc\Figures\Historical\tsdistr2.eps", as(eps) preview(off) replace

* Growth of per capita GDP	

preserve
drop if country=="NZ"
xtline y_mpd, overlay i(country) t(year) graphr(c(white)) scheme(s2mono) legend(off) ///
	xsc(range(1900 2020)) xlabel(1900(20)2020) ysc(range(-0.16 0.2)) ylabel(-0.15(0.05)0.2) ytitle("") xtitle("") ///
	ysize(2.5) title("",) name(tsgr1, replace)
restore
graph export "$loc\Figures\Historical\tsgr1.eps", as(eps) preview(off) replace

foreach x in "AU" "CA" "DE" "DK" "ES" "FI" "FR" "GB" "IT" "JP" "NL" "NO" "SE" "US" {
preserve
keep if country=="`x'" & year>=1950
twoway line y year, lc(gs2) lp(solid) graphr(c(white)) scheme(s2mono) ytitle("", col(gs2)) ///
	title("`x'", size(medium) ring(0) pos(12) color(black) nobox) ///
	xtitle("", size(medium) col(gs2)) legend(off) xsc(range(1950 2015)) xlabel(1950(20)2010) ///
	ysc(range(-0.04 0.1)) ylabel(-0.04(0.04)0.08, angle(horizontal)) name(tsgr_`x', replace)
restore
}
gr combine tsgr_AU tsgr_CA tsgr_DE tsgr_DK tsgr_ES tsgr_FI tsgr_FR ///
	tsgr_GB tsgr_IT tsgr_JP tsgr_NL tsgr_NO tsgr_SE tsgr_US, ///
	col(3) scheme(s2mono) title("", size(medium)) ///
	ysize(4.25) graphr(c(white)) name(tsgr2, replace)
gr drop tsgr_AU tsgr_CA tsgr_DE tsgr_DK tsgr_ES tsgr_FI tsgr_FR ///
	tsgr_GB tsgr_IT tsgr_JP tsgr_NL tsgr_NO tsgr_SE tsgr_US
graph export "$loc\Figures\Historical\tsgr2.eps", as(eps) preview(off) replace

* Stock market capitalization to GDP	

preserve
keep if mcap_gdp_high==1
xtline mcap_gdp, overlay i(country) t(year) graphr(c(white)) scheme(s2mono) ///
	xsc(range(1950 2015)) xlabel(1950(20)2010) ysc(range(0 1.5)) ylabel(0(0.5)1.5) ytitle("") xtitle("") ///
	legend(order(1 "AU" 2 "CA" 3 "GB" 4 "JP" 5 "NL" 6 "SE" 7 "US") region(style(none)) cols(4)) ///
	title("{it:Average stock market capitalization to GDP > 50 %}", size(medium)) name(tsfindev1, replace)
restore
preserve
keep if mcap_gdp_high==0
xtline mcap_gdp, overlay i(country) t(year) graphr(c(white)) scheme(s2mono) ///
	xsc(range(1950 2015)) xlabel(1950(20)2010) ysc(range(0 1.5)) ylabel(0(0.5)1.5) ytitle("") xtitle("") ///
	legend(order(1 "DE" 2 "DK" 3 "ES" 4 "FI" 5 "FR" 6 "IT" 7 "NO") region(style(none)) cols(4)) ///
	title("{it:Average stock market capitalization to GDP < 50 %}", size(medium)) name(tsfindev2, replace)
restore
gr combine tsfindev1 tsfindev2, col(2) scheme(s2mono) title("", size(medium)) ///
	ysize(2.5) graphr(c(white)) name(tsfd, replace)
gr drop tsfindev1 tsfindev2
graph export "$loc\Figures\Historical\tsfd.eps", as(eps) preview(off) replace

gr drop _all

********************************************************************************

/*
Table of descriptives
*/

drop if country=="NZ"
drop if year<1950

gen nr=_n
gen var=""
replace var="Panel A: Historical sample of 14 countries, 1950-2019" if nr==2
replace var="High stock market cap to GDP" if nr==3
replace var="Growth of per capita GDP" if nr==4
replace var="Top 10 % income share" if nr==5
replace var="Top 1 % income share" if nr==6
replace var="Top 0.1 % income share" if nr==7
replace var="Capital share net of capital depreciation" if nr==8
replace var="Stock market capitalization to GDP" if nr==9
replace var="Per capita GDP" if nr==10
replace var="Investment to GDP" if nr==11
replace var="Government consumption to GDP" if nr==12
replace var="Population growth" if nr==13
replace var="Tertiary education, population share" if nr==14
replace var="" if nr==15
replace var="Number of observations (countries)" if nr==16
replace var="Low stock market cap to GDP" if nr==17
replace var="Growth of per capita GDP" if nr==18
replace var="Top 10 % income share" if nr==19
replace var="Top 1 % income share" if nr==20
replace var="Top 0.1 % income share" if nr==21
replace var="Capital share net of capital depreciation" if nr==22
replace var="Stock market capitalization to GDP" if nr==23
replace var="Per capita GDP" if nr==24
replace var="Investment to GDP" if nr==25
replace var="Government consumption to GDP" if nr==26
replace var="Population growth" if nr==27
replace var="Tertiary education, population share" if nr==28
replace var="" if nr==29
replace var="Number of observations (countries)" if nr==30
gen mean=.
gen sd=.
gen min=.
gen max=.

* Statistics: high stock market cap to GDP
tabstat y if mcap_gdp_high==1, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==4
replace sd=r(StatTotal)[2,1] if nr==4
replace min=r(StatTotal)[3,1] if nr==4
replace max=r(StatTotal)[4,1] if nr==4
tabstat p90p100 if mcap_gdp_high==1, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==5
replace sd=r(StatTotal)[2,1] if nr==5
replace min=r(StatTotal)[3,1] if nr==5
replace max=r(StatTotal)[4,1] if nr==5
tabstat p99p100 if mcap_gdp_high==1, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==6
replace sd=r(StatTotal)[2,1] if nr==6
replace min=r(StatTotal)[3,1] if nr==6
replace max=r(StatTotal)[4,1] if nr==6
tabstat p999p100 if mcap_gdp_high==1, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==7
replace sd=r(StatTotal)[2,1] if nr==7
replace min=r(StatTotal)[3,1] if nr==7
replace max=r(StatTotal)[4,1] if nr==7
tabstat capsh_net if mcap_gdp_high==1, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==8
replace sd=r(StatTotal)[2,1] if nr==8
replace min=r(StatTotal)[3,1] if nr==8
replace max=r(StatTotal)[4,1] if nr==8
tabstat mcap_gdp if mcap_gdp_high==1, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==9
replace sd=r(StatTotal)[2,1] if nr==9
replace min=r(StatTotal)[3,1] if nr==9
replace max=r(StatTotal)[4,1] if nr==9
tabstat rgdpe_pc if mcap_gdp_high==1, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==10
replace sd=r(StatTotal)[2,1] if nr==10
replace min=r(StatTotal)[3,1] if nr==10
replace max=r(StatTotal)[4,1] if nr==10
tabstat csh_i if mcap_gdp_high==1, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==11
replace sd=r(StatTotal)[2,1] if nr==11
replace min=r(StatTotal)[3,1] if nr==11
replace max=r(StatTotal)[4,1] if nr==11
tabstat csh_g if mcap_gdp_high==1, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==12
replace sd=r(StatTotal)[2,1] if nr==12
replace min=r(StatTotal)[3,1] if nr==12
replace max=r(StatTotal)[4,1] if nr==12
tabstat d_pop if mcap_gdp_high==1, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==13
replace sd=r(StatTotal)[2,1] if nr==13
replace min=r(StatTotal)[3,1] if nr==13
replace max=r(StatTotal)[4,1] if nr==13
tabstat lhc if mcap_gdp_high==1, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==14
replace sd=r(StatTotal)[2,1] if nr==14
replace min=r(StatTotal)[3,1] if nr==14
replace max=r(StatTotal)[4,1] if nr==14
* Statistics: low stock market cap to GDP
tabstat y if mcap_gdp_high==0, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==18
replace sd=r(StatTotal)[2,1] if nr==18
replace min=r(StatTotal)[3,1] if nr==18
replace max=r(StatTotal)[4,1] if nr==18
tabstat p90p100 if mcap_gdp_high==0, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==19
replace sd=r(StatTotal)[2,1] if nr==19
replace min=r(StatTotal)[3,1] if nr==19
replace max=r(StatTotal)[4,1] if nr==19
tabstat p99p100 if mcap_gdp_high==0, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==20
replace sd=r(StatTotal)[2,1] if nr==20
replace min=r(StatTotal)[3,1] if nr==20
replace max=r(StatTotal)[4,1] if nr==20
tabstat p999p100 if mcap_gdp_high==0, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==21
replace sd=r(StatTotal)[2,1] if nr==21
replace min=r(StatTotal)[3,1] if nr==21
replace max=r(StatTotal)[4,1] if nr==21
tabstat capsh_net if mcap_gdp_high==0, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==22
replace sd=r(StatTotal)[2,1] if nr==22
replace min=r(StatTotal)[3,1] if nr==22
replace max=r(StatTotal)[4,1] if nr==22
tabstat mcap_gdp if mcap_gdp_high==0, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==23
replace sd=r(StatTotal)[2,1] if nr==23
replace min=r(StatTotal)[3,1] if nr==23
replace max=r(StatTotal)[4,1] if nr==23
tabstat rgdpe_pc if mcap_gdp_high==0, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==24
replace sd=r(StatTotal)[2,1] if nr==24
replace min=r(StatTotal)[3,1] if nr==24
replace max=r(StatTotal)[4,1] if nr==24
tabstat csh_i if mcap_gdp_high==0, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==25
replace sd=r(StatTotal)[2,1] if nr==25
replace min=r(StatTotal)[3,1] if nr==25
replace max=r(StatTotal)[4,1] if nr==25
tabstat csh_g if mcap_gdp_high==0, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==26
replace sd=r(StatTotal)[2,1] if nr==26
replace min=r(StatTotal)[3,1] if nr==26
replace max=r(StatTotal)[4,1] if nr==26
tabstat d_pop if mcap_gdp_high==0, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==27
replace sd=r(StatTotal)[2,1] if nr==27
replace min=r(StatTotal)[3,1] if nr==27
replace max=r(StatTotal)[4,1] if nr==27
tabstat lhc if mcap_gdp_high==0, stat(mean sd min max) save
replace mean=r(StatTotal)[1,1] if nr==28
replace sd=r(StatTotal)[2,1] if nr==28
replace min=r(StatTotal)[3,1] if nr==28
replace max=r(StatTotal)[4,1] if nr==28


















