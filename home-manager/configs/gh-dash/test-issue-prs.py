"""Run with python3 home-manager/configs/gh-dash/test-issue-prs.py (gh/jq required)."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


CONFIG = Path(__file__).with_name("config.yml").read_text()
COMMAND = CONFIG.split("    command: |\n", 1)[1].split("\n  prs:", 1)[0]
COMMAND = "\n".join(line[6:] for line in COMMAND.splitlines())
COMMAND = COMMAND.replace("{{.RepoName}}", "rgsystemes/kb").replace("{{.IssueNumber}}", "123")


class IssuePRsTest(unittest.TestCase):
    def run_command(self, pages, fail=""):
        with tempfile.TemporaryDirectory() as directory:
            gh = Path(directory, "gh")
            gh.write_text("""#!/usr/bin/env python3
import json, os, subprocess, sys
args = sys.argv[1:]
if os.environ['FAIL'] == args[0]:
    print('Erreur GitHub simulée', file=sys.stderr)
    sys.exit(1)
if args[0] == 'api':
    assert '--paginate' in args and '--slurp' in args
    print(os.environ['PAGES'])
else:
    assert args[:2] == ['pr', 'view']
    number = int(args[2].rsplit('/', 1)[1])
    data = dict(number=number, url=args[2], title='Titre\\nnettoyé',
                state={2: 'MERGED', 3: 'CLOSED'}.get(number, 'OPEN'), isDraft=number == 4)
    sys.exit(subprocess.run(['jq', '-r', args[args.index('--jq') + 1]],
                           input=json.dumps(data), text=True).returncode)
""")
            gh.chmod(0o755)
            pager = Path(directory, "less")
            pager.write_text("#!/bin/sh\ncat\n")
            pager.chmod(0o755)
            return subprocess.run(
                ["sh", "-c", COMMAND], capture_output=True, text=True,
                env={**os.environ, "PATH": directory + os.pathsep + os.environ["PATH"],
                     "PAGES": json.dumps(pages), "FAIL": fail},
            )

    def test_pages_duplicates_and_current_states(self):
        def reference(number):
            return {"event": "cross-referenced", "source": {"issue": {
                "html_url": f"https://github.com/rgsystemes/code/pull/{number}",
                "pull_request": {},
            }}}

        result = self.run_command([
            [reference(1), {"event": "commented"}, {"event": "cross-referenced",
              "source": {"issue": {"html_url": "https://github.com/rgsystemes/kb/issues/9"}}}],
            [reference(1), reference(2), reference(3), reference(4)],
        ])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.count("rgsystemes/code#1"), 1)
        for state in ("Ouverte", "Fusionnée", "Fermée", "Brouillon"):
            self.assertIn(state, result.stdout)
        self.assertIn("Titre nettoyé", result.stdout)
        self.assertNotIn("issues/9", result.stdout)

    def test_no_pr(self):
        result = self.run_command([[]])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Aucune PR accessible", result.stdout)

    def test_api_error_is_not_reported_as_no_pr(self):
        result = self.run_command([[]], fail="api")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("Aucune PR", result.stdout)

    def test_pr_error_is_not_hidden_by_the_pager(self):
        result = self.run_command([[{"event": "cross-referenced", "source": {"issue": {
            "html_url": "https://github.com/rgsystemes/code/pull/1", "pull_request": {},
        }}}]], fail="pr")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Erreur GitHub simulée", result.stderr)


if __name__ == "__main__":
    unittest.main()
