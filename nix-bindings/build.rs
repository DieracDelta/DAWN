fn main() -> miette::Result<()> {
    // let include_paths_raw = [
    //     ("/Users/jrestivo/dev/nix", "nvmlol"),
    //     ("/Users/jrestivo/dev/nix/src/libcmd/", "cmd"),
    //     ("/Users/jrestivo/dev/nix/src/libexpr/", "expr"),
    //     ("/Users/jrestivo/dev/nix/src/libfetchers/", "fetchers"),
    //     ("/Users/jrestivo/dev/nix/src/libmain/", "main"),
    //     ("/Users/jrestivo/dev/nix/src/libstore/", "store"),
    //     ("/Users/jrestivo/dev/nix/src/libutil/", "util"),
    // ];
    //
    // let include_paths : Vec<std::path::PathBuf> = include_paths_raw.into_iter().map(|path| {
    //     std::path::PathBuf::from(path.0)
    // }).collect();
    //
    //
    // let mut b = autocxx_build::Builder::new("src/lib.rs", &include_paths).build()?;
    //
    // b.flag("-std=c++2a").flag("-include=/Users/jrestivo/dev/nix/config.h ").compile("nix-bindings");
    //
    // println!("cargo:rerun-if-changed=src/lib.rs");
    //
    //
    // for (path, name) in &include_paths_raw[1..] {
    //     println!("cargo:rustc-link-search=native={path}");
    //     println!("cargo:rustc-link-lib=static={name}");
    // }
    //
    Ok(())
}
