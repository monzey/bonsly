#!/usr/bin/env python3
"""Exercise the set and drawer with a stateful Hyprland stub."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

SCRIPT = Path(__file__).with_name("gh-dash-set.sh")
STUB = r'''#!/usr/bin/env python3
import json, os, re, shlex, sys
from pathlib import Path
path = Path(os.environ["HYPR_TEST_STATE"])
state = json.loads(path.read_text())
args = sys.argv[1:]
if args[0] in ("monitors", "clients"):
    print(json.dumps(state[args[0]]))
    sys.exit()
if args[0] == "dispatch":
    command = args[1]
    state["commands"].append(command)
    def field(name):
        match = re.search(r'\b' + name + r' = ("(?:\\.|[^"\\])*"|[0-9]+)', command)
        return json.loads(match[1])
    def workspace(value):
        value = str(value).removesuffix(" silent").removeprefix("name:")
        return {"id": 9 if value == "9" else -1, "name": "conf" if value == "9" else value}
    focused = next(m for m in state["monitors"] if m["focused"])
    if "exec_cmd" in command:
        argv = shlex.split(json.loads(re.search(r'exec_cmd\(("(?:\\.|[^"\\])*")', command)[1]))
        cls = argv[argv.index("--class") + 1]
        state["clients"].append({"class": cls, "address": "0x" + str(len(state["clients"])),
                                 "workspace": workspace(field("workspace")), "argv": argv})
    elif "window.move" in command:
        next(c for c in state["clients"] if "address:" + c["address"] == field("window"))["workspace"] = workspace(field("workspace"))
    elif "workspace.move" in command:
        state["placements"][str(field("workspace"))] = field("monitor")
    elif "toggle_special" in command:
        name = "special:" + json.loads(re.search(r'toggle_special\((.*)\)', command)[1])
        focused["specialWorkspace"]["name"] = "" if focused["specialWorkspace"]["name"] == name else name
    elif "focus" in command:
        if "monitor =" in command:
            for monitor in state["monitors"]:
                monitor["focused"] = monitor["name"] == field("monitor")
        else:
            focused["activeWorkspace"] = workspace(field("workspace"))
            focused["specialWorkspace"]["name"] = ""
elif Path(sys.argv[0]).name == "code":
    state["code"] = args
else:
    raise AssertionError(args)
path.write_text(json.dumps(state))
'''


def monitors(names):
    return [{"name": name, "focused": i == 0,
             "activeWorkspace": {"id": 9, "name": "conf"},
             "specialWorkspace": {"name": ""}}
            for i, name in enumerate(names)]


with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    for name in ("hyprctl", "code"):
        binary = root / name
        binary.write_text(STUB)
        binary.chmod(0o755)
    state_path = root / "state.json"
    env = dict(os.environ, PATH=f"{root}:{os.environ['PATH']}",
               XDG_CACHE_HOME=str(root), HYPR_TEST_STATE=str(state_path))

    def save(state):
        state_path.write_text(json.dumps(state))

    def run(mode):
        subprocess.run(["bash", str(SCRIPT), mode], env=env, check=True)
        return json.loads(state_path.read_text())

    for names in (["DP-6", "DP-7", "DP-5"], ["eDP-1", "DP-6", "DP-7", "DP-5"]):
        save(dict(monitors=monitors(names), clients=[], commands=[], placements={}))
        state = run("focus")
        assert state["placements"] == {"9": "DP-7", "name:rg-claude": "DP-5"}
        assert next(m for m in state["monitors"] if m["focused"])["name"] == "DP-7"
        assert state["clients"][1]["workspace"]["name"] == "rg-claude"
        assert state["clients"][1]["argv"][-4:] == ["--directory", os.path.expanduser("~/rg"), "--hold", "claude"]
        state = run("focus")
        assert len(state["clients"]) == 2, "Repeated entry must reuse both windows"
        state = run("claude")
        assert next(m for m in state["monitors"] if m["focused"])["name"] == "DP-5"

    # Unplugging monitors must retain the existing Claude process in a drawer.
    for names in (["eDP-1"], ["eDP-1", "DP-6"]):
        state["monitors"] = monitors(names)
        save(state)
        state = run("focus")
        assert state["clients"][1]["workspace"]["name"] == "special:rg-claude"
        state = run("claude")
        assert state["monitors"][0]["specialWorkspace"]["name"] == "special:rg-claude"
        state = run("claude")
        assert state["monitors"][0]["specialWorkspace"]["name"] == ""
        assert len(state["clients"]) == 2
        state["monitors"][0]["specialWorkspace"]["name"] = "special:other-terminal"
        save(state)
        state = run("claude")
        assert state["monitors"][0]["specialWorkspace"]["name"] == "special:rg-claude"
        state = run("focus")
        assert state["monitors"][0]["specialWorkspace"]["name"] == ""

    state["monitors"] = monitors(["DP-6", "DP-7", "DP-5"])
    save(state)
    state = run("focus")
    assert state["clients"][1]["workspace"]["name"] == "rg-claude"
    assert len(state["clients"]) == 2, "Reconnecting must preserve the session"

    state["monitors"] = monitors(["eDP-1"])
    state["monitors"][0]["activeWorkspace"] = {"id": 1, "name": "web"}
    save(state)
    state = run("claude")
    assert state["code"] == ["/home/monzey/bonsly"]

print("gh-dash set: desk, drawer, reuse, monitor changes and shortcut fallback OK")
