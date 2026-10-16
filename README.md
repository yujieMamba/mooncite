# MoonCite

MoonCite 是 MoonBit 文献引用与参考文献排版库：输入 CSL XML 样式和 CSL-JSON 文献数据，在本地生成正文引用、文献表和 HTML 片段。适合文档生成、科研笔记、静态站点和教学工具，不提供在线文献检索服务。

## 0.1.2 的功能范围

- 常用样式节点：`text`、`names/name`、`label`、`date/date-part`、`number`、`group`、`choose`、`macro`、`sort` 和 `layout`。
- 姓名格式真正由样式控制：全名/姓氏/人数、缩写、连词、排序名、分隔符、et-al 截断和保留最后一位作者。支持根节点、citation、bibliography 的选项继承，以及无作者时的 substitute。
- `collapse="citation-number"` 已接入正文引用流程；不必手工调用范围辅助函数。连续三个及以上编号生成范围，两个编号保持分别列出。
- 引用簇的括号、前后缀和字体在对应层级应用；引用和文献表使用一致编号，支持排序、定位页码、逐条 prefix/suffix 和 suppress-author。
- CSL-JSON 作者、机构作者、日期、标题、页码、URL、DOI 等字段；纯文本和 HTML 输出，HTML 内容按层级转义。
- 英文/中文常用术语及简单的样式内术语覆盖。库本身不联网，不依赖 Node.js 或 JavaScript 引用引擎。

**交付终点：有限 CSL 子集，不是完整 CSL 1.0.2 兼容引擎，也不承诺本轮补齐整个标准。** 新增按实际引用文本冲突与文献表顺序分配的 year-suffix 消歧，以及共用完整文献集合的无状态 `render_document`。不做 add-names/add-givenname 消歧、ibid/position/near-note 历史、完整 locale/name-part/粒子规则或文档脚注排版。未支持渲染节点/属性/枚举值在样式载入时明确报错，历史 Cite JSON 字段、日期范围/literal 渲染也拒绝，不再静默跳过。完整边界、成功与拒绝案例见 [兼容范围](docs/compatibility.md)。

**与 Typst 并非没有重叠。** Hayagriva 已能作为独立 Rust 库使用。本项目提供不依赖外部引用引擎的 MoonBit 数据/API 与多目标输出，适合受控样式的 MoonBit 应用；不是功能、兼容性或性能更强的替代品。具体复用途径与比较依据见 [生态贡献及对标边界](docs/ecosystem-value.md)。

## 从 GitHub 获取并运行

当前源码使用 `moonc >= 0.10.15`（满足比赛要求的不低于 0.10.14）；建议使用官方工具链 2026-10-12 版或更新版本。本次修复版本为 **0.1.2**，尚未同步 MoonCakes；以下命令直接验证 GitHub 源码，不依赖 MoonCakes 上的旧版本。

```bash
git clone https://github.com/yujieMamba/mooncite.git
cd mooncite
moon version --all
moonc -v
moon fmt --check
moon check --target wasm-gc --deny-warn
moon build --target wasm-gc --deny-warn
moon test --target wasm-gc --deny-warn
moon run examples/beginners --target wasm-gc
moon run examples/numeric --target wasm-gc
moon run examples/document --target wasm-gc
```

`cmd/main` 和 `examples/*` 的 `moon.pkg` 演示了同一模块中的包依赖配置。可在这个源码模块内添加自己的可执行包，依赖 `yujieMamba/mooncite` 并使用别名 `@mooncite`；需要独立模块安装时，应等本版本发布后再按 MoonCakes 指定版本接入。

## 最小用法

下面是 `examples/beginners/main.mbt` 中的核心代码。完整样式、包配置和入口在该目录，可直接运行。

```moonbit
let item = @mooncite.Item::new("intro")
  .set_string("title", "A MoonBit introduction")
  .set_name("author", [
    @mooncite.CslName::new("Doe", given="Jane Mary"),
    @mooncite.CslName::new("Smith", given="John"),
  ])
  .set_date("issued", @mooncite.CslDate::new(2025))
let p = @mooncite.Processor::from_style(STYLE).unwrap()
println(p.render_citation([item], [@mooncite.Cite::new("intro")]).unwrap())
println(p.render_bibliography([item]).unwrap())
println(p.render_bibliography_html([item]).unwrap())
```

样式在 citation 内使用 `<name form="short" and="text"/>`，bibliography 内使用 `name-as-sort-order="first"`，根节点提供 `initialize-with=". "`。输出如下：

```text
(Doe and Smith 2025)
Doe, J. M. and J. Smith. (2025). A MoonBit introduction.
Doe, J. M. and J. Smith. (2025). <i>A MoonBit introduction</i>.
```

## 数字引用：完整渲染，不是独立辅助函数

`examples/numeric/main.mbt` 的样式包含：

