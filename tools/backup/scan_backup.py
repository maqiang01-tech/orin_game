"""Inspect Git-selected files and ZIP members without printing secret values."""
import argparse
import io
import json
from pathlib import Path
import re
import subprocess
import zipfile

PATTERNS = {
    "private_key": rb"-----BEGIN (?:RSA |OPENSSH |EC |DSA |ENCRYPTED )?PRIVATE KEY-----",
    "github_token": rb"\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{50,})\b",
    "openai_key": rb"\bsk-(?:proj-|svcacct-)?[A-Za-z0-9_-]{40,}\b",
    "aws_key": rb"\b(?:AKIA|ASIA)[A-Z0-9]{16}\b",
    "slack_token": rb"\bxox[baprs]-[A-Za-z0-9-]{25,}\b",
}
SENSITIVE_NAMES = {"auth.json", "credentials.json", "id_rsa", "id_ed25519", ".env"}


def inspect(name, data, findings, depth=0):
    if Path(name).name.lower() in SENSITIVE_NAMES:
        findings.append({"file": name, "rule": "sensitive_filename"})
    for rule, pattern in PATTERNS.items():
        if re.search(pattern, data):
            findings.append({"file": name, "rule": rule})
    if data.startswith(b"PK\x03\x04"):
        if depth >= 5:
            raise ValueError("Archive nesting exceeds inspection limit: " + name)
        with zipfile.ZipFile(io.BytesIO(data)) as archive:
            total = 0
            for entry in archive.infolist():
                total += entry.file_size
                if total > 512 * 1024 * 1024:
                    raise ValueError("Archive expansion exceeds inspection limit: " + name)
                if not entry.is_dir():
                    inspect(name + "!" + entry.filename, archive.read(entry), findings, depth + 1)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path)
    parser.add_argument("--staged", action="store_true")
    args = parser.parse_args()
    command = ["git", "-C", str(args.root)]
    if args.staged:
        command += ["diff", "--cached", "--name-only", "--diff-filter=ACMR", "-z"]
    else:
        command += ["ls-files", "--cached", "--others", "--exclude-standard", "-z"]
    names = sorted(set(n for n in subprocess.check_output(command).decode("utf-8").split("\0") if n))
    findings = []
    total = 0
    large = []
    for name in names:
        path = args.root / name
        if path.is_symlink():
            raise ValueError("Refusing symlink: " + name)
        data = (subprocess.check_output(["git", "-C", str(args.root), "show", ":" + name])
                if args.staged else path.read_bytes())
        total += len(data)
        if len(data) >= 50 * 1024 * 1024:
            large.append({"file": name, "bytes": len(data)})
        inspect(name, data, findings)
    result = {"files": len(names), "bytes": total, "credential_findings": findings,
              "large_files": large, "passed": not findings and not large,
              "limitations": "Pattern-based screen, not proof that arbitrary confidential content is absent."}
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result["passed"] else 1)


if __name__ == "__main__":
    main()
