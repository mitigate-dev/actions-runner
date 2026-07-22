# actions-runner

Custom GitHub Actions self-hosted runner image for mitigate-dev, published to
`ghcr.io/mitigate-dev/actions-runner`.

It extends the official [ARC runner](https://github.com/actions/runner)
(`ghcr.io/actions/actions-runner`) — so it stays compatible with the
`gha-runner-scale-set` helm chart — and adds a build toolchain plus common `-dev`
headers so native gem extensions (`bigdecimal`, `psych`, `pg`, `nokogiri`, ...)
compile without each workflow installing them at job time.

The runner cluster that consumes this image lives in
[`ci.mitigate.dev`](https://github.com/mitigate-dev/ci.mitigate.dev).

## Build

Built and pushed automatically by `.github/workflows/build.yml` on every push to
`main`, weekly (to pick up base-image and security updates), and on manual
dispatch. Tags: `latest` and `sha-<commit>`.

## Use

Reference it in the scale-set values (`runner.yml` in `ci.mitigate.dev`):

```yaml
template:
  spec:
    containers:
      - name: runner
        image: ghcr.io/mitigate-dev/actions-runner:latest
```

## Adding dependencies

Add packages to the `apt-get install` list in the `Dockerfile`, push to `main`,
and the workflow rebuilds and publishes.
