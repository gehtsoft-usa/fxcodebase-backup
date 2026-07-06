-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23283

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
    indicator:name("MESA Adaptive Moving Average");
    indicator:description("MESA Adaptive Moving Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addDouble("FastLimit", "FastLimit", "FastLimit", 0.5, 0, 1);
    indicator.parameters:addDouble("SlowLimit", "SlowLimit", "SlowLimit", 0.05, 0, 1);
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("FAMA_color", "Color of FAMA", "Color of FAMA", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Fwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Fstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Fstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("MAMA_color", "Color of MAMA", "Color of MAMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Mwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Mstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Mstyle", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local FastLimit;
local SlowLimit;

local first;
local source = nil;

-- Streams block
local FAMA = nil;
local MAMA = nil;

local Smooth; 
local 	Detrender; 
local 	I1; 
local 	Q1; 
local 	jI; 
local 	jQ; 
local 	I2; 
local 	Q2; 
local 	Re; 
local 	Im; 
local 	Period; 
local 	SmoothPeriod; 
local 	Phase; 
local 	MAMA; 
 local  FAMA; 

-- Routine
function Prepare(nameOnly) 
    FastLimit = instance.parameters.FastLimit;
    SlowLimit = instance.parameters.SlowLimit;
    source = instance.source;
    first = source:first()+5;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(FastLimit) .. ", " .. tostring(SlowLimit) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Smooth= instance:addInternalStream(0, 0);
	Detrender= instance:addInternalStream(0, 0);
	I1= instance:addInternalStream(0, 0);
	Q1= instance:addInternalStream(0, 0);
	jI= instance:addInternalStream(0, 0);
	jQ= instance:addInternalStream(0, 0);
	I2= instance:addInternalStream(0, 0);
	Q2= instance:addInternalStream(0, 0);
	Re= instance:addInternalStream(0, 0);
	Im= instance:addInternalStream(0, 0);
	Period= instance:addInternalStream(0, 0);
	SmoothPeriod= instance:addInternalStream(0, 0);
	Phase= instance:addInternalStream(0, 0);	
	
 
        FAMA = instance:addStream("FAMA", core.Line, name .. ".FAMA", "FAMA", instance.parameters.FAMA_color, first);
		FAMA:setWidth(instance.parameters.Fwidth);
        FAMA:setStyle(instance.parameters.Fstyle);
        MAMA = instance:addStream("MAMA", core.Line, name .. ".MAMA", "MAMA", instance.parameters.MAMA_color, first);
		MAMA:setWidth(instance.parameters.Mwidth);
        MAMA:setStyle(instance.parameters.Mstyle);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

	Detrender[period]=0; 
	I1[period]=0;  
	Q1[period]=0;  
	jI[period]=0;  
	jQ[period]=0;  
	I2[period]=0;  
	Q2[period]=0;  
	Re[period]=0;  
	Im[period]=0;  
	Period[period]=0;  
	SmoothPeriod[period]=0;  
	Phase[period]=0;  



    if period <= first or not  source:hasData(period) then
	return;
	end
		
	Smooth[period] = (4*source[period] + 3*source[period-1] + 2*source[period-2] + source[period-3]) / 10;
	
	Detrender[period] = (0.0962*Smooth[period] + 0.5769*Smooth[period-2] - 0.5769*Smooth[period-4] - 0.0962*Smooth[period-6])*(0.075*Period[period-1] + 0.54);

	
	Q1[period] = (0.0962*Detrender[period] + 0.5769*Detrender[period-2] - 0.5769*Detrender[period-4] - 0.0962*Detrender[period-6])*(0.075*Period[period-1] + 0.54);
    I1[period] = Detrender[period-3];

	
	jI[period]  = (0.0962*I1[period]  + 0.5769*I1[period-2] - 0.5769*I1[period-4] - 0.0962*I1[period-6])*(0.075*Period[period-1] + 0.54);
	jQ[period]  = (0.0962*Q1[period]  + 0.5769*Q1[period-2] - 0.5769*Q1[period-4] - 0.0962*Q1[period-6])*(0.075*Period[period-1] + 0.54);

	
	I2[period]  = I1[period]  - jQ[period] ;
	Q2[period]  = Q1[period]  + jI[period] ;

	
	I2[period]  = 0.2*I2[period]  + 0.8*I2[period-1];
	Q2[period]  = 0.2*Q2[period]  + 0.8*Q2[period-1];

	
	Re[period]  = I2[period] *I2[period-1] + Q2[period]*Q2[period-1];
	Im[period]  = I2[period] *Q2[period-1] - Q2[period]*I2[period-1];
	Re[period]  = 0.2*Re[period]  + 0.8*Re[period-1];
	Im[period]  = 0.2*Im[period]  + 0.8*Im[period-1];
	 
	--if Im[period] ~= 0 and Re[period] ~= 0 then Period[period] = 360/ArcTangent(Im[period]/Re[period]);
	if Im[period] ~= 0 and Re[period] ~= 0 then Period[period] = 360/math.atan2(Im[period],Re[period]); end
 
	
	if Period[period] > 1.5*Period[period-1] then Period[period] = 1.5*Period[period-1]; end
	if Period[period] < 0.67*Period[period-1] then Period[period] = 0.67*Period[period-1]; end
	
	if Period[period] < 6 then Period[period] = 6; end
	if Period[period] > 50 then Period[period] = 50;  end
	 Period[period] = 0.2*Period[period] + 0.8*Period[period-1];	
	 SmoothPeriod[period] = 0.33*Period[period] + 0.67*SmoothPeriod[period-1];
     
	--if I1[period] ~= 0 then Phase[period] = (ArcTangent(Q1[period] / I1[period])) end;
	if I1[period] ~= 0 then Phase[period] = (math.atan2(Q1[period] , I1[period])) end;
	 
	
	local DeltaPhase = Phase[period-1] - Phase[period];
	
	if  DeltaPhase < 1 then DeltaPhase = 1; end
	
	 local alpha = FastLimit / DeltaPhase;
	
	if alpha < SlowLimit then alpha = SlowLimit; end
	
	MAMA[period] = alpha*source[period] + (1 - alpha)*MAMA[period-1];
    FAMA[period] = 0.5*alpha*MAMA[period] + (1 - 0.5*alpha)*FAMA[period-1];
	
end

