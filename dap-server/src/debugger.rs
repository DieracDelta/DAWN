use async_trait::async_trait;
use atomic_enum::atomic_enum;
use tokio::io::{Stdin, Stdout};

use debug_types::{
    events::{Event, EventBody},
    requests::RequestCommand,
    responses::Response,
    MessageKind, ProtocolMessage,
};
use futures::{SinkExt, StreamExt};
use tokio_util::codec::{FramedRead, FramedWrite};

use either::Either;
use tracing::error;

use crate::codec::DebugAdapterCodec;

/// A list of possible states the adapter can be in.
#[atomic_enum]
#[derive(PartialEq, PartialOrd)]
pub enum State {
    /// Server has not received an `initialize` request.
    Uninitialized = 0,
    /// Server received an `initialize` request, but has not yet responded.
    Initializing = 1,
    /// Server received and responded success to an `initialize` request.
    Initialized = 2,
    /// Server received a `shutdown` request.
    ShutDown = 3,
    /// Server received an `exit` notification.
    Exited = 4,
}

pub struct Client {
    state: State,
    send_seq: i64,
    reader: FramedRead<Stdin, DebugAdapterCodec<ProtocolMessage>>,
    writer: FramedWrite<Stdout, DebugAdapterCodec<ProtocolMessage>>,
}

impl Client {
    pub fn new(
        reader: FramedRead<Stdin, DebugAdapterCodec<ProtocolMessage>>,
        writer: FramedWrite<Stdout, DebugAdapterCodec<ProtocolMessage>>,
    ) -> Self {
        Self {
            state: State::Uninitialized,
            send_seq: 0,
            reader,
            writer,
        }
    }

    pub fn set_state(&mut self, state: State) {
        if state > self.state {
            self.state = state;
        } else {
            error!("regressed somehow from {:?} to {:?}", self.state, state)
        }
    }

    pub fn get_state(&self) -> State {
        self.state
    }

    /// send event to client (only possible way)
    pub async fn send(&mut self, body: Either<EventBody, Response>) {
        let message = match body {
            Either::Left(event_body) => MessageKind::Event(Event {
                body: Some(event_body),
            }),
            Either::Right(response_body) => MessageKind::Response(response_body),
        };

        let message = ProtocolMessage {
            seq: self.send_seq,
            message,
        };

        if let Err(e) = self.writer.send(message).await {
            // TODO should this be panic?
            error!("Error sending response{e}");
        }
        self.send_seq += 1;
    }

    pub async fn next_msg(&mut self) -> ProtocolMessage {
        loop {
            if let Some(msg) = self.reader.next().await {
                match msg {
                    Ok(r) => {
                        return r;
                    }
                    Err(e) => {
                        error!("Error parsing message: {e:?}");
                    }
                }
            }
        }
    }
}

#[async_trait]
pub trait DebugAdapter {
    async fn handle_request(&mut self, seq: i64, command: RequestCommand);
}
