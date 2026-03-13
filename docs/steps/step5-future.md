# Step 5: Future Work

**Status:** ⬜ Deferred

## Planned future phases

### 5a. Unison API wrapper for AI editing
A wrapper API that allows AI agents to dynamically:
- Add/modify/delete facts in the knowledge graph
- Add/modify inference rules
- Trigger reasoning cycles and retrieve results
This will likely be exposed via a CLI or MCP tool interface.

### 5b. NLP Layer
Implement a small LLM or simple NLP pipeline for:
- Natural Language Understanding (NLU): parsing user input into Narsese/logical statements
- Natural Language Generation (NLG): translating KG facts and inference results into natural language

### 5c. Full Inference Engine
Expand the NARS and axiomatic inference stubs into a full working engine:
- Complete NAL 1-6 implementation
- Working cycle with priority-based concept selection
- Forward and backward chaining
- Temporal inference
