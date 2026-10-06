"""Deterministic Roblox XML place builder (Python standard library only).
The same scripts may alternatively be synchronized using default.project.json / Rojo.
"""
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]

def build():
    root = ET.Element('roblox', {'version': '4'})
    ET.SubElement(root, 'External').text = 'null'
    ET.SubElement(root, 'External').text = 'nil'
    count = 0

    def item(parent, cls, name, source=None):
        nonlocal count
        count += 1
        node = ET.SubElement(parent, 'Item', {'class': cls, 'referent': f'RBX{count:08d}'})
        props = ET.SubElement(node, 'Properties')
        ET.SubElement(props, 'string', {'name': 'Name'}).text = name
        if source is not None:
            ET.SubElement(props, 'ProtectedString', {'name': 'Source'}).text = source
            if cls in ('Script', 'LocalScript'):
                ET.SubElement(props, 'bool', {'name': 'Disabled'}).text = 'false'
        return node

    workspace = item(root, 'Workspace', 'Workspace')
    ET.SubElement(workspace.find('Properties'), 'bool', {'name': 'FilteringEnabled'}).text = 'true'
    storage = item(root, 'ReplicatedStorage', 'ReplicatedStorage')
    shared = item(storage, 'Folder', 'ElectricianShared')
    for name in ('Config', 'Rules'):
        item(shared, 'ModuleScript', name, (ROOT / f'src/shared/{name}.lua').read_text())
    server = item(root, 'ServerScriptService', 'ServerScriptService')
    folder = item(server, 'Folder', 'ElectricianServer')
    item(folder, 'ModuleScript', 'World', (ROOT / 'src/server/World.lua').read_text())
    item(folder, 'Script', 'Main', (ROOT / 'src/server/Main.server.lua').read_text())
    starter = item(root, 'StarterPlayer', 'StarterPlayer')
    scripts = item(starter, 'StarterPlayerScripts', 'StarterPlayerScripts')
    client = item(scripts, 'Folder', 'ElectricianClient')
    item(client, 'LocalScript', 'Main', (ROOT / 'src/client/Main.client.lua').read_text())
    item(root, 'Lighting', 'Lighting')
    ET.indent(root)
    target = ROOT / 'dist/Elektryk-0.1.rbxlx'
    target.parent.mkdir(exist_ok=True)
    ET.ElementTree(root).write(target, encoding='utf-8', xml_declaration=True)
    (target.parent / 'Elektryk-0.1.1.rbxlx').write_bytes(target.read_bytes())
    # Round-trip every embedded script, preserving exact source bytes as Unicode.
    parsed = ET.parse(target)
    actual = [n.text for n in parsed.findall('.//ProtectedString')]
    expected = [(ROOT / p).read_text() for p in (
        'src/shared/Config.lua', 'src/shared/Rules.lua', 'src/server/World.lua',
        'src/server/Main.server.lua', 'src/client/Main.client.lua')]
    assert actual == expected, 'Embedded scripts differ from source'
    print(f'Built {target.name}: {target.stat().st_size} bytes, {len(actual)} scripts verified')

if __name__ == '__main__':
    build()
