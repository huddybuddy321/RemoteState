local RunService = game:GetService("RunService")

local Signal = require(script:FindFirstAncestor("RemoteState").Signal)
local Promise = require(script:FindFirstAncestor("RemoteState").Promise)

--[=[
    @class RemoteStateServer

    RemoteState server version.
]=]

--[=[
    @prop None None

    ```lua
    GameState:Set("Map", RemoteState.None)
    ```

    @within RemoteStateServer
]=]

local RemoteStateServer = {
    States = {},
    None = require(script:FindFirstAncestor("RemoteState").None)
}

RemoteStateServer._getRemote = Instance.new("RemoteFunction")
RemoteStateServer._getRemote.Name = "GetState"
RemoteStateServer._getRemote.Parent = script:FindFirstAncestor("RemoteState")

RemoteStateServer._stateChangedRemote = Instance.new("RemoteEvent")
RemoteStateServer._stateChangedRemote.Name = "StateChanged"
RemoteStateServer._stateChangedRemote.Parent = script:FindFirstAncestor("RemoteState")

RemoteStateServer._stateCreatedRemote = Instance.new("RemoteEvent")
RemoteStateServer._stateCreatedRemote.Name = "StateCreated"
RemoteStateServer._stateCreatedRemote.Parent = script:FindFirstAncestor("RemoteState")

RemoteStateServer._stateDestroyedRemote = Instance.new("RemoteEvent")
RemoteStateServer._stateDestroyedRemote.Name = "StateDestroyed"
RemoteStateServer._stateDestroyedRemote.Parent = script:FindFirstAncestor("RemoteState")


RemoteStateServer._getRemote.OnServerInvoke = function(player, stateKey)
    return RemoteStateServer.States[stateKey]._rawData
end

--[=[
    @class ServerState

    ServerState.
]=]

--[=[
    @prop Changed Signal

    ```lua
    local GameState = RemoteState.GetState("Game")
    GameState.Changed:Connect(function(key, newValue, oldValue)
        print(key .. " was changed")
        print(newValue .. " is the new value")
        print(oldValue .. " was the old value")
    end)
    ```

    @within ServerState
]=]


local ServerState = {}
ServerState.__index = ServerState

local function createNewDictionary(dictionary)
    if dictionary and typeof(dictionary) == "table" then
        local newDictionary = {}

        for key, value in pairs(dictionary) do
            newDictionary[key] = value
        end

        return newDictionary
    end
end

--[=[
    Creates a new state.

    ```lua
    local GameState = RemoteState.new("Game", {
        Status = "Lobby"
    })
    ```

    @param stateKey any
    @param stateRawData table

    @return ClientState
]=]


function RemoteStateServer.new(stateKey, stateRawData)
    assert(not RemoteStateServer.States[stateKey], "Trying to create a new state with a used key")

    local serverState = setmetatable({}, ServerState)
    serverState._key = stateKey
    serverState._rawData = stateRawData or {}

    serverState._initialRawData = createNewDictionary(stateRawData) or {}
    serverState._keyChangedSignals = {}

    serverState.Changed = Signal.new()

    RemoteStateServer.States[stateKey] = serverState

    RemoteStateServer._stateCreatedRemote:FireAllClients(stateKey, serverState._rawData)

    return serverState
end

--[=[
    Get state.

    ```lua
    local GameState = RemoteState.GetState("Game")
    ```

    @param stateKey any

    @return ClientState
]=]

function RemoteStateServer.GetState(stateKey)
    return RemoteStateServer.States[stateKey]
end

--[=[
    Wait for state.

    ```lua
    RemoteState.WaitForState("Game"):andThen(function(state)
        print(state:Get("Status"))
    end)
    ```

    @param stateKey any

    @return Promise
]=]

function RemoteStateServer.WaitForState(stateKey)
    return Promise.new(function(resolve)
        local heartbeatConnection
        heartbeatConnection = RunService.Heartbeat:Connect(function()
            if RemoteStateServer.GetState(stateKey) then
                heartbeatConnection:Disconnect()
                resolve(RemoteStateServer.GetState(stateKey))
            end
        end)
    end)
end

--[=[
    Set value in state.

    @within ServerState

    ```lua
    GameState:Set("Status", "InGame")
    ```

    @param key any
    @param value any

    @return any
]=]


