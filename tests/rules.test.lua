local C=dofile('src/shared/Config.lua')
local R=dofile('src/shared/Rules.lua')
local assertions=0
local function check(condition,message) assertions=assertions+1; assert(condition,message) end
local function apply(s,a,d) return R.apply(s,C,a,d) end
local function solve(s)
 for slot,part in pairs(C.Jobs[s.job].slots) do check(apply(s,'install',{slot=slot,part=part}),'install') end
 for _,e in ipairs(C.expected(C.Jobs[s.job])) do
  check(apply(s,'wire',{a=e[1],b=e[2],color=({L='brown',N='blue',PE='pe'})[e[3]]}),'wire')
 end
end
local s=R.new()
check(not apply(s,'test'),'empty panel cannot pass')
check(s.coins==0 and not s.powered,'failed test does not reward or energize')
check(not apply(s,'next'),'cannot skip job')
check(not apply(s,'install',{slot=0,part='MAIN'}),'bad slot')
check(not apply(s,'install',{slot=0/0,part='MAIN'}),'NaN slot')
check(not apply(s,'install',{slot=1.5,part='MAIN'}),'fractional slot')
check(not apply(s,'install',{slot=12,part='RCD'}),'RCD outside rail')
check(not apply(s,'install',{slot=1,part='UNKNOWN'}),'unknown part')
check(apply(s,'install',{slot=2,part='RCD'}),'RCD install')
check(not apply(s,'install',{slot=3,part='B10'}),'overlap second RCD slot')
check(not apply(s,'wire',{a='SUP.L',b='S99.L1',color='brown'}),'unknown terminal')
check(not apply(s,'wire',{a='SUP.L',b='SUP.L',color='brown'}),'same terminal')
check(not apply(s,'wire',{a='SUP.L',b='S2.L1',color='bogus'}),'unknown color')
check(apply(s,'wire',{a='SUP.L',b='S2.L1',color='brown'}),'wire')
check(not apply(s,'wire',{a='S2.L1',b='SUP.L',color='black'}),'reverse duplicate')
check(apply(s,'remove',{slot=2}),'remove')
check(#s.wires==0,'removal cleans incident wires')
check(not apply(s,'unwire',{index=math.huge}),'invalid wire index')
for job=1,3 do
 solve(s)
 if job==1 then
  s.wires[1].color='blue'; check(not apply(s,'test'),'phase wrong color'); check(s.coins==0,'no reward on bad color'); s.wires[1].color='gray'
  check(apply(s,'wire',{a='SUP.L',b='BUS.PE',color='brown'}),'allow erroneous link for puzzle')
  check(not apply(s,'test'),'extra unsafe connection detected'); check(not s.powered,'failed test remains off')
  check(apply(s,'unwire',{index=#s.wires}),'remove extra')
 end
 check(apply(s,'test'),'correct job passes')
 local coins=s.coins
 check(not apply(s,'test'),'repeat test blocked')
 check(s.coins==coins,'no double reward')
 check(not apply(s,'reset'),'cannot reset claimed job')
 check(not apply(s,'remove',{slot=1}),'completed board locked')
 if job<3 then check(apply(s,'next'),'advance'); check(#s.wires==0 and next(s.modules)==nil,'next clears board') end
end
check(s.coins==720 and s.completed==3,'total rewards')
check(not apply(s,'next'),'final job bounded')
local other=R.new(); check(other.coins==0 and other.job==1,'separate sessions')
local malformed={{},123,false,'garbage'}
for _,data in ipairs(malformed) do check(not apply(other,'install',data),'malformed payload') end
local locked=R.new(); locked.powered=true
check(not apply(locked,'install',{slot=1,part='MAIN'}),'energized edit blocked')
check(apply(locked,'powerOff'),'power off')
check(apply(locked,'install',{slot=1,part='MAIN'}),'deenergized edit accepted')
for _,path in ipairs({'src/shared/Config.lua','src/shared/Rules.lua','src/server/World.lua','src/server/Main.server.lua','src/client/Main.client.lua'}) do
 check(loadfile(path)~=nil,'Lua syntax: '..path)
end
print('PASS: '..assertions..' assertions; all 3 jobs, invalid inputs, wiring, locks and rewards.')
