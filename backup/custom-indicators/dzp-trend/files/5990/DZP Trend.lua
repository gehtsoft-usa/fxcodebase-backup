-- Id: 2291
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2654


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
    indicator:name("DZP Trend");
    indicator:description("DZP Trend");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
   
    indicator.parameters:addInteger("Frame", "EMA Period", "", 20,0,200);
	indicator.parameters:addInteger("Shift", "Shift", "", 22,0,200);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addBoolean("Histogram", "Histogram", "", false);
    indicator.parameters:addColor("DZP_UP", "Color of DZP UP", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DZP_DN", "Color of DZP DN", "", core.rgb(255, 0, 0));
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;
local Shift;
local Histogram;

local first;
local source = nil;

-- Streams block
local DZPUP = nil;
local DZPDN = nil;
local EMA=nil;

local A,B,DZP;

-- Routine
function Prepare(nameOnly)
    Histogram=instance.parameters.Histogram; 
    Shift=instance.parameters.Shift;
    Frame=instance.parameters.Frame;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() ..  ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	A=instance:addInternalStream (first, 0);
	B=instance:addInternalStream (first, 0);
		
	
	EMA = core.indicators:create("EMA", source, Frame);
	
	if Histogram then 
	DZP=instance:addInternalStream (first, 0);
    DZPUP = instance:addStream("DZPUP", core.Bar, name .. ".UP", "UP", instance.parameters.DZP_UP, EMA.DATA:first());
    DZPDN = instance:addStream("DZPDN", core.Bar, name .. ".DN", "DN", instance.parameters.DZP_DN, EMA.DATA:first());
	DZPUP:setPrecision(math.max(2, instance.source:getPrecision()));
	DZPDN:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	DZP = instance:addStream("DZP", core.Line, name .. ".DZP", "DZP", instance.parameters.DZP_UP,EMA.DATA:first());
	DZP:setPrecision(math.max(2, instance.source:getPrecision()));
	end
	
	
	
	

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)      
    if period >= first and source:hasData(period) then
		
			 EMA:update(mode);  
			 if period < EMA.DATA:first() or period <  (EMA.DATA:first()+Shift)  then	
			 return;
			 end
			 
			 
			   A[period]= (source[period] - source[period -Shift])/ source[period -Shift];
               B[period]=(EMA.DATA[period]-EMA.DATA[period-Shift])/EMA.DATA[period-Shift];
               DZP[period]=(A[period]-B[period])*100;
			 
			 
			    if  Histogram then
					if DZP[period] > DZP[period-1] then 
					DZPUP[period]=DZP[period];
					DZPDN[period]=nil;
					else
					DZPDN[period]=DZP[period];
					DZPUP[period]=nil;
					end
				end	
	  end
   

end