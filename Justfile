chart := `awk '/^name:/{print $2}' Chart.yaml`
version := `awk '/^version:/{print $2}' Chart.yaml`

REGISTRY := "oci://ghcr.io/helmetica-framework"

# renovate: datasource=go depName=github.com/kyverno/chainsaw
CHAINSAW_VERSION := "v0.2.15"
CHAINSAW_CMD := "go run github.com/kyverno/chainsaw@" + CHAINSAW_VERSION

_default:
    @just --list

# Package the chart
build:
    helm dependency build .
    helm package .

# Push the packaged chart to the registry
push: build
    helm push {{ chart }}-{{ version }}.tgz {{ REGISTRY }}

# End-to-end test against a running athanor cluster (just ignite).
e2e:
    {{ CHAINSAW_CMD }} test --config test/e2e/chainsaw-config.yaml test/e2e

# Push main, tag the current commit and push the tag to trigger the release
release:
    #!/usr/bin/env bash
    set -euo pipefail
    # Abort if the committed Chart.yaml version doesn't match the working copy
    # (e.g. bump not committed/exported).
    test "$(git show HEAD:Chart.yaml | awk '/^version:/{print $2}')" = "{{ version }}" \
        || { echo "HEAD Chart.yaml != working {{ version }}; commit the bump first"; exit 1; }
    git push origin main
    git tag v{{ version }}
    git push origin v{{ version }}
