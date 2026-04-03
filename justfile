switch attic="false":
    #!/usr/bin/env bash
    if [ "{{ attic }}" = "true" ]; then just attic-init; fi
    # https://github.com/NixOS/nix/issues/4653
    sudo nix run nix-darwin -- switch --verbose --flake ./nix#Elijahs-MacBook-Pro --option access-tokens "github.com=$(gh auth token)"
    cargo install-update -a --git
    pnpm update -g
    pnpm list -g
    if [ "{{ attic }}" = "true" ]; then
        just attic-push
        just clean
    fi

update attic="false":
    #!/usr/bin/env bash
    if [ "{{ attic }}" = "true" ]; then just attic-init; fi
    sudo darwin-rebuild switch --verbose --flake ./nix/. --option access-tokens "github.com=$(gh auth token)"
    cargo install-update -a --git
    pnpm update -g
    pnpm list -g
    if [ "{{ attic }}" = "true" ]; then
        just attic-push
        just clean
    fi

clean:
    sudo nix-collect-garbage --delete-older-than 7d -k --quiet
    cargo clean-all -d 14 -y ~/Desktop/Stuff/Programing/

attic-init:
    #!/usr/bin/env bash
    attic cache create mac | true
    attic use mac | true
    attic cache configure mac --priority 9 | true

attic-push:
    #!/usr/bin/env bash
    just attic-init
    nix shell nixpkgs/nixos-unstable#findutils nixpkgs/nixos-unstable#util-linux nixpkgs/nixos-unstable#coreutils -c bash -c '
      valid_paths=$(find /nix/store -maxdepth 1 -type d -name "*-*" | \
        head -1000 | \
        xargs -I {} -P $(nproc) sh -c "nix path-info \"\$1\" >/dev/null 2>&1 && echo \"\$1\"" _ {} | \
        tr "\n" " ")

      if [ -n "$valid_paths" ]; then
        for i in {1..10}; do
          nix run nixpkgs/nixos-unstable#attic-client push mac $valid_paths && break || [ $i -eq 10 ] || sleep 5
        done
      fi
    '

install:
    nix run nix-darwin -- switch --flake .

hud:
    #!/usr/bin/env bash
    toggle=$([ "$(launchctl getenv MTL_HUD_ENABLED)" = "1" ] && echo 0 || echo 1)
    launchctl setenv MTL_HUD_ENABLED "$toggle"
    echo "MTL_HUD_ENABLED set to $toggle"

dot:
    zed ~/.zshrc
    zed ~/.bashrc
    zed ~/.config/zed/settings.json
    # https://github.com/NixOS/nix/issues/8254#issuecomment-1787238439
    zed ~/.config/nix/nix.conf
    zed ~/.gitconfig
    zed ~/.config/jj/config.toml
    zed ~/.config/jjui/config.toml
    zed ~/.hermes/config.yaml
    zed ~/.hermes/.env

rc:
    just rclone-hetzner
    just rclone-mac
    # just rclone-proton

rclone args command="sync" threads="32":
    rclone {{ command }} -P --fast-list --transfers {{ threads }} --multi-thread-streams {{ threads }} {{ args }}

rclone-mac:
    just rclone "/Users/elijahmcmorris/Desktop/Stuff/Excel tower:main/Excel"
    just rclone "/Users/elijahmcmorris/Desktop/Stuff/Pic tower:main/Pic"
    # just rclone "/Users/elijahmcmorris/.cache/lm-studio/models tower:lm-studio/models"

rclone-proton:
    just rclone '--delete-before --protondrive-replace-existing-draft=true --protondrive-enable-caching=false --exclude "!Other/hetzner/" /Users/elijahmcmorris/Desktop/Stuff/Excel proton_compress:Excel' sync 4

rclone-wikidata:
    just rclone "tower:main/latest-all.json.bz2 /Users/elijahmcmorris/Desktop/Stuff/Programing/nextrack/data/latest-all.json.bz2" copyto

rclone-hetzner:
    just rclone "hetzner:NexVeridian/minecraft-data-vanilla /Users/elijahmcmorris/Desktop/Stuff/Excel/!Other/hetzner/minecraft-data-vanilla"
    just rclone "hetzner:NexVeridian/data/parquet /Users/elijahmcmorris/Desktop/Stuff/Excel/!Other/hetzner/data/parquet"
    # All data
    just rclone '--exclude "attic-data/" --exclude "forgejo-data/.cache/" hetzner:NexVeridian tower:main/hetzner'

docker:
    # colima stop
    # colima start --cpu 2 --memory 4

    docker stop $(docker ps -q) || true
    docker system prune -f -a

    # docker run --rm --privileged -d --name buildkit moby/buildkit

github_upstream repo_name="loco-rs/loco-openapi-Initializer":
    #!/usr/bin/env bash
    repo_dir="{{ repo_name }}"
    repo_dir="${repo_dir##*/}"
    jj git clone --remote upstream git@github.com:{{ repo_name }}.git
    cd "$repo_dir"
    jj git remote add origin git@github.com:NexVeridian/"$repo_dir".git

git_forgejo repo_name="NexVeridian/dotfiles":
    jj git remote add nex ssh://git@git.nexveridian.com:222/{{ repo_name }}.git
    jj git push -u nex main
