# 第三方来源与许可证

MoonCite 根据公开规范及参考行为，以 MoonBit 独立重写常用引用排版路径。生产库源代码采用 Apache-2.0，没有复制下列引用引擎的源文件，不宣称完整 CSL 认证。

| 来源 | 用途 | 来源地址 | 许可及边界 |
|---|---|---|---|
| CSL 1.0.2 Specification | 元素、属性和排版语义参考 | https://github.com/citation-style-language/documentation/blob/master/specification.rst | 规范文档为 CC-BY-SA-4.0；与采用 MIT 的 CSL schema 不同。没有把规范正文复制到本库文档 |
| citeproc-rs | 首版设计及渲染边界的参考方向 | https://github.com/zotero/citeproc-rs | MPL-2.0；未复制其源代码 |
| citation-js | CSL-JSON 数据形状的参考 | https://github.com/citation-js/citation-js | MIT；未复制其源代码 |
| citeproc-js / npm citeproc 2.4.63 | 可选开发对照：17 组姓名/数字/HTML 用例 | https://github.com/Juris-M/citeproc-js ; https://www.npmjs.com/package/citeproc/v/2.4.63 | 包内 LICENSE 允许选择 CPAL-1.0 或 AGPL-3.0-or-later；以实际发行包许可为准，不使用 npm 元数据的错误简写 |

## 开发对照与生产库的分离

`tools/reference` 仅包含本项目自写的测试脚本、fixture、最小 locale 及 npm 锁文件。运行 npm ci 后独立安装参考引擎，并在 Node.js 进程中运行；MoonBit 库不调用或链接该引擎。node_modules 被 Git 忽略，仓库不分发其源文件，不能将其 LICENSE 替换为本库的 Apache-2.0。

如果另行分发上游引擎、修改它，或将其嵌入自己的产品，应保留上游许可并按所选许可履行要求。本仓库不提供这种分发或嵌入方案。

原项目名称、商标与著作权属于各自权利人。规范的参考与选定行为对照不等于获得上游背书，也不等于完整兼容性认证。
