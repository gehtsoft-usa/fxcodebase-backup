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
    indicator:name("The Hilbert Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
	
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "1.  Line Color", "", core.rgb(0, 255, 0));	
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);

    indicator.parameters:addColor("color2", "2.  Line Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);


	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
 
local first;
local source = nil;
 
local Oscillator,h;  


local a, b, c2, c3, c1, h1;
-- Routine
 function Prepare(nameOnly)   
  
	
	local Parameters= "";
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
    assert(core.indicators:findIndicator("EHLERS HILBERT TRANSFORMATION") ~= nil, "Please, download and install EHLERS HILBERT TRANSFORMATION.LUA indicator");
			
    source = instance.source; 
	h = core.indicators:create("EHLERS HILBERT TRANSFORMATION", source );
	first=h.DATA:first()+2 ;

    Smooth= instance:addInternalStream(0, 0);
	q3= instance:addInternalStream(0, 0);
 
 
   


	
	i3 = instance:addStream("i3" , core.Line, " i3"," i3",instance.parameters.color1, first );
	i3:setWidth(instance.parameters.width1);
    i3:setStyle(instance.parameters.style1);
    i3:setPrecision(math.max(5, source:getPrecision()));	
 
    V1 = instance:addStream("V1" , core.Line, " V1"," V1",instance.parameters.color2, first);
	V1:setWidth(instance.parameters.width2);
    V1:setStyle(instance.parameters.style2);
    V1:setPrecision(math.max(5, source:getPrecision()));
	

end

-- Indicator calculation routine
function Update(period, mode)

    h:update(mode); 
	if period < first
	then
	return;
	end
	 
    GetValue(period);
				  
end


function GetValue(period)

    
   Smooth[period]  = (4 * source[period] + 3 * source[period- 1] + 2 * source[period- 2] + source[period- 3]) / 10;
   q3[period] = 0.5 * (Smooth[period] - Smooth[period-2]) * (0.1759 * h.SmoothPeriod[period] + 0.4607);
   
   local  sp2 = math.ceil(h.SmoothPeriod[period] / 2); 
   if (sp2 < 3) then sp2 = 3; end
   
 	if period < first+sp2
	then
	return;
	end
	
   i3[period] = 0.0;
   for i = 0,sp2, 1  do
      i3[period] = i3[period] + q3[period- i];
    end
	
   i3[period] = (1.57 * i3[period]) / sp2;
  


	local sp4 = math.ceil(h.SmoothPeriod[period] / 4);
	for   i = 0, sp4, 1  do
    V1[period] = V1[period] + q3[period-i];
	end			
	
   	V1[period] = 1.25 * V1[period] / sp4;    
end

