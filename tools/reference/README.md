# citeproc-js 对照用例

这是独立的开发测试工具，不参与 MoonCite 的运行时渲染。固定使用 npm `citeproc` **2.4.63**，锁文件固定依赖及完整性校验；建议 Node.js 22。

```bash
npm ci --prefix tools/reference --ignore-scripts
npm test --prefix tools/reference
```

17 组 fixture 覆盖：两种连词、三种缩写分隔、first/all 倒置、三种 et-al 截断、连字符姓名、机构作者、范围/两个编号/关闭折叠/数字排序/HTML 端点。参考引擎实际输出与 `fixtures.json` 中 expected 精确比较，不使用 substring 或手工挑选输出。

根目录 `reference_test.mbt` 由同一份 fixture 生成，使用 MoonCite 实际解析/渲染并比较同一个 expected。它被 `moon test` 自动执行：一边检查参考实现、一边检查本库，两边通过才构成这些用例的行为一致证据。

修改 fixture 后执行：

```bash
npm run generate --prefix tools/reference
moon fmt
moon test --target wasm-gc --deny-warn
```

生成器先执行参考引擎验证，再写 MoonBit 测试；普通 npm test 检查 fixture SHA-256 与生成文件头是否一致，避免遗漏重新生成。最小英文 locale 由本项目自行编写，仅服务于这些测试，没有复制外部 locale 文件。

范围限制：不覆盖完整 CSL、复杂脚注/消歧、多语言回退，也不是性能测试；`after-collapse-delimiter` 不在对照范围。上游引擎许可见根目录 THIRD_PARTY.md 和安装包 LICENSE。node_modules 被忽略，不提交上游源码。
