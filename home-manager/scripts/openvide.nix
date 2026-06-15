{ config, pkgs, ... }:

let
  updateScript = pkgs.writeShellScriptBin "openvide" ''
    #!/bin/bash
    # Usage: openvide new    → ouvre un nouveau projet  (SUPER+SHIFT+N)
    #        openvide switch → switche vers un set ouvert (SUPER+CTRL+O)
    MODE="''${1:-new}"

    mkdir -p "$HOME/.cache/nvim"
    hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-7" })'

    # Dériver le nom de set depuis un chemin absolu
    get_proj() {
      local dir="$1"
      if [[ "$dir" == *".worktrees/"* ]]; then
        local branch repo_name
        branch=$(basename "$dir")
        repo_name=$(basename "$(dirname "$dir")" | sed 's/\.worktrees$//')
        echo "$repo_name-$branch"
      else
        basename "$dir"
      fi
    }

    # Switcher vers un set existant (move + focus les 3 workspaces)
    switch_set() {
      local proj="$1"
      hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"name:$proj-lazygit\",  monitor = \"DP-6\" })"
      hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"name:$proj-code\",     monitor = \"DP-7\" })"
      hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"name:$proj-opencode\", monitor = \"DP-5\" })"
      hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-6" })'
      hyprctl dispatch "hl.dsp.focus({ workspace = \"name:$proj-lazygit\" })"
      hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-5" })'
      hyprctl dispatch "hl.dsp.focus({ workspace = \"name:$proj-opencode\" })"
      hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-7" })'
      hyprctl dispatch "hl.dsp.focus({ workspace = \"name:$proj-code\" })"
    }

    # Créer un nouveau set puis switcher dessus
    create_set() {
      local proj="$1"
      local dir="$2"
      local socket="$HOME/.cache/nvim/$proj.pipe"

      rm -f "$socket"

      # Pré-créer chaque workspace sur son monitor → exec sans workspace rule → pas de flash
      hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-6" })'
      hyprctl dispatch "hl.dsp.focus({ workspace = \"name:$proj-lazygit\" })"
      hyprctl dispatch "hl.dsp.exec_cmd(\"kitty -d $dir --hold zsh -c 'lazygit'\")"

      hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-5" })'
      hyprctl dispatch "hl.dsp.focus({ workspace = \"name:$proj-opencode\" })"
      hyprctl dispatch "hl.dsp.exec_cmd(\"kitty -d $dir --hold zsh -c 'opencode-fhs'\")"

      hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-7" })'
      hyprctl dispatch "hl.dsp.focus({ workspace = \"name:$proj-code\" })"
      hyprctl dispatch "hl.dsp.exec_cmd(\"bash -c 'cd $dir && neovide -- --listen $socket'\")"

      sleep 0.5
      switch_set "$proj"
    }

    # ── MODE SWITCH ────────────────────────────────────────────────────────────
    if [[ "$MODE" == "switch" ]]; then
      existing=$(hyprctl workspaces -j | jq -r '.[] | select(.name | endswith("-code")) | .name[:-5]')
      count=$(echo "$existing" | grep -c . || true)

      if [[ -z "$existing" ]]; then
        exit 0
      elif [[ "$count" -eq 1 ]]; then
        switch_set "$existing"
      else
        selection=$(printf '%s' "$existing" | dmenu -p "switch:")
        [[ -z "$selection" ]] && exit 0
        switch_set "$selection"
      fi
      exit 0
    fi

    # ── MODE NEW ───────────────────────────────────────────────────────────────
    all_git=$(find ~ -maxdepth 4 -name ".git" -not -path "*/node_modules/*" 2>/dev/null \
      | sed 's|/.git$||' | sed "s|^$HOME/||" | sort)

    main_repos=$(find ~ -maxdepth 4 -name ".git" -type d -not -path "*/node_modules/*" 2>/dev/null \
      | sed 's|/.git$||' | sed "s|^$HOME/||" | sort)

    pick=$(printf '[nouveau worktree]\n%s' "$all_git" | dmenu -p "projet:")
    [[ -z "$pick" ]] && exit 0

    if [[ "$pick" == "[nouveau worktree]" ]]; then
      repo=$(printf '%s' "$main_repos" | dmenu -p "repo:")
      [[ -z "$repo" ]] && exit 0

      repo_path="$HOME/$repo"
      repo_parent=$(dirname "$repo_path")
      repo_name=$(basename "$repo_path")
      # Si le repo est déjà dans un dossier .worktrees, placer le nouveau worktree à côté
      if [[ "$repo_parent" == *".worktrees" ]]; then
        wt_dir="$repo_parent"
      else
        wt_dir="$repo_parent/$repo_name.worktrees"
      fi

      # Branches remote (sans origin/ ni HEAD)
      remote_branches=$(git -C "$repo_path" branch -r 2>/dev/null \
        | grep -v 'HEAD' | sed 's|.*origin/||' | sed 's/^[[:space:]]*//' | sort)

      branch=$(printf '[nouvelle branche]\n%s' "$remote_branches" | dmenu -p "branche:")
      [[ -z "$branch" ]] && exit 0

      if [[ "$branch" == "[nouvelle branche]" ]]; then
        branch=$(dmenu -p "nom branche:" < /dev/null)
        [[ -z "$branch" ]] && exit 0
      fi

      # Nom du dossier worktree (défaut = nom de la branche)
      wt_name=$(printf '%s' "$branch" | dmenu -p "nom dossier (défaut: $branch):")
      [[ -z "$wt_name" ]] && wt_name="$branch"

      wt_path="$wt_dir/$wt_name"
      mkdir -p "$wt_dir"

      base=$(git -C "$repo_path" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||')
      [[ -z "$base" ]] && base=$(git -C "$repo_path" branch --show-current 2>/dev/null)
      [[ -z "$base" ]] && base="main"

      if git -C "$repo_path" show-ref --verify --quiet "refs/heads/$branch"; then
        git -C "$repo_path" worktree add "$wt_path" "$branch"
      elif git -C "$repo_path" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
        git -C "$repo_path" worktree add --track -b "$branch" "$wt_path" "origin/$branch"
      else
        git -C "$repo_path" worktree add -b "$branch" "$wt_path" "$base"
      fi

      dir="$wt_path"
    else
      dir=$(realpath ~/"$pick")
    fi

    [[ ! -d "$dir" ]] && exit 0

    proj=$(get_proj "$dir")

    # Set déjà ouvert → juste switcher
    if hyprctl workspaces -j | jq -e --arg n "$proj-code" '.[] | select(.name == $n)' > /dev/null 2>&1; then
      switch_set "$proj"
    else
      create_set "$proj" "$dir"
    fi
  '';
in
{
  home.packages = [ updateScript ];
}
