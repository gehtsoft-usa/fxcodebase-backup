-- Id: 20416
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65663

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Total risk");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Color", "", core.rgb(128, 128, 0));
    indicator.parameters:addInteger("FontSize", "Font size", "0 - default", 0);
end

local source = nil;
local color;
local Profits, Losses, Total=0, 0, 0;
local BalPS=0;

-- initializes the instance of the indicator
function Prepare(nameOnly)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    instance:ownerDrawn(true);
    
    color = instance.parameters.color;
    instance:setLabelColor(color);
end

function Update(period)
    local trades = core.host:findTable("trades");
    local enum = trades:enumerator();
    Profits, Losses=0, 0;
    while true do
      local row = enum:next();
      if row == nil then break end
      if row.GrossPL>0 then
        Profits=Profits+row.GrossPL;
      else
        Losses=Losses-row.GrossPL;
      end
    end
    Total=Profits-Losses;

    local Balance=0;
    local accounts = core.host:findTable("accounts");
    local enum = accounts:enumerator();
    while true do
      local row = enum:next();
      if row == nil then break end
      Balance=Balance+row.Balance;
    end
    BalPS=100*Total/Balance;
end

local init = false;

function Draw(stage, context)
    if stage == 0 then
    
        if not init then
            if instance.parameters.FontSize==0 then
              context:createFont(1, "Arial", 0, -context:pointsToPixels(source:pipSize()), 0);
            else  
              context:createFont(1, "Arial", 0, instance.parameters.FontSize, 0);
            end 
            init = true;
        end

        local Str="Profit: " .. Profits .. "\013\010" .. "Loss: " .. Losses .. "\013\010" .. "Total: " .. Total;
        Str=Str .. "\013\010" .. "% of balance: " .. BalPS;
        local w, h=context:measureText(3, Str, context.LEFT);
        local top, right=context:top(), context:right();
        context:drawText(3, Str, color, -1, right-w, top, right, top+h, context.LEFT);

    end
end



