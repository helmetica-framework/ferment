CHART   := $(shell awk '/^name:/{print $$2}' Chart.yaml)
VERSION := $(shell awk '/^version:/{print $$2}' Chart.yaml)
REGISTRY ?= oci://ghcr.io/helmetica-framework

.PHONY: build push release

build: $(CHART)-$(VERSION).tgz

$(CHART)-$(VERSION).tgz: Chart.yaml values.yaml $(wildcard templates/*)
	helm package .

push: build
	helm push $(CHART)-$(VERSION).tgz $(REGISTRY)

# Push main, then tag current commit v$(VERSION) and push the tag,
# triggering the release workflow.
release:
	git push origin main
	git tag v$(VERSION)
	git push origin v$(VERSION)
