* read data
use "C:\Users\RMNI\OneDrive - Høgskulen på Vestlandet\Skrivebord\BIOS\Data_Exercise_2.dta", clear

* tabell
tab SES KMIKAT, row

* proprotional odds logistic regression 
ologit KMIKAT i.SES, or

* check PO grafically
gen logit_1_vs_234_SES1 = _b[/cut1] - _b[1.SES]
gen logit_12_vs_34_SES1 = _b[/cut2] - _b[1.SES]
gen logit_123_vs_4_SES1 = _b[/cut3] - _b[1.SES]

gen logit_1_vs_234_SES2 = _b[/cut1] - _b[2.SES]
gen logit_12_vs_34_SES2 = _b[/cut2] - _b[2.SES]
gen logit_123_vs_4_SES2 = _b[/cut3] - _b[2.SES]

gen logit_1_vs_234_SES3 = _b[/cut1] - _b[3.SES]
gen logit_12_vs_34_SES3 = _b[/cut2] - _b[3.SES]
gen logit_123_vs_4_SES3 = _b[/cut3] - _b[3.SES]

graph dot (mean) logit_1_vs_234_SES1 logit_12_vs_34_SES1 logit_123_vs_4_SES1
graph save a, replace
graph dot (mean) logit_1_vs_234_SES2 logit_12_vs_34_SES2 logit_123_vs_4_SES2
graph save b, replace
graph dot (mean) logit_1_vs_234_SES3 logit_12_vs_34_SES3 logit_123_vs_4_SES3
graph save c, replace
graph combine a.gph b.gph c.gph


* check proportinality by test (approximate likelihood-ratio test)
tabulate SES, generate(SES)
omodel logit KMIKAT SES2 SES3

* predict probabilities for each KMIKAT for each SES level and all write-scores
ologit KMIKAT i.SES, or
est store propodds
margins SES
marginsplot

* By hand
* for k = undervekt = 1 and low, medium and high SES
disp exp(_b[/cut1] - _b[1.SES])/(1 + exp(_b[/cut1] - _b[1.SES]))
disp exp(_b[/cut1] - _b[2.SES])/(1 + exp(_b[/cut1] - _b[2.SES]))
disp exp(_b[/cut1] - _b[3.SES])/(1 + exp(_b[/cut1] - _b[3.SES]))


* perform binary logistic regression for "undervekt" 
gen KMIKAT1 = 1
replace KMIKAT1 = 0 if KMIKAT <=1
tab KMIKAT KMIKAT1
logit KMIKAT1 i.SES, or
est store prg1

* perform binary logistic regression for "undervekt" + "normal"
gen KMIKAT2 = 1
replace KMIKAT2 = 0 if KMIKAT <=2
tab KMIKAT KMIKAT2
logit KMIKAT2 i.SES, or
est store prg2

* perform binary logistic regression for "undervekt" + "normal" + "overvekt"
gen KMIKAT3 = 1
replace KMIKAT3 = 0 if KMIKAT <=3
tab KMIKAT KMIKAT3
logit KMIKAT3 i.SES, or
est store prg3

* estimates
esttab prg1 prg2 prg3  propodds, eform se 

