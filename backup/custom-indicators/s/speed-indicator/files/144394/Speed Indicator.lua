-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71685

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
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Speed Indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "1. Period", "", 24, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. Period", "", 170, 1, 2000);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addBoolean("Show", "Show Bars", "", false);	
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addColor("color1", "Up Bar Color", "", core.rgb(0, 255, 0));  
	indicator.parameters:addColor("color2", "Down Bar Color", "", core.rgb(255, 0, 0)); 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2,Method; 
local first;
local source = nil;
local MA1, MA2;
local Oscillator; 
local Dif;  
local PosBuffer, NegBuffer;
local Show;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
	Method= instance.parameters.Method;
	Show= instance.parameters.Show;
	
	
	local Parameters= Period1..", "..Period2..", "..Method;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	
	MA = core.indicators:create(Method, source, Period1);
	
    first=source:first() +Period1+1 ;
	 
	Dif= instance:addInternalStream(0, 0);	
    
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first+Period2);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));	
    Oscillator:addLevel(0);	
	
	if Show then
	PosBuffer = instance:addStream("PosBuffer" , core.Bar, " PosBuffer"," PosBuffer",instance.parameters.color1, first+Period2); 
    PosBuffer:setPrecision(math.max(2, source:getPrecision()));
	
	NegBuffer = instance:addStream("NegBuffer" , core.Bar, " NegBuffer"," NegBuffer",instance.parameters.color2, first+Period2); 
    NegBuffer:setPrecision(math.max(2, source:getPrecision()));	
	else
	PosBuffer= instance:addInternalStream(0, 0);	
	NegBuffer= instance:addInternalStream(0, 0);		
	end
end

-- Indicator calculation routine
function Update(period, mode)
	MA:update(mode);
 

	if period < first
	then
	return;
	end

    Dif[period]=MA.DATA[period]- MA.DATA[period-1] ;
	

        local pos_count = 0;
        local neg_count = 0;
        local pos_sum = 0;
        local neg_sum = 0;
		
	if period < first+Period2
	then
	return;
	end		
		
		
		for i= period, first, -1 do
		
			if  Dif[i] > 0 then
			pos_count=pos_count+1;
			pos_sum=pos_sum + Dif[i];
			elseif  Dif[i] < 0 then
			neg_count=neg_count+1;
			neg_sum=neg_sum + Dif[i];			
			end		
			
			if pos_count== Period2 or neg_count== Period2 then
			break;
			end
			
		end
		
 

        PosBuffer[period]  = pos_sum/Period2;
        NegBuffer[period]  = neg_sum/Period2;
		  
        if Dif[period] > 0 then
        Oscillator[period] =  Dif[period] / math.abs(PosBuffer[period]);
        elseif Dif[period] < 0 then  
        Oscillator[period] =  Dif[period] / math.abs(NegBuffer[period]);		
        else
        Oscillator[period]=0;
        end   		
end
 