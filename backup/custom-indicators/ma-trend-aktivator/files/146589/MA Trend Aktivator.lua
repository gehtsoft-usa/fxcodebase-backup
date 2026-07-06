-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72453

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MA Trend Aktivator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("x", "Period", "", 89, 1, 2000);
    indicator.parameters:addInteger("ap", "ATR Period", "", 14, 1, 2000);	
    indicator.parameters:addInteger("gg", "Green", "", 4, 1, 2000);
    indicator.parameters:addInteger("rr", "Red", "", 11, 1, 2000);	
    indicator.parameters:addDouble("factor", "factor", "", 1, 0, 2000);		
 
 	indicator.parameters:addString("Method", "MA Method", "Method" , "WMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA"); 
	 
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Trend Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Trend Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local x,ap,  gg,rr,factor,Method,Round; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	x=instance.parameters.x;
	gg=instance.parameters.gg;
	rr=instance.parameters.rr;
	factor=instance.parameters.factor;
    Method=instance.parameters.Method;	
	Round=instance.parameters.Round;
	ap=instance.parameters.ap;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  x.. "," ..  ap.. "," ..  gg .. "," ..  rr.. "," ..  factor .. "," ..  Method  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	trend = instance:addInternalStream(0, 0);
	up = instance:addInternalStream(0, 0);
	dn = instance:addInternalStream(0, 0);	
	
	Indicator= core.indicators:create(Method, source.close,x);
	ATR= core.indicators:create("ATR", source,ap);	
	first=math.max(Indicator.DATA:first(), ATR.DATA:first()) +1; 
	
	 
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

	  Indicator:update(mode); 
	  ATR:update(mode); 
	  
	trend[period]=1;
 
	
	if period <= first then
	return;
	end
   
 
 
	local green = Indicator.DATA[period-math.floor(x/gg)]
	local red = Indicator.DATA[period-math.floor(x/rr)]
	 
 

 
	if red > green then
	  up1 = red
	  dn1 = green
	else 
	  up1 = green
	  dn1 = red
	end 
 	
	
	
	up[period] = up1+(ATR.DATA[period]*factor)
    dn[period] = dn1-(ATR.DATA[period]*factor)

 

	if source.high[period]>up[period-1] then
	 trend[period]=1
	elseif source.low[period]<dn[period-1] then
	 trend[period]=-1
	end 	
	
	if trend[period]<0 and trend[period-1]>0 then
	 flag=1
	else
	 flag=0
	end 

	if trend[period]>0 and trend[period-1]<0 then
	 flagh=1
	else
	 flagh=0
	end 	
	
	
	if trend[period]>0 and dn[period]<dn[period-1] then
	dn[period]=dn[period-1]
	end
	if trend[period]<0 and up[period]>up[period-1] then
	 up[period]=up[period-1]
	end 
	
	
	if flag==1 then
	 up[period]=up1+(ATR.DATA[period]*factor)
	end 
	if flagh==1 then
	 dn[period]=dn1-(ATR.DATA[period]*factor)
	end 
	
	
	if trend[period]==1 then
    Line:setColor(period,  instance.parameters.color1);		
	 Line[period]=dn[period];
	else
    Line:setColor(period,  instance.parameters.color2);	 	
	 Line[period]=up[period];
	end  
	
	
	
end

 