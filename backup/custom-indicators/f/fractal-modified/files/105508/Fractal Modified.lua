
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63313

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("Fractal");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Bill Williams");

    indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("Size1", "Arrow Size","", 15);
	indicator.parameters:addInteger("Size2", "Font Size","", 15);
    indicator.parameters:addColor("clrUP", "Up Color","", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN", "Down Color","", core.COLOR_DOWNCANDLE);
    indicator.parameters:addBoolean("ShowPrice", "Show Price","", false);
    indicator.parameters:addColor("clrPrice", "Label Color","", core.rgb(128, 128, 128));
end

local source;
local up, down;
local Size1,Size2;
 


function Prepare(nameOnly) 
    source = instance.source;
	
	Size1= instance.parameters.Size1;
	Size2= instance.parameters.Size2;
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    up = instance:createTextOutput ("Up", "Up", "Wingdings", Size1, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size1, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
    up1 = instance:createTextOutput ("", "UpL", "Arial", Size2, core.H_Right, core.V_Top, instance.parameters.clrPrice, 0);
    down1 = instance:createTextOutput ("", "DnL", "Arial", Size2, core.H_Right, core.V_Bottom, instance.parameters.clrPrice, 0);
 
 end
 
 
function Update(period, mode)
    if (period > 6) then
        local curr = source.high[period - 2];
        if (curr > source.high[period - 4] and curr > source.high[period - 3] and
            curr > source.high[period - 1] and curr > source.high[period]) then
            up:set(period - 2, source.high[period - 2], "\217", source.high[period - 2]);
            if instance.parameters.ShowPrice then
                up1:set(period - 2, source.high[period - 2], "  " .. source.high[period - 2]);
            end
        else
            up:setNoData(period - 2);
            up1:setNoData(period - 2);
        end
        curr = source.low[period - 2];
        if (curr < source.low[period - 4] and curr < source.low[period - 3] and
            curr < source.low[period - 1] and curr < source.low[period]) then
            down:set(period - 2, source.low[period - 2], "\218", source.low[period - 2]);
            if instance.parameters.ShowPrice then
                down1:set(period - 2, source.low[period - 2], "  " .. source.low[period - 2]);
            end
        else
            down:setNoData(period - 2);
            down1:setNoData(period - 2);
        end
    end
end

 
