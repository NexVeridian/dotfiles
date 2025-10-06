{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      rust-overlay,
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget

          nixpkgs.config.allowUnfree = true;

          # Apply the rust-overlay to nixpkgs
          nixpkgs.overlays = [
            rust-overlay.overlays.default
          ];

          # https://search.nixos.org/packages
          environment.systemPackages = with pkgs; [
            google-chrome
            raycast
            keka
            yt-dlp
            modrinth-app
            zoom-us

            # dev cli
            lazygit
            lazydocker
            jujutsu
            jjui
            lazyjj
            # gitbutler
            gh

            just
            btop
            hyperfine
            cmake
            rclone
            attic-client
            # colima
            # docker
            # dbeaver-bin

            # bash replacements
            bashInteractive
            wget
            bat
            eza
            zoxide
            dua

            # typst
            typst
            typstyle

            # rust
            (pkgs.rust-bin.selectLatestNightlyWith (
              toolchain:
              toolchain.default.override {
                extensions = [ "rustc-codegen-cranelift-preview" ];
                targets = [ "wasm32-unknown-unknown" ];
              }
            ))

            # (pkgs.rust-bin.stable.latest.default.override {
            #   # extensions = [ "rustc-codegen-cranelift-preview" ];
            #   targets = [ "wasm32-unknown-unknown" ];
            # })

            # (pkgs.rust-bin.stable."1.89.0".default.override {
            #   # extensions = [ "rustc-codegen-cranelift-preview" ];
            #   targets = [ "wasm32-unknown-unknown" ];
            # })

            taplo
            tombi
            libiconv
            openssl
            pkg-config

            cargo-nextest
            cargo-insta
            cargo-edit
            cargo-update
            cargo-binstall
            cargo-machete

            bacon
            zola
            mdbook
            trunk
            dioxus-cli
            wasm-bindgen-cli

            # js
            nodejs_24
            pnpm
            biome

            # python
            python3
            uv
            ruff
            pyright

            # go
            go

            # nix
            devenv
            nixpkgs-review
            nix-fast-build
            # nix format
            nixd
            nixfmt-rfc-style
            mkalias

            # k8s
            hcloud
            kubectl
            talosctl
            kubernetes-helm
            k9s
          ];

          nix = {
            distributedBuilds = true;
            optimise.automatic = true;

            settings = {
              max-jobs = 32;
              substituters = [
                "https://nix-community.cachix.org?priority=41"
                "https://numtide.cachix.org?priority=41"
              ];
              trusted-public-keys = [
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
              ];
              trusted-users = [
                "root"
                "elijahmcmorris"
              ];
            };

            # https://nixos.wiki/wiki/Storage_optimization
            gc = {
              automatic = true;
              interval = {
                Weekday = 0;
                Hour = 0;
                Minute = 0;
              };
              options = "-d";
            };
          };

          system.activationScripts.applications.text =
            let
              env = pkgs.buildEnv {
                name = "system-applications";
                paths = config.environment.systemPackages;
                pathsToLink = "/Applications";
              };
            in
            pkgs.lib.mkForce ''
              # Set up applications.
              echo "setting up /Applications..." >&2
              rm -rf /Applications/Nix\ Apps
              mkdir -p /Applications/Nix\ Apps
              find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
              while read -r src; do
                app_name=$(basename "$src")
                echo "copying $src" >&2
                ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
              done
            '';

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Configure environment variables for OpenSSL
          environment.variables = {
            LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [ openssl ];
          };

          # Enable alternative shell support in nix-darwin.
          programs.zsh.enable = true;
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 5;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."Elijahs-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
        ];
      };
    };
}
