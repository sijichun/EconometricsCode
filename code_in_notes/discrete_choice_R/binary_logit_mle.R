# binary_logit_mle.R
# 复刻 binary_logit_mle.do
# 手写二元 Logit 的极大似然估计（lf0：提供逐观测对数似然与解析导数），
# 使用 BFGS 最大化，聚类稳健（cluster(id)）三明治标准误

# ---- 数据准备（对应 do binary_logit_lottery.do 中的变量构造部分） ----
lottery <- read.csv("discrete_choice/lottery_data.csv")
with(lottery, {
  eiL  <<- P0left * prize0  + P1left * prize1  + P2left * prize2  + P3left * prize3
  eiR  <<- P0right * prize0 + P1right * prize1 + P2right * prize2 + P3right * prize3
  ei2L <<- P0left * prize0^2  + P1left * prize1^2  + P2left * prize2^2  + P3left * prize3^2
  ei2R <<- P0right * prize0^2 + P1right * prize1^2 + P2right * prize2^2 + P3right * prize3^2
})
lottery$deltaI <- eiR - eiL
lottery$deltaV <- (ei2R - eiR^2) - (ei2L - eiL^2)

d   <- subset(lottery, !is.na(Choices))   # ml model ... if Choices~=.
y   <- d$Choices                          # $ML_y1
X   <- cbind(`(Intercept)` = 1, as.matrix(d[, c("deltaI", "deltaV")]))
id  <- d$id

# ---- 对数似然函数（对应 program binarylogitobj） ----
# 返回逐观测贡献 lnfj 的向量；梯度对应 g1 = y*(1-Lambda) - (1-y)*Lambda
lnfj <- function(b) {
  theta  <- drop(X %*% b)                 # mleval `theta' = `b', eq(1)
  Lambda <- plogis(theta)                 # 1/(1+exp(-theta))
  y * log(Lambda) + (1 - y) * log(1 - Lambda)
}
negll <- function(b) -sum(lnfj(b))        # optim 默认最小化，取负

# 解析梯度（对应 g1：dlnf/db = (y - Lambda) * x）
neggr <- function(b) -colSums((y - plogis(drop(X %*% b))) * X)

# ---- 最大化（对应 ml model lf0 ... tech(bfgs) + ml search + ml maximize） ----
# Stata lf0 默认初始值为 0；ml search 仅用于寻找更优初始点（可选），此处从 0 出发
opt <- optim(par = rep(0, ncol(X)), fn = negll, gr = neggr,
             method = "BFGS", hessian = TRUE,
             control = list(reltol = 1e-10, maxit = 1000))

b_hat <- opt$par
names(b_hat) <- colnames(X)
H     <- opt$hessian            # 负对数似然的 Hessian（最小化问题），即观测信息矩阵
bread <- solve(H)

# ---- 聚类稳健三明治方差：V = bread %*% meat %*% bread ----
# 逐观测得分 G_i = (y_i - Lambda_i) * x_i，按 id 加总后求外积和
G    <- (y - plogis(drop(X %*% b_hat))) * X
Gu   <- rowsum(G, group = id)             # 每个 cluster 的得分和
meat <- crossprod(Gu)
# Stata 聚类稳健的有限样本修正因子：M/(M-1) * (N-1)/(N-k)
M <- length(unique(id)); N <- nrow(X); k <- ncol(X)
V <- bread %*% meat %*% bread * (M / (M - 1)) * ((N - 1) / (N - k))

se <- sqrt(diag(V))
res <- data.frame(Coef = b_hat, `Robust SE` = se, z = b_hat / se,
                  `P>|z|` = 2 * pnorm(-abs(b_hat / se)), check.names = FALSE)
cat("Log likelihood =", -opt$value, "\n")
print(res)
