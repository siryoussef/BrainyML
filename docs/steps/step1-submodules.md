# Step 1: Git Submodules Setup

**Status:** ✅ Complete

## Tasks

### 1a. NELL data (gitignored)
The `submodules/NELL/` directory contains ~3.8GB of CMU RTW data and is listed in `.gitignore`.
Files present:
- `NELL.08m.1115.esv.csv.gz` (930MB) – All beliefs (TSV: Entity/Relation/Value + confidence)
- `NELL.08m.1110.cesv.csv.gz` (2.7GB) – Candidate beliefs
- `NELL.08m.1115.ontology.csv.gz` (3.9MB) – Ontology of categories & relations
- `NELL.08m.1115.extractionPatterns.csv.gz` (229MB) – CPL extraction patterns
- `NELL.08m.734.categories.csv` (16KB) – Category list
- `NELL.08m.1116.heatmap.tsv` (6MB) – Learning activity heatmap

**NELL TSV format** (ontology): `Entity\tRelation\tValue` (tab-separated)
**NELL TSV format** (beliefs): complex multi-field with entity, generalizations, confidence scores, iteration metadata, evidence URLs.

No further action needed for NELL — it's already in place and gitignored.

### 1b. CSKG submodule
`submodules/CSKG/` is currently empty.
```bash
cd /Shared/@Repo/BrainyML
git submodule add https://github.com/usc-isi-i2/cskg.git submodules/CSKG
```
CSKG uses KGTK format: 10-column TSV (id, node1, relation, node2, node1_label, node2_label, relation_label, relation_dimension, source, sentence).

### 1c. Reference submodules (read-only)
```bash
cd /Shared/@Repo/BrainyML
git submodule add https://github.com/clawdbrunner/openclaw-graphiti-memory.git submodules/openclaw-graphiti-memory
git submodule add https://github.com/AkashaBot/openclaw-memory-offline-sqlite.git submodules/openclaw-memory-offline-sqlite
```

### 1d. Commit
```bash
git add .gitmodules submodules/CSKG submodules/openclaw-graphiti-memory submodules/openclaw-memory-offline-sqlite
git commit -m "Add CSKG and reference submodules"
```

## Verification
```bash
git submodule status
# Should show 3 submodules (NELL is gitignored, not a submodule)
```

## Next
Proceed to `docs/steps/step2-unison-types.md`.
