local RunService = game:GetService("RunService")

local Signal = require(script:FindFirstAncestor("RemoteState").Signal)
local Promise = require(script:FindFirstAncestor("RemoteState").Promise)

local GetStateRemote = script:FindFirstAncestor("RemoteState"):WaitForChild("GetState")
local StateCreatedRemote = script:FindFirstAncestor("RemoteState"):WaitForChild("StateCreated")
local StateChangedRemote = script:FindFirstAncestor("RemoteState"):WaitForChild("StateChanged")

local RemoteStateClient = {
    States = {}
}

StateChangedRemote.OnClientEvent:Connect(function(stateKey, key, newValue)
    local state = RemoteStateClient.States[stateKey]
    if state then
        state._rawData[key] = newValue
        state.Changed:Fire(key, newValue)

        if state._keyChangedSignals[key] then
            state._keyChangedSignals[key]:Fire(newValue)
        end
    end
end)

local ClientState = {}
ClientState.__index = ClientState

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
                    return RemoteStateClient.States[stateKey]
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
    state._rawData = stateRawData
    state._key = stateKey
    state._keyChangedSignals = {}

    state.Changed = Signal.new()

    return state
end

function ClientState:Get(key)
    return self._rawData[key]
end

function ClientState:GetState()
    return self._rawData
end

function ClientState:GetChangedSignal(key)
    if self._keyChangedSignals[key] then
        return self._keyChangedSignals[key]
    else
        self._keyChangedSignals[key] = Signal.new()
        return self._keyChangedSignals[key]
    end
end

return RemoteStateClient