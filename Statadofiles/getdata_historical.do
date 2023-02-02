cd "$loc\Data"

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

/*
Open the Bentsson and Waldenström (2018) data and merge the top income shares
*/

cd "$loc\Data\Original"

clear
import excel BW_data.xlsx, sheet("Capital Shares Database") cellrange(A14:H2217) firstrow
keep ccode year cs_g cs_n
rename cs_g capsh_gross
rename cs_n capsh_net
kountry ccode, from(iso3c) to(iso2c)
rename _ISO2C_ country
order country
replace country="JP" if ccode=="JAP"
drop ccode
replace capsh_gross = capsh_gross / 100
replace capsh_net = capsh_net / 100

cd "$loc\Data"

merge 1:1 country year using WID_p99p100.dta
drop if _merge==2
drop _merge
merge 1:1 country year using WID_p999p100.dta
drop if _merge==2
drop _merge
merge 1:1 country year using WID_p90p100.dta
drop if _merge==2
drop _merge

erase WID_p99p100.dta
erase WID_p999p100.dta
erase WID_p90p100.dta

gen period = 5 * floor(year/5)
collapse capsh_gross-p90p100, by(country period)
rename period year
tab year // rough coverage over time, tells us very little

/*
Countries to be dropped
- Argentina stands out in terms of economic development. Net shares missing and holes in inequality measure coverage
- Austria: inequality info starts in 1980
- Belgium: inequality info starts in 1980
- Brazil stands out in terms of economic development. Net shares missing and holes in inequality measure coverage
- Ireland: a hole in the inequality measures
*/

drop if country=="AR" | country=="AT" | country=="BE" | country=="BR" | country=="IE"

/*
We drop if consecutive years are missing. If a single hole, we interpolate.
*/

drop if country=="CA" & year<1925
drop if country=="DE" & year<1950
drop if country=="DK" & year<1900
drop if country=="FI" & year<1920
drop if country=="FR" & year<1900
drop if country=="GB" & year<1900
drop if country=="IT" & year<1900
drop if country=="NO" & year<1925
drop if country=="NZ" & year>2010
drop if country=="SE" & year<1900
tab year // portrays an accurate coverage over years
egen long id = group(country)
xtset id year, delta(5)
foreach var of varlist capsh_gross capsh_net p99p100 p999p100 p90p100 {
	replace `var' = (F.`var' + L.`var') / 2 if `var'==.
}
drop id

/*
For Finland and the Netherlands, there are full series on top 1 but after 1950
- 6 windows missing for Finland, top 10 and top 0.1
- 2 windows missing for the Netherlands, top 0.1
Use the info on co-movement and fill in the gaps
*/
preserve
keep if country=="FI"
keep if p90p100!=. & p999p100!=.
gen ratio1=p99p100/p90p100
gen ratio2=p99p100/p999p100
sum ratio1 ratio2
restore
replace p90p100=p99p100/0.2824045 if country=="FI" & p90p100==.
replace p999p100=p99p100/3.212775 if country=="FI" & p999p100==.
preserve
keep if country=="NL"
keep if p90p100!=. & p999p100!=.
gen ratio2=p99p100/p999p100
sum ratio2
restore
replace p999p100=p99p100/3.894496 if country=="NL" & p999p100==.

/*
Save
*/

save BW_WID_merged_5yr.dta, replace

/*
Real GDP per capita from MPD
*/

cd "$loc\Data\Original"
use mpd2020.dta, clear
cd "$loc\Data"
egen long id = group(country)
xtset id year, yearly
rename gdppc rgdpe_pc
keep countrycode id year rgdpe_pc
gen l_rgdpe_pc = log(rgdpe_pc)
gen y_mpd = (F4.l_rgdpe_pc-l_rgdpe_pc)/4
replace y_mpd = (F3.l_rgdpe_pc-l_rgdpe_pc)/3 if year==2015
gen l_rgdpe_pc_tminus1_mpd = L.l_rgdpe_pc
gen avg_log_gdppc_mpd = (l_rgdpe_pc+F1.l_rgdpe_pc+F2.l_rgdpe_pc+F3.l_rgdpe_pc+F4.l_rgdpe_pc)/5
replace avg_log_gdppc_mpd = (l_rgdpe_pc+F1.l_rgdpe_pc+F2.l_rgdpe_pc+F3.l_rgdpe_pc)/4 if year==2015
rename rgdpe_pc rgdpe_pc_mpd
rename l_rgdpe_pc l_rgdpe_pc_mpd
drop if year<=1899
drop if year==1901
drop if year==1902
drop if year==1903
drop if year==1904
drop if year==1906
drop if year==1907
drop if year==1908
drop if year==1909
drop if year==1911
drop if year==1912
drop if year==1913
drop if year==1914
drop if year==1916
drop if year==1917
drop if year==1918
drop if year==1919
drop if year==1921
drop if year==1922
drop if year==1923
drop if year==1924
drop if year==1926
drop if year==1927
drop if year==1928
drop if year==1929
drop if year==1931
drop if year==1932
drop if year==1933
drop if year==1934
drop if year==1936
drop if year==1937
drop if year==1938
drop if year==1939
drop if year==1941
drop if year==1942
drop if year==1943
drop if year==1944
drop if year==1946
drop if year==1947
drop if year==1948
drop if year==1949
drop if year==1951
drop if year==1952
drop if year==1953
drop if year==1954
drop if year==1956
drop if year==1957
drop if year==1958
drop if year==1959
drop if year==1961
drop if year==1962
drop if year==1963
drop if year==1964
drop if year==1966
drop if year==1967
drop if year==1968
drop if year==1969
drop if year==1971
drop if year==1972
drop if year==1973
drop if year==1974
drop if year==1976
drop if year==1977
drop if year==1978
drop if year==1979
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
keep if country=="AU" | country=="CA" | country=="DE" | country=="DK" | country=="ES" | ///
	country=="FI" | country=="FR" | country=="GB" | country=="IT" | country=="JP" | ///
	country=="NL" | country=="NO" | country=="NZ" | country=="SE" | country=="US"
save MPD_5yr.dta, replace

/*
Real GDP per capita and capital stock from PWT
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
drop if year<1950
drop if year==1951
drop if year==1952
drop if year==1953
drop if year==1954
drop if year==1956
drop if year==1957
drop if year==1958
drop if year==1959
drop if year==1961
drop if year==1962
drop if year==1963
drop if year==1964
drop if year==1966
drop if year==1967
drop if year==1968
drop if year==1969
drop if year==1971
drop if year==1972
drop if year==1973
drop if year==1974
drop if year==1976
drop if year==1977
drop if year==1978
drop if year==1979
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
replace l_rgdpe_pc_tminus1=l_rgdpe_pc if year==1950
keep if country=="AU" | country=="CA" | country=="DE" | country=="DK" | country=="ES" | ///
	country=="FI" | country=="FR" | country=="GB" | country=="IT" | country=="JP" | ///
	country=="NL" | country=="NO" | country=="SE" | country=="US"
save PWT_5yr.dta, replace

/*
Financial development
*/

cd "$loc\Data\Original"
use KZ_data.dta, clear
cd "$loc\Data"
kountry iso, from(iso3c) to(iso2c)
keep year mcap-eq_tr _ISO2C_
rename _ISO2C_ country
order country year
gen period = 5 * floor(year/5)
collapse mcap mcap_gdp eq_capgain-eq_tr, by(country period)
rename period year
keep if country=="AU" | country=="CA" | country=="DE" | country=="DK" | country=="ES" | ///
	country=="FI" | country=="FR" | country=="GB" | country=="IT" | country=="JP" | ///
	country=="NL" | country=="NO" | country=="SE" | country=="US"
drop if year<1950

foreach var of varlist mcap mcap_gdp eq_capgain divi_gdp eq_dp eq_tr {
	bysort country: egen mean_`var' = mean(`var')
}
foreach var of varlist mean_mcap mean_mcap_gdp mean_eq_capgain mean_divi_gdp mean_eq_dp mean_eq_tr {
	preserve
	collapse `var', by(country)
	sort `var'
	list
	restore
}
gen mcap_gdp_high=0
replace mcap_gdp_high=1 if mean_mcap_gdp>0.5

