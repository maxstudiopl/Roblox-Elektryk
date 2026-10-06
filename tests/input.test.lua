-- Execute the actual input callback with service doubles, without a Roblox engine.
local file=assert(io.open('src/client/Main.client.lua')); local source=file:read('*a'); file:close()
local block=assert(source:match('(UIS.InputBegan:Connect%b())'), 'Input handler missing')
local handler,focused,opened,closed=nil,false,0,0
local root={Visible=false}
local env={
 UIS={InputBegan={Connect=function(_,fn) handler=fn end},GetFocusedTextBox=function() return focused end},
 Enum={KeyCode={E='E',Q='Q'}},root=root,
 requestOpen=function() opened=opened+1 end,
 close=function() closed=closed+1 end,
}
assert(load(block,'client input','t',env))()
handler({KeyCode='E'},false); assert(opened==1,'E opens')
handler({KeyCode='E'},true); assert(opened==2,'native prompt processing does not swallow fallback E')
focused=true; handler({KeyCode='E'},true); assert(opened==2,'typing never opens')
focused=false; root.Visible=true; handler({KeyCode='E'},false); assert(opened==2,'open panel not reopened')
handler({KeyCode='Q'},false); assert(closed==1,'Q closes')
handler({KeyCode='Q'},true); assert(closed==1,'processed Q ignored')
root.Visible=false; handler({KeyCode='X'},false); assert(opened==2,'unrelated key ignored')
print('PASS: 7 input regression cases (actual callback, mocked services).')
