# binary_logit_eut.R
# 复刻 binary_logit_eut.do
# Original Recipe EUT：CRRA 效用 + 无误差项，Probit 连接函数
# 参数仅一个自由参数 r（CRRA 系数），BFGS + cluster(id) 稳健标准误

link <- "Probit"   # 对应 global link "Probit"（改为 "Logit" 即切换连接函数）

lottery <- read.csv("discrete_choice/lottery_data.csv")
d  <- subset(lottery, !is.na(Choices))        # ml model ... if Choices~=.
y  <- d$Choices                               # $ML_y1
PL <- as.matrix(d[, c("P0left",  "P1left",  "P2left",  "P3left")])   # $ML_y2-$ML_y5
PR <- as.matrix(d[, c("P0right", "P1right", "P2right", "P3right")])  # $ML_y6-$ML_y9
PZ <- as.matrix(d[, c("prize0", "prize1", "prize2", "prize3")])      # $ML_y10-$ML_y13
W  <- d$stake                                 # $ML_y14

# ---- 逐观测对数似然与解析导数（对应 program ML_eut） ----
# u_j = (w + x_j)^r；euL = sum_j PjL * u_j；euR = sum_j PjR * u_j；theta = euR - euL
components <- function(r) {
  U   <- (W + PZ)^r                                # n x 4 CRRA 效用
  dU  <- ifelse(W + PZ > 0, U * log(W + PZ), 0)    # du_j/dr = u_j*log(w+x_j)；0^r 处导数为 0
  euL <- rowSums(PL * U);  euR <- rowSums(PR * U)
  deu <- rowSums(PR * dU) - rowSums(PL * dU)       # d(euR-euL)/dr
  list(theta = euR - euL, dtheta = deu)
}
lnfj <- function(par) {
  th <- components(par[1])$theta
  Lambda <- if (link == "Logit") plogis(th) else pnorm(th)
  Lambda <- pmin(pmax(Lambda, 1e-12), 1 - 1e-12)   # 数值保护，避免 log(0)
  ll <- y * log(Lambda) + (1 - y) * log(1 - Lambda)
  ll[!is.finite(ll)] <- -1e10                 # 非可行点视为极差，对应 Stata ml 的 feasible 步骤
  ll
}
# 逐观测得分 dlnf_i/dr；probit: (y-L)/(L(1-L)) * phi(th) * dth；logit: (y-L) * dth
score_i <- function(par) {
  co <- components(par[1])
  Lambda <- pmin(pmax(if (link == "Logit") plogis(co$theta) else pnorm(co$theta), 1e-12), 1 - 1e-12)
  q <- if (link == "Logit") (y - Lambda) else (y - Lambda) / (Lambda * (1 - Lambda)) * dnorm(co$theta)
  q * co$dtheta
}
negll <- function(par) -sum(lnfj(par))
neggr <- function(par) -sum(score_i(par))

# ---- 初始点搜索（对应 Stata ml 在初始值不可行时的自动 feasible/search 步骤） ----
# r=0 附近因 0^r 的不连续性导致数值导数不可行，故在小网格上寻找可行的较优起点
grid    <- c(0.1, 0.2, 0.5, 0.8, 1)
ll_grid <- sapply(grid, function(r) sum(lnfj(r)))
start   <- grid[which.max(ll_grid)]

# ---- BFGS 最大化（对应 ml model ... technique(bfgs) + ml maximize） ----
opt <- optim(par = c(r = start), fn = negll, gr = neggr, method = "BFGS",
             control = list(reltol = 1e-12, maxit = 1000))
cat("optim convergence code:", opt$convergence, "\n")  # 0 表示收敛
b_hat <- opt$par

# ---- 聚类稳健三明治方差：V = bread %*% meat %*% bread ----
bread <- solve(optimHess(b_hat, negll, neggr))   # 对解析梯度差分得到的 Hessian 更精确
G    <- matrix(score_i(b_hat), ncol = 1)         # 逐观测得分
Gu   <- rowsum(G, group = d$id)                  # 每个 cluster 的得分和
meat <- crossprod(Gu)
# Stata 聚类稳健的有限样本修正因子：M/(M-1) * (N-1)/(N-k)
M <- length(unique(d$id)); N <- nrow(d); k <- length(b_hat)
V <- bread %*% meat %*% bread * (M / (M - 1)) * ((N - 1) / (N - k))

se <- sqrt(diag(V))
res <- data.frame(Coef = b_hat, `Robust SE` = se, z = b_hat / se,
                  `P>|z|` = 2 * pnorm(-abs(b_hat / se)), check.names = FALSE)
cat("Log likelihood =", -opt$value, "\n")
print(res)
