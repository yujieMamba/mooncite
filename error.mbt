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
pub extend CslError with Eq::{not_equal, equal}

///|
pub extend CslError with @debug.Debug::{to_repr}

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
