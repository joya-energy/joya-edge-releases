#!/usr/bin/env bash
# Bootstrap a production Pi from joya-energy/joya-edge-releases (latest).
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/joya-energy/joya-edge-releases/main/bootstrap-prod.sh | bash
set -euo pipefail

MANIFEST_URL="${JOYA_EDGE_MANIFEST_URL:-https://raw.githubusercontent.com/joya-energy/joya-edge-releases/main/latest.json}"

echo "Fetching $MANIFEST_URL"
curl -fsSL "$MANIFEST_URL" -o /tmp/joya-latest.json

python3 - <<'PY'
import hashlib, json, os, pathlib, shutil, subprocess, sys, tarfile, urllib.request

m = json.load(open("/tmp/joya-latest.json", encoding="utf-8"))
url = str(m.get("url") or "").strip()
sha = str(m.get("sha256") or "").strip().lower()
ver = str(m.get("version") or "").strip()
if not url or len(sha) != 64 or not ver:
    sys.exit("latest.json missing version/url/sha256 — publish a release first")

print(f"Downloading joya-edge {ver}")
print(f"  {url}")
archive = pathlib.Path(f"/tmp/joya-edge-{ver}.tar.gz")
urllib.request.urlretrieve(url, archive)
digest = hashlib.sha256(archive.read_bytes()).hexdigest()
if digest != sha:
    sys.exit(f"SHA256 mismatch: got {digest}, expected {sha}")

stage = pathlib.Path(f"/tmp/joya-edge-extract-{ver}")
if stage.exists():
    shutil.rmtree(stage)
stage.mkdir(parents=True)
with tarfile.open(archive, "r:gz") as tar:
    try:
        tar.extractall(stage, filter=tarfile.data_filter)  # type: ignore[arg-type]
    except (AttributeError, TypeError):
        tar.extractall(stage)

root = None
for p in stage.iterdir():
    if p.is_dir() and (p / "deploy" / "install.sh").is_file():
        root = p
        break
if root is None and (stage / "deploy" / "install.sh").is_file():
    root = stage
if root is None:
    sys.exit("Archive missing deploy/install.sh")

print(f"Running install from {root}")
cmd = ["bash", str(root / "deploy" / "install.sh")]
if os.geteuid() != 0:
    cmd = ["sudo", *cmd]
subprocess.check_call(cmd)
print(f"Installed joya-edge {ver}")
print("Next: sudo nano /etc/joya-edge/config.yaml")
print("Then:  sudo joya register --claim-code YOUR_CODE")
print("Guide: docs/PROD-SETUP.md (in the edge repo)")
PY
