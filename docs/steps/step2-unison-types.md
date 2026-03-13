# Step 2: Unison Type System (ADTs)

**Status:** ✅ Complete (types defined, implementations are stubs)

**Prerequisite:** `step1.5-api-design.md` — completed.

## What Was Built

18 Unison files across 5 layers, all with context + provenance fields:

### Core (`unison/core/`)
| File | Contents |
|------|----------|
| `Common.u` | `Context` (6 variants), `Provenance` record |
| `Atom.u` | `GroundedValue` (inc. `GUnisonHash Bytes`), `Atom` (7 variants), `Atom.id` (stub), `Atom.match` (stub) |
| `AtomSpace.u` | `EdgeMeta`, `Edge`, `AtomSpace`, `empty`, `addAtom`/`addEdge`/`query`/`rewrite` (all stubs) |

### KG (`unison/kg/`)
| File | Contents |
|------|----------|
| `Entity.u` | `Entity`, `KGSource`, `Entity.toAtom` ✓ |
| `Relation.u` | `Relation`, `Relation.toAtom` ✓ |
| `Fact.u` | `Fact`, `Fact.toAtom` ✓ — ⚠️ has `TruthValuePlaceholder` (BUG: duplicates NARS `TruthValue`) |
| `KnowledgeGraph.u` | `KnowledgeGraph`, all ops stubs |

### Reasoning (`unison/reasoning/`)
| File | Contents |
|------|----------|
| `axiomatic/Logic.u` | `Proposition`, `Term` — full FOL types ✓ |
| `axiomatic/Axiom.u` | `Axiom`, `Theorem`, `Proof`, `InferenceRule` — all inference stubs |
| `nars/Narsese.u` | Full `NarsTerm` with all NAL connectives ✓ |
| `nars/TruthValue.u` | `TruthValue` type ✓, `revision`/`deduction`/`abduction`/`induction`/`expectation` — all stubs |
| `nars/NarsConcept.u` | `Sentence`, `Stamp`, `Concept`, `Task`, `Bag`, links — `Bag.probabilisticSelect` stub |
| `nars/NarsInference.u` | `NarsRule`, `NarsMemory` — `NarsMemory.cycle` stub |

### Memory (`unison/memory/`)
| File | Contents |
|------|----------|
| `MemoryItem.u` | `MemoryItem` with context+provenance ✓ |
| `MemoryFact.u` | `MemoryFact`, `ExtractionMethod` — ⚠️ missing `use` imports |
| `MemoryGraph.u` | `GraphNode`, `GraphEdge`, `TemporalInfo`, `MemoryGroup`, `MemoryLayer` — ⚠️ missing `KGSource` import |
| `UnifiedMemory.u` | `UnifiedMemory`, `MemoryGraphDB` — all 8 ops stubs, ⚠️ missing imports |

### API (`unison/api/`)
| File | Contents |
|------|----------|
| `Operations.u` | 7 API ops (`remember`, `recall`, `assertFact`, `retract`, `queryKG`, `infer`, `explain`) — mostly stubs, `remember` has bad ID gen |

## Known Issues (to fix in Step 2.5)
1. **BUG**: `Fact.u` defines `TruthValuePlaceholder` duplicating NARS `TruthValue`
2. **BUG**: `MemoryFact.u` missing `use` imports
3. **BUG**: `MemoryGraph.u` missing `KGSource` import
4. **BUG**: `UnifiedMemory.u` missing multiple imports
5. **BUG**: `Operations.u` `remember` uses hardcoded IDs

## Next
Proceed to `docs/steps/step2.5-implementations.md` (bug fixes + core implementations).
