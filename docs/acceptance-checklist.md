# MoonCite 验收对应说明

更新时间：2026-10-16，源码版本 0.1.2。这里是技术复现说明，不是报名表，也不是已通过复审的声明。

| 要求 | 当前对应内容 |
|---|---|
| MoonBit 为主，moonc 不低于 0.10.14 | 根包 19 个生产文件；本版使用不低于 0.10.15；CI 检查门槛 |
| GitHub 公开且提交清晰 | yujieMamba/mooncite；修复按功能、测试、文档与验证提交 |
| 源码结构与核心能力 | 解析、兼容门禁、姓名、节点、排序、引用、消歧、整篇输出分文件；范围见 compatibility.md |
| README 安装/用法/示例 | 提供从 GitHub 源码运行方式；明确本版 MoonCakes 尚未发布 |
| CI 检查/构建/测试 | 四目标 fmt/check/build/test/五例子与独立 reference job；不是用 check 代替 build |
| 运行示例 | 五入口，新增 document 展示一致后缀与实际拒绝历史样式 |
| 核心路径测试 | 100 项 MoonBit 测试；26 组 citeproc-js 2.4.63 共享 fixture；实测环境与远端运行见质量报告 |
| MoonCakes 发布 | **暂未完成本版发布**：按用户要求等待登录后再同步；不得标记为完成 |
| 开源与参考许可 | 生产 Apache-2.0；独立测试引擎与规范参考见 THIRD_PARTY.md；未复制上游引擎源码 |

```bash
moon version --all
moon fmt --check
moon check --target wasm-gc --deny-warn
moon build --target wasm-gc --deny-warn
moon test --target wasm-gc --deny-warn
moon run examples/beginners --target wasm-gc
moon run examples/numeric --target wasm-gc
moon run examples/document --target wasm-gc
npm ci --prefix tools/reference --ignore-scripts
npm test --prefix tools/reference
```

其他目标替换为 wasm/js/native，native 需要 C 编译器。Windows 本地未验证 native build/test；以本轮 Ubuntu CI 成功日志为证，不能借用旧版本记录冒充。主办方关心的“完整 CSL 终点”“消歧与引用上下文范围”“Typst 净贡献”，分别集中在 compatibility.md 与 ecosystem-value.md；不是靠增加测试数代替范围说明。
