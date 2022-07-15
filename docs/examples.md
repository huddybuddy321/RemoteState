---
sidebar_position: 3
---

# Examples

## Door

Our first example is of a door, a really basic one. This example shows how a states key can be a instance rather than a string.

When we create each and every doors state in `local DoorState = RemoteState.new(doorInstance, {Open = false})`, we pass `doorInstance` as the states key. This creates a unique state key for each door.

# Server

```lua
local CollectionService = game:GetService("CollectionService")
local RemoteState = require(game:GetService("ReplicatedStorage").RemoteState)

local function HandleDoor(doorInstance)
    local DoorState = RemoteState.new(doorInstance, {
        Open = false
    })

    doorInstance.Door.ClickDetector.MouseClick:Connect(function()
        --Every time the door is clicked, toggle the open value
        DoorState:Toggle("Open")
    end)
end

local doorTag = "Door"

for _, doorInstance in pairs(CollectionService:GetTagged(doorTag)) do
    HandleDoor(doorInstance)
end

CollectionService:GetInstanceAddedSignal(doorTag):Connect(function(doorInstance)
    HandleDoor(doorInstance)
end)
```

# Client

```lua
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local RemoteState = require(game:GetService("ReplicatedStorage").RemoteState)

local function HandleDoor(doorInstance)
    local retrievedDoorState, DoorState = RemoteState.WaitForState(doorInstance):await()

    local function ToggleDoor(isOpen)
        task.spawn(function() --Prevent yielding
            if isOpen then
                local openTween = TweenService:Create(doorInstance:WaitForChild("Door"), TweenInfo.new(0.5), {Transparency = 0.5})
                openTween:Play()

                openTween.Completed:Wait() --Wait for the door to open

                doorInstance:WaitForChild("Door").CanCollide = false
            else
                local closeTween = TweenService:Create(doorInstance:WaitForChild("Door"), TweenInfo.new(0.5), {Transparency = 0})
                closeTween:Play()

                closeTween.Completed:Wait() --Wait for the door to open

                doorInstance:WaitForChild("Door").CanCollide = true
            end
        end)
    end

    ToggleDoor(DoorState:Get("Open"))

    DoorState:GetChangedSignal("Open"):Connect(function(isOpen)
        --We want to call every time the Open value changes
        ToggleDoor(isOpen)
    end)
end

local doorTag = "Door"

for _, doorInstance in pairs(CollectionService:GetTagged(doorTag)) do
    HandleDoor(doorInstance)
end

CollectionService:GetInstanceAddedSignal(doorTag):Connect(function(doorInstance)
    HandleDoor(doorInstance)
end)
```