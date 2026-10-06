local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local UIS=game:GetService('UserInputService')
local player=Players.LocalPlayer
local Config=require(RS:WaitForChild('ElectricianShared'):WaitForChild('Config'))
local remote=RS:WaitForChild('ElectricianEvent')
local colors={bg=Color3.fromRGB(13,20,31),panel=Color3.fromRGB(23,34,49),line=Color3.fromRGB(53,70,90),text=Color3.fromRGB(232,239,249),muted=Color3.fromRGB(150,169,192),gold=Color3.fromRGB(255,189,66),green=Color3.fromRGB(62,207,159)}
local gui=Instance.new('ScreenGui'); gui.Name='ElectricianUI'; gui.ResetOnSpawn=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=player:WaitForChild('PlayerGui')
local function frame(parent,x,y,w,h,color)
 local f=Instance.new('Frame'); f.Position=UDim2.fromOffset(x,y); f.Size=UDim2.fromOffset(w,h); f.BackgroundColor3=color or colors.panel; f.BorderSizePixel=0; f.Parent=parent; return f
end
local function round(o,n) local c=Instance.new('UICorner'); c.CornerRadius=UDim.new(0,n or 8); c.Parent=o end
local function label(parent,text,x,y,w,h,size,color)
 local l=Instance.new('TextLabel'); l.Position=UDim2.fromOffset(x,y); l.Size=UDim2.fromOffset(w,h); l.BackgroundTransparency=1
 l.Text=text; l.TextColor3=color or colors.text; l.TextSize=size or 16; l.Font=Enum.Font.Gotham; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextWrapped=true; l.Parent=parent; return l
end
local function button(parent,text,x,y,w,h,callback,color)
 local b=Instance.new('TextButton'); b.Position=UDim2.fromOffset(x,y); b.Size=UDim2.fromOffset(w,h); b.BackgroundColor3=color or colors.line; b.BorderSizePixel=0
 b.Text=text; b.TextColor3=colors.text; b.TextSize=15; b.Font=Enum.Font.GothamBold; b.TextWrapped=true; b.AutoButtonColor=true; b.Parent=parent; round(b,6)
 b.Activated:Connect(callback); return b
end
local function scroll(parent,x,y,w,h)
 local f=Instance.new('ScrollingFrame'); f.Position=UDim2.fromOffset(x,y); f.Size=UDim2.fromOffset(w,h); f.BackgroundTransparency=1; f.BorderSizePixel=0
 f.ScrollBarThickness=5; f.ScrollBarImageColor3=colors.muted; f.CanvasSize=UDim2.fromOffset(0,0); f.Parent=parent; return f
end
local function clear(f) for _,v in ipairs(f:GetChildren()) do v:Destroy() end end
local root=frame(gui,0,0,1200,780,colors.bg); root.AnchorPoint=Vector2.new(.5,.5); root.Position=UDim2.fromScale(.5,.5); root.Visible=false; round(root,14)
local scale=Instance.new('UIScale'); scale.Parent=root
local function resize()
 local camera=workspace.CurrentCamera
 if camera then scale.Scale=math.min((camera.ViewportSize.X-16)/1200,(camera.ViewportSize.Y-60)/780,1.2) end
end
workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
 resize(); if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(resize) end
end)
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(resize) end
resize()
label(root,'ELEKTRYK',22,14,180,30,25,colors.gold)
label(root,'WARSZTAT / 0.1',23,46,190,20,12,colors.muted)
local jobTitle=label(root,'Zlecenie',237,14,600,30,22)
local balance=label(root,'0 monet',940,17,165,28,19,colors.gold)
local status=label(root,'WYŁĄCZONE',238,48,630,22,13,colors.green)
local state=nil
local selectedPart='MAIN'; local selectedColor='brown'; local selectedTerminal=nil; local mode='install'; local tab='wires'
local errors={}; local pendingReset=false; local previousCamera=nil; local savedMovement=nil
local function restoreView()
 local camera=workspace.CurrentCamera
 if previousCamera and camera then camera.CameraType=previousCamera.kind; camera.CFrame=previousCamera.cf; camera.CameraSubject=previousCamera.subject end
 previousCamera=nil
 if savedMovement and savedMovement.humanoid.Parent then
  savedMovement.humanoid.WalkSpeed=savedMovement.speed; savedMovement.humanoid.AutoRotate=savedMovement.rotate
  savedMovement.humanoid.JumpPower=savedMovement.jump; savedMovement.humanoid.JumpHeight=savedMovement.height
 end
 savedMovement=nil
