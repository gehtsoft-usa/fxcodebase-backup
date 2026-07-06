-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&p=152390

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
    indicator:name("Fractal Dimension Index Hurst Difference");
    indicator:description("Fractal Dimension Hurst Difference");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Fractal Dimension Calculation");
    indicator.parameters:addInteger("Period1", "Period", "Period", 30); 
	
    indicator.parameters:addGroup("Hurst Difference Calculation");
    indicator.parameters:addInteger("Period2", "Period", "Period", 30);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr_Line", "Color of Line", "Color of Line", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

local first;
local source = nil;
local Period1; 
local Period2;
local fdi;
local HurstBuff=nil;

 function Prepare(nameOnly)   
    source = instance.source;
    Period1=instance.parameters.Period1; 
    Period2=instance.parameters.Period2; 	

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Period2  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    assert(core.indicators:findIndicator("FRACTAL DIMENSION INDEX") ~= nil, "Please, download and install FRACTAL DIMENSION INDEX.LUA indicator");
	
	Indicator = core.indicators:create("FRACTAL DIMENSION INDEX", source,  Period1);
	first = Indicator.DATA:first()+Period2;
	
    fdi = instance:addInternalStream(0, 0);
    HurstBuff = instance:addStream("HurstBuff", core.Line, name .. ".HurstBuff", "HurstBuff", instance.parameters.clr_Line, first );
    HurstBuff:setPrecision(math.max(2, instance.source:getPrecision()));
	HurstBuff:setWidth(instance.parameters.width);
    HurstBuff:setStyle(instance.parameters.style);
	
    HurstBuff:addLevel(0);
end

function Update(period, mode)


	Indicator:update(mode);
	
  
     
    if (period<=first ) then
	return;
	end
 
	 local priceMin, priceMax= mathex.minmax(Indicator.DATA, period-Period2+1, period);
     local length=0.;
     local priorDiff=0.;
     local sum=0.;
     
     for i=period-Period2+1,period,1 do
      if priceMax-priceMin>0. then
       diff=(Indicator.DATA[i]-priceMin)/(priceMax-priceMin);
       if i>period-Period2+1 then
        length=length+math.sqrt(math.pow(diff-priorDiff,2)+(1./math.pow(Period2,2)));
       end
       priorDiff=diff;
      end
     end
     
     if length>0. then
      fdi[period]=1.+(math.log(length)+math.log(2.))/math.log(2.*(Period2-1))
     else
      fdi[period]=0.;
     end
     
     HurstBuff[period]=fdi[period-1]-fdi[period];

  
end
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   | 
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |   
--+------------------------------------------------------------------------------------------------+
--| USDT on ERC-20  |                                  0x258C74Caac21c9535A0969F169FE0271d3cE56A0  | 
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+
