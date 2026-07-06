-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72149

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
    indicator:name("DSL DMI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
	

	
    indicator.parameters:addInteger("DmiPeriod", "Period", "", 32, 1, 2000);
	indicator.parameters:addString("Method", "MA Method", "Method" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
 
	
    indicator.parameters:addBoolean("Smooth", "Smooth", "", false);	
    indicator.parameters:addInteger("SmoothPeriod", "Smooth Period", "", 32, 1, 2000);	
	indicator.parameters:addString("SmoothType", "Smooth Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("SmoothType", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("SmoothType", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("SmoothType", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("SmoothType", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("SmoothType", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("SmoothType", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("SmoothType", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("SmoothType", "WMA", "WMA" , "WMA");	
	
    indicator.parameters:addInteger("SignalPeriod", "Signal Period", "", 9, 1, 2000);
	
	
	indicator.parameters:addString("Type", "Smooth Method", "Method" , "Zero");
    indicator.parameters:addStringAlternative("Type", "Zero", "Zero" , "Zero");
    indicator.parameters:addStringAlternative("Type", "Level", "Level" , "Level");
    indicator.parameters:addStringAlternative("Type", "Slope", "Slope" , "Slope");	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(0, 255, 0)); 	 
	 
 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local DmiPeriod, Smooth,SignalPeriod, Type,Method; 
local DMI;
local alpha;	
-- Routine
 function Prepare(nameOnly)   
 
    
	DmiPeriod=instance.parameters.DmiPeriod;
	Smooth=instance.parameters.Smooth;
	SmoothType=instance.parameters.SmoothType;
	SmoothPeriod=instance.parameters.SmoothPeriod;
	SignalPeriod=instance.parameters.SignalPeriod;
	Type=instance.parameters.Type;
	Method=instance.parameters.Method;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Method .. "," ..  DmiPeriod .. "," ..  SmoothType .. "," ..  SignalPeriod .. "," ..  Type  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
	alpha = 2.0/(1.0+SignalPeriod);
	

	first=source:first() ; 
	
	
	dhh = instance:addInternalStream(0, 0);
 	dll = instance:addInternalStream(0, 0);
 	tr = instance:addInternalStream(0, 0);
	plusDM= instance:addInternalStream(0, 0);
	minusDM= instance:addInternalStream(0, 0);	
	
	MA= core.indicators:create(Method, tr, DmiPeriod );	
	
	
	MA1= core.indicators:create(Method, plusDM, DmiPeriod );	
	MA2= core.indicators:create(Method, minusDM, DmiPeriod );
	
	Delta= instance:addInternalStream(0, 0);		
	MA3= core.indicators:create(SmoothType, Delta, SmoothPeriod );		
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	


    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:addLevel(0);


    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, first );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:addLevel(0);	
end


function Update(period, mode)

	  

	 if period <= first then
	 return;
	 end
	 
    dhh[period] =source.high[period]-source.high[period-1]; 
    dll[period] =  source.low[period-1]-source.low[period]; 
    tr[period]  =  math.max(source.high[period],source.close[period-1])-math.min(source.low[period],source.close[period-1]);
	
	
	MA:update(mode); 	
	if period < MA.DATA:first(period) then
	return;
	end
	
	local  atr = MA.DATA[period];

    if (dhh[period]>dll[period] and dhh[period]>0)then plusDM[period]=dhh[period]; else plusDM[period]=0; end
    if (dll[period]>dhh[period] and dll[period]>0)then minusDM[period]=dll[period];else  minusDM[period]=0;   end
	
	MA1:update(mode); 	
	MA2:update(mode); 

	if period < MA2.DATA:first(period) then
	return;
	end
	
	local plusDI    = 100*MA1.DATA[period]/atr;
    local  minusDI   = 100*MA2.DATA[period]/atr;
		 
	Delta[period]=plusDI-minusDI;	 
	
	
	MA3:update(mode);
	if period < MA3.DATA:first(period) then
	return;
	end	
 	if Smooth then 
	Line[period]  =MA3.DATA[period];
	else
	Line[period]  =Delta[period];	
	end
	
    if  Line[period]>0  then
	Top[period] = Top[period-1]+alpha*(Line[period]-Top[period-1]) 
	Bottom[period] = Bottom[period-1] 	
	else
	Top[period] =Top[period-1] 
    Bottom[period] = Bottom[period-1]+alpha*(Line[period]-Bottom[period-1]) 	
	end
	
 
	
	if Type=="Zero" then
		if Line[period]>0 then
		Line:setColor(period,  instance.parameters.color2);	
		else
		Line:setColor(period,  instance.parameters.color1);	
		end
	elseif Type=="Slope" then
	
		if Line[period]>Line[period-1] then
		Line:setColor(period,  instance.parameters.color2);	
		else
		Line:setColor(period,  instance.parameters.color1);	
		end	
	
	else
	
		if Line[period]>Top[period] then
		Line:setColor(period,  instance.parameters.color2);	
		elseif Line[period]<Bottom[period] then
		Line:setColor(period,  instance.parameters.color1);	
		else
		Line:setColor(period,  instance.parameters.color);			
		end	
	
	end
	
	
	
	
end