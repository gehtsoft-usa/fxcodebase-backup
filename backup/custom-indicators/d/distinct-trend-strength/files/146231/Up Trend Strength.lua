-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72306

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
    indicator:name("Up Trend Strength");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Number", "Number of", "", 100, 1, 100); 
	
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
    indicator.parameters:addColor("color1", "Up Trend Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("color2", "Down Trend Line Color", "", core.rgb(0, 255, 0));	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE); 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Number, Period2; 
local first;
local source = nil;
 
local Oscillator;  
local Indicator={};

-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Number= instance.parameters.Number;
    Method = instance.parameters.Method;
	
	
	local Parameters= Number ..  ", " .. Method;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    first=source:first();
 
	for i= 1, Number, 1 do
    Indicator[i] = core.indicators:create(Method, source , i); 
	  first=math.max(first, Indicator[i].DATA:first());
    end
	
  
	
	 
   
 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color1, first);
    Line:setPrecision(math.max(2, source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);	
 	
end

-- Indicator calculation routine
function Update(period, mode)

 
	for i= 1, Number, 1 do 
    Indicator[i]:update(mode);
    end
	
    if period < first then
	return;
	end
	
 
				local TheBottom=Number;
				for i= Number -1, 1, -1 do 
				TheBottom=i;	
					if 	Indicator[i].DATA[period] <Indicator[i+1].DATA[period]  
					then
					break
					end
				
				end
				
				
				Line[period]=Number-TheBottom;
                Line:setColor(period,  instance.parameters.color2);	
				
				local TheBottom=1;
				for i= 2, Number , 1 do 
				TheBottom=i;	
					if 	Indicator[i].DATA[period] <Indicator[i-1].DATA[period]  
					then
					break
					end
				
				end
				
				
				Line[period]=Line[period]+ TheBottom;
                Line:setColor(period,  instance.parameters.color2);					
	 
end

