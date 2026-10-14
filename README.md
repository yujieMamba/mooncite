# MoonCite

MoonCite 是 MoonBit 文献引用与参考文献排版库：输入 CSL XML 样式和 CSL-JSON 文献数据，在本地生成正文引用、文献表和 HTML 片段。适合文档生成、科研笔记、静态站点和教学工具，不提供在线文献检索服务。

## 0.1.1 的功能范围

- 常用样式节点：`text`、`names/name`、`label`、`date/date-part`、`number`、`group`、`choose`、`macro`、`sort` 和 `layout`。
- 姓名格式真正由样式控制：全名/姓氏/人数、缩写、连词、排序名、分隔符、et-al 截断和保留最后一位作者。支持根节点、citation、bibliography 的选项继承，以及无作者时的 substitute。
- `collapse="citation-number"` 已接入正文引用流程；不必手工调用范围辅助函数。连续三个及以上编号生成范围，两个编号保持分别列出。
- 引用簇的括号、前后缀和字体在对应层级应用；引用和文献表使用一致编号，支持排序、定位页码、逐条 prefix/suffix 和 suppress-author。
- CSL-JSON 作者、机构作者、日期、标题、页码、URL、DOI 等字段；纯文本和 HTML 输出，HTML 内容按层级转义。
- 英文/中文常用术语及简单的样式内术语覆盖。库本身不联网，不依赖 Node.js 或 JavaScript 引用引擎。

**范围说明：**不是完整 CSL 1.0.2 兼容实现。不支持依赖引用历史的 ibid/position、完整消歧算法、姓名粒子和 name-part 全部规则、多语言 locale 回退、日期区间的完整规则及文档脚注布局。`position` 条件和非数字 collapse 模式会明确报错；其他未支持的扩展节点/属性可能被忽略，不能把任意期刊样式直接视为已兼容。BibTeX/MARC 导入、在线 DOI 查询和 PDF 排版也不在本库范围内。

## 从 GitHub 获取并运行

要求 `moonc >= 0.10.14`。本次修复版本为 **0.1.1**，尚未同步 MoonCakes；以下命令直接验证 GitHub 源码，不依赖 MoonCakes 上的旧版本。

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

四个可运行目标：

```bash
moon run cmd/main --target wasm-gc
moon run examples/beginners --target wasm-gc
moon run examples/numeric --target wasm-gc
moon run examples/text-extract --target wasm-gc
```

68 个 MoonBit 测试覆盖核心路径和回归问题；其中 17 个用例与独立的 **citeproc-js 2.4.63** 使用相同输入及预期输出，分别验证姓名格式、数字范围和 HTML 范围端点。它们是选定行为的精确对照，不代表全部 CSL 兼容，也不是性能基准。

对照工具仅是开发依赖，需要 Node.js 22：

```bash
npm ci --prefix tools/reference --ignore-scripts
npm test --prefix tools/reference
```

CI 对 `wasm-gc`、`wasm`、`js`、`native` 分别执行格式检查、检查、显式构建、测试和四个示例；独立运行 citeproc-js 对照。本地复现记录见 [质量报告](docs/quality/quality-report.md)，本次修复与验收步骤见 [修复验证](docs/repair-verification.md) 和 [验收对应说明](docs/acceptance-checklist.md)。

## 源码组织

| 文件 | 职责 |
|---|---|
| `xml.mbt`、`style.mbt` | XML/样式解析、选项继承、宏验证 |
| `model.mbt`、`item_json.mbt` | 文献与引用数据模型、CSL-JSON |
| `names_render.mbt`、`render.mbt` | 姓名及节点渲染、文本/HTML |
| `citation.mbt`、`ordering.mbt` | 引用簇、实际范围折叠、排序及一致编号 |
| `locale.mbt`、`advanced.mbt`、`features.mbt` | 术语及扩展辅助 API |
| `render_regression_test.mbt`、`reference_test.mbt` | 回归测试与共享对照用例 |

## 许可证

生产库采用 Apache License 2.0。规范文档、参考项目和可选测试引擎的许可边界见 [THIRD_PARTY.md](THIRD_PARTY.md)。仓库不包含上游引用引擎源文件；开发对照工具不能被理解为生产库的运行时依赖。
