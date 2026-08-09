// mix_logit_eut_fechner.do
clear
set more off
set seed 42
* define Original Recipe EUT with CRRA and Fechner errors
global R=500
cap program drop ML_eut_fechner_mixlogit
program define ML_eut_fechner_mixlogit
    args lnf alpha beta vsigma tau
    tempvar r rm sigma sigmam zeta zetam y0 y1 y2 y3 euL euR Lambda
    * construct likelihood for EUT
    qui{
		gen `Lambda' = 0
		gen `y0' = 0
		gen `y1' = 0
		gen `y2' = 0
		gen `y3' = 0
		gen `euL' = 0
		gen `euR' = 0
		// numerical integral
		forvalues rep=1/$R {
			
			bysort $ML_y15 : gen `rm' = rbeta(`alpha',`beta') if _n==1
			egen `r' = min(`rm'), by($ML_y15 )
			bysort $ML_y15 : gen `sigmam' = exp(rnormal(`vsigma', `tau')) if _n == 1
			egen `sigma' = min(`sigmam'), by($ML_y15 )
			
			replace `y0' = ($ML_y14+$ML_y10)^`r'
			replace `y1' = ($ML_y14+$ML_y11)^`r'
			replace `y2' = ($ML_y14+$ML_y12)^`r'
			replace `y3' = ($ML_y14+$ML_y13)^`r'
			
			replace `euL' = ($ML_y2 *`y0')+($ML_y3 *`y1')+($ML_y4 *`y2')+($ML_y5 *`y3')
			replace `euR' = ($ML_y6 *`y0')+($ML_y7 *`y1')+($ML_y8 *`y2')+($ML_y9 *`y3')
			
			replace `Lambda' = `Lambda' + 1/(1+exp(-1*(`euR' - `euL')/`sigma'))
			
			drop `rm' `r' `sigmam' `sigma' 
		}
		replace `Lambda' = `Lambda'/$R
		replace `lnf' = $ML_y1 * log(`Lambda') + (1-$ML_y1 ) * log(1-`Lambda')
	}
end

use datasets/lottery_data.dta
ml model lf ML_eut_fechner_mixlogit (r: Choices P0left P1left P2left P3left P0right P1right P2right P3right prize0 prize1 prize2 prize3 stake id= ,freeparm) /beta /sigma /tau if Choices~=., cluster(id) technique(bfgs) 
ml init /r=1 /beta=1 /sigma=0 /tau=1
ml maximize