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

### Phase 2: Unison Type System (ADTs)
Design the Unison ADTs spanning 5 layers (see `docs/architecture.md` for details):
- [ ] Core Atomspace (MeTTa-style Atom, AtomSpace metagraph)
- [ ] KG types (Entity, Relation, Fact, KnowledgeGraph)
- [ ] Axiomatic reasoning (Proposition, Axiom, Theorem, Proof, InferenceRule)
- [ ] NARS ADTs (NarsTerm, TruthValue, Concept, Task, Bag, NarsMemory)
- [ ] Unified Memory types bridging Graphiti & SQLite (MemoryItem, MemoryFact, GraphNode, GraphEdge, MemoryGroup, Layers)
- [ ] API stubs for query, inference, and memory operations
- **AI Instruction**: Check types compilation with `ucm transcript`.

### Phase 3: Python KG Parsers
- [ ] `parse_nell.py`: NELL → Unison parser (TSV beliefs/ontology → Entity/Fact)
- [ ] `parse_cskg.py`: CSKG → Unison parser (KGTK edges → Fact)
- [ ] CLI entry point (`scripts/parse_kg.py`)
- **AI Instruction**: Ensure parsers handle the massive TSV files efficiently (e.g., using pandas in chunks or streaming).

### Phase 4: OpenClaw Integration
- [ ] Define `SKILL.md` + `_agents/AGENTS.md`.
- [ ] Create `shared-files/` and `skill/` directories.
- [ ] Wire KG query API as OpenClaw memory backend.
- **AI Instruction**: This makes the knowledge graph accessible to the overarching agent architecture.

### Phase 5: Later Phases (Deferred)
- [ ] A Unison API wrapper for AI to dynamically edit facts and rules.
- [ ] NLP layer (small LLM for NLU/NLG).
- [ ] Inference rules engine full implementation.

## Tooling
- **Nix / Devenv**: Used for deterministic package management (Unison, Python).
- **Unison**: Used for ADTs and logic.
- **Python**: Used for parsing the massive NELL/CSKG datasets.

See `docs/` for more detailed specifications on structure and schemas.
