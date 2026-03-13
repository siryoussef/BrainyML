# BrainyML

Symbolic AI system bootstrapped as an OpenClaw memory extension. The core knowledge representation uses Unison language code objects for the knowledge graph, axiomatic reasoning, and non-axiomatic reasoning (NARS). OpenClaw's own backend acts as the NLP layer for now.

## Overview
This repository manages the BrainyML unified memory and reasoning layer for OpenClaw. It integrates temporal facts, formal logic, and NARS under a single Unison-based API.

## Project Plan & Progress Tracker

This project is divided into several phases to keep context manageable. Each phase must be documented upon completion. AI assistants working on this project should refer to these docs to resume work.

### Phase 0: Project Scaffolding
- [x] Initial directory structure created.
- [x] `README.md` and `docs/` created.
- [x] Create devenv flake (Nix): Unison, Python, jq.
- [x] Initialize git submodules for reference repos and data.
- **AI Instruction:** Upon completing Phase 0, update this checklist and review `docs/architecture.md`.

### Phase 1: Git Submodules Setup
- [x] Ensure `submodules/NELL` is added to `.gitignore`.
- [x] Determine approach for `CSKG` (manual populating vs `usc-isi-i2/cskg` fork).
- [x] Add `openclaw-graphiti-memory` and `openclaw-memory-offline-sqlite` as reference read-only submodules.
- **AI Instruction**: Update checklist when done.

### Phase 1.5: Unified API Design *(must precede Phase 2)*
Design the simplified API that LLM/OpenClaw will use to access all knowledge and reasoning. See `docs/steps/step1.5-api-design.md`.
- [x] Define 7 core operations: `remember`, `recall`, `assert`, `retract`, `query`, `infer`, `explain`
- [x] Design context/microtheory system (from CycL)
- [x] Define wire format for LLM tool calls
- [x] Document ADT constraints (context, provenance, toAtom) that Step 2 must follow
- **AI Instruction**: This step is PLANNING ONLY — it shapes Step 2 before any Unison code is written.

### Phase 2: Unison Type System (ADTs) ✅
All 18 Unison files defined across 5 layers. Types complete, **all implementations are stubs**. See `docs/steps/step2-unison-types.md`.
- [x] Core Atomspace (`Atom.u`, `AtomSpace.u`, `Common.u`)
- [x] KG types (`Entity.u`, `Relation.u`, `Fact.u`, `KnowledgeGraph.u`)
- [x] Axiomatic reasoning (`Logic.u`, `Axiom.u`)
- [x] NARS ADTs (`Narsese.u`, `TruthValue.u`, `NarsConcept.u`, `NarsInference.u`)
- [x] Unified Memory (`MemoryItem.u`, `MemoryFact.u`, `MemoryGraph.u`, `UnifiedMemory.u`)
- [x] API (`Operations.u` — 7 operations defined)

### Phase 2.5: Harden Types & Implement Core Functions ✅
5 bugs fixed, 10 features implemented. See `docs/steps/step2.5-implementations.md`.
- [x] **Sub-phase A** — Bug fixes (TruthValuePlaceholder dup, missing imports ×3, bad ID gen)
- [x] **Sub-phase B** — Core: Atom.match, AtomSpace ops, TruthValue formulas, KG ops, NARS cycle
- [x] **Sub-phase C** — Memory: RuleEngine, UnifiedMemory wiring, Operations completion, EpisodicMemory, RuleSet self-modification
- **New files:** `RuleEngine.u`, `EpisodicMemory.u` (20 total Unison files)

### Phase 3: Python KG Parsers
- [ ] `parse_nell.py`: NELL → Unison parser (TSV beliefs/ontology → Entity/Fact)
- [ ] `parse_cskg.py`: CSKG → Unison parser (KGTK edges → Fact)
- [ ] CLI entry point (`scripts/parse_kg.py`)
- **AI Instruction**: Ensure parsers handle the massive TSV files efficiently.

### Phase 4: OpenClaw Integration
- [ ] Define `SKILL.md` + `_agents/AGENTS.md`.
- [ ] Create `shared-files/` and `skill/` directories.
- [ ] Wire KG query API as OpenClaw memory backend.

### Phase 5: Later Phases (Deferred)
- [ ] NLP layer (small LLM for NLU/NLG).
- [ ] Full inference engine (NAL 1–6, temporal inference).
- [ ] Logic verification & proof checking (Lean4 bridge or native Unison solutions).

## Tooling
- **Nix / Devenv**: Used for deterministic package management (Unison, Python).
- **Unison**: Used for ADTs and logic.
- **Python**: Used for parsing the massive NELL/CSKG datasets.

See `docs/` for more detailed specifications on structure and schemas.
