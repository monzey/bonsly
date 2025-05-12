{ config, pkgs, ... }:

let
  updateScript = pkgs.writeShellScriptBin "merge" ''
#!/bin/bash
  set -e

          git fetch origin -p --no-tags
          git checkout -b tmp origin/master

          branches_to_merge=""
          branches=$(git branch -a | grep -iE "remotes/origin/(feat-|fix-|ops-)")

          for branch in $branches; do
            issue_number=$(echo "$branch" | grep -oE '(feat|fix|ops)-[0-9]+' | sed 's/^[a-zA-Z]*-//' || true)

            if [ -z "$issue_number" ]; then
              echo "Impossible de trouver un numéro d'issue dans la branche $branch, elle sera incluse."
              branches_to_merge="$branches_to_merge $branch"
              continue
            fi

            if curl -s -H "Authorization: token $GITHUB_TOKEN" \
              "https://api.github.com/repos/rgsystemes/kb/issues/$issue_number/labels" | grep -q '"name": "no-unstable"'; then
              echo "La branche $branch est ignorée car l'issue a le label 'no-unstable'."
              continue
            fi

            branches_to_merge="$branches_to_merge $branch"
          done

          if [ -n "$branches_to_merge" ]; then
            echo "Merge des branches dans unstable avec la stratégie octopus : $branches_to_merge"
            git merge --no-edit $branches_to_merge
          else
            echo "Aucune branche à merger."
          fi
  '';
in
{
  home.packages = [ updateScript ];
}
