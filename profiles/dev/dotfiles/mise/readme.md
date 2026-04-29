# Mise Config

- For `mise` config I decided to just copy `config.toml` to `.config/mise`, not symlink the config
- Pros:
  - Faster and easier to switch tool version
- Cons:
  - `mise` config not sync to git

---

- If I set `mise` config using `nix`
- Pros:
  - `mise` config is synced to git
- Cons:
  - Difficult to switch tool version. Need to change `config.toml`, then rebuild nix.
  - It takes longer time to rebuild nix as well.