function ServerState:Set(key, value)
    local oldValue = self._rawData[key]

    self._rawData[key] = value
    self.Changed:Fire(key, value)

    if self._keyChangedSignals[key] then
        self._keyChangedSignals[key]:Fire(value)
    end

    --RemoteStateServer._stateChangedRemote:FireAllClients(self._key, key, value, oldValue)
    RemoteStateServer._stateChangedRemote:FireAllClients(self._key, {[key] = value})

    return value
end

--[=[
    Set multiple values in state.

    @within ServerState

    ```lua
    GameState:SetState({
        Status = "InGame",
        Gamemode = "Swordfight"
    })
    ```

    @param newData array
]=]

function ServerState:SetState(newData)
    --Update all the values before calling changed signal

    for key, value in pairs(newData) do
        self._rawData[key] = value
    end

    for key, value in pairs(newData) do
        self.Changed:Fire(key, value)

        if self._keyChangedSignals[key] then
            self._keyChangedSignals[key]:Fire(value)
        end
    end

    RemoteStateServer._stateChangedRemote:FireAllClients(self._key, newData)
end

--[=[
    Increment a value in state.

    @within ServerState

    ```lua
    local pointsAvailable = GameState:Increment("PointsAvailable", 69)
    ```

    @param key any
    @param increment number

    @return number
]=]

function ServerState:Increment(key, increment)
    return self:Set(key, self:Get(key) + increment)
end

--[=[
    Decrement a value in state.

    @within ServerState

    ```lua
    local pointsAvailable = GameState:Decrement("PointsAvailable", 69)
    ```

    @param key any
    @param decrement number

    @return number
]=]

function ServerState:Decrement(key, decrement)
    return self:Set(key, self:Get(key) - decrement)
end

--[=[
    Toggle a value in state.

    @within ServerState

    ```lua
    local isPlaying = GameState:Toggle("Playing")
    ```

    @param key any

    @return boolean
]=]

function ServerState:Toggle(key)
    local toggle = not self:Get(key)

    self:Set(key, toggle)

    return toggle
end

--[=[
    Get value from state.

    @within ServerState

    ```lua
    local gameStatus = GameState:Get("Status")
    print("The current game status is " .. gameStatus)
    ```

    @param key any

    @return any
]=]

function ServerState:Get(key)
    local value = self._rawData[key]

    if typeof(value) == "table" then
        if value.Flag and value.Flag == RemoteStateServer.None.Flag then
            return nil
        end
    end

    return value
end

--[=[
    Get all values from state.

    @within ServerState

    ```lua
    local gameData = GameState:GetState()
    print(gameData)
    ```

    @return array
]=]

function ServerState:GetState()
    local rawData = createNewDictionary(self._rawData)

    for key, value in pairs(rawData) do
        if typeof(value) == "table" then
            if value.Flag and value.Flag == RemoteStateServer.None.Flag then
                rawData[key] = nil
            end
        end
    end

    return rawData
end

--[=[
    Get the changed signal of a value within a state.

    @within ServerState

    ```lua
    GameState:GetChangedSignal("Status"):Connect(function(status)
        print("The game's new status is " .. status)
    end)
    ```

    @param key any

    @return Signal
]=]

function ServerState:GetChangedSignal(key)
    if self._keyChangedSignals[key] then
        return self._keyChangedSignals[key]
    else
        self._keyChangedSignals[key] = Signal.new()
        return self._keyChangedSignals[key]
    end
end

--[=[
    Reset the state to its initial data.

    @within ServerState

    ```lua
    wait(30)
    print("Game over!")
    GameState:Reset()
    ```
]=]

function ServerState:Reset()
    --[[
    for key, _ in pairs(self._rawData) do
        if self._initialRawData[key] then
            self:Set(key, self._initialRawData[key])
        else
            self:Set(key, nil)
        end
    end
    ]]--

    local newData = {}

    for key, _ in pairs(self._rawData) do
        if self._initialRawData[key] then
            newData[key] = self._initialRawData[key]
        else
            newData[key] = RemoteStateServer.None
            --self:Set(key, nil)
        end
    end

    self:SetState(newData)
end

--[=[
    Disconnects all connections to signals within state.

    :::note
    `ClientState:Destroy()` will be called on the given state.
    :::

    @within ServerState
]=]

function ServerState:Destroy()
    self.Changed:Destroy()
    for _, signal in pairs(self._keyChangedSignals) do
        signal:Destroy()
    end

    RemoteStateServer.States[self._key] = nil

    RemoteStateServer._stateDestroyedRemote:FireAllClients(self._key)
end

return RemoteStateServer