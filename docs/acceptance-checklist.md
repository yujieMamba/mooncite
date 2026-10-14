# MoonCite 验收对应说明

更新时间：2026-10-14，源码版本：0.1.1。

| 验收要求 | 当前对应内容 |
|---|---|
| MoonBit 为主要实现语言，moonc >= 0.10.14 | 根包 15 个生产 `.mbt` 文件；最终源码使用 0.10.15；CI 检查 0.10.15 编译器门槛（高于比赛最低要求） |
| GitHub 仓库公开、提交清晰 | https://github.com/yujieMamba/mooncite；修复提交按核心渲染、独立对照、文档示例与 CI 分组 |
| 源码结构清晰、核心功能可用 | XML/样式、姓名、节点渲染、引用簇、排序编号、模型/JSON 分文件；本次三个问题见 `docs/repair-verification.md` |
| README 含安装、使用、可复现示例 | 源码克隆方式、完整示例入口、输出、数据集合与编号说明、已支持及未支持范围 |
| CI 覆盖检查、构建、测试 | `.github/workflows/ci.yml` 四目标矩阵：fmt/check/**build**/test、四个例子；独立 reference job。不是用 check 冒充显式 build |
| 至少一个可运行例子 | 四个例子；数字示例实际调用 Processor，不依赖独立范围辅助函数伪装核心功能 |
| 测试覆盖核心路径 | 68 个 MoonBit 测试，三个本地目标各 68/68；17 组参考引擎精确输出对照 |
| 发布到 MoonCakes | **本次 0.1.1 暂不发布/同步**，等待参赛者登录后再执行；该条不能标记为本次已完成 |
| OSI 开源许可、遵守上游许可 | 生产源码 Apache-2.0，LICENSE 完整；独立开发测试引擎许可及不复制源码的边界见 THIRD_PARTY.md |

## 从源码验证

```bash
moonc -v
moon fmt --check
moon check --target wasm-gc --deny-warn
moon build --target wasm-gc --deny-warn
moon test --target wasm-gc --deny-warn
moon run examples/beginners --target wasm-gc
moon run examples/numeric --target wasm-gc
npm ci --prefix tools/reference --ignore-scripts
npm test --prefix tools/reference
```

替换为 wasm、js 或 native 可验证其他目标；native 需要系统 C 编译器。本地 Windows 缺少 C 编译器，只完成 native check，native 构建、测试和例子由 Ubuntu CI 验证。远端结果以 Actions 为准，见质量报告。

本说明用于技术复现，不是组织方审批表，不表示已经通过复验。
