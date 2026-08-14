CHART   := $(shell awk '/^name:/{print $$2}' Chart.yaml)
VERSION := $(shell awk '/^version:/{print $$2}' Chart.yaml)
REGISTRY ?= oci://ghcr.io/helmetica-framework
# renovate: datasource=go depName=github.com/kyverno/chainsaw
CHAINSAW_VERSION := v0.2.15
CHAINSAW_CMD := go run github.com/kyverno/chainsaw@$(CHAINSAW_VERSION)

.PHONY: build push release e2e

build: $(CHART)-$(VERSION).tgz

$(CHART)-$(VERSION).tgz: Chart.yaml values.yaml $(wildcard templates/*)
	helm dependency build .
	helm package .

push: build
	helm push $(CHART)-$(VERSION).tgz $(REGISTRY)

# End-to-end test against a running athanor cluster (just ignite).
e2e:
	$(CHAINSAW_CMD) test --config test/e2e/chainsaw-config.yaml test/e2e

# Push main, then tag current commit v$(VERSION) and push the tag,
# triggering the release workflow. Aborts if the committed Chart.yaml
# version doesn't match the working copy (e.g. bump not committed/exported).
release:
	test "$$(git show HEAD:Chart.yaml | awk '/^version:/{print $$2}')" = "$(VERSION)" \
		|| { echo "HEAD Chart.yaml != working $(VERSION); commit the bump first"; exit 1; }
	git push origin main
	git tag v$(VERSION)
	git push origin v$(VERSION)
