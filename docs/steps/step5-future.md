# Step 5: Future Work

**Status:** ⬜ Deferred

## Planned future phases

### 5a. NLP Layer
Implement a small LLM or simple NLP pipeline for:
- Natural Language Understanding (NLU): parsing user input into Narsese/logical statements
- Natural Language Generation (NLG): translating KG facts and inference results into natural language

### 5b. Full Inference Engine
Expand the NARS and axiomatic inference stubs into a full working engine:
- Complete NAL 1-6 implementation
- Working cycle with priority-based concept selection
- Forward and backward chaining
- Temporal inference

### 5c. Logic Verification & Proof Checking
Verify the correctness of stored logic rules and inference results:
- **Lean4 bridge**: Explore bridging Unison inference rules to Lean4 for formal proof verification. Lean4's type-theoretic foundation could validate that inference rules are logically sound.
- **Native Unison solutions**: Investigate whether Unison's type system and abilities can provide sufficient guarantees for proof correctness without an external prover.
- **Proof certificates**: When a rule produces a derivation, generate a machine-checkable proof certificate that can be verified independently.
- This is a complex research-level goal — the initial system operates on trust + confidence values, with formal verification added later.

## Note
Episodic memory (Feature 9) and RuleSet self-modification (Feature 10) were originally deferred but are now part of Phase 2.5 Sub-phase C. See `docs/steps/step2.5-implementations.md`.

