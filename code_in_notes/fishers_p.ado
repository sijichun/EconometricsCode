cap program drop fishers_p
program define fishers_p, rclass
	syntax varlist(min=2 max=2)[, reps(int 1000) plot]
	tempname frstats w y N Nt test_stat p
	tempvar w_rea random_num
	tokenize `varlist'
	local `y' "`1'"
	local `w' "`2'"
	frame create `frstats' stats
	qui{
		// 计算样本量
		su ``w''
		local `N'=r(N)
		local `Nt'=r(sum)
		// 计算均值的差
		reg ``y'' ``w''
		local `test_stat'=_b[``w'']
		// 重新分配
		gen `w_rea'=.
		gen `random_num'=.
		forvalues i=1/`reps'{
			replace `random_num'=runiform()
			sort `random_num'
			replace `w_rea'=(_n<=``Nt'')
			reg ``y'' `w_rea'
			frame post `frstats' (_b[`w_rea'])
		}
		frame `frstats'{
			gen extreme=abs(stats)>abs(``test_stat'')
			su extreme
			local `p'=r(mean)
		}
	}
	if "`plot'"=="plot"{
		frame `frstats': hist stats, xline(``test_stat'')
	}
	return scalar p=``p''
end
