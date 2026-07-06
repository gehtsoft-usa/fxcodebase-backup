-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72566

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Optimized Trend Tracker");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("length", "OTT Period", "", 2, 1, 2000);
     indicator.parameters:addInteger("percent", "OTT Percent", "", 1.4, 0, 2000);
 
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local length, percent, Method; 
local first;
local source = nil;
 
local Line1;  
local Line2;
local MA;

-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    length= instance.parameters.length;
    percent = instance.parameters.percent;
    Method = instance.parameters.Method;	
	
	local Parameters= length ..  ", " .. percent..  ", " .. Method;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;   
  
    MA  = core.indicators:create(Method, source, length); 
    first=MA.DATA:first(); 

    longStop= instance:addInternalStream(0, 0); 
    shortStop= instance:addInternalStream(0, 0);
    dir= instance:addInternalStream(0, 0);	 	
	Line1 = instance:addStream("Line1" , core.Line, " Line1"," Line1",instance.parameters.color1, first);
	Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:setPrecision(math.max(2, source:getPrecision()));
	
	Line2 = instance:addStream("Line2" , core.Line, " Line2"," Line2",instance.parameters.color2, first);
	Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:setPrecision(math.max(2, source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)

  
    MA:update(mode);
	
	
    if period <= first then
	dir[period]=1;
	return;
	end
	
	
 
	
     Line2[period]=MA.DATA[period];
	
	
	local  fark=MA.DATA[period]*percent*0.01
	
	
    longStop[period] = MA.DATA[period] - fark 
	shortStop[period] =  MA.DATA[period] + fark
	 
	 if MA.DATA[period] > longStop [period-1] then 
	  longStop[period] = math.max(longStop[period], longStop [period-1])
	 end
	 
	 if MA.DATA[period] < shortStop [period-1] then 
	  shortStop[period]= math.min(shortStop[period], shortStop [period-1])
	 end
	 
	 
	 if dir[period-1]==-1 and MA.DATA[period]>shortStop [period-1] then 
	  dir[period] = 1
	 elseif dir[period-1]==1 and MA.DATA[period]<longStop[period-1] then 
	  dir[period] = -1	 
	  end
	 
	 
	local MT;
    if dir[period]==1 then
	MT = longStop[period];
	else
	MT = shortStop[period];
	end
	
	 if dir[period]==1  then 
	  Line1[period] = MT*(200+percent)/200 
	 else
	  Line1[period] = MT*(200-percent)/200
	 end  
 
end


