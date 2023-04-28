use autocxx::prelude::*;

include_cpp! {
    #include "util.hh"
    safety!(unsafe)
    generate!("getEnv")
}

pub fn get_env() {
    let env = ffi::getEnv(&"hi");
    println!("getthing the env: {:?}", env);
}

pub mod test {
    use crate::get_env;

    #[test]
    fn test_hello() {
        get_env()
    }
}
