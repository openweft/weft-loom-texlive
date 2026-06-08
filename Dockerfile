# weft-loom-texlive — LaTeX compile sandbox image for weft-loom.
#
# Consumed by weft-agent when a `weft-loom` compile job has
# language="latex". The image ships :
#
#   - a minimal Debian root
#   - TeX Live (texlive-full -- ~3 GB ; covers fonts/packages most
#     LaTeX projects need without extra apt installs)
#   - latexmk (default driver)
#   - a non-root `build` user
#   - /workspace as the project mount point + writable build dir
#
# Invocation contract :
#
#   docker run --rm \
#     -v <project>:/workspace:ro \
#     -v <scratch>:/workspace/.build:rw \
#     weft-loom-texlive \
#     latexmk -pdf -outdir=/workspace/.build /workspace/main.tex
#
# The artefact lands at /workspace/.build/main.pdf ; weft-loom-server
# fetches it through weft-agent after the compile finishes.

FROM debian:13-slim

# texlive-full is huge ; we trade install time for "just works"
# coverage. Operators who want a slim image can fork + replace
# with texlive-latex-base + per-class extras.
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        texlive-full \
        latexmk \
        biber \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Non-root build user. Compile jobs SHOULD NOT run as root inside
# the microVM ; weft-agent's hypervisor isolation already covers
# kernel-level boundary, but defence in depth.
RUN useradd --create-home --shell /bin/bash --uid 1000 build \
 && mkdir -p /workspace \
 && chown build:build /workspace

USER build
WORKDIR /workspace

# Default command : latexmk against main.tex. Override via the
# job's ExtraArgs to compile a different entry file.
CMD ["latexmk", "-pdf", "-outdir=/workspace/.build", "/workspace/main.tex"]

LABEL org.opencontainers.image.title="weft-loom-texlive"
LABEL org.opencontainers.image.description="LaTeX compile sandbox for weft-loom (TeX Live full + latexmk + biber)"
LABEL org.opencontainers.image.source="https://github.com/openweft/weft-loom-texlive"
LABEL org.opencontainers.image.licenses="BSD-3-Clause"
