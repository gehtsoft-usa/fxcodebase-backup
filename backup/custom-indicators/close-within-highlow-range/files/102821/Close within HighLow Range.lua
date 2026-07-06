-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=62783


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
    indicator:name("Close within HighLow Range");
    indicator:description("Close within HighLow Range");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addBoolean("ShowReversePattern", "Show reverse pattern", "", false);
	indicator.parameters:addDouble("TL", "Up Limit", "", 60);
	indicator.parameters:addDouble("BL", "Down Limit", "", 40);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Direct pattern color", "Direct pattern color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Reverse pattern color", "Reverse pattern color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 15  );
end

local first;
local source = nil;
local Pattern;
local ShowReversePattern;
local Up,Down,DotSize;
local LengthPattern;
local TL,BL;
function Prepare(nameOnly)
    source = instance.source; 
    ShowReversePattern=instance.parameters.ShowReversePattern;
	TL=instance.parameters.TL;
	BL=instance.parameters.BL;
	DotSize=instance.parameters.DotSize;
    first = source:first();
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    Up  = instance:createTextOutput ("Up", "Up", "Wingdings", DotSize, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    Down  = instance:createTextOutput ("Down", "Down", "Wingdings", DotSize, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    Up:setNoData(period);
	Down:setNoData(period);
	local Range= (source.high[period]-source.low[period])/100;
    if source.close[period]> (source.low[period]+ Range*TL) then
		if not ShowReversePattern then
		Up:set(period, source.high[period], "\217");
		else
		 Down:set(period, source.low[period], "\218");
		end
	end
	
   if source.close[period]< (source.low[period]+ Range*BL) then
		if  ShowReversePattern then
		Up:set(period, source.high[period], "\217");
		else
		 Down:set(period, source.low[period], "\218");
		end
	end
end

