local World={}
function World.build()
 local world=Instance.new('Model'); world.Name='ElectricianWorkshop'; world.Parent=workspace
 local function part(name,size,pos,color,material)
  local p=Instance.new('Part'); p.Name=name; p.Size=size; p.Position=pos; p.Anchored=true
  p.Color=Color3.fromRGB(color[1],color[2],color[3]); p.Material=material or Enum.Material.SmoothPlastic
  p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=world; return p
 end
 local function sign(parent,text)
  local gui=Instance.new('SurfaceGui'); gui.Face=Enum.NormalId.Front; gui.CanvasSize=Vector2.new(1000,250); gui.Parent=parent
  local label=Instance.new('TextLabel'); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1
  label.Text=text; label.TextColor3=Color3.fromRGB(239,246,255); label.TextScaled=true; label.Font=Enum.Font.GothamBold; label.Parent=gui
 end
 part('Floor',Vector3.new(48,1,40),Vector3.new(0,-.5,0),{48,56,67},Enum.Material.Concrete)
 part('BackWall',Vector3.new(48,16,1),Vector3.new(0,8,14),{27,35,48})
 part('LeftWall',Vector3.new(1,16,40),Vector3.new(-24,8,0),{34,43,58})
 part('RightWall',Vector3.new(1,16,40),Vector3.new(24,8,0),{34,43,58})
 local banner=part('WorkshopSign',Vector3.new(20,3,.3),Vector3.new(0,11,13.3),{19,26,38})
 sign(banner,'ELEKTRYK / WARSZTAT 01')
 part('Accent',Vector3.new(20,.12,.4),Vector3.new(0,9.25,13.1),{246,182,54},Enum.Material.Neon)
 part('BenchTop',Vector3.new(12,.5,4),Vector3.new(0,3.4,8),{158,112,69},Enum.Material.Wood)
 for _,x in ipairs({-5,5}) do
  for _,z in ipairs({6.6,9.4}) do part('BenchLeg',Vector3.new(.4,3.2,.4),Vector3.new(x,1.6,z),{48,55,69},Enum.Material.Metal) end
 end
 local cabinet=part('Cabinet',Vector3.new(6,4,.7),Vector3.new(0,5.5,9),{226,232,239},Enum.Material.Metal)
 part('CabinetInterior',Vector3.new(5.5,3.5,.12),Vector3.new(0,5.5,8.57),{37,46,61})
 part('DINRail',Vector3.new(5,.15,.2),Vector3.new(0,5.5,8.4),{153,166,183},Enum.Material.Metal)
 for i=1,12 do
  local p=part('ModulePreview',Vector3.new(.34,1.2,.35),Vector3.new(-2.2+(i-1)*.4,5.5,8.2),{222,229,239})
  part('SwitchPreview',Vector3.new(.2,.32,.12),p.Position+Vector3.new(0,0,-.24),{34,45,63})
 end
 local prompt=Instance.new('ProximityPrompt'); prompt.Name='OpenBench'; prompt.ActionText='Buduj rozdzielnicę'
 prompt.ObjectText='Stanowisko elektryka'; prompt.HoldDuration=0; prompt.MaxActivationDistance=12; prompt.RequiresLineOfSight=false; prompt.Parent=cabinet
 for _,x in ipairs({-16,16}) do
  for _,y in ipairs({2,5,8}) do
   part('Shelf',Vector3.new(7,.3,3),Vector3.new(x,y,11),{85,98,117},Enum.Material.Metal)
   for i=1,3 do
    local box=part('PartsBox',Vector3.new(1.7,1.2,1.6),Vector3.new(x-2.5+i*1.3,y+.75,11),{175,130,71})
    sign(box,({'B10','B16','RCD'})[i])
   end
  end
 end
 for _,x in ipairs({-12,0,12}) do
  local light=part('WorkLight',Vector3.new(6,.2,1),Vector3.new(x,13,5),{238,246,255},Enum.Material.Neon)
  local point=Instance.new('PointLight'); point.Brightness=1.5; point.Range=30; point.Parent=light
 end
 local spawn=Instance.new('SpawnLocation'); spawn.Name='WorkshopSpawn'; spawn.Size=Vector3.new(6,.2,6); spawn.Position=Vector3.new(0,.1,-7)
 spawn.CFrame=CFrame.new(0,.1,-7)*CFrame.Angles(0,math.pi,0)
 spawn.Anchored=true; spawn.Neutral=true; spawn.Duration=0; spawn.Material=Enum.Material.Neon; spawn.Color=Color3.fromRGB(51,170,179); spawn.Parent=world
 local lighting=game:GetService('Lighting'); lighting.ClockTime=14; lighting.Brightness=2; lighting.Ambient=Color3.fromRGB(130,140,160)
 workspace.FallenPartsDestroyHeight=-50
 return cabinet,prompt
end
return World
