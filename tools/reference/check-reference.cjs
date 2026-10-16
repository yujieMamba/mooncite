// Independent test-only reference engine; never loaded by the MoonBit library.
const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const crypto = require("node:crypto");
const fixturesPath = path.join(__dirname, "fixtures.json");
// Normalize checkout line endings before hashing shared fixture source.
const bytes = Buffer.from(fs.readFileSync(fixturesPath, "utf8").replace(/\r\n/g, "\n"));
const fixtures = JSON.parse(bytes);
const digest = crypto.createHash("sha256").update(bytes).digest("hex");
if (!process.argv.includes("--generate")) {
  const generated = fs.readFileSync(path.join(__dirname, "../../reference_test.mbt"), "utf8");
  assert.ok(generated.includes("// Fixtures SHA-256: " + digest), "fixtures changed; run npm run generate, then moon fmt");
}

const moduleArg = process.argv.indexOf("--module");
const CSL = require(moduleArg === -1 ? "citeproc" : path.resolve(process.argv[moduleArg + 1]));
// Self-authored, minimal locale for these isolated names/numeric cases only.
const locale = '<locale xmlns="http://purl.org/net/xbiblio/csl" xml:lang="en-US"><terms><term name="and">and</term><term name="et-al">et al.</term><term name="citation-range-delimiter">–</term></terms></locale>';
for (const fixture of fixtures) {
  const sys = {
    retrieveLocale: () => locale,
    retrieveItem: id => fixture.items.find(item => item.id === id),
  };
  const engine = new CSL.Engine(sys, fixture.style);
  engine.setOutputFormat(fixture.format || "text");
  engine.updateItems(fixture.items.map(item => item.id));
  const actual = engine.makeCitationCluster(fixture.cites);
  assert.equal(actual, fixture.expected, fixture.name);
  if (fixture.bibliographyExpected !== undefined) {
    // citeproc-js frames each bibliography entry with one terminal LF;
    // remove that framing only, preserving all text inside each entry.
    const bibliography = engine.makeBibliography()[1].map(x => x.replace(/\n$/, "")).join("\n");
    assert.equal(bibliography, fixture.bibliographyExpected, fixture.name + " bibliography");
  }
  if (fixture.clusters) {
    assert.deepEqual(fixture.clusters.map(cites => engine.makeCitationCluster(cites)), fixture.clusterExpected, fixture.name + " clusters");
  }
  console.log(`PASS ${fixture.name}: ${actual}`);
}
console.log(`${fixtures.length}/${fixtures.length} citeproc-js reference fixtures passed`);
if (process.argv.includes("--generate")) {
  const q = JSON.stringify;
  let source = '// Generated from tools/reference/fixtures.json; run npm run generate, then moon fmt.\n';
  source += '// Fixtures SHA-256: ' + digest + '\n';
  for (const f of fixtures) {
    source += `\n///|\ntest ${q("reference " + f.name)} {\n`;
    source += `  let p = @mooncite.Processor::from_style(${q(f.style)}).unwrap()\n`;
    source += `  let items = @mooncite.parse_items_json(${q(q(f.items))}).unwrap()\n`;
    source += `  let cites = @mooncite.parse_cites_json(${q(q(f.cites))}).unwrap()\n`;
    source += `  assert_eq(p.render_citation(items, cites, format=${q(f.format || "text")}), Ok(${q(f.expected)}))\n`;
    if (f.bibliographyExpected !== undefined) {
      source += `  assert_eq(p.render_bibliography(items), Ok(${q(f.bibliographyExpected)}))\n`;
    }
    if (f.clusters) {
      const cs = f.clusters.map(c => `@mooncite.parse_cites_json(${q(q(c))}).unwrap()`).join(", ");
      source += `  let document = p.render_document(items, [${cs}]).unwrap()\n`;
      source += `  assert_eq(document.citations, [${f.clusterExpected.map(q).join(", ")}])\n`;
      source += `  assert_eq(document.bibliography, ${q(f.bibliographyExpected)})\n`;
    }
    source += `}\n`;
  }
  fs.writeFileSync(path.join(__dirname, "../../reference_test.mbt"), source);
}
