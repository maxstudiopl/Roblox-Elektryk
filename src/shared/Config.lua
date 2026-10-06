-- Elektryk 0.1: a deliberately simplified puzzle, not an installation design.
local C = {}
C.Version = "0.1.1"
C.InteractionDistance = 18
C.Parts = {
 MAIN = {name="Wyłącznik główny", label="GŁÓWNY", width=1, terminals={"L1", "L2"}},
 RCD = {name="RCD 2P", label="RCD", width=2, terminals={"L1", "N1", "L2", "N2"}},
 B10 = {name="Wyłącznik B10", label="B10", width=1, terminals={"L1", "L2"}},
 B16 = {name="Wyłącznik B16", label="B16", width=1, terminals={"L1", "L2"}},
}
C.PartOrder = {"MAIN", "RCD", "B10", "B16"}
C.Colors = {
 brown={name="Brązowy", rgb={133,82,47}, kind="L"},
 black={name="Czarny", rgb={48,53,64}, kind="L"},
 gray={name="Szary", rgb={159,171,187}, kind="L"},
 blue={name="Niebieski", rgb={50,151,255}, kind="N"},
 pe={name="Żółto-zielony", rgb={226,224,66}, kind="PE"},
}
C.ColorOrder = {"brown", "black", "gray", "blue", "pe"}
C.Jobs = {
 {name="Światło w garażu", reward=150, slots={[1]="MAIN",[2]="RCD",[4]="B10"}, loads={"LIGHT"}, brief="Zamontuj: główny w 1, RCD w 2–3, B10 w 4. Podłącz obwód lampy."},
 {name="Gniazdo warsztatowe", reward=220, slots={[1]="MAIN",[2]="RCD",[4]="B16"}, loads={"SOCKET"}, brief="Zamontuj: główny w 1, RCD w 2–3, B16 w 4. Podłącz obwód gniazda."},
 {name="Mały warsztat", reward=350, slots={[1]="MAIN",[2]="RCD",[4]="B10",[5]="B16"}, loads={"LIGHT","SOCKET"}, brief="Zamontuj: główny w 1, RCD w 2–3, B10 w 4 i B16 w 5. Podłącz dwa obwody."},
}
C.Names = {['SUP.L']='Zasilanie L',['SUP.N']='Zasilanie N',['SUP.PE']='Zasilanie PE',['BUS.N']='Listwa N',['BUS.PE']='Listwa PE',['LIGHT.L']='Lampa L',['LIGHT.N']='Lampa N',['LIGHT.PE']='Lampa PE',['SOCKET.L']='Gniazdo L',['SOCKET.N']='Gniazdo N',['SOCKET.PE']='Gniazdo PE'}
function C.endpointName(id)
 if C.Names[id] then return C.Names[id] end
 local slot, pin = string.match(id, '^S(%d+)%.(%w+)$')
 return slot and ('Pole '..slot..' / '..pin) or id
end
function C.expected(job)
 local edges = {{'SUP.L','S1.L1','L'},{'S1.L2','S2.L1','L'},{'SUP.N','S2.N1','N'},{'S2.N2','BUS.N','N'},{'SUP.PE','BUS.PE','PE'}}
 for i, load in ipairs(job.loads) do
  local slot = 3+i
  edges[#edges+1]={'S2.L2','S'..slot..'.L1','L'}
  edges[#edges+1]={'S'..slot..'.L2',load..'.L','L'}
  edges[#edges+1]={'BUS.N',load..'.N','N'}
  edges[#edges+1]={'BUS.PE',load..'.PE','PE'}
 end
 return edges
end
return C
