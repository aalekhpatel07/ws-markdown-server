<script>
  import MarkdownToHtml from './lib/MarkdownToHtml.svelte'
  import { markdownText, connection } from './lib/stores';
  import { onMount, onDestroy } from "svelte";

  const DEFAULT_WEBSOCKET_URL = "ws://0.0.0.0:9003";
  const WEBSOCKET_URL = import.meta.env.DEV ? DEFAULT_WEBSOCKET_URL : import.meta.env.VITE_MD_SERVER_URL;

  async function setupSocket(ws_url = WEBSOCKET_URL) {
    const socket = new WebSocket(ws_url);
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
