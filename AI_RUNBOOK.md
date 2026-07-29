# AI Runbook — my-robot

Operational notes. No secrets.

## Local verify

```bash
bash .verify.sh
# smoke: tests/smoke_bootstrap.sh (also run by the gate)
```

## Install into another repo

Prefer clone + dry-run (do not pipe unknown scripts to a shell without reviewing):

```bash
git clone https://github.com/noidsoup/my-robot
./my-robot/bootstrap.sh --dry-run /path/to/repo
./my-robot/bootstrap.sh /path/to/repo
```

Standalone fetch (review the script first, or pass `--dry-run`):

```bash
curl -fsSL https://raw.githubusercontent.com/noidsoup/my-robot/main/bootstrap.sh | bash -s -- --dry-run
```

## Regenerate a target repo's verify gate

Existing `.verify.sh` is never overwritten. To regenerate after adding tests:

```bash
rm /path/to/repo/.verify.sh
path/to/my-robot/template/gen-verify-gate.sh /path/to/repo
```

## CI

GitHub Actions workflow: `.github/workflows/verify.yml` — runs `.verify.sh` on push/PR to `main`.

## Release

Push `main`. Tags optional. Template files under `template/` are the install payload; keep `TEMPLATE_FILES` in `bootstrap.sh` in sync with disk.
