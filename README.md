# weft-loom-texlive

LaTeX compile sandbox image for [weft-loom-server](https://github.com/openweft/weft-loom-server).

OCI image pulled by `weft-agent` when a weft-loom compile job has
`language: "latex"`. Ships TeX Live full + `latexmk` + `biber` ; runs
as non-root user `build`. The microVM provides the kernel-level
isolation ; the non-root user is defence in depth.

## Invocation contract

```
docker run --rm \
  -v <project>:/workspace:ro \
  -v <scratch>:/workspace/.build:rw \
  ghcr.io/openweft/weft-loom-texlive:latest \
  latexmk -pdf -outdir=/workspace/.build /workspace/main.tex
```

Artefact lands at `/workspace/.build/main.pdf` — weft-loom-server
fetches it via weft-agent after compile completes.

## Image

- Base : `debian:13-slim`
- Size : ~3 GB (TeX Live full)
- Arch : `linux/amd64`, `linux/arm64` (built via buildx + QEMU on tag)
- Registry : `ghcr.io/openweft/weft-loom-texlive`
- Tag policy : `latest` (rolling main), `vX.Y.Z` (immutable)

## Roadmap

V0.2 will publish a `slim` variant (texlive-latex-base only, ~600 MB)
for projects that don't need the full font/package set.

## License

BSD 3-Clause — see LICENSE.
