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
erase "$loc\Data\temp.dta"
xtset id year, delta(5)

********************************************************************************

gen nr=_n
gen var=""
replace var="Panel B: Recent sample of 115 countries, 1980-2019" if nr==2
replace var="Advanced economies" if nr==3
replace var="Growth of per capita GDP" if nr==4
replace var="Top 10 % income share" if nr==5
replace var="Gini coefficient" if nr==6
replace var="Capital share of net national income" if nr==7
replace var="Stock market capitalization to GDP" if nr==8
replace var="Private credit to GDP" if nr==9
replace var="Aggregate financial development, index" if nr==10
replace var="Development of financial institutions, index" if nr==11
replace var="Development of financial markets, index" if nr==12
replace var="Per capita GDP" if nr==13
replace var="Investment to GDP" if nr==14
replace var="Government consumption to GDP" if nr==15
replace var="Population growth" if nr==16
replace var="Tertiary education, population share" if nr==17
replace var="Number of observations (countries)" if nr==18
replace var="Emerging markets" if nr==19
replace var="Growth of per capita GDP" if nr==20
replace var="Top 10 % income share" if nr==21
replace var="Gini coefficient" if nr==22
replace var="Capital share of net national income" if nr==23
replace var="Stock market capitalization to GDP" if nr==24
replace var="Private credit to GDP" if nr==25
replace var="Aggregate financial development, index" if nr==26
replace var="Development of financial institutions, index" if nr==27
replace var="Development of financial markets, index" if nr==28
replace var="Per capita GDP" if nr==29
replace var="Investment to GDP" if nr==30
replace var="Government consumption to GDP" if nr==31
replace var="Population growth" if nr==32
replace var="Tertiary education, population share" if nr==33
replace var="Number of observations (countries)" if nr==34
replace var="Low income countries" if nr==35
replace var="Growth of per capita GDP" if nr==36
replace var="Top 10 % income share" if nr==37
replace var="Gini coefficient" if nr==38
replace var="Capital share of net national income" if nr==39
replace var="Stock market capitalization to GDP" if nr==40
replace var="Private credit to GDP" if nr==41
replace var="Aggregate financial development, index" if nr==42
replace var="Development of financial institutions, index" if nr==43
replace var="Development of financial markets, index" if nr==44
replace var="Per capita GDP" if nr==45
replace var="Investment to GDP" if nr==46
replace var="Government consumption to GDP" if nr==47
replace var="Population growth" if nr==48
replace var="Tertiary education, population share" if nr==49
replace var="Number of observations (countries)" if nr==50
gen mean=.
gen sd=.
gen min=.
gen max=.

* Statistics: advanced economies
tabstat y p90p100 gini Ksh_nni mcap_gdp_wb cred_gdp_wb FD FI FM rgdpe_pc csh_i csh_g d_pop lhc if imf_income=="AM", stat(mean sd min max) save
forval i = 1(1)14 {
replace mean=r(StatTotal)[1,`i'] if nr==`i'+3
replace sd=r(StatTotal)[2,`i'] if nr==`i'+3
replace min=r(StatTotal)[3,`i'] if nr==`i'+3
replace max=r(StatTotal)[4,`i'] if nr==`i'+3
}
* Statistics: emerging markets
tabstat y p90p100 gini Ksh_nni mcap_gdp_wb cred_gdp_wb FD FI FM rgdpe_pc csh_i csh_g d_pop lhc if imf_income=="EM", stat(mean sd min max) save
forval i = 1(1)14 {
replace mean=r(StatTotal)[1,`i'] if nr==`i'+19
replace sd=r(StatTotal)[2,`i'] if nr==`i'+19
replace min=r(StatTotal)[3,`i'] if nr==`i'+19
replace max=r(StatTotal)[4,`i'] if nr==`i'+19
}
* Statistics: low income countries
tabstat y p90p100 gini Ksh_nni mcap_gdp_wb cred_gdp_wb FD FI FM rgdpe_pc csh_i csh_g d_pop lhc if imf_income=="LIC", stat(mean sd min max) save
forval i = 1(1)14 {
replace mean=r(StatTotal)[1,`i'] if nr==`i'+35
replace sd=r(StatTotal)[2,`i'] if nr==`i'+35
replace min=r(StatTotal)[3,`i'] if nr==`i'+35
replace max=r(StatTotal)[4,`i'] if nr==`i'+35
}