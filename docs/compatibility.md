# MoonCite 0.1.2：交付范围与 CSL 兼容边界

本页定义本项目本轮交付的终点，不是未来路线图。**交付的是独立、无引用历史状态的 CSL 样式子集处理器，不是完整 CSL 1.0.2 引擎。** 不承诺在本次比赛结束前补齐整个标准。若业务要求任意期刊 CSL 样式、完整脚注历史或完整消歧，应使用成熟处理器，而不是直接替换为本库。

CSL 规范使用 `version="1.0"` 的样式也可以遵循 1.0.2 修订；根节点的版本字符串不能证明实现符合整个标准。本库接受 1.0、1.0.1、1.0.2 声明，但均受本页子集限制。当前名称为 **MoonCite 0.1.2 profile**，不是官方认证或标准符合性等级。

## 能力矩阵

| 范畴 | 本轮交付终点 | 不在范围内 / 拒绝方式 | 可复现证据 |
|---|---|---|---|
| 输入 | CSL XML 常用节点、CSL-JSON 文献、逐条 Cite | 非完整 XML/CSL schema 验证器；未知复杂文献元数据不保证解释 | XML 测试、`scope_test.mbt` |
| 渲染 | text、names/name、number、label、显式 date/date-part、group、choose、macro；纯文本/HTML | 未支持渲染节点、属性、枚举值、错误层级返回带路径的 BadStyle | `style_compatibility_issues`；`compatibility.mbt` |
| 姓名 | 全名/姓氏/计数、缩写、连词、倒置、et-al、机构作者、简单 substitute、三层选项继承 | name-part、完整粒子降级/排序规则、姓名消歧扩展不实现 | 共享 fixture 的 names/et-al 案例 |
| 消歧 | **仅 year-suffix 最后一步**：按实际基础引用文本识别碰撞，按文献表顺序分配 a…z、aa…；引用与文献表一致 | 不做 add-names、add-givenname、givenname-disambiguation-rule、`disambiguate` 条件；这些样式选项会被拒绝 | 9 组 suffix 共享 fixture |
| 自动后缀放置 | 无显式 year-suffix 的样式，每个存在的布局必须恰有一个 issued/year；后缀随年份渲染 | 自动模式不接受条件/替代中的日期定位或多个年份；缺失年份导致无法消歧时报 BadItem | `automatic_suffix_dates`；缺失年份/放置错误测试 |
| 显式后缀放置 | `text variable="year-suffix"` 可控制位置；一侧显式使用时不再在另一侧自动追加 | 若实际条件分支未输出后缀、仍然碰撞，拒绝输出而非返回伪消歧结果 | 显式双侧与仅 citation 侧的共享 fixture |
| 引用上下文 | 调用方提供完整文献集合、引用簇顺序、locator/label、prefix/suffix、suppress-author；`render_document` 使用同一集合生成全部簇及文献表 | **没有隐藏的文档/脚注历史状态**；不解释 noteIndex 等历史字段 | 文档共享 fixture、`examples/document` |
| 历史相关能力 | 明确不做 | position 的 first/subsequent/ibid/ibid-with-locator/near-note；first-reference-note-number；noteIndex；自动回溯重排。样式或 Cite JSON 中相应输入报错 | `scope_test.mbt` 中逐模式拒绝测试 |
| 数字引用 | 同一集合下排序、编号；citation-number collapse 真正接入主流程 | 只折叠无附加上下文的三个及以上连续编号；带 locator/前后缀/suppress-author 不参与折叠；year 等 collapse 被拒绝 | 原有数字共享 fixture、numeric 示例 |
| 日期与 locale | 单个日期显式部件，年/月/日、数字/本地化月份；en-US/zh-CN 简单术语表与标量术语覆盖 | 日期范围、literal 日期渲染明确拒绝；不做季节/完整历法/完整 locale 回退。多形态术语、locale date 节点等拒绝 | 日期输入与 locale 回归测试 |
| 文献表与排序 | 简单变量/宏排序、稳定顺序、文献表与引用共用编号 | 不做完整语言排序、二次字段对齐、悬挂缩进、后续作者替换、PDF/Typst 版面 | 排序回归测试；不支持属性门禁 |
| 输出安全 | 文本无 HTML 字体标签，HTML 层级转义；输入渲染副本不写回调用方 | 不把 HTML 片段当作完整网页安全方案；不做任意标记保留 | HTML 与输入副本测试 |

