import { readable, writable } from "svelte/store";

export const markdownText = writable(`# This is a title.
This is some example text that comes before the subtitle.
## This is a subtitle
This is some example text that comes after the subtitle.
---
Here's a list
- item 1
- [item 2](https://www.google.com)`);
export const connection = writable(null);
