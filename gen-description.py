#!/usr/bin/env python3
# gen_descriptions.py — generate OR remove :description: for AsciiDoc pages via Ollama.
# Final version with capitalization fix, native attribute parsing, and file logging.

import argparse
import csv
import logging
import os
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Set, Tuple

import requests

# =========================
# Configuration
# =========================

@dataclass
class ScriptConfig:
    """Groups all configuration settings and pre-compiled regex patterns."""
    # Banned terms
    BANNED_LITERALS: Set[str] = field(default_factory=lambda: {"Uyuni", "SUSE Manager", "SUSE"})
    BANNED_REGEX_STRS: List[str] = field(default_factory=lambda: [r"\bSUSE\s+Multi[- ]Linux\s+Manager\b"])

    # Terminology mapping
    SHORT_MAP: Dict[str, str] = field(default_factory=lambda: {
        r"\bRed Hat Enterprise Linux\b": "RHEL", r"\bSUSE Linux Enterprise Server\b": "SLES",
        r"\bSUSE Linux Enterprise\b": "SLE", r"\bOracle Linux\b": "OL",
        r"\bopenSUSE(?:\s+Leap|\s+Tumbleweed)\b": "openSUSE", r"\bAmazon Linux\b": "AL",
        r"\bCentOS\s+Stream\b": "CentOS",
    })
    ROLE_TERM_MAP: List[Tuple[str, str]] = field(default_factory=lambda: [
        (r"\bSUSE(?:[- ]based)?\s+environment\b", "Server"), (r"\bSUSE\s+server\s+environment\b", "Server"),
        (r"\bMLM\s+server\s+environment\b", "Server"), (r"\bMLM\s*server\b", "Server"),
        (r"\bSUSE\s*server\b", "Server"), (r"\bmanagement\s+server\b", "Server"),
        (r"\bprimary\s+server\b", "Server"), (r"\bcentral\s+server\b", "Server"),
        (r"\bMLM\s*proxy\b", "Proxy"), (r"\bSUSE\s*proxy\b", "Proxy"),
        (r"\bproxy\s+server\b", "Proxy"), (r"\bproxy\s+system\b", "Proxy"),
        (r"\bintermediate\s+node\b", "Proxy"), (r"\bMLM\s*client\b", "Client"),
        (r"\bSUSE\s*client\b", "Client"), (r"\bmanaged\s+(system|node|host|client)\b", "Client"),
        (r"\bend\s+(node|host|system)\b", "Client"), (r"\bretail\s+environments?\b", "Retail"),
        (r"\bretail\s+contexts?\b", "Retail"), (r"\bretail\s+systems?\b", "Retail"),
        (r"\bretail\s+deployments?\b", "Retail"), (r"\bMLM\s*retail\b", "Retail"),
        (r"\bSUSE\s*retail\b", "Retail"),
    ])
    CLIENT_ALIASES: Dict[str, List[str]] = field(default_factory=lambda: {
        "RHEL": [r"\bRHEL\b", r"\bRed Hat Enterprise Linux\b"], "SLE": [r"\bSLE\b", r"\bSUSE Linux Enterprise\b"],
        "SLES": [r"\bSLES\b", r"\bSUSE Linux Enterprise Server\b"], "OL": [r"\bOL\b", r"\bOracle Linux\b"],
        "Ubuntu": [r"\bUbuntu\b"], "Debian": [r"\bDebian\b"],
        "openSUSE": [r"\bopenSUSE\b", r"\bopenSUSE\s+Leap\b", r"\bopenSUSE\s+Tumbleweed\b"],
        "AL": [r"\bAL\b", r"\bAmazon Linux\b"], "Rocky": [r"\bRocky Linux\b", r"\bRocky\b"],
        "CentOS": [r"\bCentOS\b", r"\bCentOS\s+Stream\b"], "MicroOS": [r"\bMicroOS\b"],
        "RaspberryPi": [r"\bRaspberry\s*Pi\s*OS\b", r"\bRaspberry\s*Pi\b"],
    })
    
    # Prompting
    PROMPT_TMPL: str = """You write concise meta descriptions for technical documentation.

Task:
- Read the provided AsciiDoc page content.
- Write ONE complete sentence between 120 and 160 characters (ideally 140–155).
- The sentence MUST end with a period. No lists or sentence fragments.
- Focus on what the user will achieve or learn. Do NOT describe the document itself (avoid "This guide explains...").
- If the content is primarily a list of links or topics (like a table of contents), describe the page as a starting point for accessing those topics. Do not try to connect the topics into a single narrative.
- Only use these exact, capitalized role names: Server, Proxy, Client, Retail.
- Only mention client operating systems if the content is clearly specific to them.
- Do NOT use the following product or brand names: {blacklist}.
- Allowed short forms for operating systems are: {allowed_shorts}.
- Avoid colons, pipes, newlines, quotes, or emojis. Maintain a neutral, professional tone.

AsciiDoc page content:
---
{content}
---
Output ONLY the final sentence:
"""
    
    # --- Pre-compiled Regex Patterns ---
    _banned_regex: list = field(init=False)
    _short_map_re: list = field(init=False)
    _role_term_map_re: list = field(init=False)
    
    FORBIDDEN_CHARS_RE: re.Pattern = re.compile(r'[:|“”"‘’]')
    DOC_META_PATTERNS: List[re.Pattern] = field(init=False)
    TRAILING_STOPWORDS: Set[str] = field(default_factory=lambda: set(
        "and or to for with in of on at by from into via as that which including such as than then while when where".split()
    ))
    
    # Adoc structure patterns
    TITLE_RE: re.Pattern = re.compile(r"^\s*=\s+.+")
    DESC_RE: re.Pattern = re.compile(r"^:\s*description\s*:\s*", re.IGNORECASE)
    REV_RE: re.Pattern = re.compile(r"^:\s*revdate\s*:\s*", re.IGNORECASE)
    PAGEREV_RE: re.Pattern = re.compile(r"^:\s*page-revdate\s*:\s*", re.IGNORECASE)
    
    # Nav file skip patterns
    NAV_GENERIC_RE: re.Pattern = re.compile(r"^nav(?:-.+)?\.adoc$", re.IGNORECASE)
    NAV_GUIDE_RE: re.Pattern = re.compile(r"^nav-.+-guide\.adoc$", re.IGNORECASE)

    def __post_init__(self):
        """Compile regex patterns after the object is created."""
        self._banned_regex = [re.compile(p, re.IGNORECASE) for p in self.BANNED_REGEX_STRS]
        self._short_map_re = [(re.compile(p, re.IGNORECASE), s) for p, s in self.SHORT_MAP.items()]
        self._role_term_map_re = [(re.compile(p, re.IGNORECASE), r) for p, r in self.ROLE_TERM_MAP]
        self.DOC_META_PATTERNS = [
            re.compile(p, re.IGNORECASE) for p in [
                r"^\s*This\s+(guide|page|document|section)\s+(describes|covers|explains|provides|offers|details|walks\s+you\s+through|helps\s+users)\s+",
                r"^\s*In\s+this\s+(guide|page|document|section)\s+",
                r"^\s*The\s+(guide|page|document|section)\s+(describes|covers|explains|provides|offers|details)\s+",
            ]
        ]

