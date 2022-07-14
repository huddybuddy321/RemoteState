# RemoteState
 
Remote State is a lightweight library that simplifies the process of replicating a server state to clients.

## Basic Example

### Server

```lua
local RemoteState = require(game:GetService("ReplicatedStorage").RemoteState)

local GameState = RemoteState.new("Game", {
    Status = "Lobby",
})

wait(5)

GameState:SetState({
    Gamemode = "Swordfight",
    Status = "InGame"
})

wait(5)

GameState:Set("Status", "Lobby")
```

### Client

```lua
local RemoteState = require(game:GetService("ReplicatedStorage").RemoteState)

local GameState = RemoteState.GetState("Game")

GameState:GetChangedSignal("Status"):Connect(function(status)
    if status == "Lobby" then
        print("We are in the lobby!")
    elseif status == "InGame" then
        print("We are in a game, the gamemode is " ..  GameState:Get("Gamemode"))
    end
end)
```