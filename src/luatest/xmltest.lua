
dofile("framework/xml.lua")
dofile("framework/xml_handler.lua")
dofile("framework/xml_pretty.lua")


function init()
  local raw = _c_framework.loadAscii("data/out.xml")

  h = simpleTreeHandler()
  p = xmlParser(h)
  p:parse(raw)
  sprites = h.root.sheet.sprite
  for i, v in ipairs(sprites) do
    print(v._attr.name)
  end
  --pretty("root", h.root)

end


function update(deltaMs)

end

function draw()
end
