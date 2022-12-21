# Movescript
Simplified robot actions for Minecraft's ComputerCraft mod.

For **installation, starter guides, examples, and reference documentation**, please refer to the [Movescript Documentation Pages](https://andrewlalis.github.io/movescript/).

## Development

All sources are developed under `src`, and automatic minified versions of them are added to the `min` directory.

There are two main GitHub Actions that can run:

1. On pushes to `main` with changes under `docs/`, the VuePress documentation site will be rebuilt and deployed to GitHub pages.
2. On pushes to `main` with changes under `src/`, all sources will be minified and an automated pull-request will be opened, to be manually merged by an administrator.
