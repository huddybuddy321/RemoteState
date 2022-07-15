local RunService = game:GetService("RunService")

local Signal = require(script:FindFirstAncestor("RemoteState").Signal)
local Promise = require(script:FindFirstAncestor("RemoteState").Promise)

local GetStateRemote = script:FindFirstAncestor("RemoteState"):WaitForChild("GetState")
local StateCreatedRemote = script:FindFirstAncestor("RemoteState"):WaitForChild("StateCreated")
local StateChangedRemote = script:FindFirstAncestor("RemoteState"):WaitForChild("StateChanged")

--[=[
    @class RemoteStateClient

    RemoteState client version.
]=]

local RemoteStateClient = {
    States = {},
    None = require(script:FindFirstAncestor("RemoteState").None)
}

local function createNewDictionary(dictionary)
    local newDictionary = {}

    for key, value in pairs(dictionary) do
        newDictionary[key] = value
    end

    return newDictionary
end

--[[

StateChangedRemote.OnClientEvent:Connect(function(stateKey, key, newValue, oldValue)
    local state = RemoteStateClient.States[stateKey]
    if state then
        state._rawData[key] = newValue
        state.Changed:Fire(key, newValue, oldValue)

        if state._keyChangedSignals[key] then
            state._keyChangedSignals[key]:Fire(newValue, oldValue, key)
        end
    end
end)
]]--

StateChangedRemote.OnClientEvent:Connect(function(stateKey, newData)
    local state = RemoteStateClient.States[stateKey]
    if state then
        local oldData = createNewDictionary(state._rawData)

        for key, value in pairs(newData) do
            state._rawData[key] = value
        end

        for key, value in pairs(newData) do
            state.Changed:Fire(value, oldData[key], key)

            if state._keyChangedSignals[key] then
                state._keyChangedSignals[key]:Fire(value, oldData[key], key)
            end
        end
    end
end)

--[=[
    @class ClientState

    ClientState.
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

    @within ClientState
]=]

local ClientState = {}
ClientState.__index = ClientState

--[=[
    Get state.

    ```lua
    local GameState = RemoteState.GetState("Game")
    ```

    @param stateKey any

    @return ClientState
]=]

function RemoteStateClient.GetState(stateKey)
    if not RemoteStateClient.States[stateKey] then
        local stateRawData = GetStateRemote:InvokeServer(stateKey)

        local state = ClientState.new(stateKey, stateRawData)
        RemoteStateClient.States[stateKey] = state

        return state
    else
        return RemoteStateClient.States[stateKey]
    end
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

function RemoteStateClient.WaitForState(stateKey)
    local state = RemoteStateClient.GetState(stateKey)
    if state then
        return Promise.resolve(state)
    else
        return Promise.new(function(resolve)
            local heartbeatConnection
            heartbeatConnection = RunService.Heartbeat:Connect(function()
                if RemoteStateClient.States[stateKey] then
                    heartbeatConnection:Disconnect()
                    resolve(RemoteStateClient.States[stateKey])
                end
            end)
        end)
    end
end

StateCreatedRemote.OnClientEvent:Connect(function(stateKey, stateRawData)
    local state = ClientState.new(stateKey, stateRawData)
    RemoteStateClient.States[stateKey] = state
end)

function ClientState.new(stateKey, stateRawData)
    local state = setmetatable({}, ClientState)
    state._rawData = stateRawData or {}
    state._key = stateKey
    state._keyChangedSignals = {}

    state.Changed = Signal.new()

    return state
end

--[=[
    Get value from state.

    @within ClientState

    ```lua
    local gameStatus = GameState:Get("Status")
    print("The current game status is " .. gameStatus)
    ```

    @param key any

    @return any
]=]

function ClientState:Get(key)
    local value = self._rawData[key]

    if typeof(value) == "table" then
        if value.Flag and value.Flag == RemoteStateClient.None.Flag then
            return nil
        end
    end

    return value
end

--[=[
    Get all values from state.

    @within ClientState

    ```lua
    local gameData = GameState:GetState()
    print(gameData)
    ```

    @return array
]=]

function ClientState:GetState()
    local rawData = createNewDictionary(self._rawData)

    for key, value in pairs(rawData) do
        if typeof(value) == "table" then
            if value.Flag and value.Flag == RemoteStateClient.None.Flag then
                rawData[key] = nil
            end
        end
    end

    return rawData
end

--[=[
    Get the changed signal of a value within a state.

    @within ClientState

    ```lua
    GameState:GetChangedSignal("Status"):Connect(function(status)
        print("The game's new status is " .. status)
    end)
    ```

    @param key any

    @return Signal
]=]

function ClientState:GetChangedSignal(key)
    if self._keyChangedSignals[key] then
        return self._keyChangedSignals[key]
    else
        self._keyChangedSignals[key] = Signal.new()
        return self._keyChangedSignals[key]
    end
end

--[=[
    Disconnects all signals within state.

    @within ClientState

    ```lua
    GameState:Destroy()
    ```
]=]

function ClientState:Destroy()
    self.Changed:Destroy()
    for _, signal in pairs(self._keyChangedSignals) do
        signal:Destroy()
    end
end

return RemoteStateClient