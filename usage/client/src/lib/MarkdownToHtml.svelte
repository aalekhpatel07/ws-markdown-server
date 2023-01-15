<script>
    import { connection } from "./stores";
    import { onMount } from "svelte";

    export let text;

    let htmlText;
    let resultDiv = null;
    let textArea = null;

    const TAB_OUTPUT = "  ";

    connection.subscribe((socket) => {
        if (!socket) return;

        socket.onmessage = (event) => {
            htmlText = event.data;
            if (resultDiv) {
                resultDiv.innerHTML = event.data;
            }
        };
        socket.onopen = () => {
            socket.send(text);
        };
    });
    
    $: {
        connection.subscribe((socket) => {
            if (!socket) return;
            try {
                socket.send(text);
            } catch (e) {
                // console.log(e);
            }
        });
    }

    onMount(() => {
        textArea.addEventListener("keydown", (/** @type {{ key: string; preventDefault: () => void; }} */ event) => {
            if (event.key === "Tab") {
                event.preventDefault();
                textArea.setRangeText(
                    TAB_OUTPUT,
                    textArea.selectionStart,
                    textArea.selectionEnd,
                    "end"
                );
            }
        });
    });

</script>
<style scoped>
    .markdown-layout {
        display: flex;
        flex-direction: col;
        justify-content: space-between;
        gap: 1rem;
    }
    .markdown {
        font-family: monospace;
        font-size: 1.2rem;
    }
    .w-full {
        width: 100%;
    }
</style>
<h1> Markdown to HTML </h1>
<div class="markdown-layout">
    <div class="w-full">
        <textarea 
            class="markdown"
            rows="10" 
            cols="100"    
            bind:value={text}
            bind:this={textArea}
        ></textarea>
    </div>
    <div class="w-full">
        <div style="border: 1px solid black;" class="w-full">
            <p>{htmlText}</p>
        </div>
    </div>
</div>
<div class="w-full" style="border: 1px solid black;">
    <div bind:this={resultDiv}></div>
</div>