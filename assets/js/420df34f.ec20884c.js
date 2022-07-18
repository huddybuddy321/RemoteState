"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[944],{84469:e=>{e.exports=JSON.parse('{"functions":[{"name":"new","desc":"Creates a new state.\\n\\n```lua\\nlocal GameState = RemoteState.new(\\"Game\\", {\\n    Status = \\"Lobby\\"\\n})\\n```","params":[{"name":"stateKey","desc":"","lua_type":"any"},{"name":"stateRawData","desc":"","lua_type":"table"}],"returns":[{"desc":"","lua_type":"ClientState"}],"function_type":"static","source":{"line":99,"path":"src/RemoteStateServer.lua"}},{"name":"GetState","desc":"Get state.\\n\\n```lua\\nlocal GameState = RemoteState.GetState(\\"Game\\")\\n```","params":[{"name":"stateKey","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"ClientState"}],"function_type":"static","source":{"line":131,"path":"src/RemoteStateServer.lua"}},{"name":"WaitForState","desc":"Wait for state.\\n\\n```lua\\nRemoteState.WaitForState(\\"Game\\"):andThen(function(state)\\n    print(state:Get(\\"Status\\"))\\nend)\\n```","params":[{"name":"stateKey","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"Promise"}],"function_type":"static","source":{"line":149,"path":"src/RemoteStateServer.lua"}}],"properties":[{"name":"None","desc":"```lua\\nGameState:Set(\\"Map\\", RemoteState.None)\\n```","lua_type":"None","source":{"line":21,"path":"src/RemoteStateServer.lua"}}],"types":[],"name":"RemoteStateServer","desc":"RemoteState server version.","source":{"line":11,"path":"src/RemoteStateServer.lua"}}')}}]);