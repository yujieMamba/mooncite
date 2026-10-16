> 本页是 0.1.1（2026-10-14）的历史修复记录，不代表当前范围。0.1.2 的最终契约、消歧与引用上下文案例见 [兼容范围](compatibility.md)，与 Typst 的关系见 [生态贡献](ecosystem-value.md)。

# 0.1.1 修复验证

日期：2026-10-14。本说明针对姓名配置、引用折叠和实际数字渲染三个问题，不包含个人资料或邮件截图。

## 三项修复对应

| 原问题 | 当前实现 | 验证入口 |
|---|---|---|
| `<names>` 使用固定默认配置 | `style.mbt` 读取 `<name>` 属性及 style/citation/bibliography 继承；`names_render.mbt` 执行连词、缩写、倒置、et-al 等选项 | `examples/beginners`；姓名回归测试及 12 组独立引擎对照 |
| citation_collapse 未进入渲染 | `citation.mbt` 的 `Processor::render_citation` 读取样式 collapse 并处理排序后的引用簇 | `examples/numeric`；开关、连续范围、两个编号、排序回归测试 |
| 数字范围仅为辅助 API | 编号准备、引用排序、范围识别和最终布局在完整 Processor 流程内完成；示例没有手工调用 `collapse_numeric_ranges` | 数字示例同时生成 `[1–3, 5, 7–9]` 和编号文献表 |

姓名对照 12 组：连词两组、缩写三组、倒置两组、et-al 三组、连字符姓名、机构作者。数字及 HTML 对照 5 组。与回归测试存在交叉，不能相加当成更多独立覆盖。

## 可复现命令

```bash
moon fmt --check
moon check --target wasm-gc --deny-warn
moon build --target wasm-gc --deny-warn
moon test --target wasm-gc --deny-warn
moon run examples/beginners --target wasm-gc
moon run examples/numeric --target wasm-gc
npm ci --prefix tools/reference --ignore-scripts
npm test --prefix tools/reference
```

期望：68/68 MoonBit 测试通过，17/17 独立引擎用例通过。姓名示例第一行是 `(Doe and Smith 2025)`；数字示例前两行是 `[1–3, 5, 7–9]` 和 `[1, 2, pp. 12-14, 3]`。将目标改为 wasm 或 js 可复现相同输出；native 构建/测试还需要 C 编译器。

## 一并修复的问题

- 引用布局前后缀仅包围整个引用簇一次；HTML 范围端点分别保留字体标签。
- 编号与排序不修改输入数据；无 sort 保留顺序，数值排序不再按字符串比较，缺失键排在末尾。
- 定位标签、prefix/suffix、suppress-author 和重复引用不会被范围吞掉；混合标题布局不强行折叠。
- 纯文本不带字体 HTML；HTML 变量、前后缀和分隔符只转义一次，宏内标记不双重转义，大小写转换不破坏标签。
- JSON 序列化正确处理引号、换行及反斜杠；机构作者保留 literal。
- XML 未闭合、结束标签不完整、多根节点、重复属性、DOCTYPE 等会报错。无效数字字符实体保留原文而非进行危险字符转换。解析器仍不是通用 XML 规范验证器。
- 未定义/循环宏报错；依赖引用历史的 position 条件及非数字 collapse 模式明确拒绝，不再伪装为支持。

## 尚未覆盖的范围

完整 CSL 消歧、引用历史、全部 locale/name-part/日期区间规则和复杂脚注仍未实现；本次 17 组对照不证明这些功能。`after-collapse-delimiter` 不在对照集合内，不作与参考引擎完全一致的承诺。没有编造覆盖率或性能提升。

本次只更新 GitHub 源码，不同步 MoonCakes，也不代替组织方的验收结论。
