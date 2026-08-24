---
name: eli5
description: Re-explain the previous reply in this session as a simple, visual, self-contained HTML page. Reflects on the current session by default; an optional argument steers the focus.
disable-model-invocation: true
---

Re-explain what you just told the user, for someone smart but new to the topic.

## Input

- The subject is your own previous message in this session. If that message only makes sense in the light of the wider conversation, reflect on the whole session instead. Never ask the user what to explain.
- If the user passed an argument, treat it as steering (which part confused them, who the audience is, what to emphasize), not as a fresh topic.

## How to explain

1. Identify the audience's baseline knowledge from the session itself: the terms the user used confidently, the questions they asked, what they got stuck on. Pitch the explanation one level below that baseline.
2. Pick ONE central concept - the single idea most likely to be blocking understanding. Resist re-explaining everything; mention side details only if the main idea needs them.
3. Explain it through simple analogies rooted in everyday objects and situations. Introduce each technical term only after its analogy has done the work.

## Output

Produce a self-contained local HTML file (no external requests; inline all CSS/JS/SVG):

- Large visuals carry the explanation: big inline SVG diagrams, generous type, one idea per screen-height section.
- Minimal text: short sentences, captions under visuals, no walls of prose.
- End with a short "Check your understanding" section: 2-3 questions, each with the answer hidden behind a `<details>` element.

Save it in the current project under `.lavish/eli5/<short-slug>.html`. If the `lavish-axi` CLI is available, open the file with `lavish-axi <file>` so the user can review and annotate it; otherwise just give the user the file path. Never publish it to a hosted service.
