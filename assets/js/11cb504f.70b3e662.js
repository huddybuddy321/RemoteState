"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[625],{28778:e=>{e.exports=JSON.parse('{"functions":[{"name":"Set","desc":"Set value in state.\\n\\n\\n```lua\\nGameState:Set(\\"Status\\", \\"InGame\\")\\n```","params":[{"name":"key","desc":"","lua_type":"any"},{"name":"value","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"any"}],"function_type":"method","source":{"line":143,"path":"src/RemoteStateServer.lua"}},{"name":"SetState","desc":"Set multiple values in state.\\n\\n\\n```lua\\nGameState:SetState({\\n    Status = \\"InGame\\",\\n    Gamemode = \\"Swordfight\\"\\n})\\n```","params":[{"name":"newData","desc":"","lua_type":"array"}],"returns":[],"function_type":"method","source":{"line":175,"path":"src/RemoteStateServer.lua"}},{"name":"Increment","desc":"Increment a value in state.\\n\\n\\n```lua\\nlocal pointsAvailable = GameState:Increment(\\"PointsAvailable\\", 69)\\n```","params":[{"name":"key","desc":"","lua_type":"any"},{"name":"increment","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number"}],"function_type":"method","source":{"line":208,"path":"src/RemoteStateServer.lua"}},{"name":"Decrement","desc":"Decrement a value in state.\\n\\n\\n```lua\\nlocal pointsAvailable = GameState:Decrement(\\"PointsAvailable\\", 69)\\n```","params":[{"name":"key","desc":"","lua_type":"any"},{"name":"decrement","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number"}],"function_type":"method","source":{"line":227,"path":"src/RemoteStateServer.lua"}},{"name":"Toggle","desc":"Toggle a value in state.\\n\\n\\n```lua\\nlocal isPlaying = GameState:Toggle(\\"Playing\\")\\n```","params":[{"name":"key","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"method","source":{"line":245,"path":"src/RemoteStateServer.lua"}},{"name":"Get","desc":"Get value from state.\\n\\n\\n```lua\\nlocal gameStatus = GameState:Get(\\"Status\\")\\nprint(\\"The current game status is \\" .. gameStatus)\\n```","params":[{"name":"key","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"any"}],"function_type":"method","source":{"line":266,"path":"src/RemoteStateServer.lua"}},{"name":"GetState","desc":"Get all values from state.\\n\\n\\n```lua\\nlocal gameData = GameState:GetState()\\nprint(gameData)\\n```","params":[],"returns":[{"desc":"","lua_type":"array"}],"function_type":"method","source":{"line":291,"path":"src/RemoteStateServer.lua"}},{"name":"GetChangedSignal","desc":"Get the changed signal of a value within a state.\\n\\n\\n```lua\\nGameState:GetChangedSignal(\\"Status\\"):Connect(function(status)\\n    print(\\"The game\'s new status is \\" .. status)\\nend)\\n```","params":[{"name":"key","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"Signal"}],"function_type":"method","source":{"line":321,"path":"src/RemoteStateServer.lua"}},{"name":"Reset","desc":"Reset the state to its initial data.\\n\\n\\n```lua\\nwait(30)\\nprint(\\"Game over!\\")\\nGameState:Reset()\\n```","params":[],"returns":[],"function_type":"method","source":{"line":342,"path":"src/RemoteStateServer.lua"}},{"name":"Destroy","desc":"Disconnects all connections to signals within state.\\n\\n\\n```lua\\nGameState:Destroy()\\n```","params":[],"returns":[],"function_type":"method","source":{"line":377,"path":"src/RemoteStateServer.lua"}}],"properties":[],"types":[],"name":"ServerState","desc":"ServerState.","source":{"line":38,"path":"src/RemoteStateServer.lua"}}')}}]);