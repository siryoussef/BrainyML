# BrainyML — AI Planning Prompt (v2, codebase-aware)
## Annotated modification suggestions for completing the symbolic AGI memory layer

---

## YOUR ROLE

You are an expert in:
- Unison (the content-addressed functional language — NOT the sync tool)
- Symbolic AI: knowledge graphs, inference engines, probabilistic logic
- NARS (Non-Axiomatic Reasoning System), PLN, ECAN cognitive architectures
- OpenClaw agent memory integration

You will read the existing codebase carefully, then produce **annotated modification
suggestions**: for each suggestion, state exactly which existing file and function
it applies to, what to add or change, why it is needed, and how it connects to
other suggestions. Do NOT rewrite the whole codebase. Annotate and extend what exists.
Respect the existing namespace structure and phase plan in README.md.

---

## PROJECT CONTEXT

**Project:** BrainyML — a Unison-native symbolic AI substrate for the OpenClaw agent.
**Phase status:** Phases 0–2 complete. Phase 3 (Python parsers) not started.
**Current goal:** Harden Phase 2 types and fill in the placeholder implementations
so the system actually functions as a memory and inference engine.

**Why Unison:** Content-addressed, append-only codebase gives structural deduplication
and safe self-modification for free. Inference rules stored as `GUnisonHash` atoms are
versioned automatically — a "learned" rule update is just a new hash appended to the
active rule set, never a mutation of existing definitions.

---

## WHAT IS ALREADY BUILT (Phase 2 — complete)

The following files exist with real type definitions. Treat them as the ground truth
of the current architecture. Do NOT suggest recreating them — only modify or extend.

### `unison/core/Common.u`
- `Context` — 6 variants: CommonSense, Agent, User, System, Session, Domain
- `Provenance` — record with source, timestamp, confidence, derivation