上述“拒绝”不是占位 TODO：它们是本版本的接口契约。`style_compatibility_issues(xml)` 会返回节点路径与原因；`Processor::from_style(xml)` 也执行同一门禁，调用方不必记得额外运行预检。未知渲染节点和属性不再被静默丢掉。info 下的作者、链接等元数据不会参与渲染，不属于该门禁的校验对象；其他文献元数据、日期合法性的完整语义也不属于完整校验承诺。

`style_compatibility_issues` 返回空数组，只表示通过本库 profile 的解析与静态检查，不表示已覆盖所有数据组合、通过官方 schema、具备完整 CSL 语义，或获得官方认证。渲染阶段仍可能因未知 ID、重复 ID、无法消歧、无效格式或不支持的日期数据报错。

## 消歧案例：不能把作者/年份分组当作完整实现

两个输入对象的 id、题目和作者如下，年份均为 2025：

| id | title | author |
|---|---|---|
| a | Zulu | Jane Doe |
| z | Alpha | John Doe |

样式输出姓氏与年份，且文献表按 title 升序：

```xml
<citation disambiguate-add-year-suffix="true">
  <layout prefix="(" suffix=")" delimiter="; ">
    <group delimiter=" ">
      <names variable="author"><name form="short"/></names>
      <date variable="issued"><date-part name="year"/></date>
    </group>
  </layout>
</citation>
```

基础输出都是 `Doe 2025`，因此需要后缀。先按文献表顺序 Alpha、Zulu 分配 a、b；按引用顺序 `[a, z]` 渲染得到 **`(Doe 2025b; Doe 2025a)`**，而不是按照 id 排出后缀。文献表为：

```text
Doe 2025a. Alpha
Doe 2025b. Zulu
```

- 改为完整姓名 Jane Doe / John Doe 时已能区分，不追加后缀。
- 不同第二作者因 et-al 被省略后导致文本相同，仍需要后缀。
- 若引用已包含不同标题，则不再因为元数据作者/年份相同而多加后缀。
- 28 个碰撞对象可生成到 aa、ab，不停在 z。
- 不会尝试逐步增加作者或展开 given name；需要这些行为的样式必须交给其他引擎。

## 引用上下文案例：统一集合，不是假装维护历史

`render_document(items, [[a], [z], [a]])` 得到：

```text
(Doe 2025b)
(Doe 2025a)
(Doe 2025b)
```

三个簇与文献表共用同一 `items` 集合，包括希望列入文献表但正文未引的对象。单独调用 `render_citation` 时，调用方也必须传同一完整集合。传入子集会重新计算编号和后缀，这是显式无状态 API，不是引擎自动记住的历史。新增或删去文献、修改排序数据后，应重新渲染整个文档。本轮未实现增量更新、回溯编辑或复杂脚注关系。

`Cite::locator`、`label`、`prefix`、`suffix`、`suppress_author` 仅作用于当前条引用，不推导脚注号、前次引用或邻近距离。若样式含 `position="ibid"`，结果是：

```text
/style/citation/layout/choose/if/@position: unsupported option (not silently ignored)
```

传 `noteIndex` 或 `author-only` 到 Cite JSON 也会得到 BadJson，不能悄悄忽略并继续输出。完整可运行源码与上述成功/拒绝案例见 `examples/document`。

## 验证与参考

```bash
moon run examples/document --target wasm-gc
moon test --target wasm-gc --deny-warn
npm ci --prefix tools/reference --ignore-scripts
npm test --prefix tools/reference
```

共享 fixture 为本项目自写的有限样例，不是 CSL 官方全量处理器测试套件。26/26 只表示这些 fixture 在 MoonCite 与 citeproc-js 2.4.63 两侧符合各自精确 expected；不表示支持率 100%，也没有性能或标准覆盖率结论。

依据：[CSL 1.0.2 规范：Disambiguation / Citation-specific Options / Choose](https://docs.citationstyles.org/en/stable/specification.html)。规范文档许可与参考实现许可见 THIRD_PARTY.md。
