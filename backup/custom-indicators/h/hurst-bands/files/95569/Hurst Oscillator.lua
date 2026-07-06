-- Id: 12363
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61075

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Hurst Oscillator");
    indicator:description("Hurst Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length", "Length", "Length", 10, 1, 2000);
    indicator.parameters:addInteger("smooth", "MA Length for Close", "MA Length for Close", 1, 1, 2000);
	 
 
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color", "Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local length;
local InnerValue;
local OuterValue;
local ExtremeValue;
local showClosingPriceLine;
local showExtremeBands;
local smooth;
local first;
local source = nil;
 local displacement;
local FlowValue;
-- Streams block
 
local FlowPrice = nil;
local MVA;
local CMA;
local showOuterBand;
local showInnerBand;
-- Routine
function Prepare(nameOnly)
    length = instance.parameters.length; 
	smooth = instance.parameters.smooth;
    InnerValue = instance.parameters.InnerValue;
    OuterValue = instance.parameters.OuterValue;
    ExtremeValue = instance.parameters.ExtremeValue; 
	displacement = (length / 2) + 1
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(length).. ", " .. tostring(smooth)  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        MVA = core.indicators:create("MVA", source.median,length );
        first = MVA.DATA:first()+displacement;
        CMA= instance:addInternalStream(0, 0); 
		
		FlowValue= instance:addInternalStream(0, 0)
		SMA= core.indicators:create("MVA", FlowValue,smooth );
		
        FlowPrice = instance:addStream("FlowPrice", core.Line, name .. ".FlowPrice", "FlowPrice", instance.parameters.color, SMA.DATA:first());
    FlowPrice:setPrecision(math.max(2, instance.source:getPrecision()));
		FlowPrice:setWidth(instance.parameters.width);
        FlowPrice:setStyle(instance.parameters.style);
		 
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


    MVA:update(mode);
    if period  < first or not source:hasData(period) then
	return;
	end
	
	
	CMA[period]= MVA.DATA[period-displacement];
	
	 
	 if source.close[period] > source.close[period-1] then
	 FlowValue[period]=  source.high[period];
	 elseif source.close[period] < source.close[period-1] then
	 FlowValue[period]= source.low [period]
	 else
	 FlowValue[period]=source.median[period]
	 end
	 
	 
     SMA:update(mode); 
	 if period < SMA.DATA:first() then
	 return;
	 end

        FlowPrice[period] = SMA.DATA[period]-CMA[period];
   
end

