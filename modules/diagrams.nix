# `nix run .#write-diagrams` → docs/diagrams/den/*.md + section between den-diagram markers in docs/den.md.
{
  den,
  lib,
  inputs,
  ...
}:
let
  diagram = inputs.den-diagram.lib;
in
{
  perSystem =
    { pkgs, ... }:
    let
      rc = diagram.renderContext { inherit pkgs; };
      cap = den.lib.capture.captureFleet { };
      entry = view: ext: drv: {
        name = "den";
        inherit view ext drv;
        dir = "den";
        tool = null;
      };
      # Drop %%{init}%% theme line so GitHub applies its own light/dark mermaid theme.
      stripInit =
        src: lib.concatStringsSep "\n" (lib.filter (l: !lib.hasPrefix "%%{init:" l) (lib.splitString "\n" src));
      fence = src: "```mermaid\n${stripInit src}\n```\n";
      scopeTopology = fence (rc.render.toScopeTopologyMermaid cap);
      namespace = fence (
        rc.renderDense.toMermaid (
          diagram.graph.ofNamespace {
            aspects = den.aspects;
            filter = v: v.name != "wsl-host-aspect";
          }
        )
      );
      denSection = pkgs.writeText "den-section.md" ''
        **Scope topology** — system → host → user:

        ${scopeTopology}
        <details>
        <summary>Aspect namespace — every aspect and what it includes</summary>

        ${namespace}
        </details>
      '';
      writeFiles = diagram.export.mkWriteScript pkgs {
        entries = [
          (entry "scope-topology" "md" (pkgs.writeText "scope-topology.md" scopeTopology))
          (entry "namespace" "md" (pkgs.writeText "namespace.md" namespace))
        ];
        destExpr = ''"$(${pkgs.git}/bin/git rev-parse --show-toplevel)/docs"'';
        scriptName = "write-diagram-files";
      };
    in
    {
      packages.write-diagrams = pkgs.writeShellScriptBin "write-diagrams" ''
        set -euo pipefail
        ${writeFiles}/bin/write-diagram-files
        doc="$(${pkgs.git}/bin/git rev-parse --show-toplevel)/docs/den.md"
        ${pkgs.gawk}/bin/awk -v section=${denSection} '
          /<!-- den-diagram:start -->/ { print; print ""; while ((getline l < section) > 0) print l; skip = 1; next }
          /<!-- den-diagram:end -->/ { skip = 0 }
          !skip
        ' "$doc" > "$doc.tmp"
        mv "$doc.tmp" "$doc"
        echo "Updated $doc"
      '';
    };
}
