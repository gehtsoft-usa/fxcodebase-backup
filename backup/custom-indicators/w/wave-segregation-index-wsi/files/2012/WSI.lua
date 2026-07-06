-- Id: 714
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1060

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
    indicator:name("Wave Segregation Index");
    indicator:description("Wave Segregation Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CCIP", "CCI Period", "CCI Period", 100,2,2000);
    indicator.parameters:addInteger("ADXP", "ADX Period", "ADX Period", 100,2,2000);
	indicator.parameters:addDouble("Level", "Level", "Level", 1.5);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("UP", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DOWN", "Color of DOWN", "Color of DOWN", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local CCIP;
local ADXP;

local first;
local source = nil;

-- Streams block
local UP = nil;
local DOWN = nil;
local WSI = nil;
local CCI=nil;
local ADX=nil;
local UPC,DOWNC;
local Level;
-- Routine
function Prepare(nameOnly)
    CCIP = instance.parameters.CCIP;
    ADXP = instance.parameters.ADXP;
	Level= instance.parameters.Level;
	
	UPC = instance.parameters.UP;
    DOWNC = instance.parameters.DOWN;
    source = instance.source;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. CCIP .. ", " .. ADXP .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	WSI = instance:addInternalStream(0,0); 
	
	CCI = core.indicators:create("CCI", source, CCIP);
	ADX = core.indicators:create("ADX", source, ADXP);
	
	first = math.max(CCI.DATA:first(), ADX.DATA:first());
    UP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", UPC, first);
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
    DOWN = instance:addStream("DOWN", core.Bar, name .. ".DOWN", "DOWN", DOWNC, first);
    DOWN:setPrecision(math.max(2, instance.source:getPrecision()));
	UP:addLevel(Level);
	DOWN:addLevel(-Level);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	
	
	   CCI:update(mode);
	   ADX:update(mode);
	
	   WSI[period]=(CCI.DATA[period]*source.typical[period]* ADX.DATA[period]) / 1000;
	  
	    if WSI[period] >= 0  then
	    UP[period] = WSI[period];
		else
        DOWN[period] = WSI[period];
		end 
 
end

