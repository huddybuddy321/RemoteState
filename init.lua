local RunService = game:GetService("RunService")

local RemoteStateServer = script.RemoteStateServer
local RemoteStateClient = script.RemoteStateClient

if RunService:IsServer() then
    return require(RemoteStateServer)
elseif RunService:IsClient() then
    return require(RemoteStateClient)
end