# horizon-plain

Builds of [Horizon](https://github.com/horizon-rust/horizon) without its extras: the same game,
compiled with the `horizon-extras` feature off (see `docs/forking.md` in Horizon). No launcher,
no updates, no mods browser, no cosmetics.

- `build.sh <tag>` clones that tag of horizon-rust/horizon and builds `horizon-client` and
  `horizon-prepare` with the client's default features minus `horizon-extras`.
- `.github/workflows/build.yml` does it on GitHub-hosted runners (Linux x86_64, Windows x64,
  macOS arm64) for the newest dated Nightly (`nightly-YYYY-MM-DD…`) published at least 7 days
  ago, so it always trails the official build (repository variables: `TAG_PATTERN` changes which
  tags count, `LAG_DAYS` the delay), every 6 hours, once per tag. Run it by hand for a
  given tag from the Actions tab.
- The results are the run's artifacts, kept 90 days. They are **not signed or notarized**:
  Horizon's signing keys and Apple notarization belong to the official build. On macOS,
  right-click > Open the first time.

Best effort: a tag that fails to build here changes nothing in Horizon. Tags from before
`horizon-extras` existed have no plain build.

MIT, as Horizon.
