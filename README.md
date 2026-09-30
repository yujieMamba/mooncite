# MoonCite

MoonCite 是一个面向 MoonBit 的 CSL（Citation Style Language）文献引用与参考文献排版库。它把 CSL 样式、CSL-JSON 数据和本地化术语连接起来，在不访问网络的情况下生成正文引用、参考文献表和 HTML 片段。

项目名称中的 Cite 指 citation，不是在线文献数据库。库的重点是让 MoonBit 程序可以把“文献数据 + 样式”变成稳定、可测试的排版结果，适合文档生成、科研笔记、静态站点和教学工具。

## 当前范围

- 解析常用 CSL XML：`style`、`macro`、`citation`、`bibliography`、`layout`、`text`、`names`、`name`、`date`、`date-part`、`number`、`group`、`choose` 和排序键。
- 读取 CSL-JSON 的标题、作者、日期、页码、URL、DOI、出版物等字段。
- 输出纯文本与 HTML；支持前后缀、大小写、字体样式、作者姓名、日期、数字、条件分支和分组分隔符。
- 提供英文、中文等本地化术语，页码范围折叠、数字引用范围折叠、作者键和文献表统计等辅助功能。
- 样式与数据都在本地输入，库本身不联网、不调用外部服务。

这是一个有明确边界的首版移植：覆盖常见 CSL 排版路径和可复用的数据模型，但不是对 CSL 1.0.2 全部扩展点的认证实现。复杂的脚注布局、完整的 disambiguation、BibTeX/MARC 导入、在线 DOI 查询和 PDF 排版不在当前版本范围内。

## 安装与快速开始

MoonCite 当前按 MoonBit 模块发布源码，要求 `moonc >= 0.10.14`。验收前不依赖 MoonCakes，直接克隆仓库即可复现：

```bash
git clone https://github.com/yujieMamba/mooncite.git
cd mooncite
moon version --all
moonc -v
moon check --target wasm-gc --deny-warn
moon test --target wasm-gc
```

在自己的 MoonBit 模块中使用时，可先把仓库作为本地源码依赖，或复制 `moon.mod`、`moon.pkg` 和库源码到工作区；本仓库的 `cmd/main` 和 `examples/*` 已经给出完整的可运行接入方式。MoonCite 暂未上传到 `mooncakes.io`，因此 README 不把尚未提供的包版本写成可安装事实。


```moonbit
let style = """
<style xmlns="http://purl.org/net/xbiblio/csl" version="1.0">
  <info><title>Demo</title><id>http://example.org/demo</id></info>
  <citation><layout prefix="(" suffix=")"><text variable="title"/></layout></citation>
  <bibliography><layout><names variable="author" suffix=". "><name/></names><date variable="issued" prefix="(" suffix="). "><date-part name="year"/></date><text variable="title"/></layout></bibliography>
</style>
"""
let processor = @mooncite.Processor::from_style(style).unwrap()
let item = @mooncite.Item::new("paper")
item.set_string("title", "A short paper")
item.set_name("author", [@mooncite.CslName::new(family="Doe", given="Jane")])
item.set_date("issued", @mooncite.CslDate::new(2024))
let result = processor.render_bibliography([item])
println(result.unwrap())
```

仓库内有四个可直接运行的例子：

```bash
moon run cmd/main
moon run examples/beginners
moon run examples/numeric
moon run examples/text-extract
```

## 质量与可复现性

质量报告记录了本地实际运行结果，而不是估算值：实现代码超过 3,000 行，包含 9 个测试用例和 4 个 runnable examples；在 `moonc v0.10.14` 下，`wasm-gc`、`wasm`、`js`、`native` 检查及 `wasm`/`js`/`wasm-gc` 测试均通过。CI 会固定检查 `moonc >= 0.10.14`，并执行 MoonBit 的格式检查、四个目标检查和测试。

## 设计取舍

MoonCite 借鉴 CSL 规范、citeproc 实现和 CSL-JSON 数据形状，但代码以 MoonBit 数据类型和纯函数式渲染流程重写。解析器不依赖网络，数据结构公开，便于在命令行、服务端、Wasm 或静态生成器中复用。

## 许可证

本项目采用 Apache License 2.0。规范与参考实现的来源、版本和边界见 [THIRD_PARTY.md](THIRD_PARTY.md)。


