-- Strategy profile initialization routine
-- Defines Strategy profile properties and Strategy parameters
function Init()
    strategy:name("Entry Polyline Alert");
    strategy:description("Entry Polyline Alert");

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    strategy.parameters:addString("Name", "Polyline name", "", "1");
    strategy.parameters:addBoolean("Beams", "Use sections as beams", "", false);
end

local indicator = nil

local Amount
local BS
local source

-- Routine
function Prepare(nameOnly)
    local name = "EntryPolylineAlert - " .. instance.parameters.Name
    instance:name(name);

    source = instance.parameters.Type == "Bid" and instance.bid or instance.ask
end


-- strategy calculation routine
function Update()
    if indicator == nil  then
        local indiName = "EntryPolyline - " .. instance.parameters.Name
        for i = 0, interop:size() - 1 do
            local ii = interop:instance(i)

            if ii:name() == indiName then
                indicator = ii
            end
        end
        assert(indicator ~= nil, "EntryPolyline - " .. instance.parameters.Name .. " not found")

        local pair = indicator:invoke("GetPair")
        assert(pair == instance.bid:instrument(), "EntryPolyline - " .. instance.parameters.Name .. " applied to another currency pair")
    end

    if interop:isalive(indicator) then
     Size=source:size();
     if indicator:invoke("Crosses",source:date(Size-2), source[Size-2], source:date(Size-1), source[Size-1] ,instance.parameters.Beams) then
      terminal:alertMessage(source:instrument(), source[source:size() - 1], "Crosses with polyline " .. instance.parameters.Name, source:date(source:size() - 1));
      core.host:execute("stop");
     end
    end 

end


--dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
