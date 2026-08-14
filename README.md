# Ferment

Small bit of transformed matter added to base mass to convert whole, like leaven in dough.
Philosopher's Stone often called "ferment" for this reason.

## Starter Chart for Helmetica Transmuter

This repository contains a starter chart which is used by helmetica's transmuter.

## Testing

The chart contains a chainsaw end-to-end test in `test/e2e`, run with `just e2e`
against a running athanor cluster (`just ignite` in athanor, `KUBECONFIG`
pointing at it). It publishes the chart to the in-cluster registry, lets
chrysopoeia generate the CRD from it, claims an instance and checks the release.

`just test` runs `helm lint` and the offline unit tests in `test/unit`, which assert
that the templates render as expected (helm-unittest plugin, installed by the
recipe if missing). No cluster needed.

All three are generic and only check that the chart installs and renders
properly. Any reagent specific tests and asserts are to be added by a service
maintainer.
