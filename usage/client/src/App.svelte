<script>
  import MarkdownToHtml from './lib/MarkdownToHtml.svelte'
  import { markdownText, connection } from './lib/stores';
  import { onMount, onDestroy } from "svelte";

  const DEFAULT_WEBSOCKET_URL = `0.0.0.0:9003`;
  const WEBSOCKET_URL = import.meta.env.PROD ? import.meta.env.VITE_MD_SERVER_URL : DEFAULT_WEBSOCKET_URL;

  async function setupSocket(
    protocol=import.meta.env.PROD ? "wss": "ws", 
    ws_url = WEBSOCKET_URL
  ) {
    const socket = new WebSocket(`${protocol}://${ws_url}/`);
    connection.set(socket);
  }

  onMount(async () => {
    await setupSocket();
  });
  onDestroy(() => {
    connection.set(null);
  });

</script>

<main>
  <div class="card">
    <MarkdownToHtml bind:text={$markdownText}/>
  </div>
</main>