end
local function close()
 root.Visible=false; selectedTerminal=nil; restoreView(); remote:FireServer('close')
end
button(root,'Zamknij',1100,17,80,35,close)
local hud=button(gui,'OTWÓRZ STANOWISKO',16,16,235,45,function() remote:FireServer('open') end)
local hudText=label(gui,'Podejdź do rozdzielnicy i naciśnij E. Na telefonie dotknij przycisku przy stanowisku.',16,67,300,66,15)
local sidebar=frame(root,16,89,205,593,colors.panel); round(sidebar)
label(sidebar,'01 / APARATY',14,12,185,24,14,colors.gold)
local render
local partButtons={}
for i,part in ipairs(Config.PartOrder) do
 partButtons[part]=button(sidebar,Config.Parts[part].name,12,42+(i-1)*43,181,36,function()
  selectedPart=part; mode='install'; selectedTerminal=nil; pendingReset=false; render()
 end)
end
button(sidebar,'Usuń aparat',12,217,181,34,function() mode='remove'; selectedTerminal=nil; render() end)
label(sidebar,'02 / PRZEWODY',14,268,180,23,14,colors.gold)
local colorButtons={}
for i,id in ipairs(Config.ColorOrder) do
 local rgb=Config.Colors[id].rgb
 colorButtons[id]=button(sidebar,Config.Colors[id].name,12,299+(i-1)*39,181,32,function()
  selectedColor=id; mode='wire'; selectedTerminal=nil; render()
 end,Color3.fromRGB(rgb[1],rgb[2],rgb[3]))
 if id=='pe' or id=='gray' then colorButtons[id].TextColor3=colors.bg end
end
local toolHint=label(sidebar,'',13,504,179,78,14,colors.muted)
local board=frame(root,235,89,949,411,Color3.fromRGB(32,43,58)); round(board)
local boardLayer=frame(board,0,0,949,411,Color3.fromRGB(32,43,58)); boardLayer.ClipsDescendants=true; round(boardLayer)
local brief=label(root,'',236,505,945,40,15,colors.muted)
local lower=frame(root,235,550,949,132,colors.panel); round(lower)
local list=scroll(lower,10,35,927,90)
button(lower,'Połączenia',10,5,140,26,function() tab='wires'; render() end)
button(lower,'Wynik testu',157,5,140,26,function() tab='errors'; render() end)
button(lower,'Plan połączeń',304,5,170,26,function() tab='plan'; render() end)
local message=label(root,'',20,695,740,48,16)
button(root,'WYCZYŚĆ',20,748,120,25,function()
 if not pendingReset then pendingReset=true; message.Text='Usunąć aparaty i przewody? Kliknij WYCZYŚĆ ponownie.'; return end
 pendingReset=false; selectedTerminal=nil; remote:FireServer('reset')
end)
label(root,'Uproszczona łamigłówka • postęp tylko w tej sesji',152,749,560,22,12,colors.muted)
button(root,'WYŁĄCZ',771,699,122,43,function() remote:FireServer('powerOff') end)
button(root,'TEST',903,699,120,43,function() tab='errors'; remote:FireServer('test') end,Color3.fromRGB(28,127,101))
local nextButton=button(root,'NASTĘPNE',1033,699,150,43,function() selectedTerminal=nil; pendingReset=false; remote:FireServer('next') end,Color3.fromRGB(153,101,28))
local function drawSegment(parent,x1,y1,x2,y2,color,width,z)
 local dx,dy=x2-x1,y2-y1; local length=math.sqrt(dx*dx+dy*dy)
 if length<.1 then return end
 local f=frame(parent,(x1+x2)/2,(y1+y2)/2,length,width,color); f.AnchorPoint=Vector2.new(.5,.5); f.Rotation=math.deg(math.atan2(dy,dx)); f.ZIndex=z or 4; round(f,2)
