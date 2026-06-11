# NLPAICS 2026 Summer School — The Paradigm Shift: From Rules to Models in NLP

Materials for the [NLPAICS 2026 Summer School](https://summer-school.gplsi.es/) (Alicante, 15–17 June 2026): slides, hands-on notebooks, and setup scripts for every lesson.

## Quick start

```bash
git clone https://github.com/EEstevanell/NLPAICS-2026-summer-school.git
cd NLPAICS-2026-summer-school
./setup.sh
```

This installs the dependencies for **all** lessons. To set up only the lessons you need (faster), pass their numbers:

```bash
./setup.sh 07          # just lesson 07
./setup.sh 04 06 07    # all of Day 2's afternoon
```

Then open the lesson's notebook:

```bash
jupyter lab 07-model-hyperparameter-optimisation/
```

## Requirements

- Python 3.10+ and `pip`
- Jupyter (`pip install jupyterlab`)
- Git and a Unix-like shell (Linux, macOS, or WSL on Windows)
- Internet access on first run (setup scripts download datasets/models)

## Repository layout

Each lesson lives in its own numbered directory:

```
NN-lesson-name/
├── README.md     # lesson title and info
├── setup.sh      # installs everything this lesson needs
├── *.pptx/pdf    # slides
└── *.ipynb       # practical notebook
```

`setup.sh` at the repo root runs each lesson's `setup.sh` in order, continues past failures, and reports any that failed.

## Programme

### Day 1 · Monday 15 June — LLM Foundations

| Lesson | Lecturer |
|---|---|
| [01 — Understanding Language Models](01-understanding-language-models/) | Hansi Hettiarachchi |
| [02 — LLMs for Low-Resource Languages](02-llms-for-low-resource-languages/) | Robiert Sepulveda Torres |
| [03 — Fairness in ML: Evaluating Gender Bias in LLMs](03-fairness-gender-bias-in-llms/) | Juan Pablo Consuegra Ayala |

### Day 2 · Tuesday 16 June — LLM Applications

| Lesson | Lecturer |
|---|---|
| [04 — Quality Estimation for Machine Translation](04-quality-estimation-for-mt/) | Tharindu Ranasinghe |
| [05 — Machine Translation for Low-Resource Languages](05-mt-for-low-resource-languages/) | Alicia Picazo Izquierdo |
| [06 — Explainable AI in NLP](06-explainable-ai-in-nlp/) | Salima Lamsiyah |
| [07 — Model and Hyperparameter Optimisation](07-model-hyperparameter-optimisation/) | Ernesto Luis Estevanell |

### Day 3 · Wednesday 17 June — LLM Applications

| Lesson | Lecturer |
|---|---|
| [08 — Gaze Data in NLP Research](08-gaze-data-in-nlp-research/) | Cengiz Acartürk |
| [09 — Beyond the Single Text: NLP in Digital Humanities](09-nlp-in-digital-humanities/) | Isuri Anuradha |
| [10 — Legal NLP in the LLM Era](10-legal-nlp-in-the-llm-era/) | Damith Premasiri |
| [11 — LLMs and Sentiment Analysis](11-llms-and-sentiment-analysis/) | Maram Alharbi |

Full schedule (keynotes, panel, invited lecture): [summer-school.gplsi.es/programme](https://summer-school.gplsi.es/programme/)

## Troubleshooting

- A lesson's setup failed? Re-run just that lesson: `./setup.sh NN`. The root script tells you exactly which lessons failed.
- Use a virtual environment to keep things clean: `python -m venv .venv && source .venv/bin/activate` before running `./setup.sh`.
- Still stuck? Ask a teaching assistant, or contact <summer-school@dlsi.ua.es>.

## For lecturers

Put your slides and notebook in your lesson directory, and fill in its `setup.sh` with everything the practical needs: pinned pip installs, dataset downloads, model caching. It must run non-interactively and be safe to re-run.
