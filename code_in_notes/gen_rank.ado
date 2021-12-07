cap program drop gen_rank
program define gen_rank
	syntax varname , gen(name)
	tempname replicates_tag original_order mean_order
	gen `original_order'=_n
	sort `varlist'
	gen `gen'=_n
	duplicates tag `varlist', gen(`replicates_tag')
	egen `mean_order'=mean(`gen') if `replicates_tag'~=0, by(`varlist')
	replace `gen'=`mean_order' if `replicates_tag'~=0
	sort `original_order'
end