# =========================
# Ollama Interaction
# =========================

def call_ollama(model: str, prompt: str, base_url: str, timeout=120) -> str:
    """Calls the Ollama API with fallback from /api/chat to /api/generate."""
    base = base_url.rstrip("/")
    try:
        r = requests.post(
            f"{base}/api/chat",
            json={"model": model, "stream": False, "messages": [{"role": "user", "content": prompt}]},
            timeout=timeout
        )
        if r.status_code in (404, 405): 
            raise requests.exceptions.HTTPError("Fallback to /api/generate")
        r.raise_for_status()
        data = r.json()
        return (data.get("message", {}).get("content") or "").strip()
    except requests.exceptions.RequestException:
        logging.info(f"Chat endpoint failed, falling back to generate endpoint for model {model}")
        r = requests.post(
            f"{base}/api/generate",
            json={"model": model, "prompt": prompt, "stream": False},
            timeout=timeout
        )
        r.raise_for_status()
        data = r.json()
        return (data.get("response") or "").strip()


# =========================
# Sanitization & Cleaning Pipeline
# =========================

def sanitize_desc(draft: str, config: ScriptConfig) -> str:
    """Runs the full cleaning and standardization pipeline on a raw description."""
    desc = re.sub(r"\s+", " ", draft).strip()
    
    for pat, short in config._short_map_re:
        desc = pat.sub(short, desc)
    for pat, role in config._role_term_map_re:
        desc = pat.sub(role, desc)

    for pat in config._banned_regex:
        desc = pat.sub("", desc)
    for name in sorted(config.BANNED_LITERALS, key=len, reverse=True):
        desc = re.sub(rf"\b{re.escape(name)}\b", "", desc, flags=re.IGNORECASE)
    
    desc = config.FORBIDDEN_CHARS_RE.sub(" ", desc)
    
    for pat in config.DOC_META_PATTERNS:
        desc = pat.sub("", desc).strip()
    desc = re.sub(r"^(by|with|through|using)\s+", "", desc, flags=re.IGNORECASE)
    
    desc = re.sub(r"\s*/\s*", " ", desc)
    desc = re.sub(r"\s{2,}", " ", desc).strip(" ,;:-")
    
    desc = re.sub(r"\bserver\b", "Server", desc, flags=re.IGNORECASE)
    desc = re.sub(r"\bproxy\b", "Proxy", desc, flags=re.IGNORECASE)
    desc = re.sub(r"\bclient\b", "Client", desc, flags=re.IGNORECASE)
    desc = re.sub(r"\bretail\b", "Retail", desc, flags=re.IGNORECASE)

    return re.sub(r"\s+", " ", desc).strip()

