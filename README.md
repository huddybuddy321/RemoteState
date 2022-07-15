# RemoteState
 
Remote State is a lightweight library that simplifies the process of replicating state across clients.

Read the [documentation](https://huddybuddy321.github.io/RemoteState/) for more information on Remote State.

## Basic Example

### Server

```lua
local RemoteState = require(game:GetService("ReplicatedStorage").RemoteState)

local GameState = RemoteState.new("Game", {
    Status = "Intermission",
    Gamemode = RemoteState.None
})

task.wait(5)

GameState:SetState({
    Gamemode = "Swordfight",
    Status = "GamePlaying"
})

task.wait(5)

GameState:Reset()
```

### Client

```lua
local RemoteState = require(game:GetService("ReplicatedStorage").RemoteState)

local GameState = RemoteState.GetState("Game")

GameState:GetChangedSignal("Status"):Connect(function(status)
    if status == "Intermission" then
        print("We are in intermission!")
    elseif status == "GamePlaying" then
        print("We are in a game, the gamemode is " ..  GameState:Get("Gamemode"))
    end
end)
```