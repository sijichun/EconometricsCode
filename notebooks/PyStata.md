# 在 Jupyter 中使用 Stata（PyStata / stata_setup 使用说明）

本目录（`EconometricsCode/notebooks/`）下的教学 notebook 通过 **PyStata** 在 Jupyter 中直接调用 Stata，
以便把 Stata 代码、输出与图形和讲解文字放在同一个 notebook 中，方便课堂演示。

本文说明 `stata_setup` 的安装、配置与常用方法。

---

## 1. 环境要求

- **Stata 17 或更高版本**（本机为 Stata 18.0 MP，安装路径为 `/opt/Stata`）；
- **Python 3.7+**（本机使用 Anaconda，Python 3.11；Jupyter 内核选择 `anaconda`）；
- Python 包 **`stata_setup`**（见下一节安装）。

## 2. 安装 stata_setup

```bash
pip install --upgrade stata_setup
```

## 3. 配置与启动

在 notebook 的第一个代码单元中运行：

```python
import stata_setup
stata_setup.config("/opt/Stata", "mp")   # 参数：安装路径、版本（mp/se/be）
```

成功后会输出 Stata 的启动信息（banner），并自动注册 `%stata` / `%%stata` 魔法命令。
注意：**每个 notebook 都需要先运行配置单元**，然后再运行含有 Stata 代码的单元。

## 4. 在 notebook 中使用 Stata

### 4.1 单元魔法 `%%stata`（最常用）

整个单元作为一段 Stata 命令执行（相当于执行一个 do 文件片段）：

```stata
%%stata
use ../datasets/chfs2017_hh.dta, clear
reg total_consump total_income
```

### 4.2 行魔法 `%stata`

只执行一行 Stata 命令：

```python
%stata summarize total_income
```

## 5. 注意事项

- **程序定义不可拆分**：`program define ... end`、`mata: ... end`、`foreach`/`forvalues` 的
  花括号块必须放在同一个 `%%stata` 单元中，否则无法运行。
- **行内注释**：PyStata 对交互模式下的行内 `//` 注释敏感，会报 `'/' not allowed in varlist`。
  请把行内注释移到上一行（整行注释 `//`、`///` 续行、`/* */` 都正常）。
- **图形**：默认省略 `graph export`，图形由 PyStata 内联显示；
  若需导出，可手动补加（对应 .do 文件保留了导出命令）。
- **工作目录**：notebook 的开头通常会 `os.chdir("../../code_in_notes/Chap.n")`，
  保证 Stata 中的相对路径（如 `../datasets/...`）与 .do 文件一致。
