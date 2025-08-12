#!/usr/bin/env python3
# gen_descriptions.py — generate OR remove :description: for AsciiDoc pages via Ollama 0.11.4
# Outcome-first descriptions, standardized roles (Server, Proxy, Client, Retail), robust sentence cleanup.

import argparse
import csv
import os
import re
from pathlib import Path
import requests

# =========================
# Config
# =========================

# Banned product/brand literals (case-insensitive)
DEFAULT_BANNED_LITERALS = {"Uyuni", "SUSE Manager", "SUSE"}

# Regex bans (safety net; we normalize terms instead)
DEFAULT_BANNED_REGEX = [r"\bSUSE\s+Multi[- ]Linux\s+Manager\b"]

# Long → short replacements (regex → token). Allow plain "openSUSE" & "CentOS" as-is.
SHORT_MAP = {
    r"\bRed Hat Enterprise Linux\b": "RHEL",
    r"\bSUSE Linux Enterprise Server\b": "SLES",
    r"\bSUSE Linux Enterprise\b": "SLE",
    r"\bOracle Linux\b": "OL",
    r"\bopenSUSE(?:\s+Leap|\s+Tumbleweed)\b": "openSUSE",
    r"\bAmazon Linux\b": "AL",
    r"\bCentOS\s+Stream\b": "CentOS",
}

# Standardized role terminology (map variants → canonical capitalized terms)
ROLE_TERM_MAP = [
    # Server
    (r"\bSUSE(?:[- ]based)?\s+environment\b", "Server"),
    (r"\bSUSE\s+server\s+environment\b", "Server"),
    (r"\bMLM\s+server\s+environment\b", "Server"),
    (r"\bMLM\s*server\b", "Server"),
    (r"\bSUSE\s*server\b", "Server"),
    (r"\bmanagement\s+server\b", "Server"),
    (r"\bprimary\s+server\b", "Server"),
    (r"\bcentral\s+server\b", "Server"),
    # Proxy
    (r"\bMLM\s*proxy\b", "Proxy"),
    (r"\bSUSE\s*proxy\b", "Proxy"),
    (r"\bproxy\s+server\b", "Proxy"),
    (r"\bproxy\s+system\b", "Proxy"),
    (r"\bintermediate\s+node\b", "Proxy"),
    # Client
    (r"\bMLM\s*client\b", "Client"),
    (r"\bSUSE\s*client\b", "Client"),
    (r"\bmanaged\s+(system|node|host|client)\b", "Client"),
    (r"\bend\s+(node|host|system)\b", "Client"),
    # Retail
    (r"\bretail\s+environments?\b", "Retail"),
    (r"\bretail\s+contexts?\b", "Retail"),
    (r"\bretail\s+systems?\b", "Retail"),
    (r"\bretail\s+deployments?\b", "Retail"),
    (r"\bMLM\s*retail\b", "Retail"),
    (r"\bSUSE\s*retail\b", "Retail"),
]

# For relevance checks: SHORT → alias regexes
CLIENT_ALIASES = {
    "RHEL": [r"\bRHEL\b", r"\bRed Hat Enterprise Linux\b"],
    "SLE":  [r"\bSLE\b", r"\bSUSE Linux Enterprise\b"],
    "SLES": [r"\bSLES\b", r"\bSUSE Linux Enterprise Server\b"],
    "OL":   [r"\bOL\b", r"\bOracle Linux\b"],
    "Ubuntu": [r"\bUbuntu\b"],
    "Debian": [r"\bDebian\b"],
    "openSUSE": [r"\bopenSUSE\b", r"\bopenSUSE\s+Leap\b", r"\bopenSUSE\s+Tumbleweed\b"],
    "AL":   [r"\bAL\b", r"\bAmazon Linux\b"],
    "Rocky": [r"\bRocky Linux\b", r"\bRocky\b"],
    "CentOS": [r"\bCentOS\b", r"\bCentOS\s+Stream\b"],
    "MicroOS": [r"\bMicroOS\b"],
}

