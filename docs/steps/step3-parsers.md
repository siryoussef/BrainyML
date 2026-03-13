# Step 3: Python KG Parsers

**Status:** ⬜ Not started

## Tasks

### 3a. NELL parser (`scripts/parse_nell.py`)
Reads NELL TSV files from `submodules/NELL/` and outputs Unison code.

**Input files:**
- `NELL.08m.1115.ontology.csv.gz` – Ontology (Entity/Relation/Value TSV, ~4MB compressed)
- `NELL.08m.1115.esv.csv.gz` – Beliefs (~930MB compressed, complex multi-field TSV)
- `NELL.08m.734.categories.csv` – Category list (16KB, plain CSV)

**NELL belief TSV format (observed):**
Each line has tab-separated fields including: entity name, `generalizations`, target concept, confidence score, iteration metadata, aliases, other category generalizations, and evidence/source URLs.

**Strategy:**
1. Parse ontology first (small) to build category/relation maps.
2. Stream beliefs file in chunks (pandas `chunksize` or line-by-line) because it's ~930MB.
3. Emit Unison `Entity` and `Fact` constructor calls.

### 3b. CSKG parser (`scripts/parse_cskg.py`)
Reads CSKG KGTK 10-column edges from `submodules/CSKG/`.

**KGTK format:** `id, node1, relation, node2, node1_label, node2_label, relation_label, relation_dimension, source, sentence`

**Strategy:**
1. Map `node1` → Entity, `node2` → Entity, `relation` → Relation.
2. Emit Unison `Fact` constructor calls.

### 3c. CLI entry (`scripts/parse_kg.py`)
```python
import click

@click.group()
def cli():
    pass

@cli.command()
@click.option('--input', required=True)
@click.option('--output', required=True)
@click.option('--dry-run', is_flag=True)
def nell(input, output, dry_run):
    # calls parse_nell logic
    pass

@cli.command()
@click.option('--input', required=True)
@click.option('--output', required=True)
@click.option('--dry-run', is_flag=True)
def cskg(input, output, dry_run):
    # calls parse_cskg logic
    pass

if __name__ == '__main__':
    cli()
```

**Usage:**
```bash
python scripts/parse_kg.py nell --input submodules/NELL/ --output unison/kg/generated/
python scripts/parse_kg.py cskg --input submodules/CSKG/ --output unison/kg/generated/
```

## Verification
```bash
# Dry run on ontology (small file)
python scripts/parse_kg.py nell --input submodules/NELL/ --output /tmp/test/ --dry-run
# Check output contains valid Unison type constructors
head /tmp/test/*.u
```

## Next
Proceed to `docs/steps/step4-openclaw.md`.
