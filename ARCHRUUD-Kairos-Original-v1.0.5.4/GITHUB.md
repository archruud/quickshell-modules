# Publish v1.0.5.4 to GitHub

Repository: https://github.com/archruud/quickshell-modules

1. Extract `ARCHRUUD-Kairos-Original-v1.0.5.4-GitHub.zip`.
2. In the repository create `ARCHRUUD-Kairos-Original-v1.0.5.4-GitHub/`.
3. Upload **all files and folders inside the extracted directory**, retaining
   `config/`, `integration/`, `scripts/`, docs, and the executable source files.
4. Suggested commit message: `ARCHRUUD Kairos v1.0.5.4 — vertical side controls`.
5. Keep `ARCHRUUD-Kairos-Original-v1.0-Stable/` as an archived previous release,
   or make its deprecation explicit. Do not rename installed Quickshell config.

If using a Git clone, copy the extracted folder into the repo, then:

```bash
git add ARCHRUUD-Kairos-Original-v1.0.5.4-GitHub
git commit -m "ARCHRUUD Kairos v1.0.5.4 - GitHub release"
git push
```

This is only a source release. **No GitHub upload or repository change is
performed by the ZIP or its install scripts.**
