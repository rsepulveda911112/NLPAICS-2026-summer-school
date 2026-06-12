# NLPAICS 2026 Summer School — The Paradigm Shift: From Rules to Models in NLP

Materials for the [NLPAICS 2026 Summer School](https://summer-school.gplsi.es/) (Alicante, 15–17 June 2026): slides, hands-on notebooks, and setup scripts for every lesson.

## Quick start

```bash
git clone https://github.com/EEstevanell/NLPAICS-2026-summer-school.git
cd NLPAICS-2026-summer-school
./setup.sh
```

This creates an **isolated environment per lesson** (so lessons' dependencies never conflict) and registers a Jupyter kernel for each. To set up only the lessons you need (faster), pass their numbers:

```bash
./setup.sh 07          # just lesson 07
./setup.sh 04 06 07    # all of Day 2's afternoon
```

Then open the lesson's notebook and **select its kernel** ("NLPAICS NN — …") from the kernel picker:

```bash
jupyter lab 07-model-hyperparameter-optimisation/
```

## Requirements

- Python 3.10+ with `venv` (on Debian/Ubuntu: `apt-get install python3-venv`)
- Jupyter (`pip install jupyterlab`)
- On vast.ai PyTorch templates all of the above is preinstalled; lesson environments inherit the image's torch/CUDA
- Git and a Unix-like shell (Linux, macOS, or WSL on Windows)
- Internet access on first run (setup scripts download datasets/models)

## Repository layout

Each lesson lives in its own numbered directory:

```
NN-lesson-name/
├── README.md     # lesson title and info
├── setup.sh      # installs everything this lesson needs
├── .venv/        # the lesson's own environment (created by setup, not in git)
├── *.pptx/pdf    # slides
└── practical.ipynb  # hands-on notebook (template provided, kernel pre-wired)
```

The root `setup.sh`, for each lesson: creates a virtualenv (inheriting the system's torch/CUDA), runs the lesson's `setup.sh` inside it, and registers a Jupyter kernel named after the lesson. It continues past failures and reports any lesson that failed.

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

## Running on vast.ai (organisers)

We use the **PyTorch (Vast)** template with Jupyter launch mode. To make instances self-provision:

1. On [cloud.vast.ai/templates](https://cloud.vast.ai/templates/), edit the *PyTorch (Vast)* template.
2. In *Environment Variables*, add `PROVISIONING_SCRIPT` =
   `https://raw.githubusercontent.com/EEstevanell/NLPAICS-2026-summer-school/main/provision_vast.sh`
3. Set disk space to **150 GB** when renting (cannot be changed after creation).
4. Create the instance(s). On first boot the script clones this repo into `/workspace` and runs `./setup.sh` for all lessons (log: `/workspace/nlpaics_setup.log`).

Students then open Jupyter, browse into the lesson folder, and open `practical.ipynb` — the right kernel is pre-selected.

On vast images the ML stack lives in `/venv/main`; `setup.sh` detects this and chains each lesson environment to it, so torch/CUDA are available without reinstalling.

## Troubleshooting

- A lesson's setup failed? Re-run just that lesson: `./setup.sh NN`. The root script tells you exactly which lessons failed.
- Environment broken? Delete it and rebuild: `rm -rf NN-lesson-name/.venv && ./setup.sh NN`.
- Notebook can't find a package? Check you selected the lesson's own kernel ("NLPAICS NN"), not the default Python 3.
- Still stuck? Ask a teaching assistant, or contact <summer-school@dlsi.ua.es>.

## For lecturers

Put your slides and notebook in your lesson directory, and fill in its `setup.sh` with everything the practical needs: pinned pip installs, dataset downloads, model caching. Your script runs inside your lesson's own virtualenv, so plain `pip install` is already isolated — don't reinstall torch unless you need a specific version. It must run non-interactively and be safe to re-run.

Push your changes directly to `main` (you only ever touch your own folder).

**Testing on the GPU machine we provide:** you receive a link that opens Jupyter in your browser. There, open a terminal (File > New > Terminal) and run:

```bash
cd /workspace/NLPAICS-2026-summer-school
git pull && ./setup.sh NN        # NN = your lesson number
```

When it prints `OK`, open your `practical.ipynb`, select your lesson's kernel ("NLPAICS NN"), and run it top to bottom. The machine is temporary: only what you push to the repository is kept.

**Testing locally (optional):** the student machines use the public [`vastai/pytorch`](https://hub.docker.com/r/vastai/pytorch/) image, so you can iterate on your `setup.sh` on your own computer if you have Docker (and an NVIDIA GPU + container toolkit for the GPU parts):

```bash
docker run --rm -it --gpus all vastai/pytorch:<TAG> bash   # use the exact tag we announce
git clone https://github.com/EEstevanell/NLPAICS-2026-summer-school.git
cd NLPAICS-2026-summer-school && ./setup.sh NN
```

Without an NVIDIA GPU (e.g. macOS), drop `--gpus all`: installs and downloads can still be tested, GPU cells cannot. The shared test machine remains the reference: always do your final run there.
