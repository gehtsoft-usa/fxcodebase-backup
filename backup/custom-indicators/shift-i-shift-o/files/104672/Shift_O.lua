-- Id: 15427

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63122

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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


function Init()
    indicator:name("Shifted Line Indicator");
    indicator:description("The indicator will shift selected indicator lines by the specified number of periods and/or points.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Data Selection");	
	indicator.parameters:addString("INDICATOR", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR",core.FLAG_INDICATOR);
	--indicator.parameters:addInteger("Number", "Data Stream Number", "", 1, 1 , 100);
	
	indicator.parameters:addGroup("Calculation");
   indicator.parameters:addString("Method", "Method", "Method" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Pips", "Pips" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Value", "Value" , "Value");
	indicator.parameters:addStringAlternative("Method", "Percentage", "Percentage" , "Percentage");
    indicator.parameters:addInteger("SX", "Shift in periods", "Postive is future, negative is past", 0);
    indicator.parameters:addDouble("SY", "Shift in points", "", 0);
	
	
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("width","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

local source;
local OUT={};
local first1, first2;
local SX, SY;
local Method;
local INDICATOR;
local Indicator;
local INDEX={};
function Prepare(nameOnly) 
    local name;
	
	INDICATOR=instance.parameters.INDICATOR;
	Method=instance.parameters.Method;
    name = profile:id() .. "(" .. instance.source:name() .. ", " .. instance.parameters.SX .. " bars," .. instance.parameters.SY .. " points)";
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
	
		
	
	local iprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"));
		local iparams = instance.parameters:getCustomParameters("INDICATOR");

		if  iprofile:requiredSource() == core.Tick then			
			Indicator = iprofile:createInstance( source.close, iparams);
		else
			Indicator = iprofile:createInstance(source, iparams);
		end
	
	 Count= Indicator:getStreamCount ();
	 
   
    first1 = source:first();
    first2 = first1 + SX;
	
    if first2 < 0 then
        first2 = 0;
    end
	
	for i= 1 ,Count, 1 do
	INDEX[i]=  Indicator:getStream (i-1);
    OUT[i] = instance:addStream("Index".. i, core.Line, name .. i.. ".Shifted", i.. "Shifted", core.rgb(128, 128, 128), first2, SX);
    OUT[i]:setPrecision(math.max(2, instance.source:getPrecision()));
	OUT[i]:setWidth(instance.parameters.width);
    OUT[i]:setStyle(instance.parameters.style);
	end
	
end

function Update(period, mode)
    
		Indicator:update(mode);

    local p1 = period + SX;
    if p1 < 0 
	or  period < first1 
	or period < first2
	then
	return;
	end
	

	
	for i= 1 , Count, 1 do   
	      
	      if Method~="Percentage" then
          OUT[i][p1] =INDEX[i][period] + SY;
		  else
		  OUT[i][p1] =INDEX[i][period] + (INDEX[i][period]/100)*SY;
		  end
		  
		   
          OUT[i]:setColor(p1, INDEX[i]:colorI(period) );
	end	  
 
end

