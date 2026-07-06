-- Id: 17335
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=64276

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("Market-Meanness-Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("inputLength", "Length", "", 200);
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 76);
    indicator.parameters:addDouble("oversold","Oversold Level","", 74);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local inputLength; 
local first;
local source = nil;
 
local MMI;

-- Routine
 function Prepare(nameOnly) 
    inputLength = instance.parameters.inputLength; 
    source = instance.source;
 

    
    first=source:first()+inputLength+1;
	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. inputLength.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   
 
	MMI = instance:addStream("MMI" , core.Line, "MMI","MMI",instance.parameters.color, first);
    MMI:setPrecision(math.max(2, instance.source:getPrecision()));
	MMI:setWidth(instance.parameters.width);
    MMI:setStyle(instance.parameters.style);
    MMI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	MMI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);   
	
	
end

-- Indicator calculation routine
function Update(period)
 
	
    if period < first then
	return;
	end
		
     MMI[period]=MMI_function(period);
				  
end


function MMI_function(period) 
    local  m = mean(period);
	
    local nh = 0;
    local nl = 0;
	
    for i = period -1 , period-1-inputLength, -1 do
	
          if source.open[i] - source.close[i] > 0 then
            if (source.open[i] - source.close[i]) > m then
                if (source.open[i] - source.close[i]) > (source.open[i+1] - source.close[i+1]) then
                    nl= nl + 1
				end
             end  				
        else
            if (source.close[i] - source.open[i]) < m  then
                if (source.close[i] - source.open[i]) < (source.close[i-1] - source.open[i-1]) then
                    nh= nh + 1
				end	
			end	
	     end				
    end	
	
    return (100 - 100*(nl + nh)/(inputLength - 1));

	 
end	
	
function mean(period) 
   local  sum = 0;
   
    for i = period, period-inputLength+1, -1 do
        if source.open[i] - source.close[i] > 0 then
            sum = sum + (source.open[i] - source.close[i]);
        else
            sum = sum + (source.close[i] - source.open[i]);
		end	
   end
   
  return  (sum / inputLength);
end
 