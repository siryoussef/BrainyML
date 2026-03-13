# Step 2: Unison Type System (ADTs)

**Status:** ⬜ Not started

## Overview
Design and implement the Unison type hierarchy across 5 sub-layers. All files go under `unison/`.

## Directory layout
```
unison/
├── core/              # 2A: Core Atomspace
│   ├── Atom.u
│   └── AtomSpace.u
├── kg/                # 2B: Knowledge Graph
│   ├── Entity.u
│   ├── Relation.u
│   ├── Fact.u
│   └── KnowledgeGraph.u
├── reasoning/
│   ├── axiomatic/     # 2C: Axiomatic Reasoning
│   │   ├── Logic.u
│   │   └── Axiom.u
│   └── nars/          # 2D: NARS
│       ├── Narsese.u
│       ├── TruthValue.u
│       ├── NarsConcept.u
│       └── NarsInference.u
└── memory/            # 2E: Unified Memory
    ├── MemoryItem.u
    ├── MemoryFact.u
    ├── MemoryGraph.u
    └── UnifiedMemory.u
```

---

## 2A: Core Atomspace (MeTTa-inspired)

### Atom.u
```
unique type Atom
  = SymbolAtom Text
  | VariableAtom Text
  | ExpressionAtom [Atom]
  | GroundedAtom GroundedValue
  | FloatAtom Float
  | IntAtom Int
  | BoolAtom Boolean

unique type GroundedValue = GText Text | GFloat Float | GInt Int | GBool Boolean | GBlob Bytes
```
Functions: `Atom.id : Atom -> Hash`, `Atom.match : Atom -> Atom -> Optional [(Text, Atom)]`

### AtomSpace.u
```
unique type AtomSpace = { atoms : Map Hash Atom, edges : [Edge], index : Map Text [Hash] }
unique type Edge = { source : Hash, label : Atom, target : Hash, metadata : EdgeMeta }
unique type EdgeMeta = { confidence : Float, source : Text, timestamp : Nat, priority : Float }
```
Functions: `empty`, `addAtom`, `addEdge`, `query` (pattern-match), `rewrite`

---

## 2B: Knowledge Graph

### Entity.u
```
unique type Entity = { id : Text, name : Text, category : Text, aliases : [Text], source : KGSource, properties : Map Text Atom }
unique type KGSource = NELL | CSKG | Graphiti | UserDefined | Inferred
```

### Relation.u
```
unique type Relation = { id : Text, name : Text, domain : Text, range : Text, symmetric : Boolean }
```

### Fact.u
```
unique type Fact = { subject : Entity, relation : Relation, object : Entity, truthValue : TruthValue, source : KGSource, evidence : [Text] }
```

### KnowledgeGraph.u
```
unique type KnowledgeGraph = { space : AtomSpace, entities : Map Text Entity, relations : Map Text Relation, facts : [Fact] }
```
Functions: `findEntity`, `findFacts`, `addFact`, `relatedEntities`, `graphStats`, `traversePath`

---

## 2C: Axiomatic Reasoning

### Logic.u
```
unique type Proposition
  = PAtom Text | PNot Proposition | PAnd Proposition Proposition
  | POr Proposition Proposition | PImplies Proposition Proposition
  | PIff Proposition Proposition | PForAll Text Proposition
  | PExists Text Proposition | PPredicate Text [Term]

unique type Term = TVar Text | TConst Text | TFunc Text [Term]
```

### Axiom.u
```
unique type Axiom = { name : Text, proposition : Proposition, justification : Text }
unique type Theorem = { name : Text, proposition : Proposition, proof : Proof }
unique type Proof = Axiomatic Axiom | ModusPonens Theorem Theorem | Resolution [Theorem] | Induction Term Proof Proof | Custom Text [Theorem]

unique type InferenceRule
  = ModusPonensRule | ModusTollensRule | HypotheticalSyllogism
  | DisjunctiveSyllogism | Resolution | UniversalInstantiation
  | ExistentialGeneralization | CustomRule Text (Proposition -> Proposition -> Optional Proposition)
```
Functions: `applyRule`, `forwardChain`, `backwardChain`, `checkConsistency`

---

## 2D: NARS (Non-Axiomatic Reasoning)

