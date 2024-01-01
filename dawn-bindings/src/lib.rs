pub struct Context {}

#[no_mangle]
pub extern "C" fn initialize_plugin() -> *mut Context {
    println!("We initialized debugging context");
    Box::into_raw(Box::new(Context {}))
}

/// SAFETY:
/// The invariant that "cx" is exclusively available here is maintained by the
/// other side of the FFI. Beware.
#[no_mangle]
pub extern "C" fn deinitialize_plugin(_cx: &mut Context) {
    println!("HELLO WORLD FROM RUST!\n");
}
