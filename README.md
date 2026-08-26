# JOYA edge releases

Public **update packages** for JOYA consumption edge Pis.

This git repo is **not** the source tree. On `main` you only find:

- `latest.json` — version / URL / SHA for auto-OTA
- `bootstrap-prod.sh` — first-time Pi install
- `README.md`

## Release assets (Downloads)

Each GitHub Release tag (`vX.Y.Z`) attaches a single runtime package:

- `joya-edge-X.Y.Z.tar.gz` — install/OTA payload only: `agent/` + `deploy/` + config example
- `joya-edge-X.Y.Z.tar.gz.sha256`
- `latest.json`

No docs, no packaging scripts, no private SSH keys.

Full source stays private: `joya-energy/joya-consumption-edge`.

## Ship a new update

From the private edge repo:

```powershell
powershell -File scripts\ship.ps1
```

## New Pi

```bash
curl -fsSL https://raw.githubusercontent.com/joya-energy/joya-edge-releases/main/bootstrap-prod.sh | bash
```
