-- Id:  
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69010

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Tick CCI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("N", "Number of periods for CCI", "", 14, 2, 2000);
	
 
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrCCI", "CCI Line Color", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthCCI","CCI Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleCCI", "CCI Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCCI", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addGroup("Levels");
   
    indicator.parameters:addInteger("overbought", "OverBought Level", "", 100, -1000, 1000);
    indicator.parameters:addInteger("oversold", "OverSold Level","", -100, -1000, 1000);
    indicator.parameters:addInteger("level_overboughtsold_width", "OverBoughtSold Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style",  "OverBoughtSold Line Style", "", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "OverBoughtSold Color", "", core.rgb(255, 255, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

local source;                   -- the source
 local N;
local first;
local CCIout;
 
 
function Prepare(nameOnly)

     
    source = instance.source;    
    N = instance.parameters.N;
	first=source:first()+N;
    

    
    local name = profile:id() .. "(" .. source:name()  .. "," .. N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	 
    
    CCIout = instance:addStream("CCIout", core.Line, name .. ".RSI", "RSI", instance.parameters.clrCCI, first);   
	CCIout:setWidth(instance.parameters.widthCCI);
    CCIout:setStyle(instance.parameters.styleCCI);
    CCIout:setPrecision(2);
	
	CCIout:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    CCIout:addLevel(0);
    CCIout:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);


end 


-- the function which is called to calculate the period
function Update(period ) 
         
 
     if period < first then
	 return;
	 end
	 
	 
        local from = period - N + 1;
        local to = period;
        local mean = mathex.avg(source, from, to);
        local meandev = mathex.meandev(source, from, to);
        		
        if (meandev == 0) then
            CCIout[period] = 0;
        else
            CCIout[period] = (source[period] - mean) / (meandev * 0.015);
        end
  
     
  
end

 