PROMPT_TMPL = """You write concise meta descriptions for docs.

Task:
- Read the AsciiDoc page content.
- Write ONE complete sentence, ideally 140–155 characters (never <120 or >160).
- The sentence MUST end with a period. No lists. No trailing fragments.
- Focus on what the user will achieve or benefit from; do NOT describe the document itself.
- Avoid phrases like "This guide", "This page", "In this document", etc.
- Only mention client OS names if the page clearly focuses on tasks, configuration, or issues specific to them.
- For roles, only use exactly: Server, Proxy, Client, Retail (capitalized).
- Do NOT use product/brand names: {blacklist}. Allowed short forms if relevant: RHEL, SLE/SLES, OL, Ubuntu, Debian, openSUSE, AL, Rocky, CentOS, MicroOS.
- Avoid colons, pipes, newlines, quotes, emojis. Neutral, actionable tone.

AsciiDoc page content:
---
{content}
---
Output ONLY the final sentence:
"""

# =========================
# Ollama HTTP (chat → generate; tolerate 404/405)
# =========================

def call_ollama(model: str, prompt: str, timeout=120, base_url: str = "http://127.0.0.1:11434") -> str:
    base = base_url.rstrip("/")
    r = requests.post(
        f"{base}/api/chat",
        json={"model": model, "stream": False,
              "messages": [{"role": "system", "content": "You answer succinctly."},
                           {"role": "user", "content": prompt}]},
        timeout=timeout
    )
    if r.status_code in (404, 405):
        r = requests.post(
            f"{base}/api/generate",
            json={"model": model, "prompt": prompt, "stream": False},
            timeout=timeout
        )
    r.raise_for_status()
    data = r.json()
    return (data.get("message", {}).get("content") or data.get("response") or "").strip()

# =========================
# Helpers
# =========================

FORBIDDEN_CHARS_RE = re.compile(r'[:|“”"‘’]')
ATTR_REF_RE = re.compile(r"\{[A-Za-z0-9_-]+\}")
DOC_META_PATTERNS = [
    r"^\s*This\s+(guide|page|document|section)\s+(describes|covers|explains|provides|offers|details|walks\s+you\s+through|helps\s+users)\s+",
    r"^\s*In\s+this\s+(guide|page|document|section)\s+",
    r"^\s*The\s+(guide|page|document|section)\s+(describes|covers|explains|provides|offers|details)\s+",
]
TRAILING_STOPWORDS = (
    "and or to for with in of on at by from into via as that which including such as than then while when where"
).split()

