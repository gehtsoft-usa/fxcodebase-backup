-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71511

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

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("Ehlers Simple Window Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("length", "Period", "", 20, 1, 2000);
    indicator.parameters:addDouble("Divider", "Divider", "", 6.28,0.01, 1000);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("SU", "Strong Up Line Color", "", core.rgb(0,255, 0));
    indicator.parameters:addColor("U", "Up Line Color", "", core.rgb(0,100, 0));
    indicator.parameters:addColor("SD", "Strong Down Line Color", "", core.rgb(255,0 , 0));
    indicator.parameters:addColor("D", "Down Line Color", "", core.rgb(100,0 , 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Divider; 
local length; 
local first;
local source = nil;
 
local Oscillator;  
local filt1,filt2;
-- Routine
 function Prepare(nameOnly)   
 
    Divider= instance.parameters.Divider;
    length= instance.parameters.length;
	
	
	local Parameters= length  .. ", ".. Divider;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+length;
	
	filt= instance:addInternalStream(0, 0);
	MA1 = core.indicators:create("WMA", filt, length);
	MA2 = core.indicators:create("WMA", MA1.DATA, length);
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.SU, first );
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	slo= instance:addInternalStream(0, 0);
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end
	
	
	
 
   filt[period] = 0.0;
   local coef = 0.0;
   
   for i = 1, length, 1 do
    filt[period] = filt[period] + (source.close[period-i+1] - source.open[period-i+1]);
    coef = coef + 1;
   end	

    if coef ~= 0 then
    filt[period]= filt[period] / coef; 
    else
	filt[period]=0;
	end
	
	if period < first +length
	then
	return;
	end
	
	MA1:update(mode);
	
	if period < first +length*2
	then
	return;
	end
	
	MA2:update(mode);
	
    Oscillator[period] = (length / Divider) * (MA2.DATA[period] - MA2.DATA[period-1])
	slo[period]= Oscillator[period]-Oscillator[period-1];
 
	if slo[period]> 0	then	
	   if slo[period]> slo[period-1] then
	   Oscillator:setColor(period, instance.parameters.SU);
	   else
	   Oscillator:setColor(period, instance.parameters.U);	   
	   end
    else
	   if slo[period]< slo[period-1] then
	   Oscillator:setColor(period, instance.parameters.SD);	   
	   else
	   Oscillator:setColor(period, instance.parameters.D);	   
	   end	
	end
	 
end
 