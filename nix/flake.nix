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

    nix-rosetta-builder = {
      url = "github:cpick/nix-rosetta-builder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      rust-overlay,
      nix-rosetta-builder,
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
            keepassxc
            raycast
            # modrinth-app
            rclone
            keka
            # yt-dlp
            # zoom-us

            # dev
            attic-client
            # colima
            # docker
            dbeaver-bin

            # dev cli
            lazygit
            lazydocker
            jujutsu
            jjui
            # gitui
            btop
            # micro
            just
            hyperfine
            cmake
            gh
            wget

            # bash replacements
            bat
            eza
            zoxide
            dua

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

            # (pkgs.rust-bin.stable."1.87.0".default.override {
            #   # extensions = [ "rustc-codegen-cranelift-preview" ];
            #   targets = [ "wasm32-unknown-unknown" ];
            # })

            libiconv
            openssl
            pkg-config
            cargo-nextest
            cargo-insta
            cargo-edit
            cargo-update
            sea-orm-cli
            bacon
            zola
            mdbook
            trunk
            dioxus-cli

            # js
            nodejs_24
            pnpm
            biome

            # python
            python3
            uv
            ruff

            # nix format
            nixd
            nixfmt-rfc-style
            mkalias

            # nix
            nixpkgs-review
            # nixpacks
            nix-fast-build

            # k8s
            kubectl
            talosctl
            kubernetes-helm
          ];

          nix = {
            distributedBuilds = true;

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

            # https://github.com/nix-darwin/nix-darwin/issues/1192#issuecomment-2619629531
            linux-builder = {
              enable = true;
              systems = [
                "x86_64-linux"
                "aarch64-linux"
              ];
              # config = {
              #   virtualisation.cores = 16;
              #   boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
              # };
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

          # An existing Linux builder is needed to initially bootstrap `nix-rosetta-builder`.
          # If one isn't already available: comment out the `nix-rosetta-builder` module below,
          # uncomment this `linux-builder` module, and run `darwin-rebuild switch`:
          # { nix.linux-builder.enable = true; }
          # Then: uncomment `nix-rosetta-builder`, remove `linux-builder`, and `darwin-rebuild switch`
          # a second time. Subsequently, `nix-rosetta-builder` can rebuild itself.
          nix-rosetta-builder.darwinModules.default
          {
            # see available options in module.nix's `options.nix-rosetta-builder`
            # https://github.com/cpick/nix-rosetta-builder/blob/main/module.nix
            nix-rosetta-builder = {
              cores = 16;
              memory = "16GiB";
              onDemand = true;
              onDemandLingerMinutes = 1;
            };
          }
        ];
      };
    };
}
