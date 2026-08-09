# binary_logit_eut_fechner_hetero.R
# 复刻 binary_logit_eut_fechner_hetero.do
# Original Recipe EUT：CRRA 效用 + Fechner 误差，且 r 与 sigma 均为个体（去均值）协变量的线性函数
#   r     = a0 + a1*dm_Female + ... + a6*dm_GPAlow
#   sigma = b0 + b1*dm_Female + ... + b6*dm_GPAlow   （线性方程，与 Stata ml 一致）
# BFGS + cluster(id) 稳健标准误

link <- "Probit"   # 对应 global link "Probit"

lottery <- read.csv("discrete_choice/lottery_data.csv")

# ---- 协变量去均值（对应 foreach v: su `v'; gen dm_`v' = `v' - r(mean)，全样本均值） ----
xvars <- c("Female", "Black", "Hispanic", "Age", "Business", "GPAlow")
for (v in xvars) lottery[[paste0("dm_", v)]] <- lottery[[v]] - mean(lottery[[v]], na.rm = TRUE)
dm_x <- paste0("dm_", xvars)

d  <- subset(lottery, !is.na(Choices))        # ml model ... if Choices~=.
y  <- d$Choices
PL <- as.matrix(d[, c("P0left",  "P1left",  "P2left",  "P3left")])
PR <- as.matrix(d[, c("P0right", "P1right", "P2right", "P3right")])
PZ <- as.matrix(d[, c("prize0", "prize1", "prize2", "prize3")])
W  <- d$stake
Xd <- as.matrix(cbind(`(Intercept)` = 1, d[, dm_x]))   # 含常数项的去均值协变量矩阵
k  <- ncol(Xd)                                         # 每个方程的参数个数

# ---- 逐观测对数似然与解析导数（对应 program ML_eut_hetero） ----
# r_i = Xd_i %*% beta_r；sigma_i = Xd_i %*% beta_s；theta_i = (euR_i - euL_i)/sigma_i
components <- function(par) {
  beta_r <- par[1:k]; beta_s <- par[(k + 1):(2 * k)]
  r     <- drop(Xd %*% beta_r)                # 逐观测的 r
  sigma <- drop(Xd %*% beta_s)                # 逐观测的 sigma
  U   <- (W + PZ)^r
  dU  <- ifelse(W + PZ > 0, U * log(W + PZ), 0)      # du/dr = u*log(w+x)；0^r 处导数为 0
  euL <- rowSums(PL * U);  euR <- rowSums(PR * U)
  deu <- rowSums(PR * dU) - rowSums(PL * dU)  # d(euR-euL)/dr，逐观测
  th  <- (euR - euL) / sigma
  list(theta = th, dth_r = deu / sigma, dth_s = -th / sigma)
}
lnfj <- function(par) {
  th <- components(par)$theta
  Lambda <- if (link == "Logit") plogis(th) else pnorm(th)
  Lambda <- pmin(pmax(Lambda, 1e-12), 1 - 1e-12)   # 数值保护，避免 log(0)
  ll <- y * log(Lambda) + (1 - y) * log(1 - Lambda)
  ll[!is.finite(ll)] <- -1e10                 # 非可行点视为极差
  ll
}
# 逐观测得分矩阵（n x 2k）：前 k 列为 dlnf_i/d(beta_r) = q*dth_r*Xd_i，后 k 列为 dlnf_i/d(beta_s)
score_i <- function(par) {
  co <- components(par)
  Lambda <- pmin(pmax(if (link == "Logit") plogis(co$theta) else pnorm(co$theta), 1e-12), 1 - 1e-12)
  q <- if (link == "Logit") (y - Lambda) else (y - Lambda) / (Lambda * (1 - Lambda)) * dnorm(co$theta)
  cbind(q * co$dth_r * Xd, q * co$dth_s * Xd)
}
negll <- function(par) -sum(lnfj(par))
neggr <- function(par) -colSums(score_i(par))

# ---- 初始点（对应 Stata ml 的 feasible/search 步骤） ----
# 仅搜索两个方程的截距，其余系数从 0 出发
grid <- expand.grid(r0 = c(0.2, 0.5, 1), s0 = c(0.5, 1, 5, 10))
ll_grid <- apply(grid, 1, function(p) sum(lnfj(c(p[1], rep(0, k - 1), p[2], rep(0, k - 1)))))
s0 <- as.numeric(grid[which.max(ll_grid), ])
start <- c(s0[1], rep(0, k - 1), s0[2], rep(0, k - 1))

# ---- BFGS 最大化（technique(bfgs)） ----
opt <- optim(par = start, fn = negll, gr = neggr, method = "BFGS",
             control = list(reltol = 1e-12, maxit = 2000))
cat("optim convergence code:", opt$convergence, "\n")  # 0 表示收敛
b_hat <- opt$par
names(b_hat) <- c(paste0("r:", c("(Intercept)", dm_x)),
                  paste0("sigma:", c("(Intercept)", dm_x)))

# ---- 聚类稳健三明治方差 ----
bread <- solve(optimHess(b_hat, negll, neggr))
G    <- score_i(b_hat)
Gu   <- rowsum(G, group = d$id)
meat <- crossprod(Gu)
M <- length(unique(d$id)); N <- nrow(d)
V <- bread %*% meat %*% bread * (M / (M - 1)) * ((N - 1) / (2 * k))

se <- sqrt(diag(V))
res <- data.frame(Coef = b_hat, `Robust SE` = se, z = b_hat / se,
                  `P>|z|` = 2 * pnorm(-abs(b_hat / se)), check.names = FALSE)
cat("Log likelihood =", -opt$value, "\n")
print(res)
