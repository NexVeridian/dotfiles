switch attic="false":
    #!/usr/bin/env bash
    nix-channel --update --option access-tokens "github.com=$(gh auth token)"
    # https://github.com/NixOS/nix/issues/4653
    nix flake update --flake ./nix/. --option access-tokens "github.com=$(gh auth token)"
    sudo darwin-rebuild switch --verbose --flake ./nix/. --option access-tokens "github.com=$(gh auth token)"
    if [ "{{attic}}" = "true" ]; then
        just attic
        just clean
    fi

update attic="false":
    #!/usr/bin/env bash
    nix-channel --update --option access-tokens "github.com=$(gh auth token)"
    sudo darwin-rebuild switch --verbose --flake ./nix/. --option access-tokens "github.com=$(gh auth token)"
    if [ "{{attic}}" = "true" ]; then
        just attic
        just clean
    fi

clean:
    sudo nix-collect-garbage -d -k
    cargo clean-all -d 7 -y ~/Desktop/Stuff/Programing/
    rm -r ~/.cache/huggingface/hub/* || true

attic:
    #!/usr/bin/env bash
    attic cache create mac | true
    attic use mac | true
    for i in {1..10}; do
      attic push mac /run/current-system /nix/store/*/ && break || [ $i -eq 5 ] || sleep 5
    done

attic-tower:
    #!/usr/bin/env bash
    attic cache create tower:mac | true
    attic use tower:mac | true
    for i in {1..10}; do
      attic push tower:mac /run/current-system /nix/store/*/ && break || [ $i -eq 5 ] || sleep 5
    done

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
    # https://github.com/NixOS/nix/issues/8254#issuecomment-1787238439
    zed ~/.config/nix/nix.conf
    zed ~/.gitconfig
    zed ~/.config/jj/config.toml
    zed ~/.config/jjui/config.toml

rc:
    just hetzner
    just rclone
    just rclone-proton

rclone:
    rclone sync -v --fast-list --transfers 32 --multi-thread-streams 32 /Users/elijahmcmorris/Desktop/Stuff/Excel tower:main/Excel
    rclone sync -v --fast-list --transfers 32 --multi-thread-streams 32 /Users/elijahmcmorris/Desktop/Stuff/Pic tower:main/Pic
    rclone sync -v --fast-list --transfers 32 --multi-thread-streams 32 /Users/elijahmcmorris/.cache/lm-studio/models tower:lm-studio/models

rclone-proton:
    rclone sync -v --fast-list --protondrive-replace-existing-draft=true /Users/elijahmcmorris/Desktop/Stuff/Excel proton:Excel

wikidata:
    rclone copyto -v --fast-list --transfers 32 --multi-thread-streams 32 tower:main/latest-all.json.bz2 /Users/elijahmcmorris/Desktop/Stuff/Programing/nextrack/data/latest-all.json.bz2

hetzner:
    rclone sync -v --fast-list --transfers 32 --multi-thread-streams 32 hetzner:NexVeridian/minecraft-data-vanilla /Users/elijahmcmorris/Desktop/Stuff/Excel/!Other/hetzner/minecraft-data-vanilla
    rclone sync -v --fast-list --transfers 32 --multi-thread-streams 32 hetzner:NexVeridian/data/parquet /Users/elijahmcmorris/Desktop/Stuff/Excel/!Other/hetzner/data/parquet

docker:
    # colima stop
    # colima start --cpu 2 --memory 4

    docker stop $(docker ps -q) || true
    docker system prune -f -a

    # docker run --rm --privileged -d --name buildkit moby/buildkit

git_upstream:
    git remote add upstream git@github.com:loco-rs/loco-openapi-Initializer.git
    git remote set-branches upstream main
    git fetch upstream main
