-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72358

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

--Your donations will allow the service to continue onward.
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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Corrected generalized DEMA");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 25, 1, 2000);
    indicator.parameters:addInteger("inpFlPeriod", "Floating levels period", "", 25, 1, 2000);
    indicator.parameters:addInteger("inpFlUp", "Upper level %", "", 90, 0, 100);
    indicator.parameters:addInteger("inpFlDown", "Lower level %", "", 10, 0, 100);	
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up DEMA Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down DEMA Line Color", "", core.rgb(255, 0, 0)); 
	 
	 indicator.parameters:addGroup("Cloud Style");	
	 indicator.parameters:addColor("colorA", "Top Line Color", "", core.rgb(128, 128, 128)); 
	 indicator.parameters:addColor("colorB", "Central Line Color", "", core.rgb(128, 128, 128)); 
	 indicator.parameters:addColor("colorC", "Bottom Line Color", "", core.rgb(128, 128, 128)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;  
local Period, n;	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	inpFlPeriod=instance.parameters.inpFlPeriod;
	inpFlUp=instance.parameters.inpFlUp;
	inpFlDown=instance.parameters.inpFlDown;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period.. "," ..  inpFlPeriod .. "," ..  inpFlUp.. "," ..  inpFlDown .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    assert(core.indicators:findIndicator("DEMA") ~= nil, "Please, download and install DEMA.LUA indicator");	
	
	Indicator= core.indicators:create("DEMA", source, Period );
	first=Indicator.DATA:first() ; 
	
	
	CA = instance:addInternalStream(0, 0);
 
	
	
    Line = instance:addStream("DEMA", core.Line, name, "DEMA", instance.parameters.color1, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
 
 
    CA = instance:addStream("CA", core.Line, name, "Corrected DEMA", instance.parameters.color2, first );
    CA:setPrecision(math.max(2, instance.source:getPrecision()));
    CA:setWidth(instance.parameters.width);
    CA:setStyle(instance.parameters.style);
 
 
 
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.colorA, first );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
	
    Central = instance:addStream("Central", core.Line, name, "Central", instance.parameters.colorB, first );
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
    Central:setWidth(instance.parameters.width);
    Central:setStyle(instance.parameters.style);

    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.colorC, first );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);	
end


function Update(period, mode)

	 Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	Line[period]= Indicator.DATA[period];
 
    local STD=mathex.stdev(source, period-Period+1, period);
 
    local v1 = STD*STD;
    local v2 = (CA[period-1]-Indicator.DATA[period])*(CA[period-1]-Indicator.DATA[period]);
	
    local k;
	
	if(v2<v1) then
	k=0
	CA[period]=CA[period-1];
	else
	k=1-v1/v2
	CA[period]=CA[period-1]+k*(Indicator.DATA[period]-CA[period-1])
	end
 
 
    if period <= first + inpFlPeriod then
	return;
	end
	
	
	local  imin,imax = mathex.minmax(CA, period- inpFlPeriod+1, period); 
    local rrange = imax-imin
    Top[period]= imin+inpFlUp*rrange/100.0
    Bottom[period]= imin+inpFlDown*rrange/100.0
    Central[period] = imin+50*rrange/100.0 
	
	
	if CA[period]>CA[period- 1] then
    Line:setColor(period, instance.parameters.color1);	
	elseif CA[period]<CA[period-1] then 
    Line:setColor(period, instance.parameters.color2);		 
	end 
	if Indicator.DATA[period]>CA[period] then 
    CA:setColor(period, instance.parameters.color1);	 
	elseif Indicator.DATA[period]<CA[period] then
    CA:setColor(period, instance.parameters.color2);		  
	end 
	 
end

 