# Offline mock dataset

`response` is the deterministic response returned by `pipelines/run_mock.py`.
It is compared with `ground_truth` by the offline metrics.

For a live Foundry evaluation, replace the `target()` stub in
`pipelines/azure-eval.py` with an approved non-production agent call. In that
path, `ground_truth` remains the reference answer and the target supplies the
actual response.
