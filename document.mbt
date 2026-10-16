///|
/// Result of rendering all clusters against one complete item universe.
/// This is deliberately stateless: no note positions, ibid or hidden history.
pub(all) struct RenderedDocument {
  citations : Array[String]
  bibliography : String
} derive(Debug, Eq)

///|
pub fn Processor::render_document(
  self : Processor,
  items : Array[Item],
  clusters : Array[Array[Cite]],
  format~ : String = "text",
) -> Result[RenderedDocument, CslError] {
  let citations = []
  // All clusters receive the SAME universe, including uncited bibliography
  // items; numbers and year-suffixes therefore cannot drift between clusters.
  for cluster in clusters {
    match self.render_citation(items, cluster, format~) {
      Ok(value) => citations.push(value)
      Err(e) => return Err(e)
    }
  }
  match self.render_bibliography(items, format~) {
    Err(e) => Err(e)
    Ok(bibliography) => Ok({ citations, bibliography, })
  }
}

///|
pub extend RenderedDocument with @debug.Debug::{to_repr}

///|
pub extend RenderedDocument with Eq::{not_equal, equal}