end
render=function()
 if not state then return end
 local job=Config.Jobs[state.job]
 jobTitle.Text=string.format('%02d / %s',state.job,job.name)
 balance.Text=state.coins..' monet'
 status.Text=state.passed and 'ZALICZONE / WYNAGRODZENIE ODEBRANE' or (state.powered and 'TEST / ZASILANIE WŁĄCZONE' or 'ZASILANIE WYŁĄCZONE / MONTAŻ')
 brief.Text=job.brief
 nextButton.Text=state.job==#Config.Jobs and (state.passed and 'UKOŃCZONO!' or 'OSTATNIE') or 'NASTĘPNE'
 for part,b in pairs(partButtons) do b.BackgroundColor3=(mode=='install' and part==selectedPart) and Color3.fromRGB(143,96,30) or colors.line end
 for id,b in pairs(colorButtons) do b.Text=(mode=='wire' and id==selectedColor and '● ' or '')..Config.Colors[id].name end
 toolHint.Text=mode=='remove' and 'Kliknij obudowę aparatu, aby usunąć go wraz z przewodami.' or (mode=='wire' and (selectedTerminal and ('Wybrano '..Config.endpointName(selectedTerminal)..'. Kliknij drugi zacisk.') or 'Kliknij pierwszy zacisk, następnie drugi. Kolor zmieniasz powyżej.') or 'Kliknij wolne pole na szynie. RCD zajmuje dwa pola.')
 clear(boardLayer)
 label(boardLayer,'ZASILANIE',20,5,200,20,11,colors.muted)
 label(boardLayer,'LISTWY',728,5,200,20,11,colors.muted)
 local rail=frame(boardLayer,26,174,890,15,Color3.fromRGB(135,150,167)); rail.ZIndex=1
 local positions={}
 local function terminal(id,x,y,text)
  positions[id]={x=x,y=y}
  local b=button(boardLayer,text or id,x-20,y-14,40,28,function()
   if state.passed then message.Text='Zlecenie ukończone. Wybierz następne.'; return end
   mode='wire'
   if selectedTerminal==id then selectedTerminal=nil
   elseif not selectedTerminal then selectedTerminal=id
   else local a=selectedTerminal; selectedTerminal=nil; remote:FireServer('wire',{a=a,b=id,color=selectedColor}) end
   render()
  end,selectedTerminal==id and Color3.fromRGB(157,109,31) or Color3.fromRGB(16,25,39))
  b.TextSize=12; b.ZIndex=7
 end
 terminal('SUP.L',54,45,'L'); terminal('SUP.N',108,45,'N'); terminal('SUP.PE',162,45,'PE')
 terminal('BUS.N',775,45,'N'); terminal('BUS.PE',849,45,'PE')
 local occupied={}
 for slot,part in pairs(state.modules) do for n=slot,slot+Config.Parts[part].width-1 do occupied[n]=slot end end
 for slot=1,12 do
  local x=30+(slot-1)*74
  label(boardLayer,tostring(slot),x,78,68,20,12,colors.muted)
  if not occupied[slot] then
   local b=button(boardLayer,'+',x,112,65,126,function()
    if mode=='install' then remote:FireServer('install',{slot=slot,part=selectedPart}) else message.Text='Najpierw wybierz aparat z lewej strony.' end
   end,Color3.fromRGB(42,55,73)); b.ZIndex=2
  elseif occupied[slot]==slot then
   local part=state.modules[slot]; local spec=Config.Parts[part]; local w=spec.width*74-9
   local b=button(boardLayer,'',x,105,w,139,function()
    if mode=='remove' then selectedTerminal=nil; remote:FireServer('remove',{slot=slot}) else message.Text='Wybierz kolor i kliknij zaciski aparatu.' end
   end,Color3.fromRGB(211,220,232)); b.ZIndex=2
   local tag=label(boardLayer,spec.label,x+5,145,w-10,26,15,colors.bg); tag.ZIndex=3; tag.TextXAlignment=Enum.TextXAlignment.Center
   local toggle=frame(boardLayer,x+w/2-10,182,20,22,state.powered and colors.green or colors.line); toggle.ZIndex=3; round(toggle,3)
   if part=='RCD' then
    terminal('S'..slot..'.L1',x+30,122,'L1'); terminal('S'..slot..'.N1',x+w-30,122,'N1')
    terminal('S'..slot..'.L2',x+30,229,'L2'); terminal('S'..slot..'.N2',x+w-30,229,'N2')
   else terminal('S'..slot..'.L1',x+w/2,122,'L1'); terminal('S'..slot..'.L2',x+w/2,229,'L2') end
  end
 end
 for i,load in ipairs(job.loads) do
  local x=180+(i-1)*380
  label(boardLayer,load=='LIGHT' and 'OBWÓD LAMPY' or 'OBWÓD GNIAZDA',x-45,349,270,24,12,state.powered and colors.green or colors.muted)
  terminal(load..'.L',x,390,'L'); terminal(load..'.N',x+60,390,'N'); terminal(load..'.PE',x+120,390,'PE')
 end
 for i,w in ipairs(state.wires) do
  local a,b=positions[w.a],positions[w.b]
  if a and b then
   local rgb=Config.Colors[w.color].rgb; local color=Color3.fromRGB(rgb[1],rgb[2],rgb[3]); local route=265+(i%6)*12
   drawSegment(boardLayer,a.x,a.y,a.x,route,color,4)
   drawSegment(boardLayer,a.x,route,b.x,route,color,4)
   drawSegment(boardLayer,b.x,route,b.x,b.y,color,4)
   if w.color=='pe' then
    drawSegment(boardLayer,a.x,a.y,a.x,route,Color3.fromRGB(30,155,75),1,5)
    drawSegment(boardLayer,a.x,route,b.x,route,Color3.fromRGB(30,155,75),1,5)
    drawSegment(boardLayer,b.x,route,b.x,b.y,Color3.fromRGB(30,155,75),1,5)
   end
  end
 end
 clear(list)
 local rows={}
 if tab=='wires' then
  for i,w in ipairs(state.wires) do
   rows[#rows+1]=i..'. '..Config.endpointName(w.a)..' → '..Config.endpointName(w.b)..' / '..Config.Colors[w.color].name
  end
  if #rows==0 then rows[1]='Wybierz kolor przewodu i połącz dwa zaciski. Plan połączeń jest dostępny powyżej.' end
 elseif tab=='errors' then
  if state.passed then rows={'Test zaliczony. Zlecenie odebrane. Nagroda: '..job.reward..' monet.'}
  elseif #errors==0 then rows={'Naciśnij TEST, aby sprawdzić aparaty, połączenia i kolory przewodów.'}
  else rows=errors end
 else
  for _,e in ipairs(Config.expected(job)) do rows[#rows+1]=Config.endpointName(e[1])..' → '..Config.endpointName(e[2])..' / '..e[3] end
 end
 for i,text in ipairs(rows) do
  label(list,text,4,(i-1)*32,800,30,14,tab=='errors' and not state.passed and colors.gold or colors.text)
  if tab=='wires' and state.wires[i] and not state.passed then
   button(list,'Usuń',820,(i-1)*32+2,80,27,function() remote:FireServer('unwire',{index=i}) end)
  end
 end
 list.CanvasSize=UDim2.fromOffset(0,#rows*32)
end
local function openView()
 if root.Visible then return end
 root.Visible=true; hud.Visible=false; hudText.Visible=false
 local camera=workspace.CurrentCamera
 local world=workspace:FindFirstChild('ElectricianWorkshop'); local cabinet=world and world:FindFirstChild('Cabinet')
 if camera and cabinet then
  previousCamera={kind=camera.CameraType,cf=camera.CFrame,subject=camera.CameraSubject}
  camera.CameraType=Enum.CameraType.Scriptable
  camera.CFrame=CFrame.lookAt(cabinet.Position+Vector3.new(0,1,-9),cabinet.Position)
 end
 local humanoid=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
 if humanoid then
  savedMovement={humanoid=humanoid,speed=humanoid.WalkSpeed,rotate=humanoid.AutoRotate,jump=humanoid.JumpPower,height=humanoid.JumpHeight}
  humanoid.WalkSpeed=0; humanoid.AutoRotate=false; humanoid.JumpPower=0; humanoid.JumpHeight=0
 end
end
root:GetPropertyChangedSignal('Visible'):Connect(function() hud.Visible=not root.Visible; hudText.Visible=not root.Visible end)
remote.OnClientEvent:Connect(function(payload)
 if type(payload)~='table' then return end
 if payload.close then close() end
 if payload.state then
  state=payload.state
  local modules={}; for slot,part in pairs(state.modules) do modules[tonumber(slot)]=part end; state.modules=modules
  errors=payload.errors or {}; pendingReset=false
  if payload.open then openView() end
  render()
 end
 if payload.message then message.Text=payload.message; hudText.Text=payload.message end
end)
UIS.InputBegan:Connect(function(input,processed)
 if processed then return end
 if input.KeyCode==Enum.KeyCode.Q and root.Visible then close() end
end)
player.CharacterRemoving:Connect(function() close() end)
