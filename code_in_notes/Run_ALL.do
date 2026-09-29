clear
set more off
** 在 EconometricsCode/code_in_notes 目录下运行本文件
** 各章节代码已按 Chap.n 分类到子文件夹
local root = c(pwd)

** Chap.1 OLS_fitting
cd "`root'/Chap.1"
do reg_one_variate.do
do predict_log.do
do partioned_regression.do
do reg_with_dummies.do
do reg_with_dummy.do

** Chap.2 OLS_model_selec
cd "`root'/Chap.2"
do cross_validation_reg.do
do model_selection.do

** Chap.3 Fitting_other_method
cd "`root'/Chap.3"
do local_poly_cv.do
do local_constant.do

** Chap.4 GLM
cd "`root'/Chap.4"
do qreg_simulate.do
do logit_and_roc.do
do nls_mpc.do
do qreg_outlier.do
do log_of_gravity.do
do qreg_consump.do

** Chap.5 MachineLearning
cd "`root'/Chap.5"
do lasso_and_ridge_shrinkage.do

** Chap.7 OLS_estimation
cd "`root'/Chap.7"
do heteroscedasticity.do

** Chap.8 OLS_control
cd "`root'/Chap.8"
do quadratic.do
do aging_transformation.do
do demean.do
do jia2024.do
do ols_fe_ntv.do
do simpson_paradox.do

** Chap.9 OLS_testing
cd "`root'/Chap.9"
do chow_test.do
do multi_collinearity.do
do ohie_qje_test_one.do
do oneway_anova.do
do test_jointly_ntv.do
do wald_ols.do
do white_hetero.do

** Chap.10 DML_selection
cd "`root'/Chap.10"
do ntv_ddml.do
do ntv_double_selec.do

** Chap.11 Rubin_experiment
cd "`root'/Chap.11"
do fisher_exact_p.do

** Chap.12 Matching
cd "`root'/Chap.12"
do ddml_nsw.do

** Chap.13 System
cd "`root'/Chap.13"
do fixed_effects_ntv.do
do ohie_qje_joint_test.do

** Chap.14 Linear_panel
cd "`root'/Chap.14"
do linear_panel_fd.do
do linear_panel_fe.do

** Chap.15 DID
cd "`root'/Chap.15"
do hcw_lasso.do

** Chap.17 IV
cd "`root'/Chap.17"
do CivilConflict.do
do lasso_iv.do

** Chap.25 TimeSeries
cd "`root'/Chap.25"
do quarterly_gdp.do
do daily_stock_price.do
do gdp_growth.do
do stock_return.do
do stochastic_path.do
do auto_corr_gdp.do
do auto_corr_stock.do

** Chap.26 ARMA
cd "`root'/Chap.26"
do simulate_ma.do
do simulate_ar.do
do simulate_arma.do
do simulate_causal.do
do invertibility_ma.do
do predicting_arma.do

** Chap.27 ARMA_Est
cd "`root'/Chap.27"
do arma_model_selection.do
do ts_mean.do
do ts_ols_and_nl_of_pre_autocorr.do
do ts_regress.do
do ts_regress_lag_y.do

** Chap.28 ARCH
cd "`root'/Chap.28"
do simulate_arch.do
do stock_return_facts.do
do arch_est.do

** Chap.29 Unit_Root
cd "`root'/Chap.29"
do ts_detrend.do
do simulate_unit_root.do
do simulate_rw_coef.do
do ts_detrend_diff.do

** 未分配到章节的脚本（留在根目录）
cd "`root'"
do DID_dynamic_trend.do
do DID_disease.do
do DID_divorce.do
do DID_divorce_event_study.do
do HCW.do
do RD_r_and_d.do
do binary_logit_eut.do
do binary_logit_eut_fechner.do
do binary_logit_eut_fechner_hetero.do
do binary_logit_lottery.do
do binary_logit_mle.do
do conditional_logit_simu.do
do covatiates_balancing.do
do did_newspaper.do
do experiment_reg_hetero.do
do ipw_doubly_robust.do
do linear_panel.do
do linear_panel_fd_np.do
do linear_panel_fe_ntv.do
do ljung-box_test.do
do local_linear.do
do local_polynomial.do
do matching.do
do matching_nonexp.do
do matching_psm.do
do mix_logit_eut_fechner.do
do mlogit_employ.do
do ohie_qje.do
do ohie_science.do
do panel_binary.do
do panel_dynamic.do
do poisson.do
do propensity_score.do
do qreg_with_dummy.do
do random_forest_stata.do
do rd_fuzzy_pmgsy.do
do reg_small_b.do
do simulate_fe.do
do simulate_sprious.do

cd "`root'"