save KZ_5yr.dta, replace

/*
Controls from PWT
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
keep if country=="AU" | country=="CA" | country=="DE" | country=="DK" | country=="ES" | ///
	country=="FI" | country=="FR" | country=="GB" | country=="IT" | country=="JP" | ///
	country=="NL" | country=="NO" | country=="SE" | country=="US"
save PWT_cntrls_5yr.dta, replace

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
keep if country=="AU" | country=="CA" | country=="DE" | country=="DK" | country=="ES" | ///
	country=="FI" | country=="FR" | country=="GB" | country=="IT" | country=="JP" | ///
	country=="NL" | country=="NO" | country=="SE" | country=="US"
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
keep if country=="AU" | country=="CA" | country=="DE" | country=="DK" | country=="ES" | ///
	country=="FI" | country=="FR" | country=="GB" | country=="IT" | country=="JP" | ///
	country=="NL" | country=="NO" | country=="SE" | country=="US"
save WIID4Gini_5yr.dta, replace

/*
Combine the different data sets
*/

cd "$loc\Data"
use MPD_5yr, clear
merge 1:1 country year using PWT_5yr.dta
drop _merge
merge 1:1 country year using BW_WID_merged_5yr.dta
drop _merge
merge 1:1 country year using KZ_5yr.dta
drop _merge
merge 1:1 country year using PWT_cntrls_5yr.dta
drop _merge
merge 1:1 country year using BarroLee_5yr.dta
drop _merge
merge 1:1 country year using WIID4Gini_5yr.dta
drop _merge

save data_historical_5yr.dta, replace

erase BW_WID_merged_5yr.dta
erase KZ_5yr.dta
erase MPD_5yr.dta
erase PWT_5yr.dta
erase PWT_cntrls_5yr.dta
erase BarroLee_5yr.dta
erase WIID4Gini_5yr.dta
