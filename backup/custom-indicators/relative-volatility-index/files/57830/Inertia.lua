-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33759
-- Id: 8859

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:description("Inertia");
    indicator:name("Inertia");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MP", "Smoothing Period", "Smoothing Period", 14);
    indicator.parameters:addInteger("SP", "Standard Deviation Period", "Standard Deviation Period", 10);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("RVI_color", "Color of Inertia", "Color of Inertia", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local MP;
local SP;
local Hu,Hd, HU,HD;
local Lu,Ld, LU,LD;
local first;
local source = nil;

-- Streams block
local RVI = nil;

-- Routine
function Prepare(nameOnly)
    MP = instance.parameters.MP;
    SP = instance.parameters.SP;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(MP) .. ", " .. tostring(SP) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		Lu = instance:addInternalStream(0, 0);
		Ld = instance:addInternalStream(0, 0);
		
		LU = core.indicators:create("MVA", Lu, MP);
		LD = core.indicators:create("MVA", Ld, MP);
		
		Hu = instance:addInternalStream(0, 0);
		Hd = instance:addInternalStream(0, 0);
		
		HU = core.indicators:create("MVA", Hu, MP);
		HD = core.indicators:create("MVA", Hd, MP);
		
		first = LU.DATA:first();
        RVI = instance:addStream("RVI", core.Line, name, "RVI", instance.parameters.RVI_color, first);
    RVI:setPrecision(math.max(2, instance.source:getPrecision()));
		RVI:setWidth(instance.parameters.width);
        RVI:setStyle(instance.parameters.style);
		
		RVI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		RVI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < source:first()+SP  then
	return;
	end
    
	
  	if source.high[period]>source.high[period-1] then
	Hu[period]=mathex.stdev(source.high, period -SP+1, period);
	else
	Hu[period]=0;
	end
	
	if source.low[period]>source.low[period-1] then
	Lu[period]=mathex.stdev(source.low, period -SP+1, period);
	else
	Lu[period]=0;
	end
	
	
	
	if source.low[period]<source.low[period-1] then
	Ld[period]=mathex.stdev(source.low, period -SP+1, period);
	else
	Ld[period]=0;
	end
	
	if source.high[period]<source.high[period-1] then
	Hd[period]=mathex.stdev(source.high, period -SP+1, period);
	else
	Hd[period]=0;
	end
	
	HU:update(mode);
	HD:update(mode);
	
	LU:update(mode);
	LD:update(mode);
	
	if period < first  then
	return;
	end
    local  H= (100* HU.DATA[period])/(HU.DATA[period]+HD.DATA[period]);
	local  L= (100* LU.DATA[period])/(LU.DATA[period]+LD.DATA[period]);
    RVI[period] = (H+L)/2;
    
end

