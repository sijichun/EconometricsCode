# mix_logit_eut_fechner.R
# 复刻 temp.do（mix_logit_eut_fechner.do）
# Mixed Logit EUT：CRRA 效用 + Fechner 误差，个体随机参数：
#   r     ~ Beta(alpha, beta)            —— 个体 CRRA 系数（取值于 (0,1)）
#   sigma = exp(N(vsigma, tau))          —— 对数正态 Fechner 噪声
#   zeta  ~ N(phi, upsilon)              —— 个体随机偏好冲击
# 选择概率为 R=1000 次模拟抽样的平均 logit 概率（模拟极大似然，SML）：
#   Lambda_i = (1/R) * sum_s logit( (euR(r_s)-euL(r_s))/sigma_s + zeta_s )
#
# 此处采用固定抽样（common random numbers）并用逆 CDF 变换使似然关于参数光滑：
#   r_s = qbeta(u_s, alpha, beta)，sigma_s = exp(vsigma + tau*z1_s)，zeta_s = phi + upsilon*z2_s
# 其中 u_s, z1_s, z2_s 在估计前一次性抽好并固定。这是同一估计量的正确实现。

R_sim <- 1000            # 对应 global R=1000
set.seed(12345)          # do 文件未设种子；此处固定以便结果可复现

lottery <- read.csv("discrete_choice/lottery_data.csv")
d  <- subset(lottery, !is.na(Choices))        # ml model ... if Choices~=.
y  <- d$Choices                               # $ML_y1
PL <- as.matrix(d[, c("P0left",  "P1left",  "P2left",  "P3left")])   # $ML_y2-$ML_y5
PR <- as.matrix(d[, c("P0right", "P1right", "P2right", "P3right")])  # $ML_y6-$ML_y9
PZ <- as.matrix(d[, c("prize0", "prize1", "prize2", "prize3")])      # $ML_y10-$ML_y13
W  <- d$stake                                 # $ML_y14

# ---- 个体索引与固定模拟抽样（对应 bysort id 的逐个体随机抽取） ----
ids    <- unique(d$id)
M      <- length(ids)
id_idx <- match(d$id, ids)                    # 每个观测所属个体的编号 1..M
u_r <- matrix(runif(M * R_sim), M, R_sim)     # r 的均匀抽样（逆 CDF 用）
z_1 <- matrix(rnorm(M * R_sim), M, R_sim)     # sigma 的标准正态抽样
z_2 <- matrix(rnorm(M * R_sim), M, R_sim)     # zeta 的标准正态抽样

# ---- 预计算 ----
base    <- W + PZ                             # n x 4，w + x_j >= 0
logbase <- ifelse(base > 0, log(base), 0)
n       <- nrow(d)

