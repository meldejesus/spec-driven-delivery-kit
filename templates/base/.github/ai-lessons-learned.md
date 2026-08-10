# AI Lessons Learned

AI/model-workflow lessons discovered during implementation. Use this file for
guidance that applies to AI sandbox, model-backed artifact generation,
embedding workflows, and local AI tooling without necessarily applying to every
Osmosis product repository.

---

## Batch External-Model Artifact Generation Must Start Bounded (OSMS-18410)

Artifact-generation workflows that call external models across many records must
not make the full batch the first executable path. Start with redacted preflight
checks, a bounded small batch, checkpoint/resume behavior, run metadata, and an
explicit approval gate before the full external-model run.

**Rule:** Any batch artifact generator that can incur external model cost or
broad artifact churn must require a bounded mode (`--limit` or explicit IDs),
write checkpoints and run reports, and document the exact full-run command
before the full batch is approved.

---

## Embedding Model Upgrades Require Target Corpus Regeneration (OSMS-18410)

An embedding upgrade changes both query vectors and stored/target vectors.
Mixing a new query embedding model with old target embeddings can silently
produce invalid matching or hard dimension failures.

**Rule:** When upgrading embedding models, regenerate or audit every target
corpus used for matching, record the model name and vector dimension in
metadata, and hard-fail if query and target dimensions differ.

---

## Optional Service Clients Should Be Constructed At Execution Time (OSMS-18410)

Routes and pages can be imported during local builds, tests, or static
generation even when the optional service they use is not configured. Throwing
during module import turns a missing local Speech, Elasticsearch, or model env
value into an unrelated build failure.

**Rule:** For optional services, validate env and construct clients inside the
request handler or execution function that actually needs the service. Avoid
throwing for optional local env at module import time.