def normalize_whitespace(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip()

def enforce_short_forms(text: str) -> str:
    for pat, short in SHORT_MAP.items():
        text = re.sub(pat, short, text, flags=re.IGNORECASE)
    return text

def apply_roles(text: str) -> str:
    for pat, repl in ROLE_TERM_MAP:
        text = re.sub(pat, repl, text, flags=re.IGNORECASE)
    return text

def strip_forbidden_punct(s: str) -> str:
    s = FORBIDDEN_CHARS_RE.sub(" ", s)
    s = re.sub(r"\s{2,}", " ", s).strip()
    return s

def strip_attribute_refs(s: str) -> str:
    return ATTR_REF_RE.sub("", s)

def remove_banned_terms(text: str, banned_literals, banned_regexes):
    for pat in banned_regexes:
        text = re.sub(pat, "", text, flags=re.IGNORECASE)
    for name in sorted(banned_literals, key=len, reverse=True):
        text = re.sub(rf"\b{re.escape(name)}\b", "", text, flags=re.IGNORECASE)
    return normalize_whitespace(text)

def strip_doc_meta_openers(desc: str) -> str:
    """Remove doc-referential openers so we start with the action/value."""
    for pat in DOC_META_PATTERNS:
        desc = re.sub(pat, "", desc, flags=re.IGNORECASE).strip()
    desc = re.sub(r"^(by|with|through|using)\s+", "", desc, flags=re.IGNORECASE)
    return desc

def fix_slashes_and_leftovers(desc: str) -> str:
    """Clean orphan slashes and generic leftovers like 'in / environments'."""
    desc = re.sub(r"\b(in|on|for|across)\s*/\s*environments?\b", r"\1 systems", desc, flags=re.IGNORECASE)
    desc = re.sub(r"\bin\s+environments?\b", "in systems", desc, flags=re.IGNORECASE)
    desc = re.sub(r"\benvironments?\b", "systems", desc, flags=re.IGNORECASE)
    desc = re.sub(r"\s*/\s*", " ", desc)  # collapse remaining slashes
    desc = re.sub(r"\s{2,}", " ", desc).strip(" ,;:-")
    return desc

def trim_to_range(desc: str, min_len=120, max_len=160) -> str:
    if len(desc) <= max_len:
        return desc
    cut = desc[:max_len]
    m = re.search(rf"^(.{{{min_len},{max_len}}})([.!?)\]]|\s|$)", cut)
    if m:
        return m.group(1).rstrip()
    return cut.rstrip()

def ensure_complete_sentence(desc: str, min_len=120, max_len=160) -> str:
    """Fix mid-word truncation, drop dangling stopwords, end with period."""
    desc = normalize_whitespace(desc)
    if len(desc) > 0 and not re.search(r"[.!?]$", desc):
        if re.search(r"[A-Za-z0-9]$", desc) and not desc.endswith(" "):
            last_space = desc.rfind(" ")
            if last_space >= max(0, len(desc) - 20):
                desc = desc[:last_space].rstrip()
    desc = re.sub(r"[\s,;:]+$", "", desc).strip()
    words = desc.split()
    while words and words[-1].lower().strip(",.;") in TRAILING_STOPWORDS:
        words.pop()
    desc = " ".join(words).strip()
    if not desc.endswith("."):
        desc = desc.rstrip(",;: ") + "."
    if len(desc) > max_len:
        desc = desc[:max_len].rstrip()
        last_space = desc.rfind(" ")
        if last_space > min_len - 1:
            desc = desc[:last_space].rstrip() + "."
        elif not desc.endswith("."):
            desc = desc.rstrip(".") + "."
    return desc

def sanitize_desc(draft: str, banned_literals, banned_regexes) -> str:
    """
    Pipeline: whitespace → short forms → roles → ban names → strip {attrs} → strip forbidden punct
              → remove doc-meta → fix slashes → trim → enforce role caps → finalize sentence
    """
    desc = normalize_whitespace(draft)
    desc = enforce_short_forms(desc)
    desc = apply_roles(desc)
    desc = remove_banned_terms(desc, banned_literals, banned_regexes)
    desc = strip_attribute_refs(desc)
    desc = strip_forbidden_punct(desc)
    desc = strip_doc_meta_openers(desc)
    desc = fix_slashes_and_leftovers(desc)
    desc = trim_to_range(desc, 120, 160)
    # Enforce canonical capitalization of role terms
    desc = re.sub(r"\bserver\b", "Server", desc)
    desc = re.sub(r"\bproxy\b", "Proxy", desc)
    desc = re.sub(r"\bclient\b", "Client", desc)
    desc = re.sub(r"\bretail\b", "Retail", desc)
    desc = ensure_complete_sentence(desc, 120, 160)
    return desc.strip()

def expand_if_too_short(desc: str, payload: str, model: str, base_url: str, timeout: int = 120) -> str:
    if len(desc) >= 120:
        return desc
    prompt = f"""Rewrite this description to be 140–155 characters, neutral tone, single complete sentence ending with a period.
Only mention client OS names if the page clearly focuses on them. Use standardized role terms: Server, Proxy, Client, Retail (exactly as written).
Avoid colons, pipes, quotes, emojis, or list-like phrasing.
Original: {desc}
Context (do not quote): {payload[:800]}
"""
    try:
        return call_ollama(model, prompt, timeout=timeout, base_url=base_url)
    except Exception:
        return desc

def extract_page_payload(content: str) -> str:
    """Take first ~3000 chars after removing attribute lines, {attr} refs, and nav boilerplate."""
    lines = content.splitlines()
    lines = [ln for ln in lines if not re.match(r"^\s*:[A-Za-z0-9_-]+:\s*", ln)]
    lines = [ln for ln in lines if "nav-" not in ln.lower()]
    text = "\n".join(lines)
    text = strip_attribute_refs(text)
    return text[:3000]

def find_client_short_forms(text: str, limit: int = 3):
    found = []
    shorts_direct = [
        (r"\bRHEL\b", "RHEL"), (r"\bSLE\b", "SLE"), (r"\bSLES\b", "SLES"),
        (r"\bOL\b", "OL"), (r"\bUbuntu\b", "Ubuntu"), (r"\bDebian\b", "Debian"),
        (r"\bopenSUSE\b", "openSUSE"), (r"\bAL\b", "AL"), (r"\bRocky\b", "Rocky"),
        (r"\bCentOS\b", "CentOS"), (r"\bMicroOS\b", "MicroOS")
    ]
    for pat, short in list(SHORT_MAP.items()) + shorts_direct:
        if re.search(pat, text, flags=re.IGNORECASE):
            if short not in found:
                found.append(short)
        if len(found) >= limit:
            break
    return found

def clients_in_desc(desc: str):
    present = set()
    shorts = ["RHEL", "SLE", "SLES", "OL", "Ubuntu", "Debian", "openSUSE", "AL", "Rocky", "CentOS", "MicroOS"]
    for s in shorts:
        if re.search(rf"\b{re.escape(s)}\b", desc, flags=re.IGNORECASE):
            present.add(s)
    return present

def context_supports(short: str, payload: str) -> bool:
    aliases = CLIENT_ALIASES.get(short, [rf"\b{re.escape(short)}\b"])
    total = 0
    early_hit = False
    head = payload[:400]
    for pat in aliases:
        hits_all = re.findall(pat, payload, flags=re.IGNORECASE)
        total += len(hits_all)
        if re.search(pat, head, flags=re.IGNORECASE):
            early_hit = True
    return total >= 2 or early_hit

def remove_irrelevant_clients(desc: str, payload: str) -> str:
    """Strip client OS shorts that aren't supported by context (roles are always allowed)."""
    to_check = clients_in_desc(desc)
    if not to_check:
        return desc
    new = desc
    for short in to_check:
        if not context_supports(short, payload):
            new = re.sub(rf"\b{re.escape(short)}\b", "", new, flags=re.IGNORECASE)
            new = re.sub(r"\s{2,}", " ", new)
            new = re.sub(r"\s+,", ",", new)
            new = re.sub(r",\s*,", ", ", new)
            new = re.sub(r"\(\s*\)", "", new)
            new = re.sub(r"\s+(and|or)\s*,", " ", new, flags=re.IGNORECASE)
            new = re.sub(r"\s+(,|;)\s*", r"\1 ", new)
            new = new.replace(" ,", ",").strip()
    new = re.sub(r"\s+(for|on|across|including)\s*$", "", new, flags=re.IGNORECASE).strip()
    new = re.sub(r"\s{2,}", " ", new).strip(" -–—·,;")
    return new

# =========================
# Header placement & removal
# =========================

TITLE_RE = re.compile(r"^\s*=\s+.+")
DESC_RE  = re.compile(r"^:\s*description\s*:\s*", re.IGNORECASE)
REV_RE   = re.compile(r"^:\s*revdate\s*:\s*", re.IGNORECASE)
PAGEREV_RE = re.compile(r"^:\s*page-revdate\s*:\s*", re.IGNORECASE)

def upsert_description_attr(text: str, new_desc: str) -> str:
    """Place :description: after '= Title', before rev attributes. Replace if exists."""
    lines = text.splitlines()

    # Replace existing anywhere
    for i, line in enumerate(lines):
        if DESC_RE.match(line):
            lines[i] = f":description: {new_desc}"
            return "\n".join(lines)

    # Find title
    title_idx = None
    for i, line in enumerate(lines):
        if TITLE_RE.match(line):
            title_idx = i
            break
    if title_idx is None:
        return f":description: {new_desc}\n\n{text}"

    # Find insertion point: skip blank lines right after title
    insert_idx = title_idx + 1
    while insert_idx < len(lines) and lines[insert_idx].strip() == "":
        insert_idx += 1

    # If next non-blank is rev/page-rev, insert before it
    if insert_idx < len(lines) and (REV_RE.match(lines[insert_idx]) or PAGEREV_RE.match(lines[insert_idx])):
        lines.insert(insert_idx, f":description: {new_desc}")
        return "\n".join(lines)

    # Otherwise insert now
    lines.insert(insert_idx, f":description: {new_desc}")
    return "\n".join(lines)

def remove_description_in_header(text: str):
    """
    Remove :description: ONLY if it's in the header block:
    - After the first '= Title'
    - Among the attribute lines (':attr: ...') following the title (allow blank lines)
    Stop at the first non-blank, non-attribute line.
    Returns (new_text, removed_value or None)
    """
    lines = text.splitlines()
    # find title
    title_idx = None
    for i, line in enumerate(lines):
        if TITLE_RE.match(line):
            title_idx = i
            break
    if title_idx is None:
        return text, None

    # walk the header attribute block
    i = title_idx + 1
    # skip blank lines after title
    while i < len(lines) and lines[i].strip() == "":
        i += 1

    removed = None
    while i < len(lines):
        ln = lines[i]
        if ln.strip() == "":
            i += 1
            continue
        if ln.startswith(":"):  # attribute line
            if DESC_RE.match(ln) and removed is None:
                removed = ln.split(":", 2)[-1].strip()
                del lines[i]
                continue
            i += 1
            continue
        break  # header ends
    return "\n".join(lines), removed

# =========================
# Skip rules for nav files
# =========================

NAV_GENERIC_RE = re.compile(r"^nav(?:-.+)?\.adoc$", re.IGNORECASE)
NAV_GUIDE_RE   = re.compile(r"^nav-.+-guide\.adoc$", re.IGNORECASE)

def should_skip(path: Path) -> bool:
    if path.suffix.lower() != ".adoc":
        return True
    name = path.name
    if NAV_GUIDE_RE.match(name):
        return True
    if NAV_GENERIC_RE.match(name):
        return True
    lowered_parts = [p.lower() for p in path.parts]
    if "nav" in lowered_parts or "navigation" in lowered_parts:
        return True
    return False

# =========================
# Main
# =========================

def main():
    ap = argparse.ArgumentParser(description="Generate or remove :description: for AsciiDoc files (Ollama 0.11.4).")
    ap.add_argument("root", help="Path to repo directory (e.g., uyuni-docs/modules)")
    ap.add_argument("--model", default="llama3.1:8b", help="Ollama model (default: llama3.1:8b)")
    ap.add_argument("--ollama-url", default=os.environ.get("OLLAMA_URL", "http://127.0.0.1:11434"),
                    help="Base URL (default http://127.0.0.1:11434)")
    ap.add_argument("--blacklist", default="", help="Comma-separated extra product/brand names to ban")
    ap.add_argument("--dry-run", action="store_true", help="Preview only; do not write files")
    ap.add_argument("--report", default="description_report.csv", help="CSV report path")
    ap.add_argument("--remove", action="store_true", help="REMOVE mode: delete :description: in header block only")
    args = ap.parse_args()

    root = Path(args.root).resolve()
    if not root.exists():
        raise SystemExit(f"Path not found: {root}")

    banned_literals = set(DEFAULT_BANNED_LITERALS)
    if args.blacklist:
        banned_literals |= {x.strip() for x in args.blacklist.split(",") if x.strip()}

    changed = []

    for path in root.rglob("*.adoc"):
        if should_skip(path):
            continue

        try:
            raw = path.read_text(encoding="utf-8", errors="ignore")
        except Exception as e:
            print(f"[WARN] Cannot read {path}: {e}")
            continue

        if args.remove:
            # --- REMOVE MODE ---
            new_text, removed_val = remove_description_in_header(raw)
            if removed_val is None:
                continue
            if args.dry_run:
                print(f"[DRY] Would remove description from: {path}")
            else:
                try:
                    path.write_text(new_text, encoding="utf-8")
                except Exception as e:
                    print(f"[ERROR] Failed to write {path}: {e}")
                    continue
            changed.append((str(path), len(removed_val), f"[REMOVED] {removed_val}"))
            continue

        # --- GENERATE/UPDATE MODE ---
        payload = extract_page_payload(raw)
        if not payload.strip():
            continue

        short_hint = "RHEL, SLE/SLES, OL, Ubuntu, Debian, openSUSE, AL, Rocky, CentOS, MicroOS"

        prompt = PROMPT_TMPL.format(
            short_clients_hint=short_hint,
            blacklist=", ".join(sorted(banned_literals | {"SUSE Multi-Linux Manager"})),
            content=payload
        )

        # Call model
        try:
            draft = call_ollama(args.model, prompt, base_url=args.ollama_url)
        except Exception as e:
            print(f"[ERROR] Ollama call failed for {path}: {e}")
            continue

        # Post-process
        desc = sanitize_desc(draft, banned_literals, DEFAULT_BANNED_REGEX)

        # Retry if out of bounds
        if not (120 <= len(desc) <= 160):
            prompt_retry = prompt + "\nREMINDER: One complete sentence ending with a period; 120–160 chars; no 'This guide...' or lists."
            try:
                draft2 = call_ollama(args.model, prompt_retry, base_url=args.ollama_url)
                desc = sanitize_desc(draft2, banned_literals, DEFAULT_BANNED_REGEX)
            except Exception as e:
                print(f"[WARN] Retry failed for {path}: {e}")

        # Expand short
        if len(desc) < 120:
            expanded = expand_if_too_short(desc, payload, args.model, args.ollama_url)
            desc = sanitize_desc(expanded, banned_literals, DEFAULT_BANNED_REGEX)

        # Remove client OS names that aren't supported by context (roles are always allowed)
        desc = remove_irrelevant_clients(desc, payload)

        # Final polish & role enforcement
        desc = enforce_short_forms(desc)
        desc = apply_roles(desc)
        desc = re.sub(r"\bserver\b", "Server", desc)
        desc = re.sub(r"\bproxy\b", "Proxy", desc)
        desc = re.sub(r"\bclient\b", "Client", desc)
        desc = re.sub(r"\bretail\b", "Retail", desc)
        desc = remove_banned_terms(desc, banned_literals, DEFAULT_BANNED_REGEX)
        desc = strip_attribute_refs(desc)
        desc = strip_forbidden_punct(desc)
        desc = strip_doc_meta_openers(desc)
        desc = fix_slashes_and_leftovers(desc)
        desc = ensure_complete_sentence(desc, 120, 160)

        if not desc:
            print(f"[WARN] Empty description for {path}, skipping.")
            continue

        # Insert/update :description:
        new_text = upsert_description_attr(raw, desc)
        if new_text != raw:
            if args.dry_run:
                print(f"[DRY] Would update: {path} -> {len(desc)} chars")
            else:
                try:
                    path.write_text(new_text, encoding="utf-8")
                except Exception as e:
                    print(f"[ERROR] Failed to write {path}: {e}")
                    continue
            changed.append((str(path), len(desc), desc))

    # CSV report
    try:
        with open(args.report, "w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            w.writerow(["file", "length", "description"])
            w.writerows(changed)
        print(f"Wrote report: {args.report} with {len(changed)} items.")
    except Exception as e:
        print(f"[WARN] Could not write report: {e}")

if __name__ == "__main__":
    main()
