---
name: deploy
description: Push a Docker image to a registry with pre-flight checks. Customize this skill for your project's deployment workflow.
allowed-tools: Bash(docker *) Bash(git *)
---

# Deploy Skill — customize for your project

This is a base template. Fill in the steps specific to your deployment process.

Suggested workflow:

1. Show the image to be pushed: `docker images | head -5`
2. Confirm the registry and tag:
   - Ask the user: "Push <image>:<tag> to <registry>?"
3. Run any pre-push checks:
   - Ensure the image was built from a clean commit: `git status`
   - Optionally run a smoke test: `docker run --rm <image> <health-check-cmd>`
4. After explicit user confirmation:
   - `docker push <registry>/<image>:<tag>`
5. Output the image digest for audit purposes

TODO: customize the registry URL, tag strategy, and health-check steps for your project.
