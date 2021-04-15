// local_poly_cv.do
clear
set more off
// 生成数据
set seed 19880505
set obs 300
gen x=2*runiform()
gen y=exp(sin(x^3))+rnormal()
gen y_true=exp(sin(x^3))
label variable y_true "真实函数"
// 生成高阶项
gen x_21=x-2
forvalues i=2/5{
    gen x_2`i'=x_21^`i'
}
// 标记测试集并记录测试集数量，选最近的10个作为测试集
gen absolute_distance=abs(x_21)
sort absolute_distance
gen test_set=_n<=10
// 初始化控制变量，每次增加p的时候自动添加
local control ""
// 初始化最优的p,h，并将min_mse设置为一个比较大的数
local argmin_p=0
local argmin_h=0
local min_mse=1e5
// 开始循环
forvalues p=1/5{
    // 每次对p循环，增加x_2的高阶项
    local control "`control' x_2`p'"
    forvalues h=0.01(0.01)0.5{
    	// 初始化(p,h)组合的均方误差
        local cv_error2=0
        gen w=normalden((x-2)/`h')
        // 对选取的10个测试集进行交叉验证
        forvalues i=1/10{
            quietly: reg y `control' [iw=w] if _n~=`i'
            local cv_error2=`cv_error2'+ ///
                  (y[`i']-_b[_cons])^2
        }
        drop w
        // 计算均方误差
        local mse=`cv_error2'/10
        // 与目前最好的相比较，保留mse较小的那个组合
        if `mse'<`min_mse'{
            local min_mse=`mse'
            local argmin_h=`h'
            local argmin_p=`p'
        }
    }
}
di "h=`argmin_h', p=`argmin_p', min=`min_mse'"
// 使用最优参数进行回归
gen w=normalden((x-2)/`argmin_h')
local control ""
forvalues p=1/`argmin_p'{
    local control "`control' x_2`p'"
}
reg y `control' [iw=w]
di _b[_cons]
predict y_local_poly if x>1
label variable y_local_poly "交叉验证最优局部多项式逼近"
reg y x_2*
predict y_global_poly
label variable y_global_poly "全局五阶多项式逼近"
twoway (line y_true x) ///
    (line y_local_poly x) ///
    (line y_global_poly x) ///
    (scatter y x, msize(0.5))
graph export local_polynomial.pdf, replace
