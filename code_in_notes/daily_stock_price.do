// daily_stock_price.do

use datasets/stock_price, clear
tsset stkcd date
tsline clsprc if stkcd == 600519
graph export daily_stock_price.pdf, replace
