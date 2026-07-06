-- Id: 14390

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62387

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
    indicator:name("Trend Filter");
    indicator:description("Trend Filter");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Caclulation");
	indicator.parameters:addInteger("cp1", "Trend CCI Period","", 50);
	indicator.parameters:addInteger("cp2", "Signal CCI Period","", 14);

	
	indicator.parameters:addGroup("Style");
    color = core.colors();
	indicator.parameters:addColor("color1", "Trend CCI in OB Zone, Positive Signal CCI", "Color", color.Lime);
	indicator.parameters:addColor("color2", "Positive Trend CCI, Positive Signal CCI", "Color", color.LimeGreen);
	indicator.parameters:addColor("color3", "Trend CCI in OS Zone, Negative Signal CCI", "Color", color.Red);
	indicator.parameters:addColor("color4", "Negative Trend CCI, Negative Signal CCI", " Color", color.Brown);
    indicator.parameters:addColor("color5", "Neutral Color", " Color", color.Gray);
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local cp1, cp2;

local first;
local source = nil; 
-- Streams block
local oscillator = nil;
local CCI1,CCI2;
-- Routine
function Prepare(nameOnly)
    cp1 = instance.parameters.cp1;
    cp2 = instance.parameters.cp2;
    
    source = instance.source;
	
	CCI1 = core.indicators:create("CCI", source, cp1);
	CCI2 = core.indicators:create("CCI", source, cp2);
    first = math.max(CCI1.DATA:first(),CCI2.DATA:first());

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(cp1) .. ", " .. tostring(cp2) .. ")";
    instance:name(name); 
	
    if   (nameOnly) then
        return;
    end
        oscillator = instance:addStream("oscillator", core.Bar, name, "oscillator", instance.parameters.color5, first);	 
		oscillator:addLevel(0);
        oscillator:addLevel(1);		
		
		oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 
		
    CCI1:update(mode);
	CCI2:update(mode);
	
	 if period < first then
	 return;
	 end
	
	if CCI1.DATA[period]>100 and CCI2.DATA[period] > 0 then
	oscillator[period]=1;
	oscillator:setColor(period,  instance.parameters.color1);
	elseif CCI1.DATA[period]<-100 and CCI2.DATA[period] < 0 then
	oscillator[period]=1;
	oscillator:setColor(period,  instance.parameters.color3);
	elseif CCI1.DATA[period]> 0  and CCI2.DATA[period] > 0 then
	oscillator[period]=1;
	oscillator:setColor(period,  instance.parameters.color2);
	elseif CCI1.DATA[period]< 0 and CCI2.DATA[period] < 0   then
	oscillator[period]=1;
	oscillator:setColor(period,  instance.parameters.color4);
	else
	oscillator[period]=1;
	oscillator:setColor(period,  instance.parameters.color5);
	end
	
	
     
end
 