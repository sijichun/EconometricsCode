// binary_logit_eut.do
clear
set more off
* define Original Recipe EUT with CRRA and no errors
global link "Probit"
cap program drop ML_eut
program define ML_eut
    args lnf r
    tempvar y0 y1 y2 y3 euL euR Lambda
    * construct likelihood for EUT
    qui{
		gen double `y0' = ($ML_y14+$ML_y10)^`r'
		gen double `y1' = ($ML_y14+$ML_y11)^`r'
		gen double `y2' = ($ML_y14+$ML_y12)^`r'
		gen double `y3' = ($ML_y14+$ML_y13)^`r'

		gen double `euL' = ($ML_y2 *`y0')+($ML_y3 *`y1')+($ML_y4 *`y2')+($ML_y5 *`y3')
		gen double `euR' = ($ML_y6 *`y0')+($ML_y7 *`y1')+($ML_y8 *`y2')+($ML_y9 *`y3')
		if ("$link" == "Logit"){
			gen double `Lambda' = 1/(1+exp(-1*(`euR' - `euL')))
		}
		else{
			gen double `Lambda' = normal((`euR' - `euL'))
		}
		replace `lnf' = $ML_y1 * log(`Lambda') + (1-$ML_y1 ) * log(1-`Lambda')
	}
end

use datasets/lottery_data.dta
ml model lf ML_eut (r: Choices P0left P1left P2left P3left P0right P1right P2right P3right prize0 prize1 prize2 prize3 stake = ,freeparm) if Choices~=., cluster(id) technique(bfgs) 
ml maximize