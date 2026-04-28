---
name: release
description: Publish a package to a registry (npm, PyPI, etc.) with pre-flight checks. Customize this skill for your project's release workflow.
allowed-tools: Bash(git *) Bash(npm *) Bash(pip *) Bash(twine *)
---

# Release Skill — customize for your project

This is a base template. Fill in the steps specific to your release process.

Suggested workflow:

1. Verify the working tree is clean: `git status`
2. Confirm the version to be published:
   - npm: `node -p "require('./package.json').version"`
   - Python: read `pyproject.toml` or `setup.py`
3. Run pre-publish checks (tests, lint, build):
   - npm: `npm test && npm run build`
   - Python: `pytest && python -m build`
4. Show the version and registry target to the user and ask for confirmation
5. After explicit confirmation:
   - npm: `npm publish`
   - Python: `twine upload dist/*`
6. Tag the release: `git tag v<version> && git push --tags`

TODO: customize steps 2-5 for your specific project and registry.
