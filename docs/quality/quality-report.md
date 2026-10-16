# MoonCite 0.1.2 质量报告

验证日期：2026-10-16。这里区分本地运行、远端 CI、参考引擎对照和未实现能力，不使用覆盖率或性能猜测。

## 规模与测试口径

- 根目录 19 个生产 `.mbt` 文件，4,688 原始行；去掉空行及行首为 `//` 的注释后为 **4,120 行**。排除测试、示例、构建产物与外部引擎。文本行数不等于复杂度或质量。
- MoonBit **100 项测试**，包括原有核心回归、26 个共享 fixture 测试和本轮兼容/上下文测试。一个测试块可能检查多个模式，但只按一个测试计数。
- citeproc-js（npm citeproc **2.4.63**）**26/26** 共享 fixture 输出相等；这是有限样本，不是整个 CSL 的通过率。
- 五个可运行入口：cmd/main、examples/beginners、examples/numeric、examples/text-extract、examples/document。

## 本地实测

Windows；独立官方工具链 moon 0.1.20261012 (748b63c)，moonc v0.10.15+943464bfa（2026-10-12）。没有改共享工具链或全局 GitHub 身份。

| 流程 | wasm-gc | wasm | js | native |
|---|---|---|---|---|
| check --deny-warn | 通过 | 通过 | 通过 | 通过 |
| build --deny-warn | 通过 | 通过 | 通过 | 本机缺少 C 编译器，未计作通过 |
| test --deny-warn | 100/100 | 100/100 | 100/100 | 交由 Ubuntu CI，见下方实际记录 |
| 五个例子 | 通过 | 通过 | 通过 | 交由 Ubuntu CI，见下方实际记录 |

已执行 moon info、moon fmt、moon fmt --check、git diff --check。独立 npm test 为 26/26。所有结果必须在对应代码版本实测；不能以 0.1.1 的历史 CI 代替本轮验证。

## 本轮 GitHub CI

本轮推送后的远端运行记录将在验证后补入；暂不将配置文件视为成功证据。配置为 Ubuntu 四目标矩阵，每个目标运行 fmt/check/build/test/五例子，并核验姓名、数字范围、后缀与拒绝诊断的关键输出；另有独立参考引擎 job。

## 参考案例及精确输出

| 输入/规则 | 共享 expected |
|---|---|
| 作者连词 | `[Doe and Smith]` |
| 缩写带空格 | `[J. M. Doe]` |
| 数字分段折叠 | `[1–3, 5, 7–9]` |
| HTML 两个范围端点 | `<sup><b>1</b>–<b>3</b></sup>` |
| title 排序与相反 id 顺序 | `(Doe 2025b; Doe 2025a)` |
| 姓氏相同、完整名字不同 | `(Jane Doe 2025; John Doe 2025)`，不加后缀 |
| et-al 后发生碰撞 | `(Doe et al. 2025a; Doe et al. 2025b)` |
| 28 篇碰撞对象 | 从 a 到 z，再到 aa、ab |
| 相同全集下 a、z、a 三个簇 | `(Doe 2025b)`、`(Doe 2025a)`、`(Doe 2025b)` |

工具脚本先调用独立参考引擎，再生成 MoonBit 测试；两侧与同一 expected 精确比较。文献表比较只移除参考引擎每条末尾一个 LF 的 framing，保留正文空白。fixture 的规范化 LF SHA-256 防止忘记重新生成。样本自写，不来自官方全量 processor suite；没有进行 Typst/Hayagriva 性能或全样式测试。

## 明确拒绝的路径

测试包含全部五种 position 模式、add-names/givenname 选项、未知渲染节点/属性/枚举、重复 layout/macro、未知引用 ID、重复文献 ID、无年份碰撞、后缀放置不合规、noteIndex/author-only 等 Cite JSON 字段、不支持日期数据与错误格式。拒绝是本版本的固定边界，不是已经实现这些功能。

另外修复：空作者数组错误触发 choose；xml:lang 未识别；普通标量术语覆盖未进入 text；默认月份被输出为数字；JSON 日期范围终点被截断；数字/作者日期样式分类不准确。逐项测试在 scope_test.mbt，文档案例见 examples/document。

## 不作的声明与发布状态

不声明完整 CSL 1.0.2、完整消歧、引用历史、完整本地化、官方认证、100% 分支/标准覆盖率、性能领先或实际下游客户。范围以 docs/compatibility.md 为准；与 Typst/Hayagriva 的功能重叠及复用理由见 docs/ecosystem-value.md。

源码版本 0.1.2；**MoonCakes 未发布**，等待用户登录并明确继续发布。GitHub 技术修复和测试成功也不表示主办方已通过复审。
