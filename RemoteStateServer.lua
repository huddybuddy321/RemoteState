local Signal = require(script:FindFirstAncestor("RemoteState").Signal)

local RemoteStateServer = {
    States = {}
}

RemoteStateServer._getRemote = Instance.new("RemoteFunction")
RemoteStateServer._getRemote.Name = "GetState"
RemoteStateServer._getRemote.Parent = script:FindFirstAncestor("RemoteState")

RemoteStateServer._stateChangedRemote = Instance.new("RemoteEvent")
RemoteStateServer._stateChangedRemote.Name = "StateChanged"
RemoteStateServer._stateChangedRemote.Parent = script:FindFirstAncestor("RemoteState")


RemoteStateServer._getRemote.OnServerInvoke = function(player, stateKey)
    return RemoteStateServer.States[stateKey]._rawData
end

local ServerState = {}
ServerState.__index = ServerState

function RemoteStateServer.new(stateKey, stateRawData)
    local serverState = setmetatable({}, ServerState)
    serverState._key = stateKey
    serverState._rawData = stateRawData

    serverState.Changed = Signal.new()

    RemoteStateServer.States[stateKey] = serverState

    return serverState
end

function ServerState:Set(key, newValue)
    self._rawData[key] = newValue
    self.Changed:Fire(key, newValue)
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

function ServerState:Get(key)
    return self._rawData[key]
end

function ServerState:GetState()
    return self._rawData
end

return RemoteStateServer