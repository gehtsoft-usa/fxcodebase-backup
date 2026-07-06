-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69186
 
--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("Generic Range Indicator")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addString("INDICATOR", "Indicator", "", "")
    indicator.parameters:setFlag("INDICATOR", core.FLAG_ONLYINDICATORS)

 
    indicator.parameters:addInteger("Period", "Period", "", 100, 0, 1000)
    indicator.parameters:addInteger("Number", "Data Stream Number", "", 1, 1, 100)
	
	indicator.parameters:addBoolean("ShowAll", "ShowAll", "", false);
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","",80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

local Number
local OUT = {}
local FIRST;
local source
local Count;
local ShowAll;
local TEMP;
local Period;
function Prepare(nameOnly)
    INDICATOR = instance.parameters.INDICATOR
	Period = instance.parameters.Period;
	ShowAll = instance.parameters.ShowAll;
    source = instance.source
    Number = instance.parameters.Number
    Number = Number - 1


    local name = profile:id()
    FIRST=0;
    local i;


    name = name .. " (" ..   INDICATOR .. ")"
    instance:name(name)
    if nameOnly then
        return;
    end
 


    
    local tmpprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"))
	
	if tmpprofile == nil then
	assert(false, "Please Select the indicator")
	return;
	end

    local tmpparams = instance.parameters:getCustomParameters("INDICATOR")

    if tmpprofile:requiredSource() == core.Tick then
        TEMP = tmpprofile:createInstance(source.close, tmpparams)
    else
        TEMP = tmpprofile:createInstance(source, tmpparams)
    end

    Count = TEMP:getStreamCount()

    if Number >= Count and not ShowAll then
        Number = Count
        assert(false, "Incorrect index of stream. The indicator has only " .. Count .. " stream(s).")
    end

    if  ShowAll then
        for i = 1, Count, 1 do
            OUT[i] = instance:addStream("out" .. i, core.Line, i, i, core.rgb(0, 0, 0), TEMP.DATA:first())
            OUT[i]:setPrecision(5)

            FIRST = math.max(FIRST, TEMP:getStream(i - 1):first())
			
			 if i == 1 then
			OUT[i]:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	        OUT[i]:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
		   end
		   
        end
    else
        i = Number
        OUT[i] = instance:addStream("out" .. i, core.Line, i, i, core.rgb(0, 0, 0), TEMP.DATA:first())
        OUT[i]:setPrecision(5)
		
		 OUT[i]:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	      OUT[i]:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 

        FIRST = math.max(FIRST, TEMP:getStream(Number):first())
    end
 
   
end

function Update(period, mode)
 
    TEMP:update(mode);

    
    if period < FIRST  +Period then
        return
    end
	
	local min,max = mathex.minmax(TEMP.DATA, period-Period+1, period);

 
    if ShowAll then
        for i = 1, Count, 1 do
		
            if TEMP:getStream(i - 1):hasData(period) then
                OUT[i][period] = (TEMP:getStream(i - 1)[period] -min)/((max-min)/100);
                OUT[i]:setColor(period, TEMP:getStream(i - 1):colorI(period))
            end
        end
    else
        if TEMP:getStream(Number):hasData(period) then
            OUT[Number][period] =  (TEMP:getStream(Number)[period] -min)/((max-min)/100);
            OUT[Number]:setColor(period, TEMP:getStream(Number):colorI(period))
        end
    end
end
 