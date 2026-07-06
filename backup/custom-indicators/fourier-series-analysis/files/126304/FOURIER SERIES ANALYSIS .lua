-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68456

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("FOURIER SERIES ANALYSIS ");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Fundamental", "Fundamental", "", 20, 1, 2000);
    indicator.parameters:addDouble("Bandwidth", "Bandwidth", "", 0.1 ); 
 
	
	indicator.parameters:addGroup("Wave Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("ROC Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block


local L1, G1, S1, L2, G2, S2, L3,G3, S3;
local Fundamental,Bandwidth; 
local first;
local source = nil;
local BP1,BP2,BP3;
local Q1,Q2,Q3;
local TWOPI; 
local Wave,ROC;

-- Routine
 function Prepare(nameOnly)
 
    Fundamental = instance.parameters.Fundamental;
	Bandwidth = instance.parameters.Bandwidth;
	
	
	local Parameters= Fundamental .. ", " .. Bandwidth;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	TWOPI = 2 * 3.1415926;  
 

	L1 = math.cos(TWOPI / Fundamental); 
	G1 = math.cos(Bandwidth*TWOPI / Fundamental); 
	S1 = 1 / G1 - math.sqrt(1 / (G1*G1) - 1); 
	L2 = math.cos(TWOPI / (Fundamental / 2));
	G2 = math.cos(Bandwidth*TWOPI / (Fundamental / 2));
	S2 = 1 / G2 - math.sqrt(1 / (G2*G2) - 1);
	L3 = math.cos(TWOPI / (Fundamental / 3)); 
	G3 = math.cos(Bandwidth*TWOPI / (Fundamental / 3));
	S3 = 1 / G3 - math.sqrt(1 / (G3*G3) - 1);
	
 

    
			
    source = instance.source;
    first=source:first()+2;
	
	
	BP1 = instance:addInternalStream(0, 0);
	BP2 = instance:addInternalStream(0, 0);
	BP3 = instance:addInternalStream(0, 0);
	
	Q1 = instance:addInternalStream(0, 0);
	Q2 = instance:addInternalStream(0, 0);
	Q3 = instance:addInternalStream(0, 0);

  
	Wave = instance:addStream("Wave" , core.Line, "Wave","Wave",instance.parameters.color1, first);
	Wave:setWidth(instance.parameters.width1);
    Wave:setStyle(instance.parameters.style1);
    Wave:setPrecision(math.max(2, source:getPrecision()));
	
	ROC= instance:addStream("ROC" , core.Line, "ROC","ROC",instance.parameters.color2, first);
	ROC:setWidth(instance.parameters.width2);
    ROC:setStyle(instance.parameters.style2);
    ROC:setPrecision(math.max(2, source:getPrecision()));
end

-- Indicator calculation routine
function Update(period ) 
	
	if period < first then
	return;
	end
	
	
	
	
	--Fundamental Band-Pass
	BP1[period] = 0.5*(1 - S1)*(source[period] - source[period-2]) + L1*(1 + S1)*BP1[period-1] - S1*BP1[period-2];
	if period <= 3 then BP1[period] = 0; end
	--Fundamental Quadrature 
	Q1[period] = (Fundamental / 6.28)*(BP1[period] - BP1[period-1]);
	if period <= 4 then Q1[period] = 0; end

	
	
    --Second Harmonic Band-Pass
	BP2[period] = 0.5*(1 - S2)*(source[period] - source[period-2]) + L2*(1 + S2)*BP2[period-1] - S2*BP2[period-2]; 
	if period <= 3 then BP2[period] = 0; end
	
	--Second Harmonic Quadrature 
	Q2[period] = (Fundamental / 6.28)*(BP2[period] - BP2[period-1]); 
	if period <= 4 then Q2[period] = 0; end
	
    --Third Harmonic Band-Pass 
	BP3[period] = 0.5*(1 - S3)*(source[period] - source[period-2]) + L3*(1 + S3)*BP3[period-1] - S3*BP3[period-2];
    if period <= 3 then BP2[period] = 0; end

   --Third Harmonic Quadrature 
    Q3[period] = (Fundamental / 6.28)*(BP3[period] - BP3[period-1]);
   if period <= 4 then Q3[period] = 0; end
   
   
   if period < first +Fundamental  then
	return;
	end

	--Sum power of each harmonic at each bar over the Fundamental period 
	local P1 = 0; 
	local P2 = 0; 
	local P3 = 0;
	
	for count = 0, Fundamental - 1 ,1 do
	P1 = P1 + BP1[period-count]*BP1[period-count] + Q1[period-count]*Q1[period-count];  
	P2 = P2 + BP2[period-count]*BP2[period-count] + Q2[period-count]*Q2[period-count];
	P3 = P3 + BP3[period-count]*BP3[period-count] + Q3[period-count]*Q3[period-count];
	end

	
	--Add the three harmonics together using their relative amplitudes 
	if P1 ~= 0 then
	Wave[period] = BP1[period] +  math.sqrt(P2 / P1)*BP2[period] +  math.sqrt(P3 / P1)*BP3[period];
	end
 
 
 
 
   -- Optional cyclic trading signal 
--   Rate of change crosses zero at cyclic turning points 
     ROC[period] = (Fundamental / 12.57)*(Wave[period] - Wave[period-2]);
				  
end

 