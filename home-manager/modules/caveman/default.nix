{ lib, pkgs, ... }:

let
  # Voice skills only. The caveman repo also ships a proxy and a CLI;
  # those stay out of this module.
  skills = [
    "caveman"
    "caveman-commit"
    "caveman-compress"
    "caveman-review"
    "megacave"
    "ultracave"
  ];

  # Codex, OpenCode, Antigravity, Gemini CLI and Copilot read ~/.agents/skills.
  # Grok and Claude Code only load their own user skill directory.
  roots = [
    ".agents/skills"
    ".grok/skills"
    ".claude/skills"
  ];

  src = pkgs.fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    rev = "9b68f7ed12b05e7efaff18e65c5a3fc2849fd0a4";
    hash = "sha256-z7ykIvSjzgeokmXCSuRQhqUgoRG9rXy0pJyNy7QY38k=";
    sparseCheckout = map (name: "skills/${name}") skills;
  };
  # npx skills wrote real directories here. home.file force replaces
  # files and symlinks, and leaves a directory in place, so the link step
  # fails with "Is a directory". Remove those directories first.
  skillPaths = lib.concatMap (root: map (name: "${root}/${name}") skills) roots;
in
{
  home.activation.cavemanSkillDirs = lib.hm.dag.entryBefore [ "linkGeneration" ] (
    lib.concatMapStrings (rel: ''
      target="$HOME/${rel}"
      if [[ -d "$target" && ! -L "$target" ]]; then
        rm -rf "$target"
      fi
    '') skillPaths
  );

  # Each entry is one skill directory. The parent dirs stay unmanaged so
  # skills installed outside bonsly (frontend-design, compress) are left alone.
  home.file = lib.listToAttrs (
    lib.concatMap (root:
      map (name: {
        name = "${root}/${name}";
        value = {
          source = "${src}/skills/${name}";
          force = true;
        };
      }) skills
    ) roots
  );
}
