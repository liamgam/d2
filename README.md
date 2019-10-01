# D2
General-purpose virtual assistant for Discord.

[![Linux](https://github.com/fwcd/d2/workflows/Linux/badge.svg)](https://github.com/fwcd/d2/actions)
[![macOS](https://github.com/fwcd/d2/workflows/macOS/badge.svg)](https://github.com/fwcd/d2/actions)

In addition to suporting various web APIs, it features basic scripting capabilities (such as piping and and chaining of commands) and a permission system.

## System Dependencies
* Swift 5
	* Swift can be installed conveniently using a version manager such as [`swiftenv`](https://github.com/kylef/swiftenv)
	* Current builds of Swift for Raspberry Pi [can be found here](https://github.com/uraimo/buildSwiftOnARM/releases)
		* Note that you might need to perform a [custom installation](https://swiftenv.fuller.li/en/latest/commands.html#custom-installation) if you use `swiftenv` on Raspberry Pi
* Node.js and npm
* `timeout` and `kill` (currently only for `MaximaCommand`)

### Installation on Linux
* `sudo apt-get install libopus-dev libsodium-dev libssl1.0-dev libcairo2-dev texlive-latex-base texlive-latex-extra poppler-utils maxima`
	* Note that you might need to use `libssl-dev` instead of `libssl1.0-dev` on Ubuntu
	* If Swift cannot find the Freetype headers despite `libfreetype6-dev` being installed, you may need to add symlinks:
		* `mkdir /usr/include/freetype2/freetype`
		* `ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h`
		* `ln -s /usr/include/freetype2/tttables.h /usr/include/freetype2/freetype/tttables.h`
	* Note that you might need to `apt-get install clang` separately on a Raspberry Pi
	* Instead of using `texlive-latex-extra`, you can install the required LaTeX packages manually too:
		* To setup `tlmgr` on a Pi you might need to run:
			* `sudo apt-get install xzdec`
			* `cd ~`
			* `mkdir texmf`
			* `tlmgr init-usertree`
		* `tlmgr install standalone xkeyval varwidth preview xcolor`
* `cd Node && ./install-all`

### Installation on macOS
* Install a LaTeX distribution
* Install `maxima`
* `brew tap vapor/tap`
* `brew install opus libsodium ctls cairo poppler gd`
* `cd Node && ./install-all`

## Setup

### Required
* Create a folder named `local` in the repository
* Create a file named `discordToken.json` in `local` containing the API key:

```json
{
    "token": "YOUR_DISCORD_API_TOKEN"
}
```

### Optional
* Create a file named `config.json` in `local`:

```json
{
	"prefix": "%"
}
```

* Create a file named `adminWhitelist.json` in `local` containing a list of Discord usernames that have full permissions:

```json
{
    "users": [
        "YOUR_USERNAME#1234"
    ]
}
```

* Create a file named `webApiKeys.json` in `local` containing various API keys:

```json
{
	"mapQuest": "YOUR_MAP_QUEST_KEY",
	"wolframAlpha": "YOUR_WOLFRAM_ALPHA_KEY"
}
```

## Building

### on Linux
* `swift build`

### on macOS
* `swift build -Xlinker -L/usr/local/lib -Xlinker -lopus -Xcc -I/usr/local/include`

For Xcode support, see [the README of SwiftDiscord](https://github.com/nuclearace/SwiftDiscord/blob/master/README.md).

## Testing
* `swift test`

## Running

### on Linux
* `swift run`

### on macOS
* `swift run -Xlinker -L/usr/local/lib -Xlinker -lopus -Xcc -I/usr/local/include`

## Architecture
The program consists of three modules:

* `D2`, the executable
* `D2Commands`, the command framework and the implementations
* `D2Graphics`, a 2D drawing library based on Cairo
* `D2Permissions`, the permission manager
* `D2Utils`, a collection of useful utilities
* `D2WebAPIs`, client implementations of various web APIs

### D2
The executable application. The base functionality is provided by `CommandHandler`, which is a `DiscordClientDelegate` that handles raw, incoming messages and dispatches them to custom handlers that conform to the `Command` protocol.

### D2Commands
At a basic level, the `Command` protocol consists of a single method named `invoke` that carries information about the user's request:

```swift
protocol Command: class {
	...
	
	func invoke(input: RichValue, output: CommandOutput, context: CommandContext)
	
	...
}
```

The arguments each represent a part of the invocation context. Given a request such as `%commandname arg1 arg2`, the implementor would receive:

| Parameter | Value |
| --------- | ----- |
| `input` | `.text("arg1 arg2")` |
| `output` | `DiscordOutput` |
| `context` | `CommandContext` containing the message, the client and the command registry |

Since `output: CommandOutput` represents a polymorphic object, the output of an invocation does not necessarily get sent to the Discord channel where the request originated from. For example, if the user creates a piped request such as `%first | second | third`, only the third command would operate on a `DiscordOutput`. Both the first and the second command call a `PipeOutput` instead that passes any values to the next command:

```swift
class PipeOutput: CommandOutput {
	private let sink: Command
	private let context: CommandContext
	private let args: String
	private let next: CommandOutput?
	
	init(withSink sink: Command, context: CommandContext, args: String, next: CommandOutput? = nil) {
		self.sink = sink
		self.args = args
		self.context = context
		self.next = next
	}
	
	func append(_ value: RichValue) {
		print("Piping to \(sink)")
		let nextInput = args.isEmpty ? value : (.text(args) + value)
		sink.invoke(input: nextInput, output: next ?? PrintOutput(), context: context)
	}
}
```

Often the `Command` protocol is too low-level to be adopted directly, since the input can be of any form (including embeds or images). To address this, there are subprotocols that provide a simpler template interface for implementors:

```swift
protocol StringCommand: Command {
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext)
}
```

`StringCommand` is useful when the command accepts a single string as an argument or if a custom argument parser is used. Its default implementation of `Command.invoke` passes either `args`, if not empty, or otherwise `input.content` to `StringCommand.invoke`.

```swift
protocol ArgCommand: Command {
	associatedtype Args: Arg

	var argPattern: Args { get }
	
	func invoke(withInputArgs inputArgs: [String], output: CommandOutput, context: CommandContext)
}
```

`ArgCommand` should be adopted if the command expects a fixed structure of arguments.
