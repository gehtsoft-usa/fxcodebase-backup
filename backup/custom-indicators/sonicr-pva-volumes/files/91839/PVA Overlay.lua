-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60177

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("SonicR PVA Volumes");
    indicator:description("SonicR PVA Volumes");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PVA_Climax_Period", "PVA Climax Period", "PVA Climax Period", 10);
    indicator.parameters:addInteger("PVA_Rising_Period", "PVA Rising Period", "PVA Rising Period", 10);
    indicator.parameters:addDouble("PVA_Rising_Factor", "PVA Rising Factor", "PVA Rising Factor", 1);
    indicator.parameters:addDouble("PVA_Extreme_Factor", "PVA Extreme Factor", "PVA Extreme Factor", 2);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128,128, 128));
	
	indicator.parameters:addColor("RisingBull", "Color of Rising Bull", "Color of Rising Bull", core.rgb(0,200, 0));	
	indicator.parameters:addColor("RisingBear", "Color of Rising Bear", "Color of Rising Bear", core.rgb(200,0, 0));
	
	indicator.parameters:addColor("ClimaxBull", "Color of Climax Bull", "Color of Climax Bull", core.rgb(0,255, 0));	
	indicator.parameters:addColor("ClimaxBear", "Color of Climax Bear", "Color of Climax Bear", core.rgb(255,0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PVA_Climax_Period;
local PVA_Rising_Period;
local PVA_Rising_Factor;
local PVA_Extreme_Factor;
local ma_volume;
local first;
local source = nil;
local Range;
-- Streams block
local open=nil;
local close=nil;
local high=nil;
local low=nil;

-- Routine
function Prepare(nameOnly)
    PVA_Climax_Period = instance.parameters.PVA_Climax_Period;
    PVA_Rising_Period = instance.parameters.PVA_Rising_Period;
    PVA_Rising_Factor = instance.parameters.PVA_Rising_Factor;
    PVA_Extreme_Factor = instance.parameters.PVA_Extreme_Factor;
    source = instance.source;
	 
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PVA_Climax_Period) .. ", " .. tostring(PVA_Rising_Period) .. ", " .. tostring(PVA_Rising_Factor) .. ", " .. tostring(PVA_Extreme_Factor) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		ma_volume = core.indicators:create("MVA", source.volume, PVA_Rising_Period);
		first = ma_volume.DATA:first();
		
		Range = instance:addInternalStream(0, 0);
	
		 assert(source:supportsVolume(), "The source must have volume");
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
	
	 open:setColor(period,  instance.parameters.Neutral);  
	
	ma_volume:update(mode);
	
	if period < first or not  source:hasData(period) then
	return;
	end
	
	 if(source.volume[period] >= ma_volume.DATA[period] * PVA_Rising_Factor) then
	 
	  if(source.close[period] > source.open[period]) then
	   open:setColor(period,  instance.parameters.RisingBull); 
 
	  end
	  
      if(source.close[period] <= source.open[period]) then
	   open:setColor(period,  instance.parameters.RisingBear);  
	  end 
	 
	 end
	
	Range[period]= (source.high[period]-source.low[period])*source.volume[period];
	
	if period < PVA_Climax_Period then 
	return;
	end
	
	local max = mathex.max( Range, period -PVA_Climax_Period, period-1 );
	
	
    if Range[period] >=  max  or  (source.volume[period] >= ma_volume.DATA[period] * PVA_Extreme_Factor) then
	
			if(source.close[period] > source.open[period]) then 
			   open:setColor(period,  instance.parameters.ClimaxBull); 
			  end
			  
			  if(source.close[period] <= source.open[period]) then
			  open:setColor(period,  instance.parameters.ClimaxBear); 
			  end 
	  
	  
	end
	
        
   
end

