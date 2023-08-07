#![warn(
    clippy::all,
    clippy::pedantic,
    rust_2018_idioms,
    missing_docs,
    clippy::missing_docs_in_private_items,
    clippy::panic
)]
#![allow(clippy::unused_async, clippy::module_name_repetitions)]
//! nix debugger implementation

use dawn_infra::codec::DebugAdapterCodec;
use dawn_infra::debugger::{Client, DebugAdapter, State};
use debug_types::ProtocolMessage;
use nix_debugger::{NixDebugAdapter, NixDebugState};
use tokio_util::codec::{FramedRead, FramedWrite};
use tracing::error;
///! debugger
pub mod nix_debugger;

#[tokio::main(flavor = "multi_thread", worker_threads = 10)]
async fn main() {
    let writer = std::fs::File::create("./LOGLOG").unwrap();
    tracing_subscriber::fmt().with_writer(writer).init();

    let stdin = tokio::io::stdin();
    let stdout = tokio::io::stdout();

    let reader = FramedRead::new(stdin, DebugAdapterCodec::<ProtocolMessage>::default());
    let writer = FramedWrite::new(stdout, DebugAdapterCodec::<ProtocolMessage>::default());

    let client = Client::new(reader, writer);

    let mut debugger = NixDebugAdapter {
        client,
        state: NixDebugState::default(),
    };

    while debugger.client.get_state() < State::ShutDown {
        use debug_types::MessageKind::{Event, Request, Response};
        let msg = debugger.client.next_msg().await;
        match msg.message {
            Request(request) => debugger.handle_request(msg.seq, request).await,
            Response(response) => {
                error!("Received response {response:?}. Shouldn't be possible!");
            }
            Event(e) => error!("Received event {e:?}. Shouldn't be possible!"),
        }
        // debugger.handle_msg(msg).await;
    }
}
