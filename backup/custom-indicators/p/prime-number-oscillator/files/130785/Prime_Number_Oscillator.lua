-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69329

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--|                         https://AppliedMachineLearning.systems   |
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

function Init()
    indicator:name("Prime Number Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addDouble("percent", "Tolerance Percentage", "", 5);

    indicator.parameters:addColor("xpno_color_1", "Color #1", "Color", core.colors().Green);
    indicator.parameters:addColor("xpno_color_2", "Color #2", "Color", core.colors().Red);
    indicator.parameters:addInteger("xpno_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("xpno_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("xpno_style", core.FLAG_LINE_STYLE);
end

local percent, xpno, xpno_color_1, xpno_color_2;
local source;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    xpno_color_1 = instance.parameters.xpno_color_1;
    xpno_color_2 = instance.parameters.xpno_color_2;
    percent = instance.parameters.percent;
    xpno = instance:addStream("kpo", core.Line, "kpo", "kpo", instance.parameters.xpno_color_1, 0, 0);
    xpno:setWidth(instance.parameters.xpno_width);
    xpno:setStyle(instance.parameters.xpno_style);
end

function IsPrimeNumber(price )

    local Return=price;

    for i = 2, math.sqrt(price),1 do
        if price % i == 0 then
		    Return=0;            
        else
		    Return=price;
        end
		
		
		  if Return==0 then
		  break;
		  end
		
    end
	
	
	return Return;

end

function Update(period, mode)
   -- local pips = source.close[period] / source:pipSize()
    res1 = 0
    for j = source[period], source[period] + (source[period] / 100)*percent, 1 do
        res1= IsPrimeNumber(j );
			if res1 > 0 then
			break;
			end	   
    end
    res2 = 0
   
     for j = source[period], source[period] - (source[period] / 100)*percent, -1 do
       res2= IsPrimeNumber(j );
	        if res2 >0 then
			break;
			end	
    end
	
	  
	   
	xpno[period]=0;
	
    if math.abs(res1 - source[period]) >  math.abs(source[period] - res2) then
        xpno[period] =  res1-source[period] ;
    else
        xpno[period] =   res2-source[period]; 	
    end
	
	if xpno[period]==0 then
	 xpno[period] = xpno[period - 1];
	end
  
    if xpno[period] > 0 then
        xpno:setColor(period, xpno_color_1);
    else
        xpno:setColor(period, xpno_color_2);
    end
end