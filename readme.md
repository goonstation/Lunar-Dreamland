# Lunar Dreamland
#### What is this?
Lunar Dreamland is a reverse engineering project and a Lua and C++ library for interfacing with BYOND's Dream Daemon server software. Currently it also includes a DM bytecode disassembler and debugger. It is a continuation of the old [Asyncmos](https://github.com/Byond-Hackermen/atmospheric) project.

#### What can I do with it?
The main feature of Lunar Dreamland is hooking procs to reimplement them in Lua. Arguments and return values are automatically translated between BYOND and Lua types. You may get and set fields & call procs of datums passed to the proc. Here is an example:
```
proc = require("proc")
datum = require("datum")
proc.getProc("/proc/showcase"):hook(
	function(original, usr, src, some_datum)
		local name = some_datum.name
		name = name:gsub(" ", "_")
		proc.getProc("/proc/to_chat")(datum.world, name)
		some_datum.name = name
		name.listvar:append("Hello, world!")
		name.listvar["key"] = "value"
		some_datum:invoke("gib", 1, 2, 3)
	end
)
```

#### You said something about a debugger though?
Hell yeah! The debugger currently depends on Lunar but it might become a serparate project entirely.
At the moment, the project contains a disassembler which translates BYOND bytecode into assembly-like output. The debugger displays that output and offers the ability to set breakpoints, which stop execution of the proc and allow inspecting the proc state, such as local variable values.

#### I'm tired of recompiling the server every time I make a change.
It's not available yet but a hot patching compiler is in the works! It is integrated into [SpacemanDMM](https://github.com/SpaceManiac/SpacemanDMM) and the VSCode extension. It will allow you to simply recompile a proc and swap the new bytecode in, without even restarting Dream Daemon. Cool, huh?

#### This is great but how do I compile it?
dunno lol, use the binaries