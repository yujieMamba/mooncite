# 选题查重记录（内部过程）

- 检查日期：2026-09-28（Asia/Shanghai）。
- 目标指纹：CSL XML 样式 + CSL-JSON 文献对象 + 本地化术语，执行 citation/bibliography 排版；不是单纯 XML 解析器，也不是文献数据库或 BibTeX 转换器。
- MoonCakes 关键词：`citeproc`、`citation`、`bibliography`、`CSL`、`citation style`、`文献`、`引用`、`参考文献`、`XML style`、`CSL-JSON`。对返回结果和相关包页面做了人工边界检查，未发现以 MoonBit 实现同一 CSL 排版功能的包。
- GitHub 语言与主题检索：以 MoonBit、CSL/citeproc/citation/bibliography 等组合检索，未发现同一功能方向的 MoonBit 项目。

## 相邻项目与排除理由

1. **citeproc-rs**（https://github.com/zotero/citeproc-rs）：同一问题域的成熟 Rust 参考实现，但不是 MoonBit 包；MoonCite 只参考公开行为和数据语义，不复制代码。
2. **citation-js**（https://github.com/citation-js/citation-js）：JavaScript 文献数据工具，重点是输入解析与格式转换；MoonCite 的边界是本地 CSL 样式渲染，运行时、语言和 API 均不同。
3. **Pandoc Citeproc**（https://github.com/jgm/citeproc）：命令行/文档转换链路中的 citeproc 实现，不是 MoonBit 库；MoonCite 不承担 Markdown/Pandoc 文档转换。
4. **moon-record-linkage**：记录链接与去重评分库，虽可能处理字符串字段，但不解析 CSL XML、不执行引用样式和参考文献排版，属于不同功能。
5. **mooniban、moonbit-phonetic 等相邻 MoonCakes 包**：分别处理 IBAN 校验或语音编码，与文献引用排版无功能重叠。

## 结论和边界

在本次检索范围内，没有发现 MoonCakes 生态中与 MoonCite 同时满足“MoonBit + CSL 样式解释 + 引用/文献表渲染”的项目，因此保留该选题。该结论是基于检索日期和公开索引的范围性结论，不把“未检索到”表述成全互联网绝对不存在。若后续出现同功能包，应以功能边界、发布时间和实际 API 做复核。

已在本地项目登记表中预留 MoonCite 指纹，避免与同一工作区的其他候选题重复。
