# Step 1.5: Unified API Design (Pre-ADT Planning)

**Status:** ✅ Complete  
**Priority:** Must be completed BEFORE Step 2 (Unison ADTs)

## Motivation

The Unison type system must serve a **simplified, unified API** so an LLM/OpenClaw can access the full knowledge base — including inference rules — as easily as it accesses a SQL or Graphiti memory layer. Every ADT must be shaped to serve this API.

**Key insight:** Unison stores code as content-addressed objects in a database. This means inference rules are not separate "code" — they are **first-class knowledge objects** queryable, editable, and runnable through the same API as facts and memories. The memory IS becoming a symbolic AI.

---

## Reference: How Models Access Memory Today

### openclaw-memory-offline-sqlite (MCP Tools)

The SQLite memory extension exposes **15 MCP tools** in 3 categories via `@modelcontextprotocol/sdk`. Each tool takes JSON params (validated with Zod schemas) and returns JSON.

**Memory tools** (raw text storage + search):
| Tool | Params | Purpose |
|------|--------|---------|
| `memory_store` | `text, title?, tags?, entity_id?, session_id?` | Store text with attribution |
| `memory_recall` | `query, limit?, entity_id?, session_id?` | FTS5 full-text search + filters |
| `memory_list_entities` | — | List all entity IDs |
| `memory_list_sessions` | — | List all session IDs |
| `memory_get_by_entity` | `entity_id, limit?` | All memories from entity |
| `memory_get_by_session` | `session_id, limit?` | All memories from session |

**Fact tools** (structured subject-predicate-object triples):
| Tool | Params | Purpose |
|------|--------|---------|
| `fact_add` | `subject, predicate, object, confidence?, entity_id?` | Add a triple |
| `fact_search` | `query, limit?` | Search facts by text |
| `fact_get_by_subject` | `subject, limit?` | Facts about a subject |
| `fact_list` | `entity_id?, limit?` | List all facts |
| `fact_delete` | `id` | Delete a fact |
| `fact_list_subjects` | — | List all subjects |
| `fact_list_predicates` | — | List all predicates |

**Graph tools** (KG traversal):
| Tool | Params | Purpose |
|------|--------|---------|
| `graph_stats` | — | Node/edge counts, relation types |
| `graph_entity` | `entity` | All facts connected to entity |
| `graph_related` | `entity` | Entities directly connected |
| `graph_path` | `from, to, max_depth?, max_paths?` | Find paths between entities |
| `graph_export` | `entity?, min_confidence?, limit?` | Export subgraph as JSON |

### openclaw-graphiti-memory (Shell Scripts + HTTP)

Graphiti uses shell scripts that POST JSON to a Graphiti HTTP API:
| Script | Purpose |
|--------|---------|
| `graphiti-search.sh "query" [group_id] [max]` | Search temporal facts |
| `graphiti-log.sh <agent_id> <role> <name> "content"` | Log facts to own group |
| `graphiti-context.sh "task" [agent_id]` | Get full context (cross-group + user + system) |
| `memory-hybrid-search.sh "query" [group_id]` | Search both QMD + Graphiti in parallel |

**SKILL.md** teaches the model a 'Recall Pattern': user asks → hybrid search → synthesize answer.

