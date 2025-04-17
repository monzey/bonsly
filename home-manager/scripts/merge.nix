{ config, pkgs, ... }:

let
  updateScript = pkgs.writeShellScriptBin "merge" ''
#!/bin/bash

set -e

REMOTE="origin"
BASE_BRANCH="master"
TMP_BRANCH="tmp-conflict-check"

echo "📥 Fetching branches..."
git fetch "$REMOTE" --prune

echo "🔍 Récupération des branches à tester..."
branches=($(git branch -r | grep "$REMOTE/" | grep -E "$REMOTE/(feat-|fix-|ops-)" | sed "s#^$REMOTE/##"))

echo "🧠 Indexation des fichiers modifiés par branche..."
declare -A branch_files
for b in "${branches[@]}"; do
  files=$(git diff --name-only "$REMOTE/$BASE_BRANCH".."$REMOTE/$b" || true)
  branch_files["$b"]="$files"
done

# Compare les fichiers touchés entre 2 branches
branches_touch_same_file() {
  local f1="${branch_files[$1]}"
  local f2="${branch_files[$2]}"
  for file1 in $f1; do
    for file2 in $f2; do
      if [[ "$file1" == "$file2" ]]; then
        return 0
      fi
    done
  done
  return 1
}

echo "🧪 Test des paires de branches..."

conflicts=()
total=${#branches[@]}

git checkout "$BASE_BRANCH"
git checkout -B "$TMP_BRANCH"

for ((i = 0; i < total; i++)); do
  for ((j = i + 1; j < total; j++)); do
    b1="${branches[$i]}"
    b2="${branches[$j]}"

    if branches_touch_same_file "$b1" "$b2"; then
      echo "🔧 Merge test: $b1 + $b2"
      git reset --hard "$REMOTE/$BASE_BRANCH" &>/dev/null

      if ! git merge --no-commit --no-ff "$REMOTE/$b1" "$REMOTE/$b2" &>/dev/null; then
        conflict_files=$(git diff --name-only --diff-filter=U)
        echo "❌ Conflit entre $b1 et $b2 :"
        echo "   ⟶ $conflict_files"
        conflicts+=("❌ $b1 ⬄ $b2\n    ⟶ fichiers : $conflict_files")
        git merge --abort &>/dev/null
      fi
    fi
  done
done

echo ""
echo "📋 Résumé des conflits détectés :"
if [ ${#conflicts[@]} -eq 0 ]; then
  echo "✅ Aucun conflit trouvé entre les paires de branches."
else
  for c in "${conflicts[@]}"; do
    echo -e "$c\n"
  done
fi

# Nettoyage
git checkout "$BASE_BRANCH"
git branch -D "$TMP_BRANCH" &>/dev/null || true

  '';
in
{
  home.packages = [ updateScript ];
}