def finalize_sentence(desc: str, config: ScriptConfig, min_len=120, max_len=160) -> str:
    """Trims description to length, removes dangling words, and ensures it ends with a period."""
    if not desc:
        return ""

    if len(desc) > max_len:
        desc = desc[:max_len + 1]
        last_space = desc.rfind(" ")
        if last_space != -1:
            desc = desc[:last_space]

    desc = desc.rstrip(" ,;:-")
    words = desc.split()
    while words and words[-1].lower().strip(",.;") in config.TRAILING_STOPWORDS:
        words.pop()
    desc = " ".join(words)

    if desc and not desc.endswith('.'):
        desc += '.'
        
    # Ensure the first letter is capitalized
    if desc:
        desc = desc[0].upper() + desc[1:]
        
    return desc

def remove_irrelevant_clients(desc: str, payload: str, config: ScriptConfig) -> str:
    """Strips client OS names from the description if they lack support in the page content."""
    
    def context_supports(short: str, content: str) -> bool:
        aliases = config.CLIENT_ALIASES.get(short, [rf"\b{re.escape(short)}\b"])
        total = sum(len(re.findall(pat, content, re.IGNORECASE)) for pat in aliases)
        early_hit = any(re.search(pat, content[:400], re.IGNORECASE) for pat in aliases)
        return total >= 2 or early_hit

    present_clients = {s for s in config.CLIENT_ALIASES if re.search(rf"\b{s}\b", desc, flags=re.IGNORECASE)}
    if not present_clients:
        return desc
    
    modified_desc = desc
    for short in present_clients:
        if not context_supports(short, payload):
            logging.debug(f"Removing irrelevant client term '{short}' from description.")
            modified_desc = re.sub(rf"\b{re.escape(short)}\b", "", modified_desc, flags=re.IGNORECASE)
    
    modified_desc = re.sub(r"\s{2,}", " ", modified_desc)
    modified_desc = re.sub(r"\s+,", ",", modified_desc)
    modified_desc = re.sub(r"\s+(and|or)\s*,", ",", modified_desc, flags=re.IGNORECASE)
    modified_desc = re.sub(r",\s*(and|or)?\s*$", "", modified_desc)
    modified_desc = re.sub(r"[\s,]+$", "", modified_desc)
    
    return modified_desc.strip()

# =========================
# AsciiDoc File Operations
# =========================

