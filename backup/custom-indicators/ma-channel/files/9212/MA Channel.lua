-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3786

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
    indicator:name("MA Channel");
    indicator:description("MA Channel");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Central MA");
	indicator.parameters:addInteger("FRAME", "MA Period", "", 60);
	indicator.parameters:addInteger("STEP", "Step Period", "", 10);
	

	SELECT(1);	
	SELECT(2);	
	SELECT(3);
  
end

function SELECT (id)
 
   indicator.parameters:addGroup(id..". MA Calculation");
	indicator.parameters:addString("Method"..id, "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method"..id, "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method"..id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method"..id, "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method"..id, "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method"..id, "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method"..id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method"..id, "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method"..id, "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method"..id, "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method"..id, "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method"..id, "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method"..id, "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method"..id, "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method"..id, "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method"..id, "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method"..id, "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method"..id, "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method"..id, "JSmooth", "", "JSmooth");
	
	 indicator.parameters:addGroup(id..". MA Style");
	indicator.parameters:addInteger("width"..id, "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..id, "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..id, core.FLAG_LEVEL_STYLE);
	
	if id == 1 then
	indicator.parameters:addColor("color"..id,  id.. ". MA Color", "", core.rgb(0, 0, 255));
    elseif id == 2 then
	indicator.parameters:addColor("color"..id,  id.. ". MA Color", "", core.rgb(255, 0, 0));
	elseif id == 3 then
	indicator.parameters:addColor("color"..id,  id.. ". MA Color", "", core.rgb(0, 255, 0));
	else
	indicator.parameters:addColor("color"..id,  id.. ". MA Color", "", core.rgb(128, 128, 128));
    end
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local FRAME;
local STEP;

local first;
local source = nil;

-- Streams block
local MA = {};
local Indicator = {};

-- Routine
function Prepare(nameOnly)
    FRAME = instance.parameters.FRAME;
	STEP = instance.parameters.STEP;
    source = instance.source;
   
	assert(FRAME > STEP  , "MA Period must be greater than STEP" );
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(FRAME).. ", " .. tostring(STEP).. ", " .. tostring(instance.parameters:getString("Method".. 1)).. ", " .. tostring(instance.parameters:getString("Method".. 2)).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Indicator[1] = core.indicators:create("AVERAGES", source.close, instance.parameters:getString("Method".. 1), FRAME, false );
        Indicator[2] = core.indicators:create("AVERAGES", source.close, instance.parameters:getString("Method".. 2), FRAME+STEP, false );
        Indicator[3] = core.indicators:create("AVERAGES", source.close, instance.parameters:getString("Method".. 3), FRAME-STEP, false );
    
        first = math.max( Indicator[2].DATA:first(), Indicator[3].DATA:first() );
        MA[1] = instance:addStream("MA"..1, core.Line, name, "Cental", instance.parameters:getColor("color".. 1), first);
		MA[1]:setWidth(instance.parameters:getInteger("width".. 1));
        MA[1]:setStyle(instance.parameters:getInteger("style".. 1));
		
		MA[2] = instance:addStream("MA"..2, core.Line, name, "Channel", instance.parameters:getColor("color".. 2), first);
		MA[2]:setWidth(instance.parameters:getInteger("width".. 2));
        MA[2]:setStyle(instance.parameters:getInteger("style".. 2));
		
		MA[3] = instance:addStream("MA"..3, core.Line, name, "MA", instance.parameters:getColor("color".. 3), first);
		MA[3]:setWidth(instance.parameters:getInteger("width".. 3));
        MA[3]:setStyle(instance.parameters:getInteger("style".. 3));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not  source:hasData(period) then
	return;
	end	
	
	Indicator[1]:update(mode);
	Indicator[2]:update(mode);
	Indicator[3]:update(mode);
	
        MA[1][period] = Indicator[1].DATA[period];
		 MA[2][period] = Indicator[2].DATA[period];
		  MA[3][period] = Indicator[3].DATA[period];
    
end

