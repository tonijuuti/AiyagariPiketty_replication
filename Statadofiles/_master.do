global loc "DIRECTORY\AiyagariPiketty_replication" // change this accordingly
********************************************************************************
/*
Retrieve data
*/

* Load some needed packages
*ssc install wid
*ssc install wbopendata
*ssc install kountry

do "$loc\Statadofiles\getdata_historical"
do "$loc\Statadofiles\getdata_recent"

********************************************************************************
* Before the empirics, draw the theory figures (coefficients from Matlab)

do "$loc\Statadofiles\theoryfigures"

********************************************************************************
* Analyze historical data

/*
Descriptives
*/

do "$loc\Statadofiles\historical_descr"

/*
Panel regressions
*/

do "$loc\Statadofiles\historical_panelregr1"
do "$loc\Statadofiles\historical_panelregr2_appdx"

********************************************************************************
* Analyze recent data

/*
Descriptives
*/

do "$loc\Statadofiles\recent_descr"

/*
Panel regressions
*/

do "$loc\Statadofiles\recent_panelregr1"
do "$loc\Statadofiles\recent_panelregr2_appdx"

********************************************************************************
erase "$loc\Data\int_temp_am.dta"
erase "$loc\Data\int_temp_em.dta"
erase "$loc\Data\temp.dta"
