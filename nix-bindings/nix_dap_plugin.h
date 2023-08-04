#include <cstdarg>
#include <cstdint>
#include <cstdlib>
#include <ostream>
#include <new>

struct Context;

extern "C" {

Context *initialize_plugin();

/// SAFETY:
/// The invariant that "cx" is exclusively available here is maintained by the
/// other side of the FFI. Beware.
void deinitialize_plugin(Context *cx);

} // extern "C"