**3-layer model:**
1. Private files (agent's own `memory/` dir, QMD vector search)
2. Shared files (symlinked read-only docs: user-profile, agent-roster, infrastructure)
3. Shared KG (Graphiti temporal facts, group ownership: agents write own group, read all)

---

## BrainyML Unified API: 4 Categories

We follow the same MCP tool pattern but add a **4th category: Rules** — because Unison makes code = data.

### Category 1: Memory (raw text, as in SQLite memory)
| Tool | Params | Purpose |
|------|--------|---------|
| `memory_store` | `text, context?, entity_id?, session_id?` | Store text with attribution |
| `memory_recall` | `query, context?, limit?, filters?` | Search memories |
| `memory_list` | `context?, entity_id?` | List memories |

### Category 2: Facts (structured triples, as in SQLite facts)
| Tool | Params | Purpose |
|------|--------|---------|
| `fact_assert` | `subject, predicate, object, context?, confidence?` | Assert a fact |
| `fact_retract` | `id` | Retract a fact (with truth maintenance) |
| `fact_search` | `query, context?, limit?` | Search facts |
| `fact_get` | `subject?, predicate?, object?` | Get by pattern |
| `fact_list_subjects` | `context?` | List subjects |
| `fact_list_predicates` | `context?` | List predicates |
| `fact_explain` | `id` | Provenance: where did this fact come from? |

### Category 3: Graph (KG traversal, as in SQLite graph + Graphiti)
| Tool | Params | Purpose |
|------|--------|---------|
| `graph_related` | `entity, context?` | Find connected entities |
| `graph_path` | `from, to, max_depth?` | Find paths between entities |
| `graph_context` | `task_description, agent_id?` | Full context for a task (like graphiti-context) |
| `graph_stats` | `context?` | Node/edge/relation counts |

### Category 4: Rules (UNIQUE TO BRAINYML — Unison code-as-data)
| Tool | Params | Purpose |
|------|--------|---------|
| `rule_add` | `name, description, rule_code, context?` | Add an inference rule |
| `rule_list` | `context?` | List all active rules |
| `rule_get` | `name` | Get rule details + code |
| `rule_run` | `name, inputs?` | Execute a rule and return results |
| `rule_delete` | `name` | Deactivate a rule |
| `rule_infer` | `goal, strategy?` | Trigger inference (auto/nars/axiomatic) |
| `rule_explain` | `derivation_id` | Full derivation chain for a result |

**Why this works:** In Unison, a function `Fact -> KnowledgeGraph -> KnowledgeGraph` is a content-addressed hash. The model can `rule_add` a new inference rule by providing its Unison code, and `rule_run` it later. Rules are stored alongside facts in the same Atomspace — they're just Atoms that happen to be executable.

### Code-as-Data Mechanism (GroundedValue → GUnisonHash)

The bridge between "Atom" and "executable code" is Unison's content-addressed hash:

```
-- In the Atom ADT:
unique type GroundedValue = GText Text | GFloat Float | GInt Int | GBool Boolean
                         | GBlob Bytes | GUnisonHash Hash  -- ← Unison function hash

-- An inference rule stored as an Atom:
ruleAtom = GroundedAtom (GUnisonHash #abc123def)
-- where #abc123def is the SHA3 hash of a Unison function like:
--   inferTransitivity : Fact -> KnowledgeGraph -> [Fact]
```

**Evaluation chain:**
1. Model calls `rule_run "transitivity" {"subject": "Socrates"}`
2. API looks up rule name → finds `GroundedAtom (GUnisonHash #abc123def)`
3. UCM evaluates `#abc123def` with inputs (via `ucm run`, transcript, or UCM's local web server API at configurable port/token)
4. Results (new Facts) flow back into the Atomspace

**Key property**: The model can `rule_add` new Unison code → UCM compiles it → gets a hash → stored as a `GUnisonHash` Atom → queryable and runnable like any other Atom. This is analogous to MeTTa/OpenCog where programs ARE Atomspace subgraphs, but using Unison's type system instead of MeTTa's rewrite semantics.

---

## Context System (from CycL Microtheories + Graphiti Groups)

Every operation takes an optional `context` parameter. Contexts organize knowledge:

| Context Pattern | Maps To | Example |
|-----------------|---------|---------|
| `common-sense` | NELL + CSKG shared knowledge | "dogs are animals" |
| `agent-{id}` | Agent's private group (Graphiti `clawdbot-<id>`) | Agent's discoveries |
| `user-{id}` | User profile/preferences (Graphiti `user-main`) | "User prefers dark mode" |
| `system` | Infrastructure/roster (Graphiti `system-shared`) | Active services |
| `session-{id}` | Session-scoped (SQLite `session_id`) | Current conversation |
| `domain-{name}` | Domain-specific theory (CycL microtheory) | Medical, legal, etc. |

Contexts form a **hierarchy**: querying `common-sense` also searches sub-contexts. Writing requires specifying context.

---

## How This Shapes the ADTs (Constraints for Step 2)

Every Unison type created in Step 2 must satisfy:

1. **Context field**: Every fact, memory, rule has a `context : Context`
2. **Provenance**: Every item has `provenance : Provenance` tracking origin (source dataset, extraction, inference, user input)
3. **Canonical form**: Every type has `toAtom : X -> Atom` so all knowledge is interoperable at the Atomspace level
4. **Rules = Atoms**: Inference rules are stored AS Atoms in the AtomSpace, not in a separate system. They're queryable and modifiable through the same graph API
5. **Truth coexistence**: NARS TruthValue (frequency, confidence) must coexist with classical Boolean truth and confidence-only values from NELL/CSKG

## AI Instruction
When implementing Step 2, create an `unison/api/` module that wraps internal ADTs behind these tool signatures. The API module is the ONLY public interface — internal types are implementation details.

## Next
Proceed to `docs/steps/step2-unison-types.md` with these API constraints in mind.
