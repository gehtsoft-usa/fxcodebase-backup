-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75380

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+

function AddLine(index, price, color)
    indicator.parameters:addGroup("== Line " .. index .. " ==");
    indicator.parameters:addBoolean("line" .. index .. "on", "Draw Line " .. index, "", true);
    indicator.parameters:addDouble("line" .. index .. "_priceini", "Price reference", "", price);
    indicator.parameters:setFlag("line" .. index .. "_priceini", core.FLAG_PRICE);
    indicator.parameters:addDouble("line" .. index .. "_pricegap", "Price Gap", "", 0.01);
    indicator.parameters:addColor("line" .. index .. "_color", "Line Color", "", color);
    indicator.parameters:addInteger("line" .. index .. "_style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("line" .. index .. "_style", core.FLAG_LINE_STYLE);
end

function Init()
    indicator:name("Levels");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    AddLine("1", 1.04, core.colors().Black);
    AddLine("2", 1.039, core.colors().Gray);
end

function GetLine(index)
    local line = {};
    line.Draw = instance.parameters:getBoolean("line" .. index .. "on");
    line.Price = instance.parameters:getDouble("line" .. index .. "_priceini");
    line.Gap = instance.parameters:getDouble("line" .. index .. "_pricegap");
    line.Color = instance.parameters:getColor("line" .. index .. "_color");
    line.Style = instance.parameters:getInteger("line" .. index .. "_style");
    return line;
end

local lines = {};
local source;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    lines[1] = GetLine("1");
    lines[2] = GetLine("2");
    instance:ownerDrawn(true);
end

function Update(period, mode)
end

local init = false;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        for i, line in ipairs(lines) do
            line.Pen = i;
            context:createPen(i, context:convertPenStyle(line.Style), 1, line.Color);
        end
    end

    for i, line in ipairs(lines) do
        if line.Draw then
            local top = context:priceOfPoint(context:top());
            local top_diff = math.floor((line.Price - top) / line.Gap);
            top = line.Price - (top_diff + 1) * line.Gap;
        
            local bottom = context:priceOfPoint(context:bottom());
            local bottom_diff = math.floor(line.Price - bottom);
            bottom = line.Price - (bottom_diff + 1) * line.Gap;
            local to = math.floor(top / line.Gap);
            local from = math.floor(bottom / line.Gap);
            for i = from, to do
                local _, y = context:pointOfPrice(i * line.Gap);
                context:drawLine(line.Pen, context:left(), y, context:right(), y);
            end
        end
    end
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+