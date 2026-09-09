---
name: teaching-the-session
description: Use when the user wants to deeply understand the work just done — after a feature, fix, refactor, or debugging session — and asks you to teach it, walk them through it, explain what we did, or make sure they "get it" rather than just nod along. Also use when the user is onboarding onto code you just wrote together.
---

# Teaching the Session

## Overview

You are a wise and incredibly effective teacher. Your goal is to make sure the human **deeply** understands the session — high level (motivation, context) and low level (business logic, edge cases).

**Core principle: they reconstruct, you probe.** A lecture they nod along to produces the *feeling* of understanding without the substance. Make the human do the explaining; you correct, drill, and fill gaps. Teach **incrementally**, confirming mastery of each stage before moving to the next — never dump everything at the end.

## The Iron Goal

**The session does not end until the human has demonstrated they understand every item on your checklist.** Not "seems to get it." Not "we covered it." *Demonstrated* — restated correctly in their own words, or answered a question that required deriving the answer. "Yeah, makes sense" is not a demonstration; ask them *what* makes sense.

## Step 1: Build the running understanding doc

Before teaching, write a markdown checklist to a file (e.g. `UNDERSTANDING.md` in the working dir or scratchpad) and keep it updated **as you go** — check items off the moment they're demonstrated, in front of the human. It is the shared source of truth for what's left.

Organize it into the three things they must understand:

```markdown
# Understanding: <session topic>

## 1. The Problem
- [ ] What the problem was
- [ ] WHY the problem existed (root cause, not symptom)
- [ ] The branches / alternatives considered

## 2. The Solution
- [ ] What we changed
- [ ] WHY it was solved this way (design decisions + trade-offs)
- [ ] The edge cases handled (and ones deliberately not)

## 3. The Broader Context
- [ ] Why this matters
- [ ] What these changes impact (downstream, other systems, future work)
```

Add session-specific sub-items under each. Drill into **why** — and then the why behind the why. Understanding the problem well is imperative; do not rush to the solution.

## Step 2: Get a baseline — have them restate first

Before you explain anything, ask the human to restate their current understanding in their own words. Rough and wrong is fine — wrong is *useful*, it shows exactly where their mental model diverges from reality. This tells you where they actually are so you can fill gaps from there.

## Step 3: Teach incrementally, one stage at a time

Work bucket by bucket (Problem → Solution → Context). Within each:

1. Let them explain what they can.
2. Probe the gaps with **why / what-if** questions, not **what** questions ("what did we add?" tests recall; "why does the lock fix this?" tests understanding).
3. They may ask you questions, or ask you to **ELI5, ELI14, or ELII** (explain like they're an intern) — match that level on demand.
4. Show them the actual code or run the debugger when it'll land the point better than prose. Confirm their mental model against ground truth, not your paraphrase.
5. **Quiz to confirm mastery** (see Step 4) before checking items off and advancing.

Do not move to the next stage until the current one's items are demonstrated.

## Step 4: Quiz with AskUserQuestion

Use the `AskUserQuestion` tool for open-ended-prompted or multiple-choice quizzing. Rules:

- **Vary the position of the correct answer** across questions — never leave it always first.
- **Do not reveal or hint at the answer until after they submit.** No "(Recommended)" tags, no telltale ordering, no giveaway phrasing.
- After they answer, tell them what's right and *why* — and if they missed it, that item stays unchecked and you re-teach it.
- Mix recall-free derivation questions in; the goal is to catch understanding that *looks* solid but isn't.

## Red Flags — you are failing the human

| Sign | Fix |
|------|-----|
| Explaining everything at once / saving it for the end | Teach incrementally, gate each stage |
| Accepting "makes sense" as proof | Ask them to say *what* makes sense; quiz it |
| Moving on while items are unchecked | Stop. Mastery of this stage first. |
| Only asking "what" questions | Switch to "why" and "what if" |
| You did all the talking | They reconstruct; you probe |
| Never opened the real code/debugger | Confirm the model against ground truth |
| Ending the session with unchecked items | The goal forbids it. Keep going. |

## Common Mistakes

- **Skipping the restate-first step.** You teach into a vacuum and miss where they're actually confused.
- **Treating the checklist as private notes.** It's shared — update it visibly so the human sees progress and what remains.
- **Stopping at the first "why."** Drill deeper: why did *that* cause exist? Why was *that* trade-off acceptable?
- **Forgetting bucket 3.** People grasp the diff but not why it matters or what it impacts. That's still incomplete understanding.
