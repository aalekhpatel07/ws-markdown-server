<script>
  import MarkdownToHtml from './lib/MarkdownToHtml.svelte'
  import { markdownText, connection } from './lib/stores';
  import { onMount, onDestroy } from "svelte";

  async function setupSocket(host="0.0.0.0", port=9003) {
    const socket = new WebSocket(`ws://${host}:${port}`);
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
