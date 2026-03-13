# Step 4: OpenClaw Integration

**Status:** ⬜ Not started

## Tasks

### 4a. Skill manifest (`skill/SKILL.md`)
Create the OpenClaw skill definition file:
```yaml
---
name: brainyml-memory
description: Unified symbolic memory layer with KG, NARS, and axiomatic reasoning
---
```
Instructions for agents to query the knowledge graph, add facts, and trigger inference.

### 4b. Agent instructions (`_agents/AGENTS.md`)
Define how OpenClaw agents interact with the memory layer:
- How to query facts
- How to add new memories
- How to trigger NARS inference cycles
- How to use axiomatic proofs

### 4c. Shared files (`shared-files/`)
- `knowledge-graph.md` – Summary of the KG for agent context
- `inference-rules.md` – Active inference rules reference

### 4d. Wire KG query API
Connect the Unison UnifiedMemory query API as the backend for OpenClaw memory operations.

## Verification
- Agents should be able to call memory search and get results
- Shared files should be accessible and contain accurate KG summaries

## Next
Proceed to `docs/steps/step5-future.md`.