def load_adoc_attributes(file_path: Path) -> dict:
    """
    Parses an AsciiDoc attribute file (e.g., attributes.adoc)
    and returns a dictionary of key-value pairs.
    """
    attributes = {}
    attr_line_re = re.compile(r'^:([a-zA-Z0-9_-]+):\s+(.*)')

    try:
        with file_path.open('r', encoding='utf-8') as f:
            for line in f:
                if line.strip().startswith('//') or not line.strip():
                    continue
                
                match = attr_line_re.match(line)
                if match:
                    key = match.group(1)
                    value = match.group(2).strip()
                    attributes[key] = value
    except Exception as e:
        logging.error(f"Could not read or parse AsciiDoc attributes file {file_path}: {e}")

    return attributes

def resolve_attributes(text: str, attributes: dict) -> str:
    """
    Replaces AsciiDoc attributes {like_this} with values from a dictionary.
    Removes any attributes that are not found in the provided dictionary.
    """
    attribute_pattern = re.compile(r"\{([A-Za-z0-9_-]+)\}")

    if not attributes:
        return attribute_pattern.sub("", text)

    def replace_match(match):
        key = match.group(1)
        value = attributes.get(key)
        if value is not None:
            return str(value)
        else:
            return ""

    return attribute_pattern.sub(replace_match, text)

def upsert_description_attr(text: str, new_desc: str, config: ScriptConfig) -> str:
    """Places :description: after the title or replaces an existing one."""
    lines = text.splitlines()
    for i, line in enumerate(lines):
        if config.DESC_RE.match(line):
            lines[i] = f":description: {new_desc}"
            return "\n".join(lines)

    title_idx = -1
    for i, line in enumerate(lines):
        if config.TITLE_RE.match(line):
            title_idx = i
            break
            
    if title_idx == -1:
        return f":description: {new_desc}\n\n{text}"

    insert_idx = title_idx + 1
    while insert_idx < len(lines) and not lines[insert_idx].strip():
        insert_idx += 1

    lines.insert(insert_idx, f":description: {new_desc}")
    return "\n".join(lines)


def remove_description_in_header(text: str, config: ScriptConfig) -> Tuple[str, str | None]:
    """Removes a :description: attribute from the AsciiDoc header block."""
    lines = text.splitlines()
    title_idx = -1
    for i, line in enumerate(lines):
        if config.TITLE_RE.match(line):
            title_idx = i
            break
    if title_idx == -1:
        return text, None

    i = title_idx + 1
    removed_val = None
    in_header = True
    while i < len(lines) and in_header:
        line = lines[i].strip()
        if not line:
            i += 1
            continue
        if line.startswith(":"):
            if config.DESC_RE.match(line) and removed_val is None:
                removed_val = line.split(":", 2)[-1].strip()
                del lines[i]
            else:
                i += 1
        else:
            in_header = False
            
    return "\n".join(lines), removed_val

def should_skip(path: Path, config: ScriptConfig) -> bool:
    """Determines if a file should be skipped based on its name or path."""
    if path.suffix.lower() != ".adoc":
        return True
    name = path.name
    if config.NAV_GUIDE_RE.match(name) or config.NAV_GENERIC_RE.match(name):
        return True
    return any(p in ("nav", "navigation") for p in (part.lower() for part in path.parts))

