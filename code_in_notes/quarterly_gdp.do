// quarterly_gdp.do

clear
set more off
// 导入数据
import delimited "datasets/quarterlyGDP.csv", encoding(utf8)

// 转换日期时间为Stata内部时间格式
gen day=date(quarter,"YM")
drop quarter
// 生成年份和季度
gen year=year(day)
gen quarter=quarter(day)
// 将年份和季度合并为年份-季度类型
gen time=yq(year,quarter)
// 更改time的显示方式为年度-季度
format time %tq
save datasets/quarterlyGDP.dta, replace
// 设置数据为时间序列数据
tsset time
// 画时间序列图
tsline gdp
graph export quarter_gdp.pdf, replace
