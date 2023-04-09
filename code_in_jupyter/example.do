clear
set more off
webuse cattaneo2
lasso linear bweight c.mage##c.mage c.fage##c.fage c.mage#c.fage c.fedu##c.medu i.(mmarried mhisp fhisp foreign alcohol msmoke fbaby prenatal1)
coefpath
