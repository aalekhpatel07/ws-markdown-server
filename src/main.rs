use comrak::{markdown_to_html, ComrakOptions};
use tracing_subscriber;
use std::{sync::{Arc, Mutex}, net::SocketAddr};
use tracing::{
    trace,
    info, error
};
use tokio::net::{TcpListener, TcpStream};
use std::net::ToSocketAddrs;
use futures_util::{future, StreamExt, TryStreamExt, SinkExt};
use tokio_tungstenite::tungstenite::Result;


#[derive(Debug, Clone, Default)]
pub struct MarkdownEngine {
    pub options: ComrakOptions,
}

impl MarkdownEngine {
    pub fn new() -> Self {
        Self::default()
    }

    #[inline(always)]
    #[tracing::instrument]
    pub fn render(&self, md: &str) -> String {
        trace!(text_len = md.len(), "Rendering markdown...");
        markdown_to_html(md, &self.options)
    }

}


pub type SharedState<T> = Arc<Mutex<T>>;
pub type Engine = SharedState<MarkdownEngine>;


pub async fn accept_connection(stream: TcpStream, engine: Engine) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let addr = stream.peer_addr()?;
    if let Err(e) = handle_connection(addr, stream, engine).await {
        match e {
            tokio_tungstenite::tungstenite::Error::ConnectionClosed 
            | tokio_tungstenite::tungstenite::Error::AlreadyClosed
            | tokio_tungstenite::tungstenite::Error::Protocol(_)
            => {
                info!("Connection from {} closed", addr);
            }
            err => {
                error!("Error handling connection from {}: {}", addr, err);
            }
        }
    }
    Ok(())
}

pub async fn handle_connection(
    peer: SocketAddr, 
    stream: TcpStream,
    engine: Engine
) -> Result<()> {
    let mut ws_stream = tokio_tungstenite::accept_async(stream).await?;
    info!("Accepted connection from {}", peer);
    while let Some(msg) = ws_stream.next().await {
        let msg = msg?;
        trace!("Received message from {}: {:?}", peer, msg);
        if msg.is_text() || msg.is_binary() {
            trace!("Received text/binary message from {}: {:?}", peer, msg);
            let msg = msg.to_text()?;
            let outbound_msg = engine.lock().unwrap().render(msg);
            ws_stream.send(outbound_msg.into()).await?;
        }
    }
    Ok(())
}

pub async fn create_server<A: ToSocketAddrs>(addr: A, engine: Engine) -> Result<(), Box<dyn std::error::Error>> {
    let addr = addr.to_socket_addrs()?.next().unwrap();
    let listener = TcpListener::bind(&addr).await?;

    info!("Listening on {}", addr);
    while let Ok((stream, _)) = listener.accept().await {
        tokio::spawn(accept_connection(stream, engine.clone()));
    }
    Ok(())
}


#[tokio::main]
pub async fn main() {
    tracing_subscriber::fmt::init();
    let addr = "0.0.0.0:9003";
    let engine = Arc::new(Mutex::new(MarkdownEngine::new()));
    create_server(addr, engine).await.unwrap()
}