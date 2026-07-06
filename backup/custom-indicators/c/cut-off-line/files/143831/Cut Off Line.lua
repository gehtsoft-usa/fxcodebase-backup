-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71541

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
    indicator:name("Cut Off Line");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000);

 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period; 
local first;
local source = nil;
 
local Oscillator;  
local ChangeUp;
local ChangeDown;
local Change;

local Up, Down;
local SumUp, SumDown;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
	
	
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Period;
	
	ChangeUp= instance:addInternalStream(0, 0);
	ChangeDown= instance:addInternalStream(0, 0);   
    Change= instance:addInternalStream(0, 0);    
	SumUp= instance:addInternalStream(0, 0);
	SumDown= instance:addInternalStream(0, 0);   
	
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color1, first );
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:setPrecision(math.max(2, source:getPrecision()));
 	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	ChangeUp[period]=0; 
	SumUp[period]=0;
	ChangeDown[period]=0; 	
	SumDown[period]=0;

	
    Change[period]=math.abs(source.close[period]- source.open[period]); 

	if period < first
	then
	return;
	end
	
	local Average =mathex.avg(Change, period-Period+1, period);
	
	
	if source.close[period]> source.open[period] 
	and Change[period] >= Average
	then
	ChangeUp[period]= source.close[period]- source.open[period];
	SumUp[period]=1;	
	elseif source.close[period]< source.open[period] 
	and Change[period] >= Average
	then
	ChangeDown[period]= source.open[period]- source.close[period];
	SumDown[period]=1;	
	end
   
   local up, down=0,0;   
   if mathex.sum(SumUp, period-Period+1, period)~=0 then
   up=mathex.sum(ChangeUp, period-Period+1, period)/mathex.sum(SumUp, period-Period+1, period);
   end
   if mathex.sum(SumDown, period-Period+1, period)~=0 then
   down=mathex.sum(ChangeDown, period-Period+1, period)/mathex.sum(SumDown, period-Period+1, period);
   end
 
	if up ~= nil then
	Line[period]= up; 
	end
	if  down ~= nil then
	Line[period]=up-down;
    end
	
	if Line[period]> 0 then
	Line:setColor(period, instance.parameters.color1);
	else
	Line:setColor(period, instance.parameters.color2);
	end
end


 