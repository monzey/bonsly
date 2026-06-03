import type { Plugin } from "@opencode-ai/plugin"
import { readFileSync } from "fs"
import { basename, dirname } from "path"

function filesFromPatch(patchText: string): string[] {
  const files = new Set<string>()
  for (const line of patchText.split("\n")) {
    const match = line.match(/^\*\*\* (?:Update|Add|Delete) File: (.+)$/)
    if (match) files.add(match[1])
  }
  return [...files]
}

// Même logique que get_proj() dans openvide
function projectName(dir: string): string {
  const worktreeMatch = dir.match(/^(.+)\.worktrees\/([^/]+)$/)
  if (worktreeMatch) {
    const repoName = basename(worktreeMatch[1])
    const branch = worktreeMatch[2]
    return `${repoName}-${branch}`
  }
  return basename(dir)
}

type PendingEntry = {
  files: string[]
  newString: string | null
}

export const OpenInNeovim: Plugin = async ({ $, directory }) => {
  const proj = projectName(directory)
  const socket = `${process.env.HOME}/.cache/nvim/${proj}.pipe`
  const pending = new Map<string, PendingEntry>()

  return {
    "tool.execute.before": async (input, output) => {
      if (["edit", "write"].includes(input.tool)) {
        if (output.args?.filePath) {
          pending.set(input.callID, {
            files: [output.args.filePath],
            newString: output.args.newString ?? null,
          })
        }
      }
      if (input.tool === "apply_patch") {
        const files = filesFromPatch(output.args?.patchText ?? "")
        if (files.length > 0) pending.set(input.callID, { files, newString: null })
      }
    },

    "tool.execute.after": async (input) => {
      const entry = pending.get(input.callID)
      if (!entry) return
      pending.delete(input.callID)

      for (const file of entry.files) {
        let line = 1
        if (entry.newString) {
          try {
            const content = readFileSync(file, "utf-8")
            const lines = content.split("\n")
            const searchLine = entry.newString
              .split("\n")
              .find((l) => l.trim().length > 0) ?? ""
            const idx = lines.findIndex((l) => l.includes(searchLine.trim()))
            if (idx >= 0) line = idx + 1
          } catch {}
        }
        const escaped = file.replaceAll(" ", "\\ ")
        await $`nvim --server ${socket} --remote-send ${`:e +${line} ${escaped}<CR>`}`.quiet()
      }
    },
  }
}
