-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60009

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
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

function Init()
    indicator:name("Extended Shifted Line Indicator");
    indicator:description("The indicator will shift source line by the specified number of periods and/or points.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
   indicator.parameters:addString("Method", "Method", "Method" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Pips", "Pips" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Value", "Value" , "Value");
	indicator.parameters:addStringAlternative("Method", "Percentage", "Percentage" , "Percentage");
    indicator.parameters:addInteger("SX", "Shift in periods", "Postive is future, negative is past", 0);
    indicator.parameters:addDouble("SY", "Shift in points", "", 0);
	
	
	indicator.parameters:addGroup("Extended");	
	indicator.parameters:addInteger("Extend", "Extend", "Extend", 0);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("width","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("color", "Color of the Shifted line", "", core.rgb(255, 0, 0));
end

local source;
local OUT;
local first1, first2;
local SX, SY;
local Method;
local Extend;

function Prepare(nameOnly)   
  
    local name;
	Method=instance.parameters.Method;
	Extend=instance.parameters.Extend;
    name = profile:id() .. "(" .. instance.source:name() .. ", " .. instance.parameters.SX .. " bars," .. instance.parameters.SY .. " points)" .. " ," .. Extend;
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;
    SX = instance.parameters.SX;
	if Method=="Pips" then
    SY = instance.parameters.SY * source:pipSize();
    else 
	SY = instance.parameters.SY;
	end
   
    first1 = source:first();
    first2 = first1 + SX;
    if first2 < 0 then
        first2 = 0;
    end
    OUT = instance:addStream("Shifted", core.Line, name .. ".Shifted", "Shifted", instance.parameters.color, first2, SX+Extend);
	OUT:setWidth(instance.parameters.width);
    OUT:setStyle(instance.parameters.style);
end

function Update(period, mode)
    

    local p1 = period + SX;
    if p1 >= 0 and period >= first1 then
	   
	      if Method~="Percentage" then
          OUT[p1] =source[period] + SY;
		  else
		  OUT[p1] =source[period] + (source[period]/100)*SY;
		  end
		  
		  Delta=OUT[p1]-OUT[p1-1];
		  
		if Extend >= 1 and period==source:size()-1 then
		for i=1, Extend, 1 do
		
	      if Method~="Percentage" then
          OUT[p1+i] =source[period] + SY+Delta*i;
		  else
		  OUT[p1+i] =source[period] + (source[period]/100)*SY +Delta*i;
		  end
		  
        end		
		
		end
	
    end
	

end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+