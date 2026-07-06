-- Id: 20994
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65940

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

function Init()
    indicator:name("MyRSI Indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("SmoothLength", "SmoothLength", "", 14, 2, 2000);
    indicator.parameters:addInteger("RSILength", "RSILength", "", 10, 2, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local SmoothLength;
local RSILength; 
local first;
local source = nil;
 
 
local a1, b1, c2,c3, c1;
local Filt, Mom;
local Oscillator;  

-- Routine
 function Prepare(nameOnly)   
 
 
    SmoothLength = instance.parameters.SmoothLength;
	RSILength = instance.parameters.RSILength;
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  SmoothLength .. ", " ..  RSILength .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

   Filt = instance:addInternalStream(0, 0);
   Mom = instance:addInternalStream(0, 0);
			
    source = instance.source;
    first=source:first()+RSILength;
	
	
	--Compute Super Smoother coefficients once	
	a1 = math.exp(-1.414*3.14159 / (SmoothLength));
	b1 = 2*a1*math.cos(1.414*180 / (SmoothLength));
	c2 = b1;
	c3 = -a1*a1;
	c1 = 1 - c2 - c3;
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first+2+RSILength);
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)
 
	
    if period < first then
	return;
	end
	
	
	 --Create half dominant cycle Momentum
    Mom[period] = source[period] - source[period-RSILength + 1];
	
	
	
	if period < first+2 then
	return;
	end
	
    --SuperSmoother Filter
    Filt[period] = c1*(Mom[period] + Mom[period-1]) / 2 + c2*Filt[period-1] + c3*Filt[period-2];

	
	if period < first+3+RSILength then
	return;
	end
	
	--Accumulate "Closes Up" and "Closes Down"
	local CU = 0;
	local CD = 0;
	for count = 1,  (RSILength), 1 do
		if (Filt[period-count+1] - Filt[period-count])  > 0 then
		CU = CU + math.abs( Filt[period-count] - Filt[period-count + 1]);
		end
		
		if (Filt[period-count+1] - Filt[period-count])  < 0 then
		CD = CD + math.abs(Filt[period-count + 1] -	Filt[period-count]);
		end
	end
	
	local MyRSI=0;
	
	if (CU + CD ~= 0) then MyRSI = (CU - CD) / (CU + CD); end
    --Limit RocketRSI output to +/- 3 Standard Deviations
    if MyRSI > .999 then MyRSI = .999; end
    if MyRSI < -.999 then MyRSI = -.999; end
    --Apply Fisher Transform to establish Gaussian Probability Distribution
     Oscillator[period]= 0.5*math.log((1 + MyRSI) / (1 - MyRSI));
				  
end
