# MoonCite 与 Typst / Hayagriva 的关系

更新时间：2026-10-16；对应 0.1.2 源码。这里说明可验证的使用边界，不声称发明新的引用算法或取代成熟排版软件。

## 正面承认重叠

Typst 已有引用与文献表功能，也支持 CSL 样式。其生态中的 Hayagriva 是 Rust 文献处理库，**本身可以脱离 Typst 作为库或 CLI 使用**，并不是“必须启动排版器才能使用”的封闭功能。因此“Typst 不能做文献引用”“现有引擎不可复用”都不是本项目的理由。

MoonCite 的 CSL 解释、姓名排版、引用簇、排序和后缀消歧，与成熟引用引擎在功能上确有重叠。若允许 Rust 依赖、Typst 文档工作流或外部引用服务，应优先评估成熟方案；本项目当前兼容范围明显更小，没有证据证明输出更全、算法更优或速度更快。

## 本项目增加的部分

1. **MoonBit 内部的直接调用链**。调用方使用 MoonBit Item、Cite、Processor 和 Result，在同一个模块内完成 CSL-JSON 输入、预检、文本/HTML 输出。根 moon.pkg 仅依赖 MoonBit core/json 与 core/debug，不调用外部引擎，不需要 Rust/JS FFI 或文档编译器进程。测试用 Node 引擎不属于生产运行链。
2. **明确拒绝的有限兼容契约**。对这一小部分能力给出固定终点；错误中暴露 XML 路径、未知输入与缺失历史能力。它服务于使用可控样式的应用，不以接受任意 CSL 文件为卖点。
3. **可复现的多目标集成与参考输出**。同一 MoonBit API 在 wasm-gc、wasm、js、native 构建目标验证；仓库内提供文档整体渲染和预检的可执行例子。26 组共享样例由独立 citeproc-js 进程与 MoonBit 两侧检查。这是互操作证据，不是超越 Typst 的指标。

这些贡献主要是 MoonBit 生态的可组合性与可检验边界，不是标准层面的新功能，也不能仅凭语言不同宣称“无重复”。是否足以符合比赛价值要求，仍需由主办方评定。

## 三条实际复用途径

| 下游 | 输入与调用 | 结果 / 可复现入口 |
|---|---|---|
| MoonBit 文档或静态站点生成器 | CSL-JSON + 受控样式；以相同全集渲染所有簇及文献表 | 得到一致后缀、编号及文本/HTML；`examples/document`、`examples/numeric` |
| 科研笔记、编辑器插件中的格式预览模块 | 先调用 style_compatibility_issues，再构造 Item/Cite 与预览输出 | 在可控样式下显示姓名/年、字体与 locator；不支持 ibid 的样式当场提示；`examples/beginners` 和 `examples/document` |
| 离线元数据处理或教学工具 | 从 CSL-JSON 建立对象，渲染文献表或受限引用片段 | 在 MoonBit 程序内部产生输出与可检查错误，不依赖网络文献检索；`cmd/main`、回归测试 |

这里的使用者类别是复用路径，不代表已经有这三类真实客户或第三方集成。浏览器宿主仍由使用者负责；本项目没有交付编辑器 UI、完整静态站点框架或 Typst 插件。

## 对标边界

| 项目 | 可核实能力 / 定位 | MoonCite 的关系 |
|---|---|---|
| Typst bibliography / cite | 文档系统内的引用和文献表，支持 CSL 自定义样式 | 不争夺完整排版；输出纯文本或 HTML 给 MoonBit 调用方 |
| Hayagriva | Rust 文献数据结构、YAML、BibTeX 互通、引用与文献表；可作库/CLI | 功能覆盖更广；MoonCite 不是其代码移植，也不是完整替代 |
| citeproc-js 2.4.63 | 成熟 CSL 处理器；本仓库独立安装作为测试参考 | 只对有限共享 fixture 比较，没有宣称全套行为一致 |
| MoonCite 0.1.2 | 原生 MoonBit 的有限 CSL 子集、显式无状态文档接口、预检 | 最终范围见 compatibility.md；不提供完整消歧/脚注历史 |

参考一手资料（2026-10-16 核对）：
- [Typst bibliography 文档](https://typst.app/docs/reference/model/bibliography/)
- [Typst cite 文档](https://typst.app/docs/reference/model/cite/)
- [Hayagriva 官方 README 与使用示例](https://github.com/typst/hayagriva)
- [CSL 规范](https://docs.citationstyles.org/en/stable/specification.html)

没有运行 Typst 或 Hayagriva 的性能/全样式兼容性对照；上表是依据其官方文档说明定位，不能作为本库优于它们的实验结论。实测的独立软件对照只有 tools/reference 中锁定的 citeproc-js。
