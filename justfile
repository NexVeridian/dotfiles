switch *args='':
    nix-channel --update
    nix flake update --flake ./nix/.
    sudo darwin-rebuild switch --verbose --flake ./nix/.
    if [ "{{args}}" = "attic" ]; then just attic; fi

update *args='':
    nix-channel --update
    sudo darwin-rebuild switch --verbose --flake ./nix/.
    if [ "{{args}}" = "attic" ]; then just attic; fi

clean:
    sudo nix-collect-garbage -d -k
    cargo clean-all -y ~/Desktop/Stuff/Programing/
    rm -r ~/.cache/huggingface/hub/*

attic:
    #!/usr/bin/env bash
    attic cache create mac | true
    attic use mac | true
    for i in {1..5}; do
      attic push mac /run/current-system -j 1 && break || [ $i -eq 5 ] || sleep 5
    done
    for i in {1..5}; do
      attic push mac /nix/store/*/ && break || [ $i -eq 5 ] || sleep 5
    done

attic-tower:
    #!/usr/bin/env bash
    attic cache create tower:mac | true
    attic use tower:mac | true
    for i in {1..5}; do
      attic push tower:mac /run/current-system -j 1 && break || [ $i -eq 5 ] || sleep 5
    done
    for i in {1..5}; do
      attic push tower:mac /nix/store/*/ && break || [ $i -eq 5 ] || sleep 5
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
    # https://github.com/NixOS/nix/issues/4653
    zed ~/.config/nix/nix.conf

rc:
    just rclone
    just rclone-proton

rclone:
    rclone sync -v /Users/elijahmcmorris/Desktop/Stuff/Excel tower:main/Excel
    rclone sync -v /Users/elijahmcmorris/.cache/lm-studio/models tower:lm-studio/models

rclone-proton:
    rclone sync -v /Users/elijahmcmorris/Desktop/Stuff/Excel proton:Excel

wikidata:
    rclone copyto -v tower:main/latest-all.json.bz2 /Users/elijahmcmorris/Desktop/Stuff/Programing/nextrack/data/latest-all.json.bz2

docker:
    # colima stop
    # colima start --cpu 2 --memory 4

    docker stop $(docker ps -q) || true
    docker system prune -f -a

    # docker run --rm --privileged -d --name buildkit moby/buildkit
