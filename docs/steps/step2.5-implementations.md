# Step 2.5: Harden Types & Implement Core Functions

**Status:** ✅ Complete  
**Source:** `BrainyML_planning_prompt_v2.md` — annotated modification plan  
**Prerequisite:** Step 2 types (complete). Step 1.5 API design (complete).

## Overview

Phase 2 produced all type definitions but every function is a stub. This step fills in the implementations in **dependency order**. Work is split into 3 sub-phases to avoid overwhelming context.

---

## Sub-phase A: Bug Fixes (do first)

### BUG 1: `TruthValuePlaceholder` duplication
**File:** `unison/kg/Fact.u`  
**Fix:** Remove `TruthValuePlaceholder`. Import the real `TruthValue` from `unison/reasoning/nars/TruthValue.u`. Update `Fact` record to use `truthValue : TruthValue`.

### BUG 2: Missing imports in `MemoryFact.u`
**File:** `unison/memory/MemoryFact.u`  
**Fix:** Add `use` statements for `Context`, `Provenance`, `Atom`, `ExpressionAtom`, `SymbolAtom`, `GText`, `GroundedAtom`.

### BUG 3: Missing `KGSource` import in `MemoryGraph.u`
**File:** `unison/memory/MemoryGraph.u`  
**Fix:** Add `use` statement for `KGSource` from `unison/kg/Entity.u`.

### BUG 4: Missing imports in `UnifiedMemory.u`
**File:** `unison/memory/UnifiedMemory.u`  
**Fix:** Add `use` statements for `KnowledgeGraph`, `NarsMemory`, `MemoryItem`, `MemoryFact`, `GraphNode`, `GraphEdge`, `Theorem`.

### BUG 5: Bad ID generation in `Operations.u`
**File:** `unison/api/Operations.u`  
**Fix:** Replace hardcoded `"auto"` ID with hash of (text ++ timestamp). Accept `entity_id`, `session_id` as parameters or derive from context.

**AI Instruction:** Fix all 5 bugs before proceeding to Feature implementations. Verify with `ucm transcript`.

---

## Sub-phase B: Core Implementations (Features 1–5)

Must be implemented in this exact order (each depends on previous):

### FEATURE 1: `Atom.match` — structural unification *(load-bearing!)*
**File:** `unison/core/Atom.u`  
**What:** Pattern matching with `VariableAtom` wildcards. Returns bindings `[(Text, Atom)]`.  
**Key behaviors:**
- `match (VariableAtom "x") (SymbolAtom "Dog")` → `Some [("x", SymbolAtom "Dog")]`
- `match (SymbolAtom "Dog") (SymbolAtom "Dog")` → `Some []`
- `match (ExpressionAtom [...]) (ExpressionAtom [...])` → recursive, propagate bindings  
**Blocks:** Everything else (AtomSpace.query, NARS matching, rule firing)

