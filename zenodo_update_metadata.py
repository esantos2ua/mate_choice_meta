#!/usr/bin/env python3
"""
Update the metadata of an already-published Zenodo record from .zenodo.json.

Fixes the author list, description and keywords on record 21829678 without
minting a new version DOI. Files are untouched.

USAGE
-----
    export ZENODO_TOKEN='...'          # never commit or paste this anywhere
    python3 zenodo_update_metadata.py            # dry run: shows the diff only
    python3 zenodo_update_metadata.py --apply    # edit -> update -> publish

The token needs the `deposit:write` and `deposit:actions` scopes.

WHAT IT DOES
------------
1.  GET  the current metadata for the record.
2.  MERGE the fields from .zenodo.json into it (title, description, creators,
    keywords, license, related_identifiers). Everything else the record already
    has -- notably the GitHub release link -- is preserved, because a bare PUT
    would otherwise replace the whole metadata object.
3.  Prints a before/after summary and stops, unless --apply is given.
4.  With --apply: unlock the record for editing, PUT the merged metadata, and
    re-publish. The DOI does not change.

If anything fails the script stops and prints the server's message. It never
prints the token.
"""

import json
import os
import sys
import urllib.error
import urllib.request

RECORD_ID = "21829678"          # the version-specific record (concept DOI is ...677)
BASE = "https://zenodo.org/api/deposit/depositions"
FIELDS = ["title", "description", "creators", "keywords",
          "license", "upload_type", "access_right", "language",
          "related_identifiers"]


def die(msg):
    print(f"\nERROR: {msg}", file=sys.stderr)
    sys.exit(1)


def request(method, url, token, payload=None):
    data = json.dumps(payload).encode() if payload is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {token}")
    if data:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            body = r.read().decode()
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as e:
        detail = e.read().decode()[:600]
        die(f"{method} {url.split('?')[0]} -> HTTP {e.code}\n{detail}")
    except urllib.error.URLError as e:
        die(f"could not reach Zenodo: {e.reason}")


def main():
    apply_changes = "--apply" in sys.argv

    token = os.environ.get("ZENODO_TOKEN", "").strip()
    if not token:
        die("ZENODO_TOKEN is not set.\n"
            "  export ZENODO_TOKEN='your-token-here'   (no quotes in the token itself)")

    here = os.path.dirname(os.path.abspath(__file__))
    path = os.path.join(here, ".zenodo.json")
    if not os.path.exists(path):
        die(f".zenodo.json not found next to this script ({path})")
    with open(path, encoding="utf-8") as fh:
        desired = json.load(fh)

    print(f"Fetching record {RECORD_ID} ...")
    dep = request("GET", f"{BASE}/{RECORD_ID}", token)
    current = dep.get("metadata", {})

    print("\n--- BEFORE ---")
    print(f"  title       : {current.get('title', '(none)')[:70]}")
    print(f"  description : {'set' if current.get('description') else '(EMPTY)'}")
    print(f"  keywords    : {current.get('keywords') or '(none)'}")
    print(f"  creators    : {len(current.get('creators', []))}")
    for c in current.get("creators", []):
        print(f"      - {c.get('name')}")

    merged = dict(current)
    for k in FIELDS:
        if k in desired:
            merged[k] = desired[k]

    print("\n--- AFTER ---")
    print(f"  title       : {merged.get('title', '')[:70]}")
    print(f"  description : {'set' if merged.get('description') else '(EMPTY)'}")
    print(f"  keywords    : {len(merged.get('keywords', []))} keyword(s)")
    print(f"  creators    : {len(merged.get('creators', []))}")
    for c in merged.get("creators", []):
        print(f"      - {c.get('name'):32} {c.get('orcid', '')}")

    preserved = sorted(set(current) - set(FIELDS))
    if preserved:
        print(f"\n  preserved unchanged: {', '.join(preserved)}")

    if not apply_changes:
        print("\nDry run only. Re-run with --apply to write these changes.")
        return

    print("\nUnlocking record for editing ...")
    request("POST", f"{BASE}/{RECORD_ID}/actions/edit", token)

    print("Uploading metadata ...")
    request("PUT", f"{BASE}/{RECORD_ID}", token, {"metadata": merged})

    print("Publishing ...")
    out = request("POST", f"{BASE}/{RECORD_ID}/actions/publish", token)

    print("\nDone.")
    print(f"  DOI    : {out.get('doi_url') or out.get('doi', '(unchanged)')}")
    print(f"  Record : https://zenodo.org/records/{RECORD_ID}")
    print("\nCheck the Citation block on the record page shows all 18 authors.")


if __name__ == "__main__":
    main()
