# Markdown server

A simple Markdown Websocket (and Unix socket) server backed by [`comrak`](https://docs.rs/comrak/latest/comrak/) and [`tokio-tungstenite`](https://github.com/snapview/tokio-tungstenite).

## Installation and Usage

### Docker (recommended):

1. Download the docker image.
```sh
docker pull aalekhpatel07/ws-markdown-server:1.0.2
```

2. Start the container:

**Note**: The `9004` tcp port bind is optional and only required if you wish to expose a Unix socket server along with a WebSocket server (which runs on `9003`).

```sh
docker run \
  -d \
  -p 9003:9003 \
  -p 9004:9004 \
  --name ws-markdown-server \
  aalekhpatel07/ws-markdown-server:1.0.0
```

### Local

You can run a Markdown server on your local machine via `ws-markdown-server`:

1. Install it with `cargo`:
```sh
cargo install ws-markdown-server@1.0.2
```
2. Start the server:
```sh
RUST_LOG="ws_markdown_server=debug" \
    MD_SERVER_WS_PORT=9003 \
    MD_SERVER_TCP_PORT=9004 \
    MD_SERVER_HOST="0.0.0.0" \
    ws-markdown-server
```

## Testing it works

1. You can test it works by opening a tcp connection at `0.0.0.0:9004` and sending in some markdown text to be converted to html. 
For example:

```sh
# Start netcat once the markdown server is up and running.
nc 0.0.0.0 9004
  
# Send some markdown text to be converted to html.

> # Title
> This is some text.
> ...
> [Ctrl+D] (indicates end of file)
  
# You'll receive the html version of the sent markdown:

# <h1> Title </h1>
# <p>This is some text.</p>
# ...
```

2. Alternatively, you can also run the sample [`Svelte` app](./usage/client) that sets up the client-side Websocket and uses the `ws-markdown-server` for its backend.

```sh
cd usage/client
npm install
npm run dev -- --port 8000 --host 0.0.0.0 --open
```
