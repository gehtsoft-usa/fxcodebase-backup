-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71955

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
    indicator:name("Oscillator Template");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("inpForcePeriod", " Force index period", "", 13, 1, 2000);
    indicator.parameters:addInteger("inpBandsPeriod", "Bands period", "", 89, 1, 2000);
    indicator.parameters:addDouble("inpBandsMultip", "Bands multiplier", "", 0.21, 0, 2000);	
	
	indicator.parameters:addString("inpForceMethod", "Force index smoothing MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("inpForceMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("inpForceMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("inpForceMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("inpForceMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("inpForceMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("inpForceMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("inpForceMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("inpForceMethod", "WMA", "WMA" , "WMA");


	indicator.parameters:addString("inpBandsMethod", "Bands smoothing MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("inpBandsMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("inpBandsMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("inpBandsMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("inpBandsMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("inpBandsMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("inpBandsMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("inpBandsMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("inpBandsMethod", "WMA", "WMA" , "WMA");
 
	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
	 
	indicator.parameters:addColor("color3", "Top Line Color", "", core.rgb(128, 128, 128)); 
	indicator.parameters:addColor("color4", "Bottom Line Color", "", core.rgb(128, 128, 128));  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local inpForcePeriod, inpBandsPeriod,inpBandsMultip,inpForceMethod,inpBandsMethod; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	inpForcePeriod=instance.parameters.inpForcePeriod;
	inpBandsPeriod=instance.parameters.inpBandsPeriod;
	inpBandsMultip=instance.parameters.inpBandsMultip;
	inpForceMethod=instance.parameters.inpForceMethod;
	inpBandsMethod=instance.parameters.inpBandsMethod;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  inpForcePeriod.. "," ..  inpBandsPeriod.. "," ..  inpBandsMultip.. "," ..  inpForceMethod.. "," ..  inpBandsMethod  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
 
	
	valfr = instance:addInternalStream(0, 0);
	valvl = instance:addInternalStream(0, 0); 
	Line2 = instance:addInternalStream(0, 0); 

	Indicator1= core.indicators:create(inpForceMethod, valfr, inpForcePeriod)
	Indicator2= core.indicators:create(inpBandsMethod, valvl, inpBandsPeriod)	
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, source:first()+1+math.max(inpForcePeriod,inpBandsPeriod)  );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
 
 
    --Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, source:first()+1+math.max(inpForcePeriod,inpBandsPeriod)  );
   -- Line2:setPrecision(math.max(2, instance.source:getPrecision()));
   -- Line2:setWidth(instance.parameters.width);
   -- Line2:setStyle(instance.parameters.style);
   -- Line2:addLevel(0);	
	
	
    Top = instance:addStream("Top", core.Line, name, "Top Line", instance.parameters.color3, source:first()+1+math.max(inpForcePeriod,inpBandsPeriod)  );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:addLevel(0);	

    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom Line", instance.parameters.color4, source:first()+1+math.max(inpForcePeriod,inpBandsPeriod)  );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:addLevel(0);		
end


function Update(period, mode)

 

	 if period < source:first()+1
	 then
	 return;
	 end
	 
    valfr[period] =  (source.close[period]-source.close[period-1])* source.volume[period] 
     
    local Value=0;
	if(source.close[period-1]<source.low[period]) then
    Value=Value+ (source.low[period]-source.close[period-1])
    end
    if (source.close[period-1]>source.high[period]) then
    Value=Value+ (source.close[period-1]-source.high[period])  
    end
 
	valvl[period] =  (source.high[period]-source.low[period] + Value  ) *  source.volume[period]; 
	
	
	  Indicator1:update(mode);
	  Indicator2:update(mode);	  
 	 if period < source:first()+1+math.max(inpForcePeriod,inpBandsPeriod) 
	 then
	 return;
	 end
	
    Line1[period]=Indicator1.DATA[period];
    Line2[period]=Indicator2.DATA[period];
	
	
 
 
      
    Top[period] =  inpBandsMultip   *  Line2[period];
    Bottom[period] =  inpBandsMultip   * -Line2[period];
	
end




 
  