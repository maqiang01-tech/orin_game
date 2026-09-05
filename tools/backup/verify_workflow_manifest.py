"""Verify backup SHA-256 against staged or committed Git blobs, not disk copies."""
import argparse
import hashlib
import json
import subprocess


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("repository")
    parser.add_argument("--revision", default="", help="Empty means Git index; use HEAD after commit")
    args = parser.parse_args()
    process = subprocess.Popen(["git", "-C", args.repository, "cat-file", "--batch"],
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)

    def read_blob(path):
        if "\n" in path or "\r" in path:
            raise ValueError("Unexpected newline in manifest path")
        process.stdin.write((args.revision + ":" + path + "\n").encode("utf-8"))
        process.stdin.flush()
        header = process.stdout.readline().decode("ascii").strip().split()
        if len(header) != 3 or header[1] != "blob":
            raise ValueError("Missing Git blob: " + path)
        data = process.stdout.read(int(header[2]))
        if len(data) != int(header[2]) or process.stdout.read(1) != b"\n":
            raise ValueError("Truncated Git blob: " + path)
        return data

    try:
        manifest = json.loads(read_blob("BACKUP_MANIFEST.json"))
        for entry in manifest["files"]:
            data = read_blob(entry["path"])
            if hashlib.sha256(data).hexdigest() != entry["sha256"] or len(data) != entry["bytes"]:
                raise ValueError("Backup hash mismatch: " + entry["path"])
        print(json.dumps({"verified_files": len(manifest["files"]),
                          "revision": args.revision or "index", "passed": True}))
    finally:
        process.stdin.close()
        process.stdout.close()
        process.wait()


if __name__ == "__main__":
    main()
