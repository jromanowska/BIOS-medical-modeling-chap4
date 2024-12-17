* read data
use https://stats.idre.ucla.edu/stat/data/hsbdemo, clear

* to run binary logistic regression, make dummy of prog 
tabulate prog, gen(program)


*** with only one covariate: ses

* perform binary logistic regression for "general" with "academic" as base
logit program1 i.ses if prog != 3, or
est store general_bin

* perform binary logistic regression for "vocation" with "academic" as base
logit program3 i.ses if prog != 1, or
est store vocation_bin

* perform multinomial logistic regression with "academic" as base
mlogit prog i.ses, rrr base(2)
est store multinom

* estimates
esttab general_bin vocation_bin multinom, b se noconstant nostar brackets


*** with both covariates: ses + write

* perform binary logistic regression for "general" with "academic" as base
logit program1 i.ses c.write if prog != 3, or
est store general_bin_m

* perform binary logistic regression for "vocation" with "academic" as base
logit program3 i.ses c.write if prog != 1, or
est store vocation_bin_m

* perform multinomial logistic regression with "academic" as base
mlogit prog i.ses c.write, rrr base(2)
est store multinom_m

* estimates
esttab general_bin_m vocation_bin_m multinom_m, b se noconstant nostar brackets


*** prediction

* retain mulinomial results
est restore multinom_m

* predict probabilities for each outcome for each SES level and all write-scores
margins i.ses, at (write = (31(5)67))

* make value labels for outcome
label define pr 1  "General" 2  "Academic" 3  "Vocational"

* plot predicted probabilites
marginsplot , xdimension(write) by(ses) noci 

