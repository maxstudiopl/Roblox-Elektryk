local Players=game:GetService('Players')
local ReplicatedStorage=game:GetService('ReplicatedStorage')
local shared=ReplicatedStorage:WaitForChild('ElectricianShared')
local Config=require(shared:WaitForChild('Config'))
local Rules=require(shared:WaitForChild('Rules'))
local cabinet,prompt=require(script.Parent:WaitForChild('World')).build(Config.InteractionDistance)
local remote=Instance.new('RemoteEvent'); remote.Name='ElectricianEvent'; remote.Parent=ReplicatedStorage
local sessions={}
local function setup(player)
 if sessions[player] then return end
 sessions[player]={state=Rules.new(),opened=false,tokens=20,updated=os.clock()}
 local stats=Instance.new('Folder'); stats.Name='leaderstats'; stats.Parent=player
 local coins=Instance.new('IntValue'); coins.Name='Monety'; coins.Parent=stats
 local jobs=Instance.new('IntValue'); jobs.Name='Zlecenia'; jobs.Parent=stats
end
local function nearby(player)
 local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
 return root and (root.Position-cabinet.Position).Magnitude<=Config.InteractionDistance
end
local function send(player,message,errors,open)
 local s=sessions[player]; if not s then return end
 -- String slot keys prevent sparse numeric tables changing shape on the wire.
 local modules={}; for slot,part in pairs(s.state.modules) do modules[tostring(slot)]=part end
 remote:FireClient(player,{state={job=s.state.job,coins=s.state.coins,completed=s.state.completed,modules=modules,wires=s.state.wires,powered=s.state.powered,passed=s.state.passed},message=message,errors=errors or {},open=open})
 local stats=player:FindFirstChild('leaderstats')
 if stats then stats.Monety.Value=s.state.coins; stats.Zlecenia.Value=s.state.completed end
end
Players.PlayerAdded:Connect(setup)
for _,player in ipairs(Players:GetPlayers()) do setup(player) end
Players.PlayerRemoving:Connect(function(player) sessions[player]=nil end)
prompt.Triggered:Connect(function(player)
 setup(player)
 if not nearby(player) then return end
 sessions[player].opened=true; send(player,'Wybierz aparat, a potem wolne pole na szynie.',nil,true)
end)
remote.OnServerEvent:Connect(function(player,action,data)
 local s=sessions[player]
 if not s or type(action)~='string' or #action>20 then return end
 local now=os.clock(); s.tokens=math.min(20,s.tokens+(now-s.updated)*10); s.updated=now
 if s.tokens<1 then return end; s.tokens=s.tokens-1
 if action=='ready' then send(player,'Połączono ze stanowiskiem. Podejdź do stołu i naciśnij E.'); return end
 if action=='close' then s.opened=false; return end
 if action=='open' then
  if nearby(player) then s.opened=true; send(player,'Stanowisko gotowe.',nil,true)
  else remote:FireClient(player,{message='Podejdź do stołu z rozdzielnicą.'}) end
  return
 end
 if not s.opened or not nearby(player) then
  s.opened=false; remote:FireClient(player,{close=true,message='Podejdź ponownie do stanowiska.'}); return
 end
 local _,message,errors=Rules.apply(s.state,Config,action,data)
 send(player,message,errors)
end)
