-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72817

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("waddah attar's volume oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("FastMa", "Fast MA", "", 20, 1, 2000);
    indicator.parameters:addInteger("SlowMa", "Slow MA", "", 40, 1, 2000);
	
	indicator.parameters:addString("MaMethod", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MaMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MaMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MaMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MaMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MaMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MaMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MaMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MaMethod", "WMA", "WMA" , "WMA");	
	
 
    indicator.parameters:addInteger("Sensitive", "Sensitive", "", 50, 1, 2000);   
 
	
	
	 indicator.parameters:addGroup("Line Style");	 
	
	 indicator.parameters:addColor("color1", "Up Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down  Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local FastMa, SlowMa,MaMethod,BandsLength,Sensitive; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	FastMa=instance.parameters.FastMa;
	SlowMa=instance.parameters.SlowMa;
	MaMethod=instance.parameters.MaMethod; 
	Sensitive=instance.parameters.Sensitive;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  FastMa.. "," ..  SlowMa.. "," ..  MaMethod .. "," ..  Sensitive  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Fast= core.indicators:create(MaMethod, source, FastMa );
	Slow= core.indicators:create(MaMethod, source, SlowMa );	
	first=math.max(Fast.DATA:first() , Slow.DATA:first())+1; 
	
	
	macd = instance:addInternalStream(0, 0);
 
	
	
    Line = instance:addStream("Line", core.Bar, name, "Line", instance.parameters.color1, first+1 );
    Line:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line:addLevel(0);	
 
end


function Update(period, mode)

	  Fast:update(mode); 
	  Slow:update(mode); 
	 if period <= first then
	 return;
	 end
	 
    macd[period]=Fast.DATA[period]-Slow.DATA[period];
	
	 if period <= first+1 then
	 return;
	 end
 
               
	Line[period]= (macd[period]-macd[period-1]) * Sensitive;
	
	if Line[period]> 0 then
	Line:setColor(period,   instance.parameters.color1);	
	else
	Line:setColor(period,   instance.parameters.color2);		
	end
	
end

--[[
          macd[i]     = iCustomMa(MaMethod,getPrice(Price,Open,Close,High,Low,i),FastMa,i,0)-iCustomMa(MaMethod,getPrice(Price,Open,Close,High,Low,i),SlowMa,i,1);
          double diff = (macd[i]-macd[i+1]) * Sensitive;
              
                prices[i] = getPrice(BandsPrice,Open,Close,High,Low,i);
                avg[i]    = iCustomMa(MaMethod,prices[i],BandsLength,i,2);
         double sDev      = iDeviation(prices,BandsLength,avg[i],i);
                avgUp[i]  = avg[i] + BandsDeviation * sDev;
                avgDn[i]  = avg[i] - BandsDeviation * sDev;               
                     
                buffer1[i] =  buffer2[i] = buffer3[i] =  buffer4[i] = EMPTY_VALUE;   
                if(diff>0) buffer1[i] = buffer3[i] = diff;
                   
                if(diff<0) buffer2[i] = buffer4[i] = diff;   // if(diff<0) buffer2[i] = buffer4[i] = (-1*diff);
				
]]


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+