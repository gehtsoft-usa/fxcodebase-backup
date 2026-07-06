-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68409

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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


-- Indicator profile initialization routine

function Init()
    indicator:name("Day Of Week Average Range Bands");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addDouble("Multiple", "Multiple", "", 1); 
	
	
	indicator.parameters:addGroup("Top Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Bottom Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Multiple; 
local first;
local source = nil;
local Top,Bottom;
 
local Count={};
local Day={};
-- Routine
 function Prepare(nameOnly)   
 
 
    Multiple = instance.parameters.Multiple;
	
	
	local Parameters= Multiple;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    
    first=source:first();
	
	for i= 1, 6 ,1 do
	Day[i] = instance:addInternalStream(0, 0);
	Count[i] = instance:addInternalStream(0, 0);
	end
	 
 
	Top= instance:addStream("Top", core.Line, "Top", "Top", instance.parameters.color1, source:first());
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
	
	Bottom= instance:addStream("Bottom", core.Line, "Bottom", "Bottom", instance.parameters.color2, source:first());
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
	
end

-- Indicator calculation routine
function Update(period, mode)

 
  
	
    if period < first then
	return;
	end
	
	local ThisDay;
	
	for i= 1, 6, 1 do
	 Day[i][period]=Day[i][period-1];
	 Count[i][period]=Count[i][period-1];
	 end
	 
	 local 	table= core.dateToTable (source:date(period))
	 if table.wday==1 then
	 Day[1][period]=Day[1][period-1]+(source.high[period]-source.low[period]);
	 Count[1][period]=Count[1][period-1]+1;
	 ThisDay=Day[1][period]/Count[1][period];
	 elseif table.wday==2 then
	 Day[2][period]=Day[2][period-1]+(source.high[period]-source.low[period]);
	 Count[2][period]=Count[2][period-1]+1;	 
	 ThisDay=Day[2][period]/Count[2][period];
	 elseif table.wday==3 then
	 Day[3][period]=Day[3][period-1]+(source.high[period]-source.low[period]);
	 Count[3][period]=Count[3][period-1]+1;
	 ThisDay=Day[3][period]/Count[3][period];
	 elseif table.wday==4 then
	 Day[4][period]=Day[4][period-1]+(source.high[period]-source.low[period]);
	 Count[4][period]=Count[4][period-1]+1;
	 ThisDay=Day[4][period]/Count[4][period];
	 elseif table.wday==5 then
	 Day[5][period]=Day[5][period-1]+(source.high[period]-source.low[period]);
	 Count[5][period]=Count[5][period-1]+1;
	 ThisDay=Day[5][period]/Count[5][period];
	 elseif table.wday==6 then
	 Day[6][period]=Day[6][period-1]+(source.high[period]-source.low[period]);
	 Count[6][period]=Count[6][period-1]+1;
	 ThisDay=Day[6][period]/Count[6][period];
     end
	 
	 
	 
	  Top[period] = source.close[period] + ((ThisDay * Multiple)/2);
      Bottom[period] = source.close[period] - ((ThisDay * Multiple)/2);
      
				  
end

