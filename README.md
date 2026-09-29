# 计量经济学代码

这是上海对外经贸大学司继春老师研究生课程《高级计量经济学》的配套代码仓库。

## 仓库结构

```
EconometricsCode/
├── code_in_notes/      # 讲义中的 Stata 代码（按章节整理）
│   ├── Chap.1/         # 第 1 章（一元线性回归：拟合与预测）
│   ├── Chap.2/         # 第 2 章（拟合优度与模型选择）
│   ├── ...             # 其他章节
│   ├── Chap.29/        # 第 29 章（非平稳时间序列与单位根过程）
│   ├── datasets/       # 数据集（.dta / .csv）
│   └── Run_ALL.do      # 一键运行全部章节代码
├── notebooks/          # 与 code_in_notes 镜像的 PyStata 教学 notebook
│   ├── Chap.n/         # 与 code_in_notes/Chap.n 一一对应
│   └── PyStata.md      # PyStata 配置与使用说明
└── code_in_jupyter/    # 少量独立的 Jupyter 示例（历史遗留）
```

## 讲义中的 Stata 代码（code_in_notes/）

讲义中展示的 Stata 代码按章节整理在 `Chap.n/` 子目录（n 为讲义实际章号，如 `Chap.1`、`Chap.4`、`Chap.29`）：

- 每个章节子文件夹中为讲义中使用的 `.do` 文件及其生成的 `.pdf` 图形；
- 数据集统一放在 `code_in_notes/datasets/`；
- 章节目录下的 `.do` 文件通过 `../datasets/<name>.dta` 引用数据；
- [Run_ALL.do](code_in_notes/Run_ALL.do) 可依次运行全部章节的示例代码
  （`local root = c(pwd)` + 逐章 `cd` 后 `do`）；
- 根目录下还有少量未被讲义直接引用的 `.do` 文件，作为补充示例保留。

### 首次运行前的准备

部分示例使用了 Stata 用户命令（如 `reghdfe`、`outreg2`、`esttab`、`ddml`、`pystacked`、`poivregress`、`lasso` 等），首次运行前可用 `ssc install` 安装：

```stata
ssc install reghdfe
ssc install outreg2
ssc install estout
ssc install ddml
ssc install pystacked
ssc install poivregress
ssc install lassopack
```

使用 `pystacked` / `ddml`（基于 Python 的机器学习方法）前，需要把 Stata 的 Python 指向带 `scikit-learn` 的解释器（如 Anaconda）：

```stata
python set exec /opt/Anaconda/bin/python3
```

涉及该环境的 `.do` 文件（如 `Chap.10/ntv_ddml.do`、`Chap.12/ddml_nsw.do`）已在文件头部加入此设置。

## Stata 教学 Notebook（notebooks/）

`notebooks/` 目录提供了与 `code_in_notes/Chap.n` 一一对应的 Jupyter Notebook，通过 **PyStata** 在 Jupyter 中直接运行讲义中的 Stata 代码：

- 每个 notebook 与同名 `.do` 文件一一对应；
- 每个代码单元配有详细中文讲解（命令含义、参数说明、计量原理）；
- 图形由 PyStata 内联显示，省略了 `.do` 中的 `graph export` 命令；
- 环境配置与使用说明见 [notebooks/PyStata.md](notebooks/PyStata.md)。

## 数据说明

- 数据集统一存放于 `code_in_notes/datasets/`，主要包括：
  - `chfs2017_*.dta`：中国家庭金融调查（CHFS）2017 年家庭与个人层面数据子集；
  - `cfps_*.dta`：中国家庭追踪调查（CFPS）数据子集；
  - `quarterlyGDP.dta`、`monthly_PMI.dta`、`stock_price.dta`：宏观与金融时间序列；
  - `Lalonde_nsw/`、`OHIE_QJE.dta`、`NTV_Aggregate_Data_reshaped.dta` 等：经典计量经济学实验/准实验数据；
  - 其他论文复现所用数据。
- `2017中国家庭金融调查问卷.pdf` 是 CHFS 2017 的调查问卷，供查阅变量含义。

## code_in_jupyter

历史遗留的少量独立 Jupyter 示例，与讲义不严格对应；新内容请优先参考 `notebooks/`。
