-- Id: 1355
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1908

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
    indicator:name("John Ehler's Squelch");
    indicator:description("John Ehler's Squelch");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Squelch", "Squelch", "Squelch", 20);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Squelch_color", "Color of Squelch Line", "Color of Squelch Line", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Signal_color", "Color of Signal Line", "Color of Signal LIne", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Squelch;

local first;
local source = nil;

-- Streams block
local S1 = nil;

local Value1= nil;
local Value2= nil;
local Value3= nil;
local Value4= nil;
local Inphase = nil;
local Quad = nil;
local DeltaPhase = nil;
local Phase=nil;
local InstPeriod=nil;

local line_id=1;

-- Routine
function Prepare(nameOnly)
    Squelch = instance.parameters.Squelch;
    source = instance.source;
    first = source:first();
	
	Value1= instance:addInternalStream(6, 0);
	Value2= instance:addInternalStream(6, 0);
    Value3= instance:addInternalStream(6, 0);
	Value4= instance:addInternalStream(40, 0);
	Inphase= instance:addInternalStream(6, 0);
	Quad= instance:addInternalStream(6, 0);
    DeltaPhase= instance:addInternalStream(6, 0);		
	Phase= instance:addInternalStream(6, 0);
	InstPeriod = instance:addInternalStream(40, 0)

    local name = profile:id() .. "(" .. source:name() .. ", " .. Squelch .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    S1 = instance:addStream("S1", core.Line, name, "S1", instance.parameters.Squelch_color, 40);
    S1:setPrecision(math.max(2, instance.source:getPrecision()));
	S1:setWidth(instance.parameters.width);
    S1:setStyle(instance.parameters.style);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

core.host:execute("drawLine", line_id, source:date(first), Squelch, source:date(period), Squelch, instance.parameters.Signal_color);


S1[period]=nil;
    
    if period >= 6 then 

		  
		Value1[period]=(source.median[period]) - source.median[period-6];
		Value2[period]= Value1[period-3];
		Value3[period]=0.75*(Value1[period]-Value1[period-6]) + 0.25*(Value1[period-2]-Value1[period-4]);		  
		
		Inphase[period]= 0.33 * Value2[period] + (0.67 * Inphase[period-1]);
		Quad[period]= 0.2 * Value3[period] + ( 0.8 * Quad[period-1]);	

		
       -- {Use ArcTangent to compute the current phase}
        if math.abs(Inphase[period] +Inphase[period-1]) > 0 then
         Phase[period]=(180/3.1415)*math.atan((math.abs(Quad[period]+Quad[period-1]) / (Inphase[period]+Inphase[period-1])));
		 end
		
	
		   
		if Inphase[period]<0 and Quad[period]>0 then
		Phase[period]= 180-Phase[period];
		elseif Inphase[period]<0 and Quad[period]<0 then
		Phase[period] = 180+Phase[period];
		elseif Inphase[period]>0 and Quad[period]<0 then
		Phase[period] = 360-Phase[period]
		else
		Phase[period]= Phase[period];
		end		
		
		
	--{Compute a differential phase, resolve phase wraparound, and limit delta phase errors}
	    DeltaPhase[period] = Phase[period-1] - Phase[period];
		if Phase[period-1] < 90 and Phase[period] > 270 then 
		DeltaPhase[period] = 360 + Phase[period-1] - Phase[period];
		end
		
		if DeltaPhase[period] < 1 then 
		DeltaPhase[period] = 1;
		elseif DeltaPhase[period] > 60 then
		DeltaPhase[period] = 60;
		end
			
		InstPeriod[period]= 0;       
        Value4[period] = 0;
		 
		local count;
		
		if period >= 40 then
		
			for  count = 0, 40,1 do
			Value4[period] = Value4[period] + DeltaPhase[period-count];
				
				if Value4[period] > 360 and InstPeriod[period] == 0 then
				InstPeriod[period] = count;
				break;
				end				
			end			
				
				if InstPeriod[period] == 0 then 
				InstPeriod[period] = InstPeriod[period-1];
				end
				
				S1[period]= 0.25*InstPeriod[period] + 0.75*S1[period-1];
			
			
		end	
		 
	end	

end


