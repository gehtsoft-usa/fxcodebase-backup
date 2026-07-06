-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71345

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Shifted HA");
    indicator:description("The indicator will shift source line by the specified number of periods and/or points.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");

	indicator.parameters:addGroup("Calculation");
   indicator.parameters:addString("Method", "Method", "Method" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Pips", "Pips" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Value", "Value" , "Value");
	indicator.parameters:addStringAlternative("Method", "Percentage", "Percentage" , "Percentage");
    indicator.parameters:addInteger("SX", "Shift in periods", "Postive is future, negative is past", 0);
    indicator.parameters:addDouble("SY", "Shift in points", "", 0);
	
	
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("width","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("color", "Color of the Shifted line", "", core.rgb(255, 0, 0));
end

local source;
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local first1, first2;
local SX, SY;
local Method;


function Prepare(nameOnly)   
  
    local name;
	Method=instance.parameters.Method;
    name = profile:id() .. "(" .. instance.source:name() .. ", " .. instance.parameters.SX .. " bars," .. instance.parameters.SY .. " points)";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;
    SX = instance.parameters.SX;
	if Method=="Pips" then
    SY = instance.parameters.SY * source:pipSize();
    else 
	SY = instance.parameters.SY;
	end
   
    first1 = source:first();
    first2 = first1 + SX;
    if first2 < 0 then
        first2 = 0;
    end
    
    HA = core.indicators:create("HA", source);
	first= HA.DATA:first() +1;
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first2,SX);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first2,SX);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first2,SX);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first2,SX);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
end

function Update(period, mode)
    
    HA:update(mode); 
    local p1 = period + SX;
    if p1 < 0 or  period < first1 then
	return;
	end
	   
	      if Method=="Pips" then 
			open[p1] = HA.open[period] + SY;
			close[p1] = HA.close[period] + SY;
			high[p1] = HA.high[period] + SY;
			low[p1] = HA.low[period] + SY;
		  elseif Method=="Percentage" then  
		 	open[p1] = HA.open[period] +(HA.close[period]/100)*SY;
			close[p1] = HA.close[period] +(HA.close[period]/100)*SY;
			high[p1] = HA.high[period] +(HA.close[period]/100)*SY;
			low[p1] = HA.low[period]  +(HA.close[period]/100)*SY;
		   else
		 	open[p1] = HA.open[period] + SY;
			close[p1] = HA.close[period] + SY;
			high[p1] = HA.high[period] + SY;
			low[p1] = HA.low[period] + SY;	
		   end
   
end