# ---- 核心：给定参数，单趟循环计算对数似然、梯度、逐观测得分 ----
# 优化变量为 (a, b, vsigma, tau, phi, upsilon)，其中 alpha=exp(a), beta=exp(b)
# （对数参数化仅为保证 alpha,beta>0，模型与 Stata 完全一致；结果会变换回原参数）
# par 顺序对应 ml model 的方程顺序：(r)=alpha, /beta, /sigma=vsigma, /tau, /phi, /upsilon
eval_all <- function(par) {
  a <- par[1]; b <- par[2]; m <- par[3]; t <- par[4]; f <- par[5]; uu <- par[6]
  alpha <- exp(a); beta <- exp(b)
  # 个体 x 模拟次数 的随机参数（逆 CDF 变换）
  r_dr  <- qbeta(u_r, alpha, beta)            # M x R 的 r 抽样
  sig   <- exp(m + t * z_1)                   # M x R 的 sigma 抽样
  zet   <- f + uu * z_2                       # M x R 的 zeta 抽样
  # dr/dalpha、dr/dbeta（qbeta 的中心差分，M x R）
  hq <- 1e-6
  dra <- (qbeta(u_r, alpha + hq, beta) - qbeta(u_r, alpha - hq, beta)) / (2 * hq)
  drb <- (qbeta(u_r, alpha, beta + hq) - qbeta(u_r, alpha, beta - hq)) / (2 * hq)

  Lam <- numeric(n)                           # 选择概率累加器
  g_a <- g_b <- g_m <- g_t <- g_f <- g_u <- numeric(n)   # sum_s dLambda_s/dpar 累加器
  for (s in seq_len(R_sim)) {
    r_s <- r_dr[id_idx, s]                    # 逐观测的本次抽样参数
    sg  <- sig[id_idx, s]
    zt  <- zet[id_idx, s]
    U   <- base^r_s                           # n x 4 CRRA 效用
    dU  <- U * logbase                        # du/dr = u*log(w+x)；base=0 处 U=0、贡献为 0
    euL <- rowSums(PL * U);  euR <- rowSums(PR * U)
    deu <- rowSums(PR * dU) - rowSums(PL * dU)
    Ls  <- plogis((euR - euL) / sg + zt)      # 本次抽样的 logit 选择概率
    Lam <- Lam + Ls
    w   <- Ls * (1 - Ls)                      # dLambda_s/dx_s
    tmp <- w * deu / sg                       # 公用因子：dLambda_s/dr
    g_a <- g_a + tmp * dra[id_idx, s] * alpha # 链式法则：x exp(a)
    g_b <- g_b + tmp * drb[id_idx, s] * beta
    g_m <- g_m + w * (-(euR - euL) / sg)      # d(1/sigma)/dvsigma = -1/sigma
    g_t <- g_t + w * (-(euR - euL) / sg) * z_1[id_idx, s]
    g_f <- g_f + w
    g_u <- g_u + w * z_2[id_idx, s]
  }
  Lam <- pmin(pmax(Lam / R_sim, 1e-12), 1 - 1e-12)   # 数值保护，避免 log(0)
  ll_obs <- y * log(Lam) + (1 - y) * log(1 - Lam)    # 逐观测对数似然
  mult   <- (y - Lam) / (Lam * (1 - Lam)) / R_sim    # dlnf_i/dLam_i / R
  score_obs <- cbind(mult * g_a, mult * g_b, mult * g_m,
                     mult * g_t, mult * g_f, mult * g_u)
  list(value = -sum(ll_obs), grad = -colSums(score_obs),
       ll_obs = ll_obs, score_obs = score_obs)
}

# ---- 缓存：optim 在同一点先调 fn 再调 gr，单趟计算两者复用 ----
cache <- new.env(); cache$par <- NULL
cached_eval <- function(par) {
  if (is.null(cache$par) || any(cache$par != par)) {
    cache$par <- par
    cache$res <- eval_all(par)
  }
  cache$res
}
negll <- function(par) cached_eval(par)$value
neggr <- function(par) cached_eval(par)$grad

# ---- 初始值（对应 ml init /r=1 /beta=1 /sigma=0 /tau=1 /phi=0 /upsilon=1） ----
start <- c(a = 0, b = 0, vsigma = 0, tau = 1, phi = 0, upsilon = 1)  # alpha=beta=exp(0)=1

# ---- BFGS 最大化（technique(bfgs)） ----
opt <- optim(par = start, fn = negll, gr = neggr, method = "BFGS",
             control = list(reltol = 1e-10, maxit = 500))
cat("optim convergence code:", opt$convergence, "\n")  # 0 表示收敛
b_hat <- opt$par

# ---- 聚类稳健三明治方差（cluster(id)） ----
res_hat <- cached_eval(b_hat)
bread <- solve(optimHess(b_hat, negll, neggr))
Gu   <- rowsum(res_hat$score_obs, group = d$id)
meat <- crossprod(Gu)
M_cl <- length(unique(d$id)); N <- nrow(d); k <- length(b_hat)
V <- bread %*% meat %*% bread * (M_cl / (M_cl - 1)) * ((N - 1) / (N - k))
se <- sqrt(diag(V))

# ---- 变换回原始参数（alpha=exp(a), beta=exp(b)，delta 法 SE 同乘对应系数） ----
est <- b_hat; est[1:2] <- exp(b_hat[1:2])
se_orig <- se;  se_orig[1:2] <- se[1:2] * exp(b_hat[1:2])
names(est) <- c("r(alpha)", "beta", "sigma(vsigma)", "tau", "phi", "upsilon")
res <- data.frame(Coef = est, `Robust SE` = se_orig, z = est / se_orig,
                  `P>|z|` = 2 * pnorm(-abs(est / se_orig)), check.names = FALSE)
cat("Log likelihood =", -opt$value, "\n")
print(res)
