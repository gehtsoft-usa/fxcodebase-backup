-- Id: 24888
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68407

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
    indicator:name("Synthetic Vix Stochastic");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("pd", "WVF lookback period", "", 22, 1, 2000);
	indicator.parameters:addInteger("length", "length", "", 14, 1, 2000);
	
    indicator.parameters:addInteger("smoothK", "smoothK period", "", 3, 1, 2000);
	indicator.parameters:addInteger("smoothD", "smoothD period", "", 3, 1, 2000);
	
	indicator.parameters:addGroup("K Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addColor("color2", "Line Color", "", core.rgb(  255,0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local pd,length;
local first;
local source = nil;
local Data; 
local K,D;  
local smoothK ,smoothD; 
local wvf;
local k;
local mins, maxes;
-- Routine
 function Prepare(nameOnly)   
 
    pd= instance.parameters.pd;
	length= instance.parameters.length;
	
	smoothK = instance.parameters.smoothK;
	smoothD= instance.parameters.smoothD;
	
	local Parameters= pd .. ", " .. length.. ", " ..smoothK .. ", " .. smoothD;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

   
			
    source = instance.source;
	first=source:first()+pd; 
	
    k= instance:addInternalStream(0, 0);
    wvf= instance:addInternalStream(0, 0);
	
 
	
	K = instance:addStream("K " , core.Line, "K","K ",instance.parameters.color1, first+pd+smoothK );
    K:setPrecision(math.max(2, instance.source:getPrecision()));
	K :setWidth(instance.parameters.width1);
    K :setStyle(instance.parameters.style1);
    K :setPrecision(math.max(2, source:getPrecision()));
	
	
	D = instance:addStream("K " , core.Line, "K","K ",instance.parameters.color2, first+pd+smoothK+smoothD );
    D:setPrecision(math.max(2, instance.source:getPrecision()));
	D :setWidth(instance.parameters.width2);
    D :setStyle(instance.parameters.style2);
    D :setPrecision(math.max(2, source:getPrecision()));
	
	
	D:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	D:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
end

-- Indicator calculation routine
function Update(period, mode)

 
    if period < first   then
	return;	
	end 	
	
	local min,max=mathex.minmax(source, period-pd+1, period);
	wvf[period]= ((max-source.low[period])/ max )*-1;
	
 
	if period < first+pd +length  then
	return;	
	end
	local min,max=mathex.minmax(wvf, period-length, period);
	
	local mins  = wvf[period] - min;
    local maxes  = max - min;
	 
	
	if maxes == 0 then
    k[period] = 50;
    else
	k[period] = mins  / maxes  * 100
	end
	
	
	 if period < first+pd+  length+ smoothK  then
	return;	
	end
	
    K[period]=mathex.avg(k, period-smoothK+1, period);			  
	 
	 if period < first+pd+  length+smoothK+smoothD   then
	return;	
	end
	 D[period]=mathex.avg(K, period-smoothD+1, period);			  
end
 
 
