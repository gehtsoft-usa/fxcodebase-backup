-- Id: 14533

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62412

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("SonicR PVA Volumes with Real volume/Transactions");
    indicator:description("SonicR PVA Volumes with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
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
local Volume = nil;
local Ind;

local FirstStart;
local LastTime;

-- Routine
function Prepare(nameOnly)
    PVA_Climax_Period = instance.parameters.PVA_Climax_Period;
    PVA_Rising_Period = instance.parameters.PVA_Rising_Period;
    PVA_Rising_Factor = instance.parameters.PVA_Rising_Factor;
    PVA_Extreme_Factor = instance.parameters.PVA_Extreme_Factor;
    source = instance.source;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PVA_Climax_Period) .. ", " .. tostring(PVA_Rising_Period) .. ", " .. tostring(PVA_Rising_Factor) .. ", " .. tostring(PVA_Extreme_Factor) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
     FirstStart=true;
     LastTime=0;
  	ma_volume = core.indicators:create("MVA", Ind.DATA, PVA_Rising_Period);
    first = ma_volume.DATA:first();
	
	Range = instance:addInternalStream(0, 0);

	 assert(source:supportsVolume(), "The source must have volume");
	 


    if (not (nameOnly)) then
        Volume = instance:addStream("Volume", core.Bar, name, "Volume", instance.parameters.Neutral, first);
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 if period < first or not  source:hasData(period) then
  return;
 end
        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==first then
                FirstStart=true;
            end    
            return;
        elseif FirstStart then
            FirstStart=false;
            instance:updateFrom(first);    
        elseif LastTime~=source:date(period) and period==source:size()-1 then
            LastTime=source:date(period);
            instance:updateFrom(period-10);
        end
 Volume[period] = Ind.DATA[period];    
 Volume:setColor(period, instance.parameters.Neutral);
  
 ma_volume:update(mode);
	
 if(Ind.DATA[period] >= ma_volume.DATA[period] * PVA_Rising_Factor) then
	 
  if(source.close[period] > source.open[period]) then
   Volume:setColor(period, instance.parameters.RisingBull);
  end
	  
  if(source.close[period] <= source.open[period]) then
   Volume:setColor(period, instance.parameters.RisingBear);
  end 
 end
	
 Range[period]= (source.high[period]-source.low[period])*Ind.DATA[period];
	
 if period < PVA_Climax_Period then 
  return;
 end
	
 local max = mathex.max( Range, period -PVA_Climax_Period, period-1 );
	
 if Range[period] >=  max  or  (Ind.DATA[period] >= ma_volume.DATA[period] * PVA_Extreme_Factor) then
  if(source.close[period] > source.open[period]) then
   Volume:setColor(period, instance.parameters.ClimaxBull);
  end
			  
  if(source.close[period] <= source.open[period]) then
   Volume:setColor(period, instance.parameters.ClimaxBear);
  end 
 end
end

function AsyncOperationFinished(cookie, success, message)

end