def extract_page_payload(content: str, config: ScriptConfig, max_len: int = 4000, min_smart_len: int = 200) -> str:
    """
    Extracts a structurally-aware payload, with a fallback to a raw text slice if the
    structured extraction yields a very small result.
    """
    # --- 1. Try the "smart" structural extraction first ---
    payload_parts = []
    title_match = config.TITLE_RE.search(content)
    if title_match:
        title = title_match.group(0).lstrip('= ').strip()
        payload_parts.append(f"TITLE: {title}")

        header_end_pos = content.find(title_match.group(0)) + len(title_match.group(0))
        first_section_match = re.search(r'^==\s+', content[header_end_pos:], re.MULTILINE)
        
        end_pos = first_section_match.start() if first_section_match else len(content)
        preamble = content[header_end_pos : header_end_pos + end_pos]
        
        preamble_lines = [
            line for line in preamble.splitlines() 
            if line.strip() and not line.strip().startswith(':')
        ]
        clean_preamble = " ".join(preamble_lines).strip()
        if clean_preamble:
            payload_parts.append(f"ABSTRACT: {clean_preamble}")

    headings = re.findall(r'^(?:==|===)\s+(.*)', content, re.MULTILINE)
    if headings:
        payload_parts.append("HEADINGS: " + " | ".join(h.strip() for h in headings[:7]))

    list_items = re.findall(r'^\*\s+xref:.*\[(.*)\]', content, re.MULTILINE)
    if list_items:
        payload_parts.append("TOPICS COVERED: " + " | ".join(item.strip() for item in list_items))
    
    smart_payload = "\n".join(payload_parts)

    # --- 2. Check if the smart payload is sufficient ---
    if len(smart_payload) > min_smart_len:
        header_end_pos = 0
        if title_match:
            header_end_pos = content.find(title_match.group(0)) + len(title_match.group(0))
        body_content = content[header_end_pos:]
        paragraphs = re.findall(r'^[A-Za-z].*', body_content, re.MULTILINE)
        if paragraphs:
            first_paragraphs = " ".join(p.strip() for p in paragraphs[:3])
            smart_payload += f"\nCONTENT: {first_paragraphs}"
        return smart_payload[:max_len]

    # --- 3. If not, use the "dumb" fallback method ---
    logging.debug(f"Smart extraction for a file was too short ({len(smart_payload)} chars). Using fallback text slice.")
    
    lines = content.splitlines()
    lines = [ln for ln in lines if not re.match(r"^\s*:[A-Za-z0-9_-]+:\s*", ln)]
    lines = [ln for ln in lines if "nav-" not in ln.lower()]
    text = "\n".join(lines)
    
    return text[:max_len]

# =========================
# Main Execution
# =========================

def process_file_for_removal(path: Path, config: ScriptConfig, dry_run: bool) -> Tuple[str, int, str] | None:
    """Handles the --remove logic for a single file."""
    try:
        raw_text = path.read_text(encoding="utf-8")
        new_text, removed_val = remove_description_in_header(raw_text, config)
        if removed_val is not None:
            if not dry_run:
                path.write_text(new_text, encoding="utf-8")
            logging.info(f"{'[DRY RUN] ' if dry_run else ''}Removed description from {path}")
            return str(path), len(removed_val), f"[REMOVED] {removed_val}"
    except Exception as e:
        logging.error(f"Failed to process or write {path}: {e}")
    return None


def process_file_for_generation(path: Path, config: ScriptConfig, args: argparse.Namespace, attributes: dict) -> Tuple[str, int, str] | None:
    """Handles the generation/update logic for a single file."""
    try:
        raw_text = path.read_text(encoding="utf-8")
        resolved_text = resolve_attributes(raw_text, attributes)
        payload = extract_page_payload(resolved_text, config)
        
        if not payload.strip():
            logging.warning(f"Skipping {path} because a meaningful payload could not be extracted.")
            logging.debug(f"Raw content for {path} that failed extraction:\n---\n{raw_text[:500]}\n---")
            return None

        prompt = config.PROMPT_TMPL.format(
            blacklist=", ".join(sorted(config.BANNED_LITERALS)),
            allowed_shorts="RHEL, SLE/SLES, OL, Ubuntu, Debian, openSUSE, AL, Rocky, CentOS, MicroOS, RaspberryPi",
            content=payload
        )
        logging.debug(f"Prompting for {path} with payload:\n---\n{payload}\n---")

        draft = call_ollama(args.model, prompt, args.ollama_url)
        desc = sanitize_desc(draft, config)
        
        if not (120 <= len(desc) <= 160):
            logging.info(f"Initial description for {path} out of bounds ({len(desc)} chars). Retrying.")
            retry_prompt = prompt + "\nREMINDER: Your response MUST be a single, complete sentence between 120 and 160 characters long."
            draft = call_ollama(args.model, retry_prompt, args.ollama_url)
            desc = sanitize_desc(draft, config)
            
        desc = remove_irrelevant_clients(desc, resolved_text, config)
        desc = finalize_sentence(desc, config, min_len=120, max_len=160)
        
        if not desc or len(desc) < 100:
            logging.warning(f"Generated description for {path} was too short after final processing. Skipping.")
            return None
        
        new_text = upsert_description_attr(raw_text, desc, config)
        if new_text != raw_text:
            if not args.dry_run:
                path.write_text(new_text, encoding="utf-8")
            logging.info(f"{'[DRY RUN] ' if args.dry_run else ''}Updated description for {path} ({len(desc)} chars)")
            return str(path), len(desc), desc
        else:
            logging.info(f"Generated description for {path} resulted in no change to the file.")
            return None

    except Exception as e:
        logging.error(f"Failed to generate description for {path}: {e}")
    return None


