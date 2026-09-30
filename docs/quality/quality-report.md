# MoonCite 质量报告

日期：2026-09-30。以下数字来自本地仓库和命令输出，不是计划值。

## 实现规模

- MoonBit 实现代码：超过 2,000 行（按 `*.mbt` 源文件统计，排除 `_test.mbt`、`_wbtest.mbt` 和 `_build`）。
- 测试：9 个稳定测试用例，覆盖 XML 解析、样式解析、文本/HTML 渲染、CSL-JSON、页码范围、数字引用范围和中文日期术语。
- 示例：4 个可执行目标：`cmd/main`、`examples/beginners`、`examples/numeric`、`examples/text-extract`。

## 功能覆盖

| 维度 | 当前结果 |
|---|---|
| 输入 | CSL XML 样式、CSL-JSON 文献对象、内置/自定义本地化 |
| 输出 | 纯文本、HTML、单条引用、文献表 |
| 样式节点 | text、names/name、number、date/date-part、group、choose、sort、layout、macro |
| 辅助算法 | 页码范围、数字引用范围、作者/日期排序键、编号和基本数据校验 |
| 运行方式 | 本地纯计算，不依赖网络服务 |

## 已运行的验证

- `moonc -v`：`v0.10.14+7d59c7ec9`。
- `moon fmt --check`：通过。
- `moon check --target wasm-gc --deny-warn`：通过。
- `moon check --target wasm --deny-warn`：通过。
- `moon check --target js --deny-warn`：通过。
- `moon check --target native --deny-warn`：通过。
- `moon test --target wasm-gc`、`wasm`、`js`：均通过，9/9。
- 四个示例均已使用 `moon run` 启动并得到输出。
- `moon info` 与 `moon fmt` 在提交前执行；接口变化以生成的 `.mbti` 为准。

完整 CSL 1.0.2 兼容性尚未宣称。当前版本的质量证据说明首版移植已经可用、可测试、可复现；复杂脚注、完整 disambiguation、BibTeX/MARC 导入和在线元数据服务属于后续范围。
