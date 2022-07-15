"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[294],{45080:e=>{e.exports=JSON.parse('{"functions":[{"name":"Get","desc":"Get value from state.\\n\\n\\n```lua\\nlocal gameStatus = GameState:Get(\\"Status\\")\\nprint(\\"The current game status is \\" .. gameStatus)\\n```","params":[{"name":"key","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"any"}],"function_type":"method","source":{"line":175,"path":"src/RemoteStateClient.lua"}},{"name":"GetState","desc":"Get all values from state.\\n\\n\\n```lua\\nlocal gameData = GameState:GetState()\\nprint(gameData)\\n```","params":[],"returns":[{"desc":"","lua_type":"array"}],"function_type":"method","source":{"line":200,"path":"src/RemoteStateClient.lua"}},{"name":"GetChangedSignal","desc":"Get the changed signal of a value within a state.\\n\\n\\n```lua\\nGameState:GetChangedSignal(\\"Status\\"):Connect(function(status)\\n    print(\\"The game\'s new status is \\" .. status)\\nend)\\n```","params":[{"name":"key","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"Signal"}],"function_type":"method","source":{"line":230,"path":"src/RemoteStateClient.lua"}},{"name":"Destroy","desc":"Disconnects all signals within state.\\n\\n\\n```lua\\nGameState:Destroy()\\n```","params":[],"returns":[],"function_type":"method","source":{"line":249,"path":"src/RemoteStateClient.lua"}}],"properties":[{"name":"Changed","desc":"```lua\\nlocal GameState = RemoteState.GetState(\\"Game\\")\\nGameState.Changed:Connect(function(key, newValue, oldValue)\\n    print(key .. \\" was changed\\")\\n    print(newValue .. \\" is the new value\\")\\n    print(oldValue .. \\" was the old value\\")\\nend)\\n```","lua_type":"Signal","source":{"line":85,"path":"src/RemoteStateClient.lua"}}],"types":[],"name":"ClientState","desc":"ClientState.","source":{"line":70,"path":"src/RemoteStateClient.lua"}}')}}]);