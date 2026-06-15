use tauri_build::{try_build, Attributes};

fn main() {
  try_build(Attributes::default()).expect("failed to build tauri");
}