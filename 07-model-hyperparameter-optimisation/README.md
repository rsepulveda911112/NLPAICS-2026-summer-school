# Model and Hyperparameter Optimisation

**NLPAICS 2026 Summer School — The Paradigm Shift** · Day 2 · Tuesday 16 June 2026
**Lecturer:** Ernesto Luis Estevanell

*Automated Hyperparameter Optimization and Model Selection for NLP Pipelines.* A hands-on practical
that climbs a ladder of automation on one dataset (**20 Newsgroups**, 4 topics):

1. **Tune by hand** with scikit-learn — grid & random search over a TF-IDF → classifier pipeline
   (the 72% → 84% "before/after" hook), cross-validation, and the combinatorial explosion that
   motivates AutoML.
2. **Hand over the pipeline** with **AutoGOAL** — `find_classes` registries (scikit-learn + NLTK),
   semantic types, the pipeline-as-a-graph search space, `AutoML` with budgets/metrics, and how to
   steer the search.
3. **Extend the search** — write your own AutoGOAL block, then wrap a **transformer language model**
   (`all-MiniLM-L6-v2`) as a custom block and let the search choose it over TF-IDF. The bridge from
   classical AutoML to the LLM era.

Includes **🟢 Your turn** exercises, **💾 Checkpoints** (self-contained restart points), and
**★ Stretch** goals.

## Setup

```bash
cd NLPAICS-2026-summer-school
./setup.sh 07
```

Then open `practical.ipynb` and select the **NLPAICS 07** kernel.

## Environment notes

- **Python 3.10 required.** AutoGOAL's scientific stack (scipy/scikit-learn/gensim) is pinned to
  versions with cp310 wheels, so the install is wheels-only (no compiler). The vast.ai
  **`...-py310`** PyTorch image satisfies this — its `/venv/main` is Python 3.10, and the lesson
  venv inherits it. `setup.sh` aborts with a clear message on Python 3.11+.
- `setup.sh` installs, all via pip: a pinned scientific stack, AutoGOAL core + the `sklearn`/`nltk`
  contribs (from the Python-3.10 GitHub branches), **`sentence-transformers`** for the Part-3 LLM
  block, the NLTK data, and pre-caches the dataset (20 Newsgroups) and the embedding model so the
  session never waits on the network.
- `torch` comes from the base image (`/venv/main`) and is **not** reinstalled. The embedding model
  runs fine on CPU; a GPU is not required.
- **Runs offline during the session.** The notebook sets `HF_HUB_OFFLINE=1` / `TRANSFORMERS_OFFLINE=1`
  in its first cell so the pre-cached embedding model never makes a blocking network call mid-session.
- **A note on multiprocessing.** AutoGOAL evaluates each candidate pipeline in a worker process.
  On the vast.ai Linux image that uses `fork`, which shares memory with the kernel — so
  notebook-defined custom blocks (e.g. the Part-3 `TransformerEmbedding`) are visible to the workers.
  The notebook pins `fork` explicitly in its setup cell — a no-op on Linux, and what makes it behave
  identically if you develop it on macOS.
- All four AutoGOAL packages are given to pip together so it resolves `autogoal` to the fixed
  **1.0.4** (core branch `v1.0.4`) instead of the PyPI `autogoal` (which pins scipy 1.6). Manual
  install:
  ```bash
  pip install \
    "git+https://github.com/gia-uh/autogoal.git@v1.0.4#subdirectory=autogoal" \
    "git+https://github.com/autogoal/autogoal-contrib.git@v0.8.5#subdirectory=autogoal_contrib" \
    "git+https://github.com/autogoal/autogoal-contrib.git@v0.8.5#subdirectory=autogoal_sklearn" \
    "git+https://github.com/autogoal/autogoal-contrib.git@v0.8.5#subdirectory=autogoal_nltk" \
    "numpy==1.26.4" "sentence-transformers==5.5.1"
  ```
  (Needs `git`. For a frozen ref, swap the branch names for commit SHAs `0aae518` / `39d2711`.)
