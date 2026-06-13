"""Helper functions extracted from the translation_evaluation notebook.

These helpers are kept pure (no I/O, no model calls) so they can be exercised
in unit tests without loading any HuggingFace model.
"""

from __future__ import annotations

import json

_REQUIRED_JUDGE_KEYS: tuple[str, ...] = (
    "score_adequacy",
    "score_fluency",
    "score_grammar",
    "justification",
)

_REQUIRED_HUMAN_KEYS: tuple[str, ...] = (
    "score_adequacy",
    "score_fluency",
    "score_grammar",
)

_JSON_INSTRUCTION = (
    "Output only valid JSON with keys: score_adequacy, score_fluency, "
    "score_grammar (integers 1-5), justification (string). "
    "Do not include any other text."
)


def build_translation_prompt(source_sentence: str, target_language: str) -> str:
    """Return the user-message body asking the model to translate a sentence.

    The returned string is the natural-language instruction; the notebook wraps
    it in `tokenizer.apply_chat_template` so that the underlying chat model
    receives the expected role tokens.
    """
    if not source_sentence or not source_sentence.strip():
        raise ValueError("source_sentence must be a non-empty string")
    if not target_language or not target_language.strip():
        raise ValueError("target_language must be a non-empty string")
    return (
        f"Translate the following English sentence into {target_language}. "
        "Output only the translation, with no explanation or surrounding text."
        "\n\n"
        f"English: {source_sentence}\n"
        f"{target_language}:"
    )


def build_judge_prompt(
    source_sentence: str,
    translation: str,
    rubric: dict[str, str],
) -> str:
    """Return the user-message body for the Selene judge.

    Embeds the source sentence, the candidate translation, and a rendered
    version of the rubric. Instructs the model to reason step by step and
    then emit a single JSON object matching `_REQUIRED_JUDGE_KEYS`.
    """
    if not source_sentence or not source_sentence.strip():
        raise ValueError("source_sentence must be a non-empty string")
    if not translation or not translation.strip():
        raise ValueError("translation must be a non-empty string")
    if not rubric:
        raise ValueError("rubric must be a non-empty dict")
    rubric_text = "\n".join(f"- {k}: {v}" for k, v in rubric.items())
    return (
        "You are an expert translation evaluator.\n\n"
        f"Source sentence (English): {source_sentence}\n"
        f"Translation to evaluate: {translation}\n\n"
        "Evaluation rubric (score each criterion 1-5):\n"
        f"{rubric_text}\n\n"
        "First, reason step by step about the quality of the translation "
        "according to each criterion. Then output your evaluation.\n\n"
        f"{_JSON_INSTRUCTION}"
    )


def parse_judge_response(raw: str) -> dict[str, int | str]:
    """Parse Selene's raw output as JSON and validate required keys.

    Tolerates surrounding prose by extracting the substring between the first
    ``{`` and the last ``}``. Raises ``ValueError`` with the offending raw
    string when the response is not parseable or is missing required keys.
    """
    start = raw.find("{")
    end = raw.rfind("}")
    if start == -1 or end == -1 or start >= end:
        raise ValueError(f"Judge did not return valid JSON: {raw!r}")
    candidate = raw[start : end + 1]
    try:
        data: dict[str, object] = json.loads(candidate)
    except json.JSONDecodeError as exc:
        raise ValueError(f"Judge did not return valid JSON: {raw!r}") from exc
    for key in _REQUIRED_JUDGE_KEYS:
        if key not in data:
            raise ValueError(f"Judge response missing required key '{key}': {raw!r}")
    return {
        "score_adequacy": int(data["score_adequacy"]),  # type: ignore[call-overload]
        "score_fluency": int(data["score_fluency"]),  # type: ignore[call-overload]
        "score_grammar": int(data["score_grammar"]),  # type: ignore[call-overload]
        "justification": str(data["justification"]),
    }


def validate_human_scores(scores: dict[str, int]) -> None:
    """Validate that ``scores`` contains all three criteria with values 1-5.

    Raises ``ValueError`` on the first violation so the student can fix one
    issue at a time and re-run the cell. Non-integer values (e.g. a string
    accidentally left in place of a number) are also rejected.
    """
    for key in _REQUIRED_HUMAN_KEYS:
        if key not in scores:
            raise ValueError(f"Missing criterion: {key}")
    for criterion, value in scores.items():
        # `bool` is a subclass of `int` in Python — explicitly reject it so
        # that `True`/`False` cannot pose as a score.
        if isinstance(value, bool) or not isinstance(value, int):
            raise ValueError(f"Score for {criterion} must be 1-5, got {value!r}")
        if value < 1 or value > 5:
            raise ValueError(f"Score for {criterion} must be 1-5, got {value}")
