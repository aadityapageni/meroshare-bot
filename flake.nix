{
  description = "Meroshare Bot - Automated IPO application bot for Meroshare (CDSC Nepal)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Python environment with all dependencies
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          # Core selenium and browser automation
          selenium
          webdriver-manager

          # HTTP & networking
          requests
          urllib3
          certifi
          idna
          charset-normalizer

          # Async primitives
          trio
          trio-websocket
          sniffio
          outcome
          async-generator

          # SSL/TLS
          pyopenssl
          cryptography
          pycparser
          cffi

          # Utilities
          colorama
          tabulate
          termcolor
          sortedcontainers

          # Misc
          attrs
          h11
          wsproto
          pysocks
        ]);

      in
      {
        # Development shell: enter with `nix develop`
        devShells.default = pkgs.mkShell {
          name = "meroshare-bot";

          packages = [
            pythonEnv

            # Firefox + geckodriver for Selenium
            pkgs.firefox
            pkgs.geckodriver

            # Helpful dev tools
            pkgs.just        # optional task runner
          ];

          shellHook = ''
            echo ""
            echo "🚀 Meroshare Bot Dev Shell"
            echo "──────────────────────────────────────"
            echo "  Python : $(python --version)"
            echo "  Firefox: $(firefox --version 2>/dev/null || echo 'not found')"
            echo "  Gecko  : $(geckodriver --version 2>/dev/null | head -1 || echo 'not found')"
            echo ""
            echo "  Usage:"
            echo "    python main.py"
            echo ""

            # Point webdriver-manager to the Nix-provided geckodriver
            # so it does NOT try to download one at runtime.
            export WDM_LOG_LEVEL=0
            export GH_TOKEN=""          # suppress GitHub rate-limit warnings

            # webdriver_manager respects this env var to skip downloads
            export WDM_LOCAL=1

            # Tell selenium where geckodriver lives (Nix puts it in PATH already)
            export PATH="${pkgs.geckodriver}/bin:$PATH"
          '';
        };

        # Runnable package: `nix run`
        packages.default = pkgs.writeShellApplication {
          name = "meroshare-bot";
          runtimeInputs = [
            pythonEnv
            pkgs.firefox
            pkgs.geckodriver
          ];
          text = ''
            cd "$(dirname "$0")"
            python ${self}/main.py "$@"
          '';
        };

        # Formatter: `nix fmt`
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
