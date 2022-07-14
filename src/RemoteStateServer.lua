local RunService = game:GetService("RunService")

local Signal = require(script:FindFirstAncestor("RemoteState").Signal)
local Promise = require(script:FindFirstAncestor("RemoteState").Promise)

local RemoteStateServer = {
    States = {}
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

RemoteStateServer._getRemote.OnServerInvoke = function(player, stateKey)
    return RemoteStateServer.States[stateKey]._rawData
end

local ServerState = {}
ServerState.__index = ServerState

function RemoteStateServer.new(stateKey, stateRawData)
    assert(not RemoteStateServer.States[stateKey], "Trying to create a new state with a used key")

    local serverState = setmetatable({}, ServerState)
    serverState._key = stateKey
    serverState._rawData = stateRawData
    serverState._keyChangedSignals = {}

    serverState.Changed = Signal.new()

    RemoteStateServer.States[stateKey] = serverState

    RemoteStateServer._stateCreatedRemote:FireAllClients(stateKey, serverState._rawData)

    return serverState
end

function RemoteStateServer.WaitForState(stateKey)
    return Promise.new(function(resolve)
        local heartbeatConnection
        heartbeatConnection = RunService.Heartbeat:Connect(function()
            if RemoteStateServer.States[stateKey] then
                heartbeatConnection:Disconnect()
                return RemoteStateServer.States[stateKey]
            end
        end)
    end)
end

function ServerState:Set(key, newValue)
    self._rawData[key] = newValue
    self.Changed:Fire(key, newValue)

    if self._keyChangedSignals[key] then
        self._keyChangedSignals[key]:Fire(newValue)
    end

    RemoteStateServer._stateChangedRemote:FireAllClients(self._key, key, newValue)
end

function ServerState:SetState(newData)
    for key, value in pairs(newData) do
        self:Set(key, value)
    end
end

function ServerState:Increment(key, increment)
    self:Set(key, self:Get(key) + increment)
end

function ServerState:Decrement(key, decrement)
    self:Set(key, self:Get(key) - decrement)
end

function ServerState:Get(key)
    return self._rawData[key]
end

function ServerState:GetState()
    return self._rawData
end

function ServerState:GetChangedSignal(key)
    if self._keyChangedSignals[key] then
        return self._keyChangedSignals[key]
    else
        self._keyChangedSignals[key] = Signal.new()
        return self._keyChangedSignals[key]
    end
end

return RemoteStateServer