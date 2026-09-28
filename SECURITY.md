# 安全边界

MoonCite 是本地文献排版库，不会主动访问网络，也不会执行样式中的代码。请不要把未信任的 HTML 输出直接插入网页；使用 `render_bibliography_html` 或 `render_citation_html` 时，应由调用方负责最终页面的安全策略。

安全问题请通过 GitHub 仓库的私密渠道联系维护者，不要在公开 issue 中发布可利用的输入样例。
