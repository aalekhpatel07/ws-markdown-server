use clap::Parser;
use comrak::{markdown_to_html, ComrakOptions};
use futures_util::{SinkExt, StreamExt};
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio_tungstenite::WebSocketStream;


use std::net::ToSocketAddrs;
use std::{
    net::SocketAddr,
    sync::{Arc, Mutex},
};
use tokio::net::{TcpListener, TcpStream};
use tokio_tungstenite::tungstenite::Result;
use tracing::{error, info, trace, debug};


#[derive(Parser, Debug, Clone)]
#[clap(
    author="Aalekh Patel <aalekh.gwpeck.7998@icloud.com>", 
    about="A simple markdown-to-html websocket server backed by comrak and tokio-tungstenite.", 
    version="1.0.0",
)]

pub struct Opts {
    #[clap(short, long, default_value = "0.0.0.0", env = "MD_SERVER_HOST")]
    pub host: String,
    #[clap(short, long, default_value_t = 9093, env = "MD_SERVER_WS_PORT")]
    pub ws_port: u16,
    #[clap(short, long, default_value = None, env = "MD_SERVER_TCP_PORT")]
    pub port: Option<u16>,
}

#[derive(Debug, Clone, Default)]
pub struct MarkdownEngine {
    pub options: ComrakOptions,
}

impl MarkdownEngine {
    pub fn new() -> Self {
        Self::default()
    }

    #[inline(always)]
    #[tracing::instrument(level = "trace", skip(self))]
    pub fn render(&self, md: &str) -> String {
        debug!(text_len = md.len(), "Rendering markdown...");
        markdown_to_html(md, &self.options)
    }
}

pub type SharedState<T> = Arc<Mutex<T>>;
pub type Engine = SharedState<MarkdownEngine>;

pub async fn accept_ws_connection(
    stream: TcpStream,
    engine: Engine,
) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let addr = stream.peer_addr()?;
    let ws_stream = tokio_tungstenite::accept_async(stream).await?;
    debug!("Accepted WS connection from {}", addr);

    if let Err(e) = handle_ws_connection(addr, ws_stream, engine).await {
        match e {
            tokio_tungstenite::tungstenite::Error::ConnectionClosed
            | tokio_tungstenite::tungstenite::Error::AlreadyClosed
            | tokio_tungstenite::tungstenite::Error::Protocol(_) => {
                info!("Connection from {} closed", addr);
            }
            err => {
                error!("Error handling connection from {}: {}", addr, err);
            }
        }
    }
    Ok(())
}

pub async fn accept_socket_connection(
    stream: TcpStream,
    engine: Engine,
) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let addr = stream.peer_addr()?;
    debug!("Accepted WS connection from {}", addr);

    if let Err(e) = handle_socket_connection(addr, stream, engine).await {
        error!("Error handling connection from {}: {}", addr, e);
    }
    Ok(())
}


pub async fn handle_ws_connection(peer: SocketAddr, mut ws_stream: WebSocketStream<TcpStream>, engine: Engine) -> Result<()> {
    while let Some(msg) = ws_stream.next().await {
        let msg = msg?;
        if msg.is_text() || msg.is_binary() {
            trace!("Received text/binary message from {}: {:?}", peer, msg);
            let msg = msg.to_text()?;
            let outbound_msg = engine.lock().unwrap().render(msg);
            ws_stream.send(outbound_msg.into()).await?;
        }
    }
    Ok(())
}

pub async fn handle_socket_connection(peer: SocketAddr, mut stream: TcpStream, engine: Engine) -> Result<()> {
    debug!("Accepted TcpStream from {}", peer);
    let (mut read_half, mut write_half) = stream.split();
    loop {
        let mut buf = String::new();
        let n = read_half.read_to_string(&mut buf).await?;
        if n == 0 {
            return Ok(());
        }
        let outbound_msg = engine.lock().unwrap().render(&buf);
        write_half.write_all(outbound_msg.as_bytes()).await?;
    }
}

pub async fn create_ws_server<A: ToSocketAddrs>(
    addr: A,
    engine: Engine,
) -> Result<(), Box<dyn std::error::Error>> {

    let addr = addr.to_socket_addrs()?.next().unwrap();
    let listener = TcpListener::bind(&addr).await?;
    info!("Listening for WebSocket connections on {}", addr);

    while let Ok((stream, _)) = listener.accept().await {
        tokio::spawn(accept_ws_connection(stream, engine.clone()));
    }
    Ok(())
}


pub async fn create_tcp_server<A: ToSocketAddrs>(
    addr: A,
    engine: Engine,
) -> Result<(), Box<dyn std::error::Error>> {

    let addr = addr.to_socket_addrs()?.next().unwrap();
    let listener = TcpListener::bind(&addr).await?;
    info!("Listening for TCP (Unix) socket connections on {}", addr);

    while let Ok((stream, _)) = listener.accept().await {
        tokio::spawn(accept_socket_connection(stream, engine.clone()));
    }
    Ok(())
}

#[tokio::main]
pub async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let opts = Opts::parse();
    tracing_subscriber::fmt::init();
    let engine = Arc::new(Mutex::new(MarkdownEngine::new()));
    let ws_addr = format!("{}:{}", opts.host, opts.ws_port);

    let task1 = create_ws_server(ws_addr, engine.clone());

    let task2 = opts.port.map(|port| {
        let addr = format!("{}:{}", opts.host, port);
        create_tcp_server(addr, engine.clone())
    });

    if let Some(task2) = task2 {
        _ = tokio::join!(task1, task2);
    } else {
        task1.await?;
    }
    Ok(())
}
