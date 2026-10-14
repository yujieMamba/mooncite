# MoonCite 0.1.1 质量报告

日期：2026-10-14。以下是实际命令与选定测试的结果，不是性能预测或完整标准认证。

## 规模与验证集合

- 根包生产源码：15 个 `.mbt` 文件，4,168 行；排除空行及以 `//` 开头的注释行后为 **3,641 行**。不包含测试、示例、构建目录及外部 JavaScript 引擎；按文本行计数，不等同于复杂度或覆盖率。
- MoonBit 测试：**68/68**，其中 17 个由共享 reference fixture 生成。其余回归/基础测试覆盖姓名配置继承、替代字段、折叠边界、稳定排序、编号、定位页码、输入副本、HTML、JSON、宏错误及 XML 错误等。
- 独立参考引擎：citeproc-js / npm citeproc **2.4.63**，**17/17** 精确输出对照。参考引擎与本库分别对共享 fixture 的 expected 做相等检查。
- 四个完整可执行示例：`cmd/main`、`examples/beginners`、`examples/numeric`、`examples/text-extract`。

## 本地环境及结果

本地 Windows，MoonBit CLI `0.1.20260920 (914d7da)`，编译器 `v0.10.14+7d59c7ec9-dev (2026-09-18)`。

| 命令 | wasm-gc | wasm | js | native |
|---|---|---|---|---|
| `moon check --target TARGET --deny-warn` | 通过 | 通过 | 通过 | 通过 |
| `moon build --target TARGET --deny-warn` | 通过 | 通过 | 通过 | 本地未运行成功：缺少 C 编译器 |
| `moon test --target TARGET --deny-warn` | 68/68 | 68/68 | 68/68 | 同上，交由 Ubuntu CI 验证 |
| 四个 `moon run ... --target TARGET` | 全部成功 | 全部成功 | 全部成功 | 交由 Ubuntu CI 验证 |

`moon info`、`moon fmt`、`moon fmt --check` 和 `git diff --check` 均已执行。`npm ci --prefix tools/reference --ignore-scripts` 安装锁定开发依赖成功，`npm test --prefix tools/reference` 为 17/17。

CI 配置使用 Ubuntu 四目标矩阵，各自执行检查、显式构建、测试及四个示例，并验证姓名/数字关键输出；另有参考引擎任务。**配置存在不等于运行通过**，远端最终结果以对应 GitHub Actions run 为准，完成后记录在下方。

## 选定行为与参考软件

| 行为 | MoonCite / citeproc-js 2.4.63 相同输出示例 |
|---|---|
| 两位作者连词 | `[Doe and Smith]` |
| 空格缩写 | `[J. M. Doe]` |
| 显式空缩写分隔符 | `[JM Doe]` |
| et-al 保留最后一位作者 | `[Doe … Li]` |
| 三个连续编号及分段 | `[1–3, 5, 7–9]` |
| 两个连续编号不折叠 | `[1, 2, 4, 5]` |
| 宏及 HTML 范围端点 | `<sup><b>1</b>–<b>3</b></sup>` |

所有 17 组输入、样式与预期均在 `tools/reference/fixtures.json`，生成测试在根目录 `reference_test.mbt`，SHA-256 校验防止 fixture 变更后忘记重新生成。没有宣称 100% 标准符合率、测试覆盖率或更快性能。

## 边界与发布状态

未实现完整 CSL 消歧、引用历史、全部姓名/locale/日期规则及脚注布局。不支持的 position 条件与非数字 collapse 报错；其他未支持的扩展可能被忽略。`after-collapse-delimiter` 未纳入独立引擎对照，不能据此宣称参考引擎完全一致。

本次 GitHub 源码版本 0.1.1 暂未同步 MoonCakes。不得把本地通过、CI 配置或版本号变更视为已完成包发布或组织方验收。
