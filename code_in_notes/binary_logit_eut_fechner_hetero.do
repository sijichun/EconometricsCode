// binary_logit_eut_fechner_hetero.do
clear
set more off
* define Original Recipe EUT with CRRA and Fechner errors
global link "Probit"
cap program drop ML_eut_hetero
program define ML_eut_hetero
	args lnf r sigma
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
			gen double `Lambda' = 1/(1+exp(-1*(`euR' - `euL')/`sigma'))
		}
		else{
			gen double `Lambda' = normal((`euR' - `euL')/`sigma')
		}
		replace `lnf' = $ML_y1 * log(`Lambda') + (1-$ML_y1 ) * log(1-`Lambda')
	}
end


use datasets/lottery_data.dta
local x "Female Black Hispanic Age Business GPAlow"
local dm_x ""
foreach v of local x{
	qui: su `v'
	gen dm_`v' = `v'-r(mean)
	local dm_x "`dm_x' dm_`v'"
}
ml model lf ML_eut_hetero (r: Choices P0left P1left P2left P3left P0right P1right P2right P3right prize0 prize1 prize2 prize3 stake = `dm_x') (sigma: `dm_x') if Choices~=., cluster(id) technique(bfgs) 
ml maximize