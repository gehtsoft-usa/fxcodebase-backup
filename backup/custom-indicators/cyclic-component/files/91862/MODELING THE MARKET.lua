-- Id: 10818

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60180

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
    indicator:name("MODELING THE MARKET");
    indicator:description(" MODELING THE MARKET");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Length", "Length", 20);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Color", "Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Length;

local first;
local source = nil;
local SMA;
-- Streams block
local CC,IT;
local alpha,HP,Slope;
-- Routine
function Prepare(nameOnly)
    Length = instance.parameters.Length;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Length) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		HP = instance:addInternalStream(0, 0);
		 SMA = core.indicators:create("MVA", source, Length);
		alpha= (1 - math.sin (2* math.pi  / Length)) / math.cos(2* math.pi / Length);
		first = source:first();
		
		IT= instance:addInternalStream(0, 0);
		CC= instance:addInternalStream(0, 0);
		Slope = instance:addInternalStream(0, 0);
	
        MM = instance:addStream("MM", core.Line, name, "MM", instance.parameters.Color,first+ Length);
		MM:setWidth(instance.parameters.width);
        MM:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


   	if period == source:first() then
	CC[period]=0;
	return;
	elseif period < source:first()+3 then	
	CC[period]=source[period]-source[period-1];
	return; 
	end
	

    if period < source:first()+1 then
	return;
	end
   
    HP[period] = 0.5*(1 + alpha)*(source[period] - source[period-1]) + alpha*HP[period-1];
	 
    CC[period]  = (HP[period] + 2*HP[period-1] + 2*HP[period-2] + HP[period-3]) / 6;
	
	SMA:update(mode);
	
	if period < SMA.DATA:first()  then	
	return;
	end
	
	Slope[period]= source[period]-source[period- Length+1];	

	local SmoothSlope = (Slope[period] + 2* Slope [period-1] + 2* Slope [period-2] + Slope[period-3])/6; 
	IT[period]  = SMA.DATA[period] + 0.5 *SmoothSlope;
    
    MM[period]= IT[period]+CC[period];
end

