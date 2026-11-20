{ lib, ... }:

{
  home.file = lib.genAttrs (map (root: "${root}/openvide") [
    ".agents/skills"
    ".grok/skills"
    ".claude/skills"
  ]) (_: {
    source = ../../configs/skills/openvide;
  });
}
