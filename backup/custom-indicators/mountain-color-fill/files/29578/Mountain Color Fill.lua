-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15714
-- Id: 6304

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
    indicator:name("Mountain Color Fill");
    indicator:description("Mountain Color Fill");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addBoolean("isChannel", "Fill area under source line with color", "Defines whether the area under source line should be filled with the color.", true);
    indicator.parameters:addColor("up", "Pozitiv  Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("down", "Negativ Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("neutral", "Neutral Color", "", core.rgb(128, 128, 128))
    indicator.parameters:addInteger("transp", "Transparency, %", "Transparency, %", 80, 0, 100);
    indicator.parameters:addInteger("width", "MVA line width", "MVA line width.", 1, 1, 5);
    indicator.parameters:addInteger("style", "MVA line style", "MVA line style.", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addString("Type", "Overlay Style", "", "PN");
    indicator.parameters:addStringAlternative("Type", "Pozitiv/Negativ", "", "PN");
    indicator.parameters:addStringAlternative("Type", "Slope", "", "S");
	indicator.parameters:addStringAlternative("Type", "Simple Fill", "", "F");
	
 
end

local first = 0;
local source = nil;
local Type;
local HighBorder, LowBorder;

local isChannel;

-- initializes the instance of the indicator
function Prepare(nameOnly)
    source = instance.source;   
    first =source:first();
    Type=instance.parameters.Type;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	 isChannel = instance.parameters.isChannel;
	 
    if isChannel then
    HighBorder = instance:addStream("Mountain", core.Line, name, "Mountain", instance.parameters.up, first)
    HighBorder:setWidth(instance.parameters.width);
    HighBorder:setStyle(instance.parameters.style);

    LowBorder = instance:addInternalStream(0);

    instance:createChannelGroup("Mountain", "Mountain", HighBorder, LowBorder, instance.parameters.up, 100 - instance.parameters.transp, true);
	
	else
	
	HighBorder = instance:addInternalStream(0);
	LowBorder = instance:addInternalStream(0);
	
	end

   
end

-- calculate the value
function Update(period)

    if period < first  then
    return;
	end
	
	
	if not isChannel then
   return;
   end
      
          
                LowBorder[period] = 0;
          
                HighBorder[period] = source[period];
		if Type == "PN" then		 
				
				if HighBorder[period] > 0 then
				HighBorder:setColor(period, instance.parameters.up);
				elseif HighBorder[period] < 0 then
				HighBorder:setColor(period, instance.parameters.down);
				else
				HighBorder:setColor(period, instance.parameters.neutral);
				end
        elseif  Type == "S" then
		       
			    if HighBorder[period] > HighBorder[period-1] then
				HighBorder:setColor(period, instance.parameters.up);
				elseif HighBorder[period] < HighBorder[period-1] then
				HighBorder:setColor(period, instance.parameters.down);
				else
				HighBorder:setColor(period, instance.parameters.neutral);
				end
		       
        end		

end

