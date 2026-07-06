-- Extension for RSI, coloring high/low values
-- related to http://fxcodebase.com/code/viewtopic.php?f=17&t=13034
-- based on http://fxcodebase.com/code/viewtopic.php?f=17&t=15714


function Init()
    indicator:name("Mountain Color Fill RSI");
    indicator:description("Mountain Color Fill RSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addBoolean("isChannel", "Fill area under source line with color", "Defines whether the area under source line should be filled with the color.", true);
    indicator.parameters:addColor("up", "Positive  Color", "", core.rgb(0, 192, 0));
	indicator.parameters:addColor("down", "Negative Color", "", core.rgb(192, 0, 0));
	indicator.parameters:addColor("neutral", "Neutral Color", "", core.rgb(255, 255, 255))
    indicator.parameters:addInteger("low", "Low Value", "Low Value", 30, 0, 100);
    indicator.parameters:addInteger("high", "High Value", "Low Value", 70, 0, 100);
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
function Prepare()
    source = instance.source;   
    first =source:first();
    Type=instance.parameters.Type;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	 isChannel = instance.parameters.isChannel;
	 
    if isChannel then
    HighBorder = instance:addStream("Mountain", core.Line, name, "Mountain", instance.parameters.up, first)
    HighBorder:setWidth(instance.parameters.width);
    HighBorder:setStyle(instance.parameters.style);

    LowBorder = instance:addInternalStream(0);

    instance:createChannelGroup("Mountain", "Mountain", HighBorder, LowBorder, instance.parameters.up, 100 - instance.parameters.transp, true);
	end

   
end

-- calculate the value
function Update(period)

    if period < first  then
    return;
	end
      
          
                LowBorder[period] = 50;
          
                HighBorder[period] = source[period];
		if Type == "PN" then		 
				
				if HighBorder[period] > instance.parameters.high then
					LowBorder[period] = instance.parameters.high;
					HighBorder:setColor(period, instance.parameters.up);
				elseif HighBorder[period] < instance.parameters.low then
					LowBorder[period] = instance.parameters.low;
					HighBorder:setColor(period, instance.parameters.down);
				else
					if     HighBorder[period-1] > LowBorder[period] and HighBorder[period] > LowBorder[period] then LowBorder[period] = instance.parameters.high;
					elseif HighBorder[period-1] > LowBorder[period] and HighBorder[period] < LowBorder[period] then LowBorder[period] = 50;
					elseif HighBorder[period-1] < LowBorder[period] and HighBorder[period] > LowBorder[period] then LowBorder[period] = 50;
					elseif HighBorder[period-1] < LowBorder[period] and HighBorder[period] < LowBorder[period] then LowBorder[period] = instance.parameters.low;
					end
					
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

