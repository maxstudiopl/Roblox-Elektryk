-- Pure Lua rules: authoritative on the server; exercised outside Studio too.
local Rules = {}
function Rules.new()
 return {job=1, coins=0, completed=0, modules={}, wires={}, powered=false, passed=false}
end
local function key(a,b) if a>b then a,b=b,a end return a..'|'..b end
Rules.key=key
function Rules.terminals(state, config)
 local t={['SUP.L']=true,['SUP.N']=true,['SUP.PE']=true,['BUS.N']=true,['BUS.PE']=true}
 for slot,part in pairs(state.modules) do
  for _,pin in ipairs(config.Parts[part].terminals) do t['S'..slot..'.'..pin]=true end
 end
 for _,load in ipairs(config.Jobs[state.job].loads) do
  for _,pin in ipairs({'L','N','PE'}) do t[load..'.'..pin]=true end
 end
 return t
end
function Rules.evaluate(state,config)
 local job=config.Jobs[state.job]
 local errors={}
 for slot,part in pairs(job.slots) do
  if state.modules[slot]~=part then errors[#errors+1]='Pole '..slot..': wymagany '..config.Parts[part].name end
 end
 for slot in pairs(state.modules) do
  if not job.slots[slot] then errors[#errors+1]='Usuń dodatkowy aparat z pola '..slot end
 end
 local expected={}
 for _,e in ipairs(config.expected(job)) do expected[key(e[1],e[2])]=e end
 local found={}
 for _,w in ipairs(state.wires) do
  local k=key(w.a,w.b)
  local e=expected[k]
  if not e then errors[#errors+1]='Nieprawidłowe połączenie: '..config.endpointName(w.a)..' → '..config.endpointName(w.b)
  elseif config.Colors[w.color].kind~=e[3] then errors[#errors+1]='Zły kolor: '..config.endpointName(w.a)..' → '..config.endpointName(w.b)
  else found[k]=true end
 end
 for _,e in ipairs(config.expected(job)) do
  if not found[key(e[1],e[2])] then errors[#errors+1]='Brak: '..config.endpointName(e[1])..' → '..config.endpointName(e[2])..' ['..e[3]..']' end
 end
 return #errors==0,errors
end
function Rules.apply(state,config,action,data)
 data=type(data)=='table' and data or {}
 if action=='powerOff' then state.powered=false; return true,'Zasilanie wyłączone. Możesz pracować.' end
 if action=='next' then
  if not state.passed then return false,'Najpierw zalicz bieżące zlecenie.' end
  if state.job>=#config.Jobs then return false,'Wszystkie zlecenia wersji 0.1 ukończone!' end
  state.job=state.job+1; state.modules={}; state.wires={}; state.powered=false; state.passed=false
  return true,'Nowe zlecenie przyjęte.'
 end
 if action=='test' then
  if state.passed then return false,'Zapłata za to zlecenie została już przyznana.' end
  local ok,errors=Rules.evaluate(state,config)
  state.powered=ok
  if ok then
   state.passed=true; state.completed=state.completed+1; state.coins=state.coins+config.Jobs[state.job].reward
   return true,'Test zaliczony! +'..config.Jobs[state.job].reward..' monet.'
  end
  return false,'Test niezaliczony. Zasilanie pozostało wyłączone.',errors
 end
 if state.passed then return false,'Zlecenie odebrane. Wybierz następne.' end
 if state.powered then return false,'Najpierw wyłącz zasilanie.' end
 if action=='install' then
  local slot,part=data.slot,data.part
  if type(slot)~='number' or slot~=slot or slot%1~=0 or slot<1 or slot>12 or type(part)~='string' or not config.Parts[part] then return false,'Nieprawidłowy aparat lub pole.' end
  local width=config.Parts[part].width
  if slot+width-1>12 then return false,'Za mało miejsca na szynie.' end
  for s,p in pairs(state.modules) do
   if slot<=s+config.Parts[p].width-1 and s<=slot+width-1 then return false,'To miejsce jest zajęte.' end
  end
  state.modules[slot]=part
  return true,'Zamontowano: '..config.Parts[part].name
 elseif action=='remove' then
  local slot=data.slot
  if type(slot)~='number' or not state.modules[slot] then return false,'Wybierz zamontowany aparat.' end
  state.modules[slot]=nil
  local prefix='S'..slot..'.'
  for i=#state.wires,1,-1 do
   local w=state.wires[i]
   if w.a:sub(1,#prefix)==prefix or w.b:sub(1,#prefix)==prefix then table.remove(state.wires,i) end
  end
  return true,'Aparat i podłączone przewody usunięte.'
 elseif action=='wire' then
  local a,b,color=data.a,data.b,data.color
  if type(a)~='string' or type(b)~='string' or #a>24 or #b>24 or type(color)~='string' or not config.Colors[color] then return false,'Nieprawidłowy przewód.' end
  local terminals=Rules.terminals(state,config)
  if a==b or not terminals[a] or not terminals[b] then return false,'Wybierz dwa istniejące, różne zaciski.' end
  if #state.wires>=32 then return false,'Limit 32 przewodów. Usuń zbędne połączenia.' end
  for _,w in ipairs(state.wires) do if key(w.a,w.b)==key(a,b) then return false,'Te zaciski są już połączone.' end end
  state.wires[#state.wires+1]={a=a,b=b,color=color}
  return true,'Przewód podłączony.'
 elseif action=='unwire' then
  local index=data.index
  if type(index)~='number' or index%1~=0 or not state.wires[index] then return false,'Nie ma takiego przewodu.' end
  table.remove(state.wires,index); return true,'Przewód usunięty.'
 elseif action=='reset' then
  state.modules={}; state.wires={}; return true,'Rozdzielnica wyczyszczona.'
 end
 return false,'Nieznana czynność.'
end
return Rules
