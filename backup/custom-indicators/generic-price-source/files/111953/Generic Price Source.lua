-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64590
-- Id: 17964

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
    indicator:name("Generic Price Source");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 

    indicator.parameters:addGroup("Calculation");



    Add(1, true, "+" , "high", 0);
	Add(2, true, "+" , "median", 0);
	Add(3, true, "/" , "value", 2 );
	Add(4, false, "+", "value", 0  );
	Add(5, false, "+", "value", 0  );
	Add(6, false, "+", "value", 0  );
	Add(7, false, "+", "value", 0  );
	Add(8, false, "+", "value", 0  );
	Add(9, false, "+", "value", 0  );
	Add(10, false, "+", "value", 0  );
 
 

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line color", "Line Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

function Add(id, use, operation, source, value)
indicator.parameters:addGroup(id.. ". Component");
indicator.parameters:addBoolean("Use".. id, "Use it", "", use);

indicator.parameters:addString("Operation".. id, "Operation", "", operation);
indicator.parameters:addStringAlternative("Operation".. id, "+", "", "+");
indicator.parameters:addStringAlternative("Operation".. id, "-", "", "-");
indicator.parameters:addStringAlternative("Operation".. id, "/", "", "/");
indicator.parameters:addStringAlternative("Operation".. id, "*", "", "*");


indicator.parameters:addString("Price".. id, "Price/Value", "", source);
indicator.parameters:addStringAlternative("Price".. id, "OPEN", "", "open");
indicator.parameters:addStringAlternative("Price".. id, "HIGH", "", "high");
indicator.parameters:addStringAlternative("Price".. id, "LOW", "", "low");
indicator.parameters:addStringAlternative("Price".. id,"CLOSE", "", "close");
indicator.parameters:addStringAlternative("Price".. id, "MEDIAN", "", "median");
indicator.parameters:addStringAlternative("Price".. id, "TYPICAL", "", "typical");
indicator.parameters:addStringAlternative("Price".. id, "WEIGHTED", "", "weighted");
indicator.parameters:addStringAlternative("Price".. id, "Value", "", "value");

indicator.parameters:addDouble("Value".. id, "Value", "", value);
	
end

local Value={};
local Operation={};
local Use={};
local Price={};
local first;
local Stream;

function Prepare(onlyName)
    source = instance.source;
	first=source:first();
 
	 for i= 1 , 10 , 1 do  
	 Value[i]=instance.parameters:getDouble("Value" .. i);
	 Operation[i]=instance.parameters:getString("Operation" .. i);
	 Use[i]=instance.parameters:getString("Use" .. i);
	 Price[i]=instance.parameters:getString("Price" .. i);
	 end
	 
	local name; 
    name = profile:id();
    instance:name(name);
	
    if onlyName then
        return ;
    end
    
  

    Stream = instance:addStream("Stream", core.Line, name .. ".Stream", "Stream", instance.parameters.color, first);
    Stream:setWidth(instance.parameters.width);
    Stream:setStyle(instance.parameters.style);

    
end

function Update(period, mode)


    if period< first then
	return;
	end
	
	
	 Stream[period]=0;
	 
	for i= 1 , 10 , 1 do	
		if Use[i] then
		  
		     if Price[i]~= "value" then
		    iValue= source[Price[i]][period];
			else
			iValue=Value[i];
			end
			
			if Operation[i]== "+" then
			Stream[period]= Stream[period] + iValue;
			elseif Operation[i]== "-" then
			Stream[period]= Stream[period] - iValue;
			elseif Operation[i]== "/" then
			Stream[period]= Stream[period] / iValue;
			elseif Operation[i]== "*" then
			Stream[period]= Stream[period] * iValue;
			end
		end
	
	end
	
	
	

end

