-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72600

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
    indicator:name("Accelerate Buy&Sell VOLUME");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("PeriodFast", "Fast MA", "", 4, 1, 2000);
    indicator.parameters:addInteger("PeriodSlow", "Slow MA", "", 10, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "MACD Line Color", "", core.rgb(0, 0, 255)); 
    indicator.parameters:addColor("color2", "Short Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color3", "Long Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local PeriodFast, PeriodSlow;  
	
-- Routine
 function Prepare(nameOnly)   
 
    
	PeriodFast=instance.parameters.PeriodFast;
	PeriodSlow=instance.parameters.PeriodSlow;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  PeriodFast.. "," ..  PeriodSlow  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	MMFast= core.indicators:create("EMA", source.volume, PeriodFast );
	MMSlow= core.indicators:create("EMA", source.volume, PeriodSlow);
	first=math.max(MMFast.DATA:first(),MMSlow.DATA:first()) ; 
	
	
 
	
	VolBuyGreen = instance:addInternalStream(0, 0);
    VolSellRed = instance:addInternalStream(0, 0);

	VolBuyRed = instance:addInternalStream(0, 0);
    VolSellGreen = instance:addInternalStream(0, 0);
	
	UpVolumeFast= core.indicators:create("EMA", VolBuyGreen, PeriodFast );
	DownVolumeFast= core.indicators:create("EMA", VolSellRed, PeriodFast);	
 	UpVolumeSlow= core.indicators:create("MVA", VolBuyGreen, PeriodSlow );
	DownVolumeSlow= core.indicators:create("MVA", VolSellRed, PeriodSlow);	
	
	FIRST=math.max(PeriodFast,PeriodSlow );
	
	
    MACD = instance:addStream("MACD", core.Line, name, "MACD", instance.parameters.color1, first );
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
    MACD:setWidth(instance.parameters.width);
    MACD:setStyle(instance.parameters.style);
    MACD:addLevel(0);	

    Short = instance:addStream("SHORT", core.Line, name, "Short Volume", instance.parameters.color2, FIRST );
    Short:setPrecision(math.max(2, instance.source:getPrecision()));
    Short:setWidth(instance.parameters.width);
    Short:setStyle(instance.parameters.style);
    Short:addLevel(0);	

    Long = instance:addStream("LONG", core.Line, name, "Long Volume", instance.parameters.color3, FIRST );
    Long:setPrecision(math.max(2, instance.source:getPrecision()));
    Long:setWidth(instance.parameters.width);
    Long:setStyle(instance.parameters.style);
    Long:addLevel(0);	
	
end


function Update(period, mode)



	
	local a = source.high[period]-source.low[period];	 
	local b = source.open[period]-source.low[period];
	local c = source.high[period]-source.close[period];	 
	local d = source.high[period]-source.open[period];
	local e = source.close[period]-source.low[period];	
	
 
	local volUniBuy = source.volume[period]/(a+b+c)	 
	local volUniSell = source.volume[period]/(a+d+e)	 
	VolBuyGreen[period]=a*volUniBuy	  
	VolSellRed[period]=a*volUniSell
	
	VolBuyRed[period]=(d+e)*volUniSell	 
	VolSellGreen[period]=(b+c)*volUniBuy		
 
 
	if source.close[period]>=source.open[period] then
	 VolBuyGreen[period] = VolBuyRed[period]
	 VolSellGreen[period] = 0
	else
	 VolSellRed[period] = VolSellGreen[period]
	 VolBuyRed[period] = 0
	end  

	UpVolumeFast:update(mode); 
	DownVolumeFast:update(mode); 
	UpVolumeSlow:update(mode); 
	DownVolumeSlow:update(mode); 	
	
	if period <= FIRST then
	return;
	end
	
	Long[period]=UpVolumeFast.DATA[period]-UpVolumeSlow.DATA[period]
    Short[period]=DownVolumeFast.DATA[period]-DownVolumeSlow.DATA[period]
  
 
	MMFast:update(mode); 
	MMSlow:update(mode); 	

	 if period <= first then
	 return;
	 end
	 
	MACD[period]=  MMFast.DATA[period] - MMSlow.DATA[period]; 
end

 