### FEATURE 2: `AtomSpace` operations — `addAtom`, `addEdge`, `query`
**File:** `unison/core/AtomSpace.u`  
**What:**
- `addAtom`: Insert into `atoms` map, update `index` (for SymbolAtom: index under text; for ExpressionAtom: index under each child's id)
- `addEdge`: Append to `edges`, index under source+target keys
- `query`: Pattern-match using `Atom.match`. Return matching atoms.
- **Design decision:** Add `queryWithBindings : Atom -> AtomSpace -> [(Atom, [(Text, Atom)])]` that returns bindings alongside results (callers need to know *how* a pattern matched, not just *what* matched). Keep plain `query` for simple lookups.  
**Blocks:** Features 3–5 and `queryKG` API

### FEATURE 3: `TruthValue` formulas — 5 core NAL functions
**File:** `unison/reasoning/nars/TruthValue.u`  
**What:** Implement the actual arithmetic (pure Float, ~3 lines each):
- `revision`: `f = (f1·c1·(1-c2) + f2·c2·(1-c1)) / (c1+c2-c1·c2)`, `c = (c1+c2-c1·c2) / (c1+c2-c1·c2+k)`
- `deduction`: `f = f1·f2`, `c = c1·c2·f1·f2`
- `abduction`: `f = f2`, `c = f1·c1·c2 / (f1·c1·c2 + k)`
- `induction`: `f = f1`, `c = f2·c1·c2 / (f2·c1·c2 + k)`
- `expectation`: `e = c·(f - 0.5) + 0.5`  
**Note:** Define `k = 0.9` as a module-level constant, NOT hardcoded per formula.  
**Blocks:** NARS inference cycle (Feature 5)

### FEATURE 4: `KnowledgeGraph` operations
**File:** `unison/kg/KnowledgeGraph.u`  
**What:**
- `addFact`: Convert fact→Atom via `toAtom`, add to AtomSpace, add Edge (subject→object labeled with relation), prepend to facts list
- `findFacts`: Use `AtomSpace.queryWithBindings` with pattern
- `relatedEntities`: Query edges by source entity
- `graphStats`: Return map of counts
- `traversePath`: BFS over edges up to maxDepth  
**Requires:** Feature 2. **Blocks:** `assertFact` API

### FEATURE 5: `NarsMemory.cycle` and `Bag.probabilisticSelect`
**Files:** `unison/reasoning/nars/NarsInference.u`, `NarsConcept.u`  
**What:** The NARS working cycle:
1. `Bag.probabilisticSelect` — select by priority weight. Needs seed: `selectWithSeed : Nat -> Bag a -> Optional (a, Bag a)`
2. One cycle: select task → find/create concept → select belief → apply rule → derive new sentence → add back as task → increment cycle
3. Implement at minimum `Deduction` and `Revision` rules using Feature 3 formulas  
**Note:** Add `seed : Nat` to `NarsMemory`, update each cycle via LCG: `nextSeed = (seed * 6364136223846793005 + 1) % (2^64)`  
**Requires:** Feature 3 (TruthValue formulas)

**AI Instruction:** Sub-phase B is the most complex. Implement one feature at a time. Verify compilation after each.

---

## Sub-phase C: Memory & API Wiring (Features 6–10)

### FEATURE 6: `GUnisonHash` — rule-as-atom execution bridge
**Files:** `unison/core/Atom.u` + **NEW** `unison/api/RuleEngine.u`  
**What:**
- Define `Rule` type (name, description, atomHash:Bytes, context, provenance)
- Define `RuleSet` (active rules, history as audit trail)
- Functions: `promoteRule`, `retireRule`, `activeForContext`
- `ruleRun` in `Operations.u`: lookup rule → get `GUnisonHash` → invoke via UCM IO ability → parse results  
**Requires:** Feature 2

### FEATURE 7: `UnifiedMemory` — wire real implementations
**File:** `unison/memory/UnifiedMemory.u`  
**What:**
- `addMemory`: Real ID generation, insert to items + AtomSpace
- `search`: AtomSpace query or inverted text index (`Map Text [Text]`)
- `narsInfer`: Run `NarsMemory.cycle` N times, collect high-confidence results
- `axiomaticProve`: Delegate to `backwardChain`, needs minimal `PAtom` parser
- `extractFacts`: Naive triple extraction (first/second/rest words)  
**Requires:** Features 1–5

### FEATURE 8: `Operations.u` — complete 7 API operations
**File:** `unison/api/Operations.u`  
**What:**
- `remember`: Fix IDs (BUG 5), auto-extract facts
- `assertFact`: Construct Fact, call `KnowledgeGraph.addFact`
- `retract`: Set TruthValue to `{frequency=0.0, confidence=1.0}` (certain falsehood — safer than deletion for self-modifying systems)
- `explain`: Walk `Provenance.derivation` chain
- `infer`: Wire `narsInfer` + `axiomaticProve`, auto strategy = axiomatic first then NARS  
**DO NOT** change the 7-operation API surface — OpenClaw depends on stability.

### FEATURE 9: Episodic memory layer
**File:** **NEW** `unison/memory/EpisodicMemory.u`  
**What:** Critical for OpenClaw as a living agent — remembering *when* and *in what context*:
```
Episode = { id, core:Atom, context, timestamp, salience:Float (ECAN-style), temporal:TemporalInfo, provenance }
```
Functions: `recordEpisode`, `recallByTime`, `recallSimilar`, `decaySalience`  
**Connect:** Add `episodes : [Episode]` to `UnifiedMemory`. Add `episodeRecord`/`episodeRecall` to `Operations.u`.  
**Requires:** Feature 7

### FEATURE 10: `RuleSet` in `UnifiedMemory` — safe self-modification
**Files:** `unison/memory/UnifiedMemory.u` + `unison/api/RuleEngine.u`  
**What:** Add `ruleSet : RuleSet` to `UnifiedMemory`.
- `learn`: Add facts, revision existing TruthValues
- `learnRule`: Promote new rule to active set (old stays in history)
- `rollback`: Restore state to timestamp by re-pointing to old hashes (never undoes code — just swaps hash pointers, exploiting Unison's immutability)  
**Requires:** Feature 6

---

## What NOT to Change
- 7-operation API surface in `Operations.u`
- `Context`/`Provenance` types in `Common.u`
- `NarsTerm` grammar in `Narsese.u`
- File names or namespace paths
- Python scripts (out of scope)

## Verification
After each sub-phase: `ucm transcript` to verify compilation. After sub-phase C: run the API operations against a small test KG.

## Next
After Step 2.5 → proceed to `step3-parsers.md` (Python NELL/CSKG parsers).
