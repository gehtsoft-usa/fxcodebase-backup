-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=74409

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("VOLUME FLOW INDICATOR");
    indicator:description("VOLUME FLOW INDICATOR");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 30);
    indicator.parameters:addDouble("Coef", "Coef", "Coef", 0.2); 
    indicator.parameters:addDouble("VCoef", "VCoef", "VCoef", 2.5); 
    indicator.parameters:addInteger("SmoothPeriod", "Smooth Period", "Period", 2);	
 
    indicator.parameters:addInteger("SmoothingPeriods", "SmoothingPeriods", "SmoothingPeriods", 3);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("VFI_color", "Color of VFI", "Color of VFI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period,Coef,VCoef, SmoothPeriod; 
local first;
local source = nil;

-- Streams block 
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Coef = instance.parameters.Coef;
    VCoef = instance.parameters.VCoef;
    SmoothPeriod = instance.parameters.SmoothPeriod;
    source = instance.source;
    first = source:first()+1;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Coef) .. ", " .. tostring(VCoef) .. ", " .. tostring(SmoothPeriod) .. ")";
    instance:name(name);

    if (nameOnly)  then
	return;
	end
	
		inter = instance:addInternalStream(0, 0); 
		DirectionalVolume= instance:addInternalStream(0, 0); 
		Raw_VFI= instance:addInternalStream(0, 0); 		
		MA1 = core.indicators:create("MVA", source.volume, Period);		
		MA2 = core.indicators:create("WMA", Raw_VFI, SmoothPeriod);
		
		 
        VFI = instance:addStream("VFI", core.Line, name, "VFI", instance.parameters.VFI_color,first+Period*2+SmoothPeriod);		        
		VFI:setPrecision(math.max(2, instance.source:getPrecision()));
		
		VFI:setWidth(instance.parameters.width);
        VFI:setStyle(instance.parameters.style);
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


	MA1:update(mode);
	
	if period <= first    then
	return;
	end
	
	inter[period] = math.log(source.typical[period])-math.log(source.typical[period-1]);
	  
	 if period <= first+Period   then
	return;
	end
      
    local CutOff=Coef*mathex.stdev (inter, period-Period+1, period)*source[period]; 
	
  
	local Vave =MA1.DATA[period-1];
    local VC=Vave *VCoef;
	 
	
	if source.volume[period] < VC  then
	VC = source.volume[period];  
    end	 
	
    local MF =  source.typical[period] -  source.typical[period-1];
	
	if MF > CutOff then
	DirectionalVolume[period]=VC;
	elseif  MF < -CutOff then
	DirectionalVolume[period]=-VC;
	else
	DirectionalVolume[period]=0;
	end
	
	
	
	 if period <= first+Period*2    then
	return;
	end	
 
	
    if Vave ~= 0 then 
    Raw_VFI[period]=  mathex.sum (DirectionalVolume, period-Period+1, period)/ Vave ;  
    else
	Raw_VFI[period] = 0;
	end	
	
	 
	MA2:update(mode);
		
	if period <= first+Period*2+SmoothPeriod   then
	return;
	end		  
	
    VFI[period] = MA2.DATA[period];
 
    
end
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+ 