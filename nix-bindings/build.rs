fn main() -> miette::Result<()> {
    let include_path_raw = "../example_cxx_proj";
    let include_path = std::path::PathBuf::from(include_path_raw);
    let b = autocxx_build::Builder::new("src/lib.rs", &[&include_path]).build()?;

    b.compile("nix-bindings");

    println!("cargo:rerun-if-changed=src/lib.rs");

    let static_lib_dir = "example_cxx_proj/";

    // Link against the static library
    println!("cargo:rustc-link-search=native={}", static_lib_dir);
    println!("cargo:rustc-link-lib=static=hello");

    Ok(())
}
