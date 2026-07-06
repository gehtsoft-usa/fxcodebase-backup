-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=5275
-- Id: 4329

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Advance Trend Pressure");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("Cut", "Cutoff Period", "", 14);
	
    indicator.parameters:addGroup("Style");  
	indicator.parameters:addColor("Out_color", "Color of Sum", "Color of Sum", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;

-- Streams block
local Out;
local Cut;

-- Routine
function Prepare(nameOnly)
    Cut = instance.parameters.Cut;
    

    source = instance.source;
    first = source:first()+Cut;

    local name = profile:id() .. "(" .. source:name()  .. ", " .. Cut .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end

	Out= instance:addStream("Out", core.Line, name .. ".Out", "Out", instance.parameters.Out_color, first);
    Out:setPrecision(math.max(2, instance.source:getPrecision()));
	Out:setWidth(instance.parameters.width);
	Out:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period >= first and source:hasData(period) then
	

	local SumUp=0;
	local SumDown=0;
	local i=-1;

	

	
			while true  do
			
								i = i+1;				
								if source.close[period-i] >   source.open[period-i]   then
								SumUp= SumUp + (source.close[period-i] - source.open[period-i]);
								SumUp= SumUp +  (source.open[period-i] - source.low[period-i]);
								SumDown= SumDown+ (source.high[period-i] - source.close[period-i]) ;
												
								end
												
								if source.close[period-i] <   source.open[period-i] then 
								SumDown= SumDown + ( source.open[period-i] - source.close[period-i] );
								SumDown=SumDown + ( source.high[period-i]- source.open[period-i]) ;
								SumUp= SumUp + ( source.close[period-i]- source.low[period-i])  ;
								end
						
						

				if  i >= Cut then
				 break;
				end		
			end
       
		Out[period]=   SumUp  -  SumDown;
    end
end

