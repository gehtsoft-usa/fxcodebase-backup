-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27497
-- Id: 8047

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("VOLUME FLOW INDICATOR");
    indicator:description("VOLUME FLOW INDICATOR");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 130);
    indicator.parameters:addDouble("Coef", "Coef", "Coef", 0.2);
    indicator.parameters:addDouble("VCoef", "VCoef", "VCoef", 2.5);
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
local Period;
local Coef;
local VCoef;
local SmoothingPeriods;
local myVFI;
local first;
local source = nil;

-- Streams block
local VFI = nil;
local INTER;
local MA;
local DirectionalVolume;
local EMA;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Coef = instance.parameters.Coef;
    VCoef = instance.parameters.VCoef;
    SmoothingPeriods = instance.parameters.SmoothingPeriods;
    source = instance.source;
    first = source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Coef) .. ", " .. tostring(VCoef) .. ", " .. tostring(SmoothingPeriods) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		INTER = instance:addInternalStream(0, 0);
		
		MA = core.indicators:create("MVA", source.volume, Period);
		DirectionalVolume = instance:addInternalStream(0, 0);
		myVFI = instance:addInternalStream(0, 0);
		if SmoothingPeriods  > 0 then
		EMA = core.indicators:create("EMA", myVFI, SmoothingPeriods);
		end
	
	    if SmoothingPeriods  > 0 then
        VFI = instance:addStream("VFI", core.Line, name, "VFI", instance.parameters.VFI_color, EMA.DATA:first());
		else
		 VFI = instance:addStream("VFI", core.Line, name, "VFI", instance.parameters.VFI_color, MA.DATA:first()+Period);
		end
		VFI:setPrecision(math.max(2, instance.source:getPrecision()));
		
		VFI:setWidth(instance.parameters.width);
        VFI:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

	 if period < first +1  then
	return;
	end
	
	  INTER[period] = math.log(source.typical[period])-math.log(source.typical[period-1]);
	  
	 if period < first+1 +30   then
	return;
	end
      
    local VINTER=mathex.stdev (INTER, period-30+1, period);
    local CutOff=Coef*VINTER*source.close[period];
	
	MA:update(mode);
	if period <  MA.DATA:first()+1 then
	return;
	end
	
	local VAve=MA.DATA[period-1];
    local VMax=VAve*VCoef;
	
	local VC;
	
	if source.volume[period] < VMax  then
	VC = source.volume[period];
	else
    VC =  VMax;
    end	 
	
    local MF =  source.typical[period] -  source.typical[period-1];
	if MF > CutOff then
	DirectionalVolume[period]=VC;
	elseif  MF < -CutOff then
	DirectionalVolume[period]=-VC;
	else
	DirectionalVolume[period]=0;
	end
	
	if period <  MA.DATA:first()+Period then
	return;
	end
	
    if VAve ~= 0 then 
    myVFI[period]=  mathex.sum (DirectionalVolume, period-Period+1, period)/ VAve ;  
    else
	myVFI[period] = 0;
	end	
	
	if SmoothingPeriods > 0 then
	
	    EMA:update(mode);
		
	    if period <  EMA.DATA:first()  then
		return;
		end
	    VFI[period] = EMA.DATA[period]
	else
    VFI[period] = myVFI[period];
	end   
    
end
