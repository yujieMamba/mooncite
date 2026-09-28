///|
/// Recoverable processor errors. Messages stay stable for tests.
pub(all) enum CslError {
  BadXml(String)
  BadStyle(String)
  BadJson(String)
  BadItem(String)
  MissingStyle
} derive(Eq, Debug)

///|
pub fn CslError::message(self : CslError) -> String {
  match self {
    BadXml(s) => s
    BadStyle(s) => s
    BadJson(s) => s
    BadItem(s) => s
    MissingStyle => "style xml is required"
  }
}
