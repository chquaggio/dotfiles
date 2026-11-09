---
name: issue-tracker
description: "House conventions for the issue tracker (GitHub, Linear, Jira and the like): issue shape, comment language, closing, labels. Use before creating, editing, commenting on, labelling or closing an issue, or drafting one for the user to file. Not for the proposed issues in an end-of-task report, which AGENTS.md covers."
---

# issue-tracker

- The tracker holds tasks; documentation holds knowledge. An issue reads at a glance:
  imperative title; why it matters; an acceptance criterion the agent can check; what is
  out of scope; a link to the spec or ADR that carries the detail.
- Comments: as short as the point allows, in the language of the repo's user-facing docs.
- After a fix, draft the closing comment saying how it was verified; posting and closing
  are the user's call.
- Labels: mattpocock's triage vocabulary where the repo's labels already include it;
  elsewhere `bug`, `feat`, `debt`, `idea`.

Done when the issue or comment carries every element above that applies to it, and
nothing was posted or closed without the user's go-ahead.
