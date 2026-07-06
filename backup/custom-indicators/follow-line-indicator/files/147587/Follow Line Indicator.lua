-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72758

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
    indicator:name("Follow Line Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("BBperiod", "BB period", "", 21, 1, 2000);
    indicator.parameters:addDouble("BBdeviations", "BB deviations", "", 1, 1, 2000);
    indicator.parameters:addInteger("ATRperiod", "ATR period", "", 5, 1, 2000);	
	
    indicator.parameters:addBoolean("UseATRfilter", "Use ATR filter", "", false);
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local BBperiod, BBdeviations,ATRperiod,UseATRfilter; 
-- Routine
 function Prepare(nameOnly)   
 
    
	BBperiod=instance.parameters.BBperiod;
	BBdeviations=instance.parameters.BBdeviations;
	ATRperiod=instance.parameters.ATRperiod;
	UseATRfilter=instance.parameters.UseATRfilter;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  BBperiod.. "," ..  BBdeviations .. "," ..   ATRperiod .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	BB= core.indicators:create("BB", source.close, BBperiod);
	ATR= core.indicators:create("ATR", source , BBperiod);	
	first=math.max(BB.DATA:first(),ATR.DATA:first()) ; 
	
	
	BBSignal = instance:addInternalStream(0, 0);
	Trend = instance:addInternalStream(0, 0); 
	
	
    TrendLine = instance:addStream("TrendLine", core.Line, name, "TrendLine", instance.parameters.color1, first );
    TrendLine:setPrecision(math.max(2, instance.source:getPrecision()));
    TrendLine:setWidth(instance.parameters.width);
    TrendLine:setStyle(instance.parameters.style);
    TrendLine:addLevel(0);	
 
end


function Update(period, mode)

	BB:update(mode); 
	ATR:update(mode); 
	
	 if period <= first then
	 return;
	 end
	
 
	BBSignal[period]=BBSignal[period-1];
	
	if(source.close[period]>BB.TL[period]) then
	 BBSignal[period]=1
	end 
	if(source.close[period]<BB.BL[period]) then 
	 BBSignal[period]=-1
	end 	
 
	if(BBSignal[period]>0) then
	 if(UseATRfilter) then 
	  TrendLine[period]=source.low[period]-ATR.DATA[period]
	 end 
	 if(not UseATRfilter) then 
	  TrendLine[period]=source.low[period]
	 end 
	 if(TrendLine[period]<TrendLine[period-1]) then 
	  TrendLine[period]=TrendLine[period-1]
	 end 
	end 
 
	if(BBSignal[period]<0) then 
	 if(UseATRfilter) then 
	  TrendLine[period]=source.high[period]+ATR.DATA[period]
	 end 
	 if(not UseATRfilter) then 
	  TrendLine[period]=source.high[period]
	 end 
	 if(TrendLine[period]>TrendLine[period-1]) then 
	  TrendLine[period]=TrendLine[period-1]
	 end 
	end 
 
	
	Trend[period]=Trend[period-1]
	if(TrendLine[period]>TrendLine[period-1]) then 
	 Trend[period]=1
	TrendLine:setColor(period,   instance.parameters.color1);		 
	end 
	if(TrendLine[period]<TrendLine[period-1]) then 
	 Trend[period]=-1
	TrendLine:setColor(period,   instance.parameters.color2);		 
	end 
  

 
end


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