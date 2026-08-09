# binary_logit_eut_fechner.R
# 复刻 binary_logit_eut_fechner.do
# Original Recipe EUT：CRRA 效用 + Fechner 误差项，Probit 连接函数
# 参数：r（CRRA 系数）与 sigma（Fechner 噪声标准差，线性方程，Stata 中不加指数约束）
# BFGS + cluster(id) 稳健标准误

link <- "Probit"   # 对应 global link "Probit"（改为 "Logit" 即切换连接函数）

lottery <- read.csv("discrete_choice/lottery_data.csv")
d  <- subset(lottery, !is.na(Choices))        # ml model ... if Choices~=.
y  <- d$Choices                               # $ML_y1
PL <- as.matrix(d[, c("P0left",  "P1left",  "P2left",  "P3left")])
PR <- as.matrix(d[, c("P0right", "P1right", "P2right", "P3right")])
PZ <- as.matrix(d[, c("prize0", "prize1", "prize2", "prize3")])
W  <- d$stake

# ---- 逐观测对数似然与解析导数（对应 program ML_eut_fechner） ----
# theta = (euR - euL)/sigma；dtheta/dr = d(euR-euL)/sigma；dtheta/dsigma = -theta/sigma
components <- function(par) {
  r <- par[1]; sigma <- par[2]
  U   <- (W + PZ)^r
  dU  <- ifelse(W + PZ > 0, U * log(W + PZ), 0)
  euL <- rowSums(PL * U);  euR <- rowSums(PR * U)
  deu <- rowSums(PR * dU) - rowSums(PL * dU)
  th  <- (euR - euL) / sigma
  list(theta = th, dth_r = deu / sigma, dth_s = -th / sigma)
}
lnfj <- function(par) {
  th <- components(par)$theta
  Lambda <- if (link == "Logit") plogis(th) else pnorm(th)
  Lambda <- pmin(pmax(Lambda, 1e-12), 1 - 1e-12)   # 数值保护，避免 log(0)
  ll <- y * log(Lambda) + (1 - y) * log(1 - Lambda)
  ll[!is.finite(ll)] <- -1e10                 # 非可行点（如 sigma=0）视为极差
  ll
}
# 逐观测得分数组（n x 2）：dlnf_i/dr 与 dlnf_i/dsigma
score_i <- function(par) {
  co <- components(par)
  Lambda <- pmin(pmax(if (link == "Logit") plogis(co$theta) else pnorm(co$theta), 1e-12), 1 - 1e-12)
  q <- if (link == "Logit") (y - Lambda) else (y - Lambda) / (Lambda * (1 - Lambda)) * dnorm(co$theta)
  cbind(q * co$dth_r, q * co$dth_s)
}
negll <- function(par) -sum(lnfj(par))
neggr <- function(par) -colSums(score_i(par))

# ---- 初始点搜索（对应 Stata ml 的自动 feasible/search 步骤） ----
# 全零初始点在 sigma=0 处不可行，故在 r 与 sigma 的小网格上寻找可行的较优起点
grid <- expand.grid(r = c(0.2, 0.5, 1), sigma = c(0.1, 0.5, 1, 5, 10))
ll_grid <- apply(grid, 1, function(p) sum(lnfj(p)))
start <- as.numeric(grid[which.max(ll_grid), ])

# ---- BFGS 最大化（technique(bfgs)） ----
opt <- optim(par = start, fn = negll, gr = neggr, method = "BFGS",
             control = list(reltol = 1e-12, maxit = 1000))
cat("optim convergence code:", opt$convergence, "\n")  # 0 表示收敛
b_hat <- opt$par; names(b_hat) <- c("r", "sigma")

# ---- 聚类稳健三明治方差 ----
bread <- solve(optimHess(b_hat, negll, neggr))
G    <- score_i(b_hat)
Gu   <- rowsum(G, group = d$id)
meat <- crossprod(Gu)
M <- length(unique(d$id)); N <- nrow(d); k <- length(b_hat)
V <- bread %*% meat %*% bread * (M / (M - 1)) * ((N - 1) / (N - k))

se <- sqrt(diag(V))
res <- data.frame(Coef = b_hat, `Robust SE` = se, z = b_hat / se,
                  `P>|z|` = 2 * pnorm(-abs(b_hat / se)), check.names = FALSE)
cat("Log likelihood =", -opt$value, "\n")
print(res)
