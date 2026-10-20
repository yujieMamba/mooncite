# MoonCakes 0.1.2 发布验证

验证日期：2026-10-20。模块：`yujieMamba/mooncite@0.1.2`。

## 来源、身份及包内容

- GitHub 和 MoonCakes 服务端身份均核验为 `yujieMamba`；发布使用隔离凭据，没有切换共享账号。
- 发布源码提交：`c51c5b77155e0ab15673e1a423eda6b4573aa8d2`。
- 该提交的[GitHub CI](https://github.com/yujieMamba/mooncite/actions/runs/39362427394)为 success：wasm-gc、wasm、js、native 检查/构建/测试/示例及独立参考引擎 job 全部成功。
- [公开模块清单](https://mooncakes.io/api/v0/manifest/yujieMamba/mooncite@0.1.2)返回精确版本 0.1.2、yanked=false、build_status=success。
- ZIP SHA-256：`8714feb70b22a12b1dd69e6e20c803da45ba6c279ec2257705e45c65e3c57ed3`，与公开清单 checksum 完全一致。
- 从官方注册表下载后，逐字节比较全部 63 个包内文件，均与本次检查过的发布 ZIP 相同。
- 发布 ZIP、工作树与 Git 可达历史通过隐私检查；本地申报书及私人联系人不在发布包或仓库内。

此文及随后的验收状态属于发布后的工程记录，不是重新上传相同版本。0.1.2 的来源仍是上方固定提交；后续文档提交不改变已发布源码。

## 独立消费者

创建全新 MoonBit 模块，使用独立空 MOON_HOME、无 credentials.json、无原项目 .mooncakes 缓存，移除 registry/core/cache 等环境覆盖，不携带发布或 GitHub token。从官方注册表执行：

```bash
moon add yujieMamba/mooncite@0.1.2
```

在外部包中导入 `yujieMamba/mooncite`，而不是路径依赖或复制库源码。新增三个消费者测试：公共 API 生成引用及文献表、拒绝未支持的 ibid 上下文、processor_version() 返回 0.1.2。将本仓库 document、numeric、beginners 示例作为消费者的可执行包，仅复制示例和包导入配置，不复制库实现。

| 目标 | check / build --deny-warn | 消费者测试 | 三个例子及关键输出 |
|---|---|---|---|
| wasm-gc | 通过 | 3/3 | 通过 |
| wasm | 通过 | 3/3 | 通过 |
| js | 通过 | 3/3 | 通过 |

核对 `(Doe 2025b)`、`Doe 2025a. Alpha`、`[1–3, 5, 7–9]`、`(Doe and Smith 2025)` 及明确拒绝的诊断。消费者三个测试不是库本身的 100 项回归测试，也没有将重复目标执行次数算成不同用例。

本次仅完成发布和消费验证，不扩大兼容范围：仍是有限 CSL 子集，不代表完整 CSL 1.0.2 或比赛复审已通过。