### `unison/core/Atom.u`
- `GroundedValue` — GText, GFloat, GInt, GBool, GBlob, **GUnisonHash Bytes**
  ⚠️ Hash is stored as `Bytes` (not Unison's native `Hash` type) — this is a
  deliberate pragmatic choice noted in a comment. Keep it, but note implications.
- `Atom` — SymbolAtom, VariableAtom, ExpressionAtom, GroundedAtom, FloatAtom,
  IntAtom, BoolAtom
- `Atom.id : Atom -> Text` — placeholder returning text, not a real hash
- `Atom.match : Atom -> Atom -> Optional [(Text, Atom)]` — stub returning None

### `unison/core/AtomSpace.u`
- `EdgeMeta`, `Edge`, `AtomSpace` — all defined
- `AtomSpace.empty`, `addAtom`, `addEdge`, `query`, `rewrite` — ALL STUBS
- Uses `Map Text Atom` (Text key, not Hash key) — consistent with `Atom.id`

### `unison/kg/Entity.u`, `Relation.u`, `Fact.u`, `KnowledgeGraph.u`
- Full types with context + provenance fields ✓
- `toAtom` converters on Entity, Relation, Fact ✓
- ⚠️ `Fact.u` defines its own `TruthValuePlaceholder` — duplicates the real
  `TruthValue` in `unison/reasoning/nars/TruthValue.u`. This must be reconciled.
- All KnowledgeGraph operations are stubs.

### `unison/reasoning/axiomatic/Logic.u` and `Axiom.u`
- Full `Proposition`, `Term`, `Axiom`, `Theorem`, `Proof`, `InferenceRule` types ✓
- `applyRule`, `forwardChain`, `backwardChain`, `checkConsistency` — ALL STUBS

### `unison/reasoning/nars/`
- `Narsese.u` — full `NarsTerm` with all NAL connectives ✓
- `TruthValue.u` — `TruthValue` type + `revision`, `deduction`, `abduction`,
  `induction`, `expectation` — ALL RETURN STUBS (just return v1 or 0.5)
- `NarsConcept.u` — `Sentence`, `Stamp`, `Concept`, `Task`, `Bag`, `TermLink`,
  `TaskLink` ✓. `Bag.probabilisticSelect` — stub returning None
- `NarsInference.u` — `NarsRule` enum, `NarsMemory`. All inference functions stubs.

### `unison/memory/`
- `MemoryItem.u`, `MemoryFact.u`, `MemoryGraph.u` — types with context+provenance ✓
- `UnifiedMemory.u` — `UnifiedMemory` record + all operations as stubs

### `unison/api/Operations.u`
- All 7 API operations defined (`remember`, `recall`, `assertFact`, `retract`,
  `queryKG`, `infer`, `explain`)
- Most are stubs. `remember` builds a MemoryItem but passes empty strings for IDs.
- `queryKG` does delegate to `AtomSpace.query` — but that's a stub too.

---

## CRITICAL BUGS AND GAPS TO ADDRESS FIRST

Before any new features, the following issues in the existing code must be fixed.
Address these as the first section of your response.

### BUG 1: `TruthValuePlaceholder` duplication in `Fact.u`
**File:** `unison/kg/Fact.u`
**Problem:** Defines `unique type TruthValuePlaceholder = { frequency : Float, confidence : Float }`
which is structurally identical to `TruthValue` in `unison/reasoning/nars/TruthValue.u`.
Two different types will prevent `Fact` from interoperating with NARS inference.
**Fix:** Remove `TruthValuePlaceholder` from `Fact.u`. Add a `use` import for the
real `TruthValue`. Update the `Fact` record to use `truthValue : TruthValue`.
Show the exact `use` statement and the updated `Fact` type signature.

### BUG 2: `MemoryFact.u` missing imports
**File:** `unison/memory/MemoryFact.u`
**Problem:** Uses `Context`, `Provenance`, `Atom`, `ExpressionAtom`, `SymbolAtom`,
`GText`, `GroundedAtom` without any `use` declarations at the top of the file.
**Fix:** Add the correct `use` statements. Show the exact lines.

### BUG 3: `MemoryGraph.u` missing `KGSource` import
**File:** `unison/memory/MemoryGraph.u`
**Problem:** `MemoryGroup` variant `KnowledgeBase KGSource` references `KGSource`
from `unison/kg/Entity.u` but there is no `use` import.
**Fix:** Add the correct `use` statement.

### BUG 4: `UnifiedMemory.u` missing imports
**File:** `unison/memory/UnifiedMemory.u`
**Problem:** References `KnowledgeGraph`, `NarsMemory`, `MemoryItem`, `MemoryFact`,
`GraphNode`, `GraphEdge`, `Theorem` with no `use` declarations.
**Fix:** Add all required `use` statements. Also: `UnifiedMemory.axiomaticProve`
returns `Optional Theorem` but `Theorem` is in `unison/reasoning/axiomatic/Axiom.u`.

### BUG 5: `Operations.u` ID generation in `remember`
**File:** `unison/api/Operations.u`
**Problem:** `remember` creates a `MemoryItem` with hardcoded `"auto"` as id and
empty strings for `entityId`, `processId`, `sessionId`, and `0` for timestamp.
These are non-functional placeholders that will make items unqueryable.
**Fix:** Suggest a minimal ID generation strategy (e.g. hashing the text + timestamp
together, or accepting them as parameters). Show the updated function signature.

---

## FEATURES TO IMPLEMENT (in dependency order)

For each feature: (1) locate the anchor file, (2) show a concrete Unison snippet
fitting the existing style, (3) explain dependencies, (4) flag risks.

---

### FEATURE 1: `Atom.match` — structural unification
**File:** `unison/core/Atom.u`
**Current state:** `Atom.match a1 a2 = None` — stub

Implement structural unification: given two atoms where one may contain
`VariableAtom` wildcards, return the list of variable bindings that make them equal,
or None if they cannot unify.

Required behaviour:
- `match (VariableAtom "x") (SymbolAtom "Dog")` → `Some [("x", SymbolAtom "Dog")]`
- `match (SymbolAtom "Dog") (SymbolAtom "Dog")` → `Some []`
- `match (SymbolAtom "Dog") (SymbolAtom "Cat")` → `None`
- `match (ExpressionAtom [VariableAtom "x", SymbolAtom "isa"]) (ExpressionAtom [SymbolAtom "Dog", SymbolAtom "isa"])` → `Some [("x", SymbolAtom "Dog")]`
- Variables in both atoms: unify left-to-right, propagate bindings

This is the single most load-bearing function in the system — everything else
(AtomSpace.query, NARS pattern matching, rule firing) depends on it.

**Dependency:** Blocks Feature 2.

---

### FEATURE 2: `AtomSpace.addAtom`, `addEdge`, `query`
**File:** `unison/core/AtomSpace.u`
**Current state:** All three are stubs returning the space unchanged or `[]`

Implement:
- `addAtom`: insert atom into `atoms` map using `Atom.id` as key. Also update
  `index`: for `SymbolAtom t`, add the hash to `index` under key `t`; for
  `ExpressionAtom`, index under each child's id too.
- `addEdge`: append to `edges` list. Also index: add edge to `index` under
  both `source` and `target` keys.
- `query`: given a pattern Atom (possibly containing VariableAtoms), return all
  atoms in the space that unify with it via `Atom.match`. Return type should be
  `[Atom]` as currently declared, but consider returning `[(Atom, [(Text,Atom)])]`
  (atom + its variable bindings) — flag this as a design decision.

**Risk:** The current `query` return type `[Atom]` loses the variable bindings.
For inference to work, callers need to know *how* a pattern matched, not just
*what* matched. Suggest adding `AtomSpace.queryWithBindings : Atom -> AtomSpace
-> [(Atom, [(Text, Atom)])]` as a companion, keeping `query` for simple lookups.

**Dependency:** Blocks Features 3, 4, 5, and the API `queryKG` operation.

---

### FEATURE 3: `TruthValue` — implement the 5 core formulas
**File:** `unison/reasoning/nars/TruthValue.u`
**Current state:** All 5 functions return their first argument unchanged

Implement the actual NAL (Non-Axiomatic Logic) formulas. These are pure Float
arithmetic — no IO, no state, ~3 lines each:

- `revision`: merge two independent observations of the same statement.
  Formula: `f = (f1·c1·(1-c2) + f2·c2·(1-c1)) / (c1+c2-c1·c2)`,
  `c = (c1+c2-c1·c2) / (c1+c2-c1·c2+k)` where k is a system constant (0.9 typical)
- `deduction`: A→B, B→C ⊢ A→C.
  Formula: `f = f1·f2`, `c = c1·c2·confidence_factor`
- `abduction`: A→B, A→C ⊢ C→B (weak).
  Formula: `f = f2`, `c = f1·c1·c2 / (f1·c1·c2 + k)`
- `induction`: A→C, B→C ⊢ A→B (weak).
  Formula: `f = f1`, `c = f2·c1·c2 / (f2·c1·c2 + k)`
- `expectation`: expected truth of a statement.
  Formula: `e = c·(f - 0.5) + 0.5`

**Risk:** The `k` constant (confidence factor / evidence horizon) should be a
parameter or a module-level constant, NOT hardcoded in each formula. Suggest
defining `k = 0.9` as a top-level value in `TruthValue.u` and using it throughout.

**Dependency:** Unblocks Feature 5 (NARS inference cycle) and fixes BUG 1
(Fact.u can now use the real TruthValue).

---

### FEATURE 4: `KnowledgeGraph` operations
**File:** `unison/kg/KnowledgeGraph.u`
**Current state:** `findFacts`, `addFact`, `relatedEntities`, `graphStats`,
`traversePath` all return empty/unchanged

Implement:
- `addFact`: (a) call `KnowledgeGraph.space` to get the AtomSpace, (b) convert
  the Fact to an Atom via `Fact.toAtom`, (c) add that Atom to the AtomSpace via
  `AtomSpace.addAtom`, (d) also add an Edge connecting subject atom → object atom
  labeled with the relation atom, (e) prepend fact to `facts` list, (f) return
  updated KnowledgeGraph. Show the full implementation.
- `findFacts`: use `AtomSpace.queryWithBindings` (from Feature 2) with a pattern
  matching on the relation and subject. This replaces the current `[]` stub.
- `relatedEntities`: query edges where source = entity's atom id, collect targets.
- `graphStats`: return `Map.fromList [("entities", Map.size entities), ("facts", List.size facts), ("atoms", Map.size (AtomSpace.atoms space))]`
- `traversePath`: BFS over edges up to maxDepth. Show a clean recursive
  implementation using an accumulator for visited nodes.

**Dependency:** Requires Feature 2 (AtomSpace operations). Unblocks `assertFact`
in the API layer.

---

### FEATURE 5: `NarsMemory.cycle` and `Bag.probabilisticSelect`
**File:** `unison/reasoning/nars/NarsInference.u` and `NarsConcept.u`
**Current state:** `NarsMemory.cycle mem = mem` — complete stub

This is the heart of NARS. A single cycle:
1. Select highest-priority task from `inputBuffer` via `Bag.probabilisticSelect`
2. Find or create the corresponding `Concept` in `concepts`
3. Select a belief from the concept's belief bag
4. Apply the matching `NarsRule` to the task sentence + belief sentence
5. If a new sentence is derived, add it back to the input buffer as a new Task
6. Increment `cycleCount`

Implement `Bag.probabilisticSelect` first: select an item with probability
proportional to its priority weight. In pure Unison (no IO), this requires a
seed passed in: `Bag.selectWithSeed : Nat -> Bag a -> Optional (a, Bag a)`.
Flag this: the caller must manage the seed (pass it in from NarsMemory.cycleCount
or a separate seed field).

For `NarsRule.apply`, implement at minimum `Deduction` and `Revision` using the
formulas from Feature 3. All other rules can remain stubs but should log which
rule was attempted.

**Risk:** `Bag.probabilisticSelect` needs a random seed — pure Unison has no
global randomness. Suggest adding `seed : Nat` to `NarsMemory` and updating it
each cycle using a simple LCG: `nextSeed = (seed * 6364136223846793005 + 1) % (2^64)`.

**Dependency:** Requires Feature 3 (TruthValue formulas).

---

### FEATURE 6: `GUnisonHash` — rule-as-atom execution bridge
**File:** `unison/core/Atom.u` + new file `unison/api/RuleEngine.u`
**Current state:** `GUnisonHash Bytes` is declared but nothing uses it yet.
The `rule_run` API operation is entirely missing from `Operations.u`.

This is the feature that makes BrainyML uniquely powerful: inference rules stored
as content-addressed Unison functions inside the AtomSpace, queryable and executable
through the same API as facts.

**Part A — `RuleEngine.u` (new file):**
Define the rule execution interface:
```
unique type Rule = {
  name : Text,
  description : Text,
  atomHash : Bytes,       -- the GUnisonHash value
  context : Context,
  provenance : Provenance
}

unique type RuleSet = {
  active : [Rule],
  history : [(Nat, Rule, Rule)]  -- (timestamp, old, new) for audit trail
}
```

Define `RuleSet.promoteRule`, `RuleSet.retireRule`, `RuleSet.activeForContext`.

**Part B — execution bridge:**
The `atomHash : Bytes` stores the SHA3 hash of a compiled Unison definition.
Execution happens via UCM's transcript API or local web server. Suggest the
exact shell call pattern: `ucm run #<hash> <serialized-inputs>` and show how
`Operations.u` would invoke it via an `IO` ability call.

**Part C — add `ruleRun` to `Operations.u`:**
Show the new function signature:
```
ruleRun : Text -> [Atom] -> UnifiedMemory -> '{IO} ApiResult
```
and how it looks up the rule name → finds the `GroundedAtom (GUnisonHash bytes)`
→ shells out to UCM → parses result Atoms back.

**Dependency:** Requires Feature 2 (AtomSpace.query to look up rules by name).
This is the bridge to Phase 5 (full inference engine) described in README.

---

### FEATURE 7: `UnifiedMemory` — wire real implementations
**File:** `unison/memory/UnifiedMemory.u`
**Current state:** All 8 operations are stubs

Now that Features 1–6 are in place, wire the real implementations:

- `addMemory`: generate a real ID (hash of text ++ timestamp as Nat), insert into
  `items` map, also call `addAtom` on the memory's `toAtom` representation so it
  is queryable from the AtomSpace. Show the full implementation.
- `search`: use `AtomSpace.queryWithBindings` with a `GroundedAtom (GText query)`
  pattern. For fuzzy text search (which Unison doesn't do natively), suggest
  either (a) delegating to the Python layer for now, or (b) maintaining a separate
  inverted index `Map Text [Text]` (word → item ids) inside `UnifiedMemory`.
  Recommend option (b) with a concrete type addition.
- `narsInfer`: call `NarsMemory.cycle` N times (suggest 10 as default), collect
  new sentences whose confidence exceeds a threshold, convert to `MemoryFact`.
- `axiomaticProve`: delegate to `backwardChain` from `Axiom.u`. Parse the `Text`
  goal into a `Proposition` — this requires at minimum a trivial parser for
  `PAtom` goals. Show the simplest viable implementation.
- `extractFacts`: given a `MemoryItem`, create a `MemoryFact` by treating the
  text as a triple with `SimpleExtraction` method. For now, a naive subject =
  first word, predicate = second word, object = rest is sufficient — this will
  be improved by the NLP layer in Phase 5.

**Dependency:** Requires all Features 1–5.

---

### FEATURE 8: `Operations.u` — complete the 7 API operations
**File:** `unison/api/Operations.u`
**Current state:** `assertFact`, `retract`, `explain` are stubs; `remember` has
bad ID generation (BUG 5 above); `infer` delegates but narsInfer is a stub.

After Features 1–7:

- `remember`: fix ID generation (use hash of text content as suggested in BUG 5).
  Also call `UnifiedMemory.extractFacts` after storing, so facts are derived
  automatically from stored text.
- `assertFact`: construct a `Fact` from the text params, call
  `KnowledgeGraph.addFact`, return updated `UnifiedMemory`.
- `retract`: implement truth maintenance — rather than deleting, set the Fact's
  `TruthValue` to `{ frequency = 0.0, confidence = 1.0 }` (certain falsehood in
  NARS). Show why this is safer than deletion for a self-modifying system.
- `explain`: given a `derivationId`, walk back through `Provenance.derivation`
  chain in the AtomSpace to reconstruct the derivation path as Text.
- `infer`: after wiring `narsInfer`, also attempt `axiomaticProve` for
  `AxiomaticStrategy`, and for `AutoStrategy` try axiomatic first then fall back
  to NARS.

---

### FEATURE 9: Episodic memory layer
**File:** new `unison/memory/EpisodicMemory.u`
**Current state:** Not designed yet. `TemporalInfo` exists in `MemoryGraph.u`
but is only attached to `GraphEdge`, not to facts or memories.

This is the feature most critical for OpenClaw as a *living agent* — the ability
to remember *when* and *in what context* events happened, and recall by recency
and relevance.

Design and implement:
```
unique type Episode = {
  id : Text,
  core : Atom,             -- what happened (as an Atom)
  context : Context,       -- agent/session/domain
  timestamp : Nat,
  salience : Float,        -- attention value (ECAN-style)
  temporal : TemporalInfo,
  provenance : Provenance
}
```

Functions:
- `recordEpisode : Episode -> UnifiedMemory -> UnifiedMemory`
  Stores episode atom in AtomSpace AND adds a `GraphEdge` with temporal metadata
  linking it to the agent's context node.
- `recallByTime : Nat -> Nat -> Context -> UnifiedMemory -> [Episode]`
  Retrieve episodes between two timestamps for a given context.
- `recallSimilar : Atom -> Nat -> UnifiedMemory -> [Episode]`
  Find the N most structurally similar episodes using AtomSpace pattern matching.
- `decaySalience : Float -> UnifiedMemory -> UnifiedMemory`
  Apply exponential decay to all episode salience values (simulates forgetting).
  Formula: `newSalience = salience * decayFactor` where `decayFactor` is passed in.

**Connect to `UnifiedMemory`:** Add `episodes : [Episode]` to the `UnifiedMemory`
record and update `addMemory` to optionally wrap stored items as episodes (when
the context is a Session or Agent context).

**Connect to OpenClaw API:** Add `episodeRecord` and `episodeRecall` to
`Operations.u` as the interface OpenClaw calls after each conversation turn.

**Dependency:** Requires Feature 7 (working UnifiedMemory). This is the direct
OpenClaw memory integration.

---

### FEATURE 10: `RuleSet` as part of `UnifiedMemory` — safe self-modification
**File:** `unison/memory/UnifiedMemory.u` + `unison/api/RuleEngine.u`
**Current state:** `UnifiedMemory` has no rule tracking. Rules exist only in
`Operations.u` conceptually.

Add `ruleSet : RuleSet` to the `UnifiedMemory` record (requires Feature 6's
`RuleSet` type).

Implement the safe self-modification protocol:
- `learn : [Fact] -> UnifiedMemory -> UnifiedMemory`
  Add new facts, update existing ones via TruthValue revision, increment
  `provenance.confidence` on repeatedly confirmed facts.
- `learnRule : Rule -> UnifiedMemory -> UnifiedMemory`
  Promote a new rule into the active RuleSet. The old version stays in history.
- `rollback : Nat -> UnifiedMemory -> UnifiedMemory`
  Restore the KnowledgeGraph and RuleSet to the state at a given timestamp by
  replaying the RuleSet history backwards.

**Key Unison property to exploit explicitly in your implementation:**
Because a `Rule` stores a `Bytes` hash pointing to an immutable Unison definition,
`rollback` never needs to "undo" code changes — it just restores the pointer to
the old hash. The old function was never modified. Show this in the implementation.

---

## WHAT NOT TO CHANGE

- Do not alter the 7-operation API surface in `Operations.u` — OpenClaw integration
  depends on it being stable.
- Do not change the `Context` or `Provenance` types in `Common.u` — every other
  type depends on them.
- Do not change the `NarsTerm` grammar in `Narsese.u` — it faithfully implements
  NAL and should not be simplified.
- Do not rename existing files or move namespaces — the phase docs reference them
  by path.
- Phase 3 (Python parsers) is out of scope for this planning session — do not
  suggest changes to `scripts/`.

---

## RESPONSE FORMAT

Structure your response as exactly 10 sections, one per feature (bugs first as
section 0, then features 1–9 plus 10). For each:

```
## [BUG/FEATURE N]: <name>
**File(s):** <exact paths>
**Anchor:** <existing function or type to modify>

### Change
<concrete Unison code snippet, 10–40 lines, matching existing style>

### Why
<2–3 sentences: what this enables>

### Connects to
<which other features depend on this>

### Risk / flag
<one design decision or gotcha to watch out for>
```

Keep snippets in existing Unison style: `unique type`, accessor dot-notation,
`cases` pattern matching. Do not introduce syntax or library functions not
already present in the codebase.

---

*Generated from full codebase review of github.com/siryoussef/BrainyML —
BrainyML Unison symbolic AI substrate for OpenClaw, March 2026.*
