-- Id: 12287
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=61032


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
    indicator:name("Roofing Filter");
    indicator:description("Roofing Filter");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addColor("Filt_color", "Line Color", "Line Color", core.rgb(255, 0, 0));
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
local alpha1,a1,b1,c2,c3,c1; 
-- Streams block
local Filt = nil;
local HP;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+2;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	--alpha1 = (math.cos(.707*360 / 48) + math.sin (.707*360 / 48)  -  1) / math.cos(.707*360 / 48); 
	
	alpha1 = (math.cos((.707*360 / 48) * math.pi / 180) + 
                  math.sin((.707*360 / 48) * math.pi / 180) - 1) / 
                  math.cos((.707*360 / 48) * math.pi / 180);
				  
	a1 = math.exp(-1.414*3.14159 / 10); 
	 b1 = 2*a1*math.cos(1.414*180 / 10);
	 c2 = b1;
	 c3 = -a1*a1;
	 c1 = 1 - c2 - c3;
	
	HP = instance:addInternalStream(0, 0);

    
        Filt = instance:addStream("RoofingFilter", core.Line, name, "Roofing Filter", instance.parameters.Filt_color, first);
    Filt:setPrecision(math.max(2, instance.source:getPrecision()));
		Filt:setWidth(instance.parameters.width);
        Filt:setStyle(instance.parameters.style);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first then
	return;
	end
	
	
	--Highpass filter cyclic components whose periods are shorter than 48 bars

HP[period]  =  (1  -   alpha1   /  2)*(1  - alpha1  /  2)*(source[period]  -  2*source[period-1]  +  source[period-2])  +  2*(1  -alpha1)*HP[period-1] - (1 - alpha1)*(1 - alpha1)*HP[period-2];
 
--Smooth with a Super Smoother Filter  

      Filt[period]  = c1*(HP[period] + HP[period-1]) / 2  + c2*Filt[period-1] + c3*Filt[period-2];
 
end