### Narsese.u
```
unique type NarsTerm
  = NAtom Text | NSet SetType [NarsTerm]
  | NInheritance NarsTerm NarsTerm | NSimilarity NarsTerm NarsTerm
  | NImplication NarsTerm NarsTerm | NEquivalence NarsTerm NarsTerm
  | NConjunction [NarsTerm] | NDisjunction [NarsTerm] | NNegation NarsTerm
  | NImage ImageType NarsTerm [NarsTerm] Nat | NProduct [NarsTerm]
  | NTemporalImpl TemporalOrder NarsTerm NarsTerm

unique type SetType = ExtensionalSet | IntensionalSet
unique type ImageType = ExtImage | IntImage
unique type TemporalOrder = Before | After | Concurrent
```

### TruthValue.u
```
unique type TruthValue = { frequency : Float, confidence : Float }
```
Functions: `revision`, `deduction`, `abduction`, `induction`, `expectation`

### NarsConcept.u
```
unique type Sentence = { term : NarsTerm, truth : TruthValue, stamp : Stamp, punctuation : Punctuation }
unique type Stamp = { evidenceBase : [Nat], creationTime : Nat, occurrenceTime : Optional Nat }
unique type Punctuation = Judgement | Question | Goal | Quest

unique type Concept = { term : NarsTerm, beliefs : Bag Sentence, goals : Bag Sentence, questions : [Sentence], termLinks : [TermLink], taskLinks : [TaskLink], priority : Float, durability : Float, quality : Float }
unique type Task = { sentence : Sentence, priority : Float, parentTask : Optional Task }
unique type TermLink = { target : NarsTerm, linkType : LinkType, priority : Float }
unique type TaskLink = { target : Task, linkType : LinkType, priority : Float }
unique type LinkType = Self | Component | Compound | ComponentStatement | CompoundStatement
unique type Bag a = { items : Map Text (a, Float), capacity : Nat }
```
Functions: `Bag.probabilisticSelect`

### NarsInference.u
```
unique type NarsRule = Deduction | Abduction | Induction | Exemplification | Comparison | Analogy | Resemblance | Revision | Intersection | Union | Difference | TemporalDeduction | TemporalInduction | Decomposition | Contraposition | CustomNarsRule Text (Sentence -> Sentence -> Optional Sentence)
```
Functions: `apply`, `forwardInfer`, `backwardInfer`
```
unique type NarsMemory = { concepts : Bag Concept, inputBuffer : Bag Task, cycleCount : Nat }
```
Functions: `NarsMemory.cycle` (one inference cycle)

---

## 2E: Unified Memory (OpenClaw DB Unification)

Bridges structures from both reference repos:

### MemoryItem.u (from openclaw-memory-offline-sqlite `items` table)
```
unique type MemoryItem = { id : Text, text : Text, entityId : Text, processId : Text, sessionId : Text, timestamp : Nat, embedding : Optional [Float], metadata : Map Text Text }
```

### MemoryFact.u (from offline-sqlite `facts` table)
```
unique type MemoryFact = { id : Text, subject : Text, predicate : Text, object : Text, sourceMemory : Text, confidence : Float, extractionMethod : ExtractionMethod }
unique type ExtractionMethod = SimpleExtraction | NarsInferred | AxiomaticProof | ManualEntry
```

### MemoryGraph.u (unifying Graphiti + offline-sqlite KG)
```
unique type GraphNode = { id : Text, nodeType : Text, label : Text, group : MemoryGroup, properties : Map Text Text }
unique type GraphEdge = { source : Text, target : Text, label : Text, weight : Float, temporal : Optional TemporalInfo }
unique type TemporalInfo = { validFrom : Nat, validUntil : Optional Nat, episodic : Boolean }
unique type MemoryGroup = PrivateAgent Text | SharedUser | SharedSystem | KnowledgeBase KGSource
unique type MemoryLayer = PrivateFiles | SharedFiles | SharedKnowledgeGraph | FactsStore | EmbeddingsStore
```

### UnifiedMemory.u
```
unique type UnifiedMemory = { kg : KnowledgeGraph, narsMemory : NarsMemory, items : Map Text MemoryItem, facts : [MemoryFact], graph : MemoryGraphDB, layers : Map MemoryLayer [Text] }
unique type MemoryGraphDB = { nodes : Map Text GraphNode, edges : [GraphEdge] }
```
Functions: `search`, `searchFacts`, `getRelated`, `addMemory`, `extractFacts`, `narsInfer`, `axiomaticProve`, `graphStats`

---

## Verification
```bash
ucm transcript unison/**/*.u
# All types should parse without errors
```

## Next
Proceed to `docs/steps/step3-parsers.md`.
