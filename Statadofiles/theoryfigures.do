* Labor endowment changes: the shock of the model

clear
set obs 7
gen nr=_n
gen d=0
replace d=-0.0118922907418599 if nr==1
replace d=-0.0100873064655319 if nr==2
replace d=-0.00641724453454551 if nr==3
replace d=0.0103887325282648 if nr==5
replace d=0.0264364519464622 if nr==6
replace d=0.0504553759762998 if nr==7
gen start=0
twoway dropline d nr, lc(gs2) lp(solid) yline(0, lstyle(foreground)) ///
	graphr(c(white)) scheme(s2mono) title("", size(medium) color(black) nobox) ///
	xtitle("Labor endowment states", size(medlarge)) ytitle("Change in labor endowment", size(medlarge)) ///
	xsc(range(1 7)) xlabel(1(1)7) ysize(2.75) ///
	text(0.0525 2.75 "Changes in the expected value of the labor endowment", size(medlarge)) ///
	text(0.0475 3 "by labor endowment states when {&sigma} increases from 0.29 to 0.30", size(medlarge)) ///
	msymbol(o) name(d_endow, replace)
graph export "$loc\Theory\d_endow.eps", as(eps) preview(off) replace

* Simulations

cd "$loc\Theory"
import delimited coef_simul.txt, clear
gen alpha = _n / 10
rename v1 A00
rename v2 A05
rename v3 A10
rename v4 A15
rename v5 A20
save coef_simul.dta, replace
clear
set obs 17
gen alpha = _n / 40
replace alpha = alpha + 0.075
merge 1:1 alpha using coef_simul
erase coef_simul.dta
sort alpha
drop _merge
gen nr=_n
drop if nr==9 | nr==14
drop nr
foreach var of varlist A00 A05 A10 A15 A20 {
	replace `var' = `var' * 10
}
foreach var of varlist A00 A05 A10 A15 A20 {
	ipolate `var' alpha, gen (`var'_i)
}
twoway line A00_i alpha, lc(gs2) lp(solid) || ///
	line A05_i alpha, lc(gs4) lp(dash) || ///
	line A10_i alpha, lc(gs6) lp(dash_dot) || ///
	line A15_i alpha, lc(gs8) lp(shortdash) || ///
	line A20_i alpha, lc(gs10) lp(shortdash_dot) || , ///
	graphr(c(white)) scheme(s2mono) title("", size(medium) color(black) nobox) ///
	xtitle("Capital share", size(medlarge)) ytitle("{&Delta} Output", size(medlarge)) ///
	legend(order(1 "A{sub:1}=0.0" 2 "A{sub:1}=0.5" 3 "A{sub:1}=1.0" 4 "A{sub:1}=1.5" 5 "A{sub:1}=2.0") ///
	region(style(none)) cols(5) size(medlarge) ring(0) pos(6)) ysize(2.75) ///
	xsc(range(0.1 0.5)) xlabel(0.1(0.1)0.5) /*ysc(range(0 0.8)) ylabel(0(0.2)0.8)*/ ///
	text(-0.065 0.19 "Credit constraint {&uArr} when A{sub:1} {&uArr}", size(medlarge)) ///
	name(simreact, replace)
graph export "$loc\Theory\simreact.eps", as(eps) preview(off) replace

gr drop _all
