-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71691

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Support that the service we provide to the community be continued onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Ehlers Hilbert Transformation");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator); 
	
	
	indicator.parameters:addGroup("1. Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0,255, 0)); 
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("2. Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255,0, 0)); 
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);	
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
 
local first;
local source = nil;
local InPhase,Quadrature; 
local Smooth,Detrender,Per,Q1,I1,jI,jQ,I2,Q2, Re, Im,SmoothPeriod ;

 
-- Routine
 function Prepare(nameOnly)   
 
 
 
	
	
	local Parameters= "";
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+3;

    Smooth= instance:addInternalStream(0, 0);
    Detrender= instance:addInternalStream(0, 0);
    Per= instance:addInternalStream(0, 0);
	Q1= instance:addInternalStream(0, 0);
	I1= instance:addInternalStream(0, 0);
	jI= instance:addInternalStream(0, 0);
	jQ= instance:addInternalStream(0, 0);
	I2= instance:addInternalStream(0, 0);
	Q2= instance:addInternalStream(0, 0);
	Re= instance:addInternalStream(0, 0);
	Im= instance:addInternalStream(0, 0);
	InPhase= instance:addInternalStream(0, 0);
    Quadrature= instance:addInternalStream(0, 0);
 
	Per = instance:addStream("InPhase" , core.Line, " Per"," Per",instance.parameters.color1, first+6+6);
	Per:setWidth(instance.parameters.width1);
    Per:setStyle(instance.parameters.style1);
    Per:setPrecision(math.max(2, source:getPrecision()));
	
	SmoothPeriod= instance:addStream("SmoothPeriod" , core.Line, " SmoothPeriod"," SmoothPeriod",instance.parameters.color2, first+6+6);
	SmoothPeriod:setWidth(instance.parameters.width2);
    SmoothPeriod:setStyle(instance.parameters.style2);
    SmoothPeriod:setPrecision(math.max(2, source:getPrecision()));
	
	
 
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end
	 
    Hilbert(period);
				  
end


function Hilbert(period)

   
   Smooth[period] = (4 * source[period] + 3 * source[period- 1] + 2 * source[period- 2] + source[period- 3]) / 10;
   
   
	if period < first+6
	then
	return;
	end
	
   Detrender[period] = (0.0962 * Smooth[period]        + 0.5769 * Smooth[period- 2]     -
                         0.5769 * Smooth[period- 4]    - 0.0962 * Smooth[period- 6])    * (0.075 * Per[period- 1] + 0.54);

			 
			 
	if period < first+6+6
	then
	return;
	end
	
--InPhase and Quadrature components                        
Q1[period]        = (0.0962 * Detrender[period]     + 0.5769 * Detrender[period- 2]  -
                0.5769 * Detrender[period- 4] - 0.0962 * Detrender[period-6]) * (0.075 * Per[period- 1] + 0.54);
I1[period]        = Detrender[period- 3];    
--Advance the phase of I1 and Q1 by 90 degrees
jI[period]        = (0.0962 * I1[period]            + 0.5769 * I1[period- 2]         -
                0.5769 * I1[period- 4]        - 0.0962 * I1[period - 6])        * (0.075 * Per[period- 1] + 0.54);
jQ[period]        = (0.0962 * Q1[period]            + 0.5769 * Q1[period- 2]         -
                0.5769 * Q1[period- 4]        - 0.0962 * Q1[period- 6])        * (0.075 * Per[period- 1] + 0.54);
--Phasor Addition
I2[period]        =  I1[period] - jQ[period];
Q2[period]        =  Q1[period] + jI[period];
--Smooth the I and Q components before applying the discriminator
I2[period]        =  0.2 * I2[period] + 0.8 * I2[period- 1];
Q2[period]        =  0.2 * Q2[period] + 0.8 * Q2[period- 1];
--Homodyne Discriminator
Re[period]        = I2[period] * I2[period]      + Q2[period] * Q2[period- 1];
Im[period]        = I2[period] * Q2[period- 1]  - Q2[period] * I2[period- 1];
Re[period]        = 0.2   * Re[period]      + 0.8   * Re[period- 1];
Im[period]        = 0.2   * Im[period]      + 0.8   * Im[period- 1];

local  rad2Deg = 180.0 / (4.0 * math.atan (1));

if(Im[period]~=0 and Re[period]~=0) then
Per[period]=360/(math.atan(Im[period]/Re[period])*rad2Deg ); 
else 
Per[period]= 0;
end


if(Per[period] > 1.5  * Per[period- 1]) then Per[period]     = 1.5  * Per[period- 1]; end
if(Per[period] < 0.67 * Per[period- 1]) then Per[period]     = 0.67 * Per[period- 1]; end
if(Per[period] < 6)                 then Per[period]     = 6;                 end
if(Per[period] > 50)                then Per[period]     = 50;                end

Per[period]          = 0.2  * Per[period] + 0.8  * Per[period- 1];
SmoothPeriod[period] = 0.33 * Per[period] + 0.67 * SmoothPeriod[period- 1];

InPhase[period]      = I1[period];
Quadrature[period]   = Q1[period];
	  
end 