# BrainyML Architecture

## Design Principle
All internal complexity (NARS, axiomatic logic, MeTTa rewriting, CycL-style microtheories, KG standards) converges into a **single unified API** of 7 operations (`remember`, `recall`, `assert`, `retract`, `query`, `infer`, `explain`). An LLM/OpenClaw agent interacts ONLY through this API — never touching internal types directly. See `docs/steps/step1.5-api-design.md`.

## Component Overview

### 1. Unified Unison Type System (ADTs)
The core of BrainyML bridges MeTTa-style Atomspace, NARS, Axiomatic Logic, and OpenClaw memory structures using Unison.

#### 1A: Core Atomspace (Hypergraph Foundation)
- **Atom**: Symbolic, Variable, Expression (S-expr), and Grounded (opaque values).
- **AtomSpace**: Directed labeled hypergraph container with metadata (confidence, source, timestamp).

#### 1B: Axiomatic Reasoning (Classical Logic)
- **Proposition**: Full first-order logic (And, Or, Not, Implies, Quantifiers, Predicates).
- **Proof/Theorem**: Formalized inference steps (Modus Ponens, Resolution, Induction).

#### 1C: NARS (Non-Axiomatic Reasoning)
- **TruthValue**: Frequency and Confidence pairs.
- **NarsTerm**: Narsese grammar (Inheritance, Similarity, Implication, Sets, Temporal).
- **Control**: Concepts, Tasks, and Priority Bags for resource-constrained reasoning.

#### 1D: Unified Memory (OpenClaw DB Unification)
Unifies structures identified from reference repositories:
- **MemoryItem**: Bridges SQLite `items` (text, attribution, embeddings).
- **MemoryFact**: Bridges SQLite `facts` table (extracted S-P-O facts).
- **Graphiti Structure**: Layers (Private, Shared Files, Shared Graph) and Groups (Agent ID, User-main, System-shared).

### 2. Python Parsers
- `parse_kg.py`: Command-line tool for parsing datasets.
  - **NELL**: Reads local TSV extracting beliefs and confidence.
  - **CSKG**: Maps the standard KGTK 10-column edges.

### 3. Submodules
- `NELL`: Huge local dataset (ignored by git in the parent repo to prevent bloat).
- `CSKG`: USC ISI Commonsense Knowledge Graph.
- Reference repositories for structural guidance: `openclaw-graphiti-memory` and `openclaw-memory-offline-sqlite`.

## Agent Instructions for Continuation
When a new AI agent picks up this context:
1. Review `README.md` to see which phase is currently active.
2. Read through this `architecture.md` to understand the Unison ADT layout.
3. Focus on completing **exactly one phase at a time**.
4. Update the checkboxes in the `README.md` upon phase completion.
5. If creating new types or scripts, ensure they are documented in this folder.
