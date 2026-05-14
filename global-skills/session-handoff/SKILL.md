---
name: session-handoff
description: Use when the user says "session handoff", "wrap up session", "hand off", "handoff summary", or wants a structured end-of-session summary before clearing context. Produces a chat-only, single-fenced-block handoff with explicit copy markers covering decisions, shipped changes, key files, running state, verification steps, deferrals, dead-ends tried, tone reminders, and explicit first-action steps so a fresh agent can continue seamlessly after /clear.
---

# Session Handoff

Produce a repeatable end-of-session summary so the user can `/clear` and start a fresh agent without losing continuity. The next agent should be able to pick up by reading this summary alone.

This is a **context-handoff artifact**, not a status report. The audience is a future instance of you, not a stakeholder. The user is going to copy the handoff out of this chat and paste it into a fresh Claude session, so the output must be unambiguous about where to copy from and to.

## When to invoke

User says: "session handoff", "wrap up session", "hand off", "handoff summary", "let's wrap up", "summarize before I clear", or any near-equivalent. Also invoke proactively if the user says they're about to `/clear` without having run it yet.

## How to produce the summary

1. **Review the full conversation**, not just the last few turns. Handoffs miss things when they only summarize recent context.
2. **Pull state from these sources (in order):**
   - Plan files referenced this session (check `C:\Users\tiago\.claude\plans\` if a plan was mentioned).
   - TodoWrite state — any in-progress or pending tasks.
   - Background processes you started with `run_in_background` — shell IDs are load-bearing for the next agent.
   - Files created or modified this session — you know what you touched; don't grep to re-discover.
   - Memory files written or updated (`C:\Users\tiago\.claude\projects\<project>\memory\`).
   - Project CLAUDE.md — pull tone/communication preferences for the "Tone for this user" section.
   - Unresolved questions — things you asked the user that never got a clear answer, or things the user asked that got deflected.
   - Dead-ends — approaches you tried that didn't work, or were ruled out partway through.
3. **Do NOT audit the filesystem.** This is synthesis of what happened in THIS session. No `git log`, no broad `Glob` sweeps. If you didn't touch it this session, it doesn't belong here.
4. **Output is a single fenced code block in chat, nothing else.** No preamble. No "Here's your handoff:". No closing remarks. The user clicks the chat UI's copy button on the block, or selects between the explicit BEGIN/END markers inside it. Any text you write outside the block is text the user has to manually exclude — don't make them do that.
5. **Do not write to a file. Do not update memory.** Chat-only, fenced-block-only.

## Output template — use exactly this structure, every time

The ENTIRE output is the fenced block below. Nothing before it. Nothing after it.

```
>>> COPY EVERYTHING IN THIS BLOCK — PASTE INTO YOUR NEW CLAUDE SESSION AFTER /clear <<<

# Session Handoff — <one-line title of what this session was about>

## For the next Claude (read this first)

You are a fresh Claude session. The user just ran `/clear`. Everything above this in your context is gone — this document is your only memory of the previous session. Read it fully before acting. The user (Tiago) expects you to pick up exactly where the last session left off; check the "First action" section at the bottom for what to do in the first five minutes.

## Where it started

<2-3 sentences: what the user asked for, key framing or constraints that emerged>

## Why this matters

<1-2 sentences: the bigger goal or project phase this work fits into. For Aevum: which phase (1 research / 2 paper trading / 3 IBKR live / etc.) and what the broader objective is. Skip if genuinely unclear, but try.>

## Tone for this user

<Mirror the project CLAUDE.md tone guidance. For Aevum: "Tiago is a beginner trader. Explain finance terms in one line when used. Use BEST/NOT-RECOMMENDED labels with reasons, never neutral menus. Short plain-English sentences, no walls of text." Write "see project CLAUDE.md" if the project doesn't have specific guidance.>

## Decisions locked + what shipped

- <decision or change> — <why, and where it lives (absolute path if a file)>
- ...

## Key files for next session

- `<absolute path>` — <why the next agent should read this first>
- Plan file: `<path>` (if a plan drove the session — name it FIRST)
- Memory files touched: `<paths>` (if any)

## Running state

- Background processes: <shell IDs + what they are + how to kill> — or "none"
- Dev servers / ports: <url + port> — or "none"
- Open worktrees / branches: <paths> — or "none"

## Verification — how to confirm things still work

- `<command>` — <expected outcome>
- ...

## Tried and didn't work (dead-ends to skip)

- <approach attempted> — <why it failed or was ruled out>
- ... or "none"

## Deferred + open questions

- Deferred: <item> — <why pushed to later>
- Open: <question needing the user's input> — <context>

## First action (do these in order)

1. <Read which file end-to-end, e.g., "Read `C:\Users\tiago\.claude\plans\foo.md`">
2. <Run which command to confirm state, e.g., "Run `pytest packages/core` — should be green">
3. <Ask user which question if any, e.g., "Confirm with user whether to proceed with X or Y before any code changes">

>>> END OF HANDOFF <<<
```

## Hard rules

1. **Single fenced code block, nothing else.** Output starts with the opening fence and ends with the closing fence. No preamble (no "Here's your handoff:"). No closing line (no "Let me know if you'd like changes"). The user copies the block — anything outside it is friction.
2. **Never write the handoff to a file. Never update memory from this skill.**
3. **Never invent state.** If a section has nothing to report, write "none" — do not omit the section. Structure stability is the whole point.
4. **Absolute paths always.** The next agent may have a different working directory.
5. **If a plan file drove the session, name it first** in "Key files" so the next agent reads it before anything else.
6. **No emojis, no hype, no "great job" summaries.** Terse and concrete — paths, commands, shell IDs, decisions. Match the tone of a seasoned engineer handing off at end-of-shift.
7. **Background process IDs are critical.** If you started any `run_in_background` shells, their IDs must appear in "Running state" with the kill command — the next agent cannot find them otherwise.
8. **The two markers (`>>> COPY EVERYTHING IN THIS BLOCK <<<` and `>>> END OF HANDOFF <<<`) are mandatory and verbatim.** They are the user's belt-and-suspenders for "what do I copy?" — even if they ignore the chat UI copy button and select manually, the markers tell them exactly where to start and stop.

## Anti-patterns — do not do these

- Summarizing the last 3 turns and calling it a handoff.
- Listing files by relative path.
- Skipping the "Running state" section because "nothing is running" — write "none" instead.
- Writing the summary to `~/.claude/handoffs/` or any file. This is chat-only by design.
- Adding a "what went well / what went poorly" retrospective. This isn't a retro.
- Writing prose before or after the fenced block ("Here's your handoff:" / "Hope this helps!"). This is the #1 thing the user wants to stop seeing — the block is the whole output.
- Using only one of the two copy markers. Both top and bottom must be present, verbatim.
- Cramming "First action" into a single line. Three numbered steps minimum, each with a concrete file/command/question.
