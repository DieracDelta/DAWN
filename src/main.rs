use codec::DebugAdapterCodec;
use debug_types::ProtocolMessage;
use debugger::{Client, DebugAdapter};
use nix_debugger::{NixDebugAdapter, NixDebugState};
// use debugger::{APState};
use tokio_util::codec::{FramedRead, FramedWrite};
use tracing::error;
pub mod codec;
pub mod debugger;
pub mod nix_debugger;
pub mod service;

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

    loop {
        let msg = debugger.client.next_msg().await;
        use debug_types::MessageKind::*;
        match msg.message {
            Request(request) => debugger.handle_request(msg.seq, request).await,
            Response(response) => {
                error!("Received response {response:?}. Shouldn't be possible!")
            }
            Event(e) => error!("Received event {e:?}. Shouldn't be possible!"),
        }
        // debugger.handle_msg(msg).await;
    }
    //     error!("received message {:?}", msg);
    //     match msg {
    //         Ok(msg) => {
    //             use debug_types::MessageKind::*;
    //             let requires_followup =
    //                 match msg.message {
    //                     Request(command) => {
    //                         self.handle_request(msg.seq, command).await
    //                     }
    //                     Response(response) => {
    //                         self.handle_response(msg.seq, response).await;
    //                         false
    //                     }
    //                     Event(event) => {
    //                         self.handle_event(msg.seq, event).await;
    //                         false
    //                     }
    //                 };
    //             return Ok(requires_followup);
    //         }
    //         Err(e) => return Err(e),
    //     }

    // let mut debugger = Debugger::<DebuggerState>::new(reader, writer).await;
    // debugger.init().await.unwrap();
}
