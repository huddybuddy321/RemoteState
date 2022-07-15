---
sidebar_position: 2
---

# Getting Started

## Installation

To start using RemoteState, you must first install it.

You can download RemoteState through the [Github Releases](https://github.com/huddybuddy321/RemoteState/releases) page or on the [Roblox Library](https://www.roblox.com/library/10224464689/Remote-State) page.

### Rojo workflow

Download the .rbmx release file from the Github Releases page and place it inside your designated packages folder.

### Roblox workflow

Download the module from the Roblox Library and place the module inside ReplicatedStorage.

## Creating a state

Imagine this is some sort of round based game.

Lets start of by making some sort of a game state.

This game state will describe what the games status is (Intermission or InGame), and, if the game has started, the state will describe what the gamemode and the map are.

**Server**

```lua
local RemoteState = require(game:GetService("ReplicatedStorage").RemoteState)

local GameState = RemoteState.new("Game", {
    Status = "Intermission",
    Gamemode = RemoteState.None,
    Map = RemoteState.None
})
```

Okay, so now that we have created the state on the Server side, we must retrieve it on the Client side.

## Getting a state

**Client**

```lua
local RemoteState = require(game:GetService("ReplicatedStorage").RemoteState)

local retrievedGameState, GameState = RemoteState.WaitForState("Game"):await()
```

As you see, I used the "WaitForState" function. This is just a "safety" feature to ensure that the client retrieves the game state.

Next, we need to create some sort of a loop that changes the game state (on the Server side).

## Manipulating a state

**Server**

```lua
local intermissionTime = 10
local gameTime = 60

while true do
    wait(intermissionTime)
    --Intermission has ended

    GameState:SetState({
        Status = "GamePlaying",
        GameMode = "Classic",
        Map = "AMap"
    })

    wait(gameTime)
    --The game has ended, lets reset the state back to its initial data.

    GameState:Reset()
end
```

Okay, thats pretty much a basic game loop.

Now, on the client, lets handle these state changes.

## Handling state changes

We manipulated the state on the server, but now we need to respond to these changes on the client side.

**Client**

```lua
--Lets watch the state change
GameState:GetChangedSignal("Status"):Connect(function(status)
    if status == "Intermission" then
        print("The game is in intermission")
    elseif status == "GamePlaying" then
        --We can use the state:Get() function to get the gamemode and map
        print("We are in a game, the gamemode is " .. GameState:Get("GameMode") .. " and the map is " .. GameState:Get("Map"))
    end
end)
```

## Final Code

Well... that's pretty much it!

**Final Server Code**
```lua
local RemoteState = require(game:GetService("ReplicatedStorage").RemoteState)

local GameState = RemoteState.new("Game", {
    Status = "Intermission",
    Gamemode = RemoteState.None,
    Map = RemoteState.None
})

local intermissionTime = 10
local roundTime = 60

while true do
    wait(intermissionTime)
    --Intermission has ended

    GameState:SetState({
        Status = "GamePlaying",
        GameMode = "Classic",
        Map = "AMap"
    })

    wait(roundTime)
    --The round has ended

    GameState:Reset() --Lets reset the state back to its initial data.
end
```

**Final Client Code**

```lua
local RemoteState = require(game:GetService("ReplicatedStorage").RemoteState)

local retrievedGameState, GameState = RemoteState.WaitForState("Game"):await()

--Lets watch the state change
GameState:GetChangedSignal("Status"):Connect(function(status)
    if status == "Intermission" then
        print("The game is in intermission")
    elseif status == "GamePlaying" then
        --We can use the state:Get() function to get the gamemode and map
        print("We are in a game, the gamemode is " .. GameState:Get("GameMode") .. " and the map is " .. GameState:Get("Map"))
    end
end)
```