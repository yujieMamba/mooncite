# MoonCite 验收对应说明

更新时间：2026-09-30

| 验收要求 | 仓库中的对应内容 |
|---|---|
| MoonBit 为主要实现语言，moonc 不低于 0.10.14 | 核心实现为 `.mbt`；README 写明版本要求；CI 在检查前执行 `moonc -v` 版本门槛；本地已用 `v0.10.14+7d59c7ec9` 验证 |
| GitHub 仓库公开、提交清晰 | `https://github.com/yujieMamba/mooncite`，公开仓库，按 XML、模型、渲染、JSON、示例、测试、CI 分阶段提交 |
| 源码结构清晰、核心功能可用 | XML、模型、样式、渲染、JSON、本地化、辅助算法和验证分别组织在独立 `.mbt` 文件中 |
| README、安装、使用、示例可复现 | `README.md` 含版本要求、克隆后的检查命令、API 说明和运行命令 |
| 持续集成覆盖检查、构建、测试 | `.github/workflows/ci.yml` 覆盖格式检查、wasm-gc/wasm/js/native 检查和 wasm-gc 测试；MoonBit 检查过程包含构建 |
| 至少一个可运行示例 | `cmd/main` 以及 `examples/beginners`、`numeric`、`text-extract` 共 4 个可运行目标 |
| 完整测试覆盖核心路径 | 9 个测试覆盖 XML、样式、引用、JSON、页码范围、本地化和数字引用范围；wasm-gc、wasm、js 均通过 |
| 发布到 MoonCakes | **暂不执行**。项目按当前要求保持 GitHub 公开开发，未上传 `mooncakes.io` |
| OSI 认可的开源许可证 | Apache License 2.0，仓库含完整 `LICENSE`；第三方来源和许可证见 `THIRD_PARTY.md` |

## 当前可复现命令

```bash
moonc -v
moon fmt --check
moon check --target wasm-gc --deny-warn
moon check --target wasm --deny-warn
moon check --target js --deny-warn
moon check --target native --deny-warn
moon test --target wasm-gc
moon test --target wasm
moon test --target js
moon run cmd/main
```
