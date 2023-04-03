use autocxx::prelude::*;

include_cpp! {
    #include "hello.hpp"
    safety!(unsafe)
    generate!("hello")
}

pub fn call_hello() {
    println!("...and the result is: {:?}", ffi::hello())
}

pub mod test {
    use crate::call_hello;

    #[test]
    fn test_hello() {
        call_hello()
    }
}