```xml
<citation collapse="citation-number">
  <sort><key variable="citation-number"/></sort>
  <layout prefix="[" suffix="]" delimiter=", ">
    <group delimiter=", ">
      <text variable="citation-number"/>
      <group delimiter=" ">
        <label variable="locator" form="short"/>
        <text variable="locator"/>
      </group>
    </group>
  </layout>
</citation>
```

运行 `moon run examples/numeric --target wasm-gc`，先输出引用簇，再输出编号文献表：

```text
[1–3, 5, 7–9]
[1, 2, pp. 12-14, 3]
1. Paper 1
2. Paper 2
3. Paper 3
...
9. Paper 9
```

第二行的第 2 条引用带定位页码，因此不能吞入数字范围。重复引用、不连续/逆序编号，以及有 prefix/suffix 或 suppress-author 的引用也不参与跨条合并。没有 `<sort>` 时保留输入顺序，不为获得范围而擅自排序。混有标题等逐条信息的布局保持逐条渲染，避免折叠丢失内容。

编号由**本次传入的完整文献集合**确定：有 bibliography 排序时按该排序分配，否则按输入顺序；合法显式编号优先保留。库不维护跨调用的引用历史。多次生成引用及文献表时请传入同一个完整集合，而非每次仅传当前引用的文献子集。渲染过程中使用副本，不改写调用者的数据。

## 示例与验证

五个可运行入口（不是五个编译目标）：

```bash
moon run cmd/main --target wasm-gc
moon run examples/beginners --target wasm-gc
moon run examples/numeric --target wasm-gc
moon run examples/text-extract --target wasm-gc
moon run examples/document --target wasm-gc
```

100 个 MoonBit 测试覆盖核心路径和回归问题；其中 26 个用例与独立的 **citeproc-js 2.4.63** 使用相同输入及预期输出，分别验证姓名格式、数字范围、HTML 范围端点和年后缀消歧。它们是选定行为的精确对照，不代表全部 CSL 兼容，也不是性能基准。

对照工具仅是开发依赖，需要 Node.js 22：

```bash
npm ci --prefix tools/reference --ignore-scripts
npm test --prefix tools/reference
```

CI 对 `wasm-gc`、`wasm`、`js`、`native` 分别执行格式检查、检查、显式构建、测试和五个示例；独立运行 citeproc-js 对照。本地复现记录见 [质量报告](docs/quality/quality-report.md)，本次修复与验收步骤见 [修复验证](docs/repair-verification.md) 和 [验收对应说明](docs/acceptance-checklist.md)。

## 消歧与文档上下文

```moonbit
let document = processor.render_document(items, [
  [@mooncite.Cite::new("a")],
  [@mooncite.Cite::new("z")],
  [@mooncite.Cite::new("a")],
]).unwrap()
```

完整示例在 `examples/document`。其中题目为 Zulu/Alpha 的两篇 Doe 2025 文献，按题目排序后依次给 a/b 后缀；引用顺序 a、z、a 输出 `(Doe 2025b)`、`(Doe 2025a)`、`(Doe 2025b)`，文献表相应一致。26 组共享对照包含实际姓名渲染碰撞、et-al、显式/自动后缀和 z 之后的 aa/ab。

`items` 必须是整篇文档的同一完整集合，含需列入文献表的未引文献。新增/删除文献或改排序数据后重渲染所有簇。这个接口没有脚注历史，**不会**把第三次引用变成 ibid。`style_compatibility_issues` 可以预检样式；`Processor::from_style` 同样强制门禁，见兼容范围文档。原有 `assign_year_suffixes` 只是会修改参数的元数据辅助函数，不是引擎消歧流程；实际渲染在副本上按基础引用文本判断。

## 源码组织

| 文件 | 职责 |
|---|---|
| `xml.mbt`、`style.mbt` | XML/样式解析、选项继承、宏验证 |
| `model.mbt`、`item_json.mbt` | 文献与引用数据模型、CSL-JSON |
| `names_render.mbt`、`render.mbt` | 姓名及节点渲染、文本/HTML |
| `citation.mbt`、`ordering.mbt`、`disambiguation.mbt`、`document.mbt` | 引用簇、范围折叠、排序编号、年后缀与无状态整篇输出 |
| `compatibility.mbt` | 有限样式契约与不支持能力诊断 |
| `locale.mbt`、`advanced.mbt`、`features.mbt` | 术语及扩展辅助 API |
| `render_regression_test.mbt`、`reference_test.mbt` | 回归测试与共享对照用例 |

## 许可证

生产库采用 Apache License 2.0。规范文档、参考项目和可选测试引擎的许可边界见 [THIRD_PARTY.md](THIRD_PARTY.md)。仓库不包含上游引用引擎源文件；开发对照工具不能被理解为生产库的运行时依赖。
