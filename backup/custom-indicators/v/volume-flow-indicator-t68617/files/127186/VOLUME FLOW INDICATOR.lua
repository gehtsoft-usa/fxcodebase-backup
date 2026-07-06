-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68617
 
 

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
    indicator:name("VOLUME FLOW INDICATOR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 130, 2, 2000);
	indicator.parameters:addInteger("Period2", "MA Period", "", 3, 2, 2000);
	indicator.parameters:addInteger("Period3", "St Dev Period", "", 30, 2, 2000);
    indicator.parameters:addDouble("Coef", "Coef", "", 0.1, 0, 2000);
	indicator.parameters:addDouble("Vcoef", "Vcoef", "", 3.5, 0, 2000);
 
   
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);

	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
 local Period1,Period2,Period3, Coef,Vcoef;
local first;
local source = nil;
 
local Oscillator;   
local RSI,EMA; 
local vfii,vc,inter;
local EMA;
local vaveset;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
	Coef=instance.parameters.Coef;
	Vcoef=instance.parameters.Vcoef
	
	
	local Parameters= Period1..", ".. Period2..", ".. Period3..", "..Coef..", "..Vcoef;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
			
    source = instance.source;   
    first=source:first()+1;
	inter= instance:addInternalStream(0, 0);
	vc= instance:addInternalStream(0, 0);
	vfii= instance:addInternalStream(0, 0);
	vaveset= instance:addInternalStream(0, 0);
 
    EMA = core.indicators:create("EMA", vfii, Period2);
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first +math.max(Period1,Period3)+Period2  );
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
end

-- Indicator calculation routine
function Update(period, mode)

    
	if period < first 
	then
	return;
	end
	
	if source.typical[period] > 0 and source.typical[period-1] > 0 then
	inter[period] = math.log(source.typical[period]) - math.log(source.typical[period-1]);
	else
	inter[period] = 0
	end
	
	
	if period < first +Period3
	then
	return;
	end
	
	local vinter=mathex.stdev(inter, period-Period3+1, period)
 
    local cutoff=Coef*vinter*source.close[period];
	
	
	if period < first +Period1
	then
	return;
	end
	
	vaveset[period]=mathex.avg(source.volume, period-Period1+1, period); 
 
     local vmax=vaveset[period-1]*Vcoef;
     local vcd;
     
	if source.volume[period]<vmax then
	vcd=source.volume[period];
	else
	vcd=vmax;
	end
	
	local mf=source.typical[period]-source.typical[period-1];
	if mf>cutoff then
	vc[period]=vcd
	elseif mf<-cutoff then
	vc[period]=-vcd
	else
	vc[period]=0
	end
	 
	 vfii[period]=mathex.sum(vc, period-Period1+1, period);
	 
	 
	 if period < first +math.max(Period1,Period3)+Period2 
	then
	return;
	end
	
	 EMA:update(mode);
	
     Oscillator[period]= EMA.DATA[period];
				  
end

 
 
 
 
 