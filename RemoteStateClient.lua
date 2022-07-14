local Signal = require(script:FindFirstAncestor("RemoteState").Signal)

local GetStateRemote = script:FindFirstAncestor("RemoteState"):WaitForChild("GetState")
local StateChangedRemote = script:FindFirstAncestor("RemoteState"):WaitForChild("StateChanged")

local RemoteStateClient = {
    States = {}
}

StateChangedRemote.OnClientEvent:Connect(function(stateKey, key, newValue)
    local state = RemoteStateClient.States[stateKey]
    if state then
        state._rawData[key] = newValue
        state.Changed:Fire(key, newValue)
    end
end)

local ClientState = {}
ClientState.__index = ClientState

function ClientState.new(stateKey, stateRawData)
    local state = setmetatable({}, ClientState)
    state._rawData = stateRawData
    state._key = stateKey

    state.Changed = Signal.new()

    return state
end

function ClientState:Get(key)
    return self._rawData[key]
end

function ClientState:GetState()
    return self._rawData
end

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

return RemoteStateClient