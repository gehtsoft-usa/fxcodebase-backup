-- Id: 7426
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23534


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Alternative Balance of Market Power");
    indicator:description("Balance of Market Power");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
      indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Smoothing Period", "Period", 14);
	indicator.parameters:addBoolean("Show", "Show Raw Data", "Show Raw Data", true);
	
	  indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BMP_color", "Color of BMP", "Color of BMP", core.rgb(128, 128, 128));
		indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
		indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local MA;
local first;
local source = nil;
local Show;
-- Streams block
local BMP = nil;
local Signal = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Show= instance.parameters.Show;
    source = instance.source;
	
	
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	
	    if Show then
        BMP = instance:addStream("BMP", core.Line, name .. ".BMP", "BMP", instance.parameters.BMP_color, source:first());
		BMP:setWidth(instance.parameters.width1);
        BMP:setStyle(instance.parameters.style1);
		else
		BMP = instance:addInternalStream( source:first(), 0);
		end
		
		 MA = core.indicators:create("MVA",BMP , Period);
        Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_color, MA.DATA:first());
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
		
		BMP:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;	
	end

local THL=source.high[period]-source.low[period];

if THL == 0 then
return;
end
 
 
local BuRBoO=(source.high[period]-source.open[period])/THL;
local BuRBoC=(source.close[period]-source.low[period])/THL;
local BuRBoOC;
if source.close[period] >source.open[period] then
BuRBoOC=(source.close[period]-source.open[period])/THL;
else
BuRBoOC=0;
end




local BeRBoO=(source.open[period]-source.low[period])/THL;
local BeRBoC=(source.high[period]-source.close[period])/THL;
 
local BeRBoOC;
if source.close[period] >source.open[period] then
BeRBoOC=0;
else
BeRBoOC=(source.open[period]-source.close[period])/THL;
end

 MA:update(mode);
 
 
        BMP[period] = (BuRBoO+BuRBoC+BuRBoOC)/3 - (BeRBoO+BeRBoC+BeRBoOC)/3;
		
		if period <  MA.DATA:first() then
		return;
		end
		
		
        Signal[period] = MA.DATA[period];
   
end

