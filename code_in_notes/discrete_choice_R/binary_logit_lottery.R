# binary_logit_lottery.R
# 复刻 binary_logit_lottery.do
# 二元 Logit 模型：彩票选择 ~ 期望收益差 + 方差差（及个体变量），聚类稳健标准误

library(sandwich)  # vcovCL: 聚类稳健方差协方差矩阵
library(lmtest)    # coeftest: 使用指定 vcov 的系数检验

# ---- 读入数据（对应 use datasets/lottery_data.dta） ----
lottery <- read.csv("discrete_choice/lottery_data.csv")

# ---- 计算 lottery 的期望与方差 ----
attach(lottery)
eiL  <- P0left * prize0  + P1left * prize1  + P2left * prize2  + P3left * prize3
eiR  <- P0right * prize0 + P1right * prize1 + P2right * prize2 + P3right * prize3
ei2L <- P0left * prize0^2  + P1left * prize1^2  + P2left * prize2^2  + P3left * prize3^2
ei2R <- P0right * prize0^2 + P1right * prize1^2 + P2right * prize2^2 + P3right * prize3^2
detach(lottery)
lottery$viL    <- ei2L - eiL^2
lottery$viR    <- ei2R - eiR^2
lottery$eiL    <- eiL
lottery$eiR    <- eiR
lottery$deltaI <- eiR - eiL
lottery$deltaV <- lottery$viR - lottery$viL

# 聚类稳健 logit 的辅助函数：glm 拟合 + vcovCL 聚类稳健系数表
logit_cl <- function(formula, data, cluster = "id") {
  fit <- glm(formula, family = binomial(link = "logit"), data = data)
  V   <- vcovCL(fit, cluster = data[[cluster]])
  coeftest(fit, vcov. = V)
}

# ---- 简单模型，只加入收益的期望与方差 ----
# logit Choices deltaI deltaV, cluster(id)
m1 <- logit_cl(Choices ~ deltaI + deltaV, lottery)
print(m1)

# ---- 分别加入左、右两边的收益与方差 ----
# logit Choices eiL eiR viL viR, cluster(id)
m2fit <- glm(Choices ~ eiL + eiR + viL + viR, family = binomial("logit"), data = lottery)
V2    <- vcovCL(m2fit, cluster = lottery$id)
print(coeftest(m2fit, vcov. = V2))

# test eiL + eiR = 0  /  test viL + viR = 0  （Wald 检验，卡方统计量）
wald_test <- function(fit, V, hyp) {          # hyp 形如 c(eiL = 1, eiR = 1)
  b  <- coef(fit)[names(hyp)]
  Vh <- V[names(hyp), names(hyp)]
  z  <- as.numeric(sum(hyp * b) / sqrt(t(hyp) %*% Vh %*% hyp))
  chi2 <- z^2
  cat(sprintf("chi2(1) = %.3f,  Prob > chi2 = %.4f\n", chi2, pchisq(chi2, 1, lower.tail = FALSE)))
}
cat("test eiL+eiR=0 : "); wald_test(m2fit, V2, c(eiL = 1, eiR = 1))
cat("test viL+viR=0 : "); wald_test(m2fit, V2, c(viL = 1, viR = 1))

# ---- 加入个体层面变量 ----
# logit Choices deltaI deltaV Female Black Hispanic Age Business GPAlow, cluster(id)
f3  <- Choices ~ deltaI + deltaV + Female + Black + Hispanic + Age + Business + GPAlow
m3fit <- glm(f3, family = binomial("logit"), data = lottery)
V3    <- vcovCL(m3fit, cluster = lottery$id)
print(coeftest(m3fit, vcov. = V3))

# margins, dydx(*) —— 平均边际效应（AME）
# 二值(0/1)变量用离散差分（与 Stata margins 默认一致），连续变量用导数 b*dLambda
ame <- function(fit, V) {
  X   <- model.matrix(fit)
  b   <- coef(fit)
  dat <- model.frame(fit)
  eta <- drop(X %*% b)
  d   <- dlogis(eta)                                  # Lambda*(1-Lambda)
  is_bin <- vapply(dat, function(v) all(unique(v) %in% c(0, 1)), logical(1))
  me <- sapply(names(b)[-1], function(v) {
    if (is_bin[[v]]) {                                # 二值变量：Pr(y|x=1)-Pr(y|x=0)
      X1 <- X; X1[, v] <- 1
      X0 <- X; X0[, v] <- 0
      mean(plogis(drop(X1 %*% b)) - plogis(drop(X0 %*% b)))
    } else {
      b[[v]] * mean(d)                                # 连续变量：b * mean(dLambda)
    }
  })
  # delta 法标准误：对 AME(b) 做数值 Jacobian，J %*% V %*% t(J)
  ame_of <- function(bb) {
    ee <- drop(X %*% bb); dd <- dlogis(ee)
    sapply(names(b)[-1], function(v) {
      if (is_bin[[v]]) {
        X1 <- X; X1[, v] <- 1
        X0 <- X; X0[, v] <- 0
        mean(plogis(drop(X1 %*% bb)) - plogis(drop(X0 %*% bb)))
      } else bb[[v]] * mean(dd)
    })
  }
  h  <- 1e-6 * pmax(1, abs(b))
  J  <- sapply(seq_along(b), function(j) {
    bp <- b; bp[j] <- bp[j] + h[j]
    bm <- b; bm[j] <- bm[j] - h[j]
    (ame_of(bp) - ame_of(bm)) / (2 * h[j])
  })
  se <- sqrt(diag(J %*% V[names(b), names(b)] %*% t(J)))
  data.frame(dydx = me, se = se, z = me / se,
             p = 2 * pnorm(-abs(me / se)))
}
cat("\n margins, dydx(*) —— 平均边际效应：\n")
print(ame(m3fit, V3))