def main():
    """Main function to parse arguments and orchestrate the processing."""
    ap = argparse.ArgumentParser(description="Generate or remove :description: attributes for AsciiDoc files using an LLM.")
    ap.add_argument("root", help="Path to the root directory of your documentation files.")
    ap.add_argument("--model", default="llama3.1:8b", help="Ollama model to use (default: llama3.1:8b)")
    ap.add_argument("--ollama-url", default=os.environ.get("OLLAMA_URL", "http://127.0.0.1:11434"), help="Ollama base URL.")
    ap.add_argument("--blacklist", help="Comma-separated list of additional product/brand names to ban.")
    ap.add_argument("--dry-run", action="store_true", help="Preview changes without writing to files.")
    ap.add_argument("--report", default="description_report.csv", help="Path for the output CSV report.")
    ap.add_argument("--remove", action="store_true", help="Enable REMOVE mode to delete :description: attributes.")
    ap.add_argument("-v", "--verbose", action="store_true", help="Enable verbose logging (console).")
    ap.add_argument("--log-file", help="Path to a file to write detailed logs to.")
    ap.add_argument("--attributes-file", help="Path to an .adoc file with AsciiDoc attributes.")
    args = ap.parse_args()

    # --- Logging Setup ---
    log_level = logging.DEBUG if args.verbose else logging.INFO
    logging.basicConfig(
        level=log_level,
        format='[%(levelname)-7s] %(message)s',
        handlers=[logging.StreamHandler()]
    )

    if args.log_file:
        file_handler = logging.FileHandler(args.log_file, mode='w', encoding='utf-8')
        file_handler.setLevel(logging.DEBUG)
        formatter = logging.Formatter('%(asctime)s - %(levelname)-7s - %(message)s')
        file_handler.setFormatter(formatter)
        logging.getLogger().addHandler(file_handler)
        logging.info(f"Logging detailed output to {args.log_file}")
    # --- End Logging Setup ---
    
    # --- Attribute Loading ---
    attributes = {}
    if args.attributes_file:
        attr_path = Path(args.attributes_file)
        if attr_path.exists():
            attributes = load_adoc_attributes(attr_path)
            if attributes:
                logging.info(f"Successfully loaded {len(attributes)} attributes from {args.attributes_file}")
        else:
            logging.error(f"Attributes file not found at: {args.attributes_file}")
    # --- End Attribute Loading ---

    root = Path(args.root).resolve()
    if not root.is_dir():
        logging.critical(f"Error: Root path not found or is not a directory: {root}")
        raise SystemExit(1)

    config = ScriptConfig()
    if args.blacklist:
        config.BANNED_LITERALS.update(x.strip() for x in args.blacklist.split(","))

    changed_files = []

    logging.info(f"Starting in {'REMOVE' if args.remove else 'GENERATE'} mode. Root: {root}")
    if args.dry_run:
        logging.warning("Dry run enabled. No files will be modified.")

    all_files = list(root.rglob("*.adoc"))
    logging.info(f"Found {len(all_files)} .adoc files to scan.")
    
    for path in all_files:
        if should_skip(path, config):
            continue
        
        if args.remove:
            result = process_file_for_removal(path, config, args.dry_run)
        else:
            result = process_file_for_generation(path, config, args, attributes)
        
        if result:
            changed_files.append(result)

    if not changed_files:
        logging.info("No files were changed.")
        return

    try:
        with open(args.report, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow(["file_path", "description_length", "description_text"])
            writer.writerows(changed_files)
        logging.info(f"Successfully wrote report with {len(changed_files)} items to {args.report}")
    except Exception as e:
        logging.error(f"Could not write CSV report to {args.report}: {e}")


if __name__ == "__main__":
    main()