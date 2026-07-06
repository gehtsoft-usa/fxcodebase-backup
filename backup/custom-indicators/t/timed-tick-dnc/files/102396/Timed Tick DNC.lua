
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62665

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



-- initializes the indicator
function Init()
    -- indicator:fail()
    indicator:name("Tick Source Donchian Channel")
    indicator:description("The simple trend-following indicator. Shows highest high and lowest low for the specified number of Number of seconds.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Number of seconds", "", 20, 1, 10000);
    indicator.parameters:addString("AC", "Analyze the current period", "", "yes");
    indicator.parameters:addStringAlternative("AC", "no", "", "no");
    indicator.parameters:addStringAlternative("AC", "yes", "", "yes");
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addString("SM", "Show middle line", "", "no");
    indicator.parameters:addStringAlternative("SM", "no", "", "no");
    indicator.parameters:addStringAlternative("SM", "yes", "", "yes");
    indicator.parameters:addColor("clrDU", "Color of the Up line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrDN", "Color of the Down line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrDM", "Color of the middle line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
  

end

local first = 0;
local Period;
local ac = true;
local sm = false;
local source = nil;
local dn = nil;
local du = nil;
local dm = nil;
local One;

-- initializes the instance of the indicator
function Prepare(nameOnly)
    source = instance.source;
    Period = instance.parameters.Period;

    ac = (instance.parameters.AC == "yes");
    sm = (instance.parameters.SM == "yes");
	
	s, e = core.getcandle("m1", 0, 0, 0);
    One=(e-s)/60;
	
    first =  source:first()+1 ;
   
    local name = profile:id() .. "(" .. source:name() .. "," .. Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    dn = instance:addStream("DU", core.Line, name .. ".DU", "DU", instance.parameters.clrDU,  first)
	dn:setWidth(instance.parameters.width2);
    dn:setStyle(instance.parameters.style2);
    du = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.clrDN,  first)
	du:setWidth(instance.parameters.width1);
    du:setStyle(instance.parameters.style1);
    if (sm) then
        dm = instance:addStream("DM", core.Line, name .. ".DM", "DM", instance.parameters.clrDM,  first)
		dm:setWidth(instance.parameters.width3);
        dm:setStyle(instance.parameters.style3);
    end
end

-- calculate the value
function Update(period)
    if (period < first) then
	return;
	end
	
	
	
	
        local range;
        if not ac and period < source:size()-1
		or ac
		then
		    p2=period;
            p1=core.findDate (source, source:date(p2)-One*Period,false);
			
			if  p1 == -1 then
			return;
			end
			
			du[period] =  mathex.max (source, p1  , p2);
			dn[period] = mathex.min (source, p1  , p2);
		
			if (sm) then
				dm[period] = (du[period] + dn[period]) / 2;
			end
        elseif not ac and period == source:size()-1
		then
		
		    p2=period-1;
            p1=core.findDate (source, source:date(p2)-One*Period,false);
			
			if  p1 == -1 then
			return;
			end
			
			du[period-1] =  mathex.max (source, p1  , p2);
			dn[period-1] = mathex.min (source, p1  , p2);
		
			if (sm) then
				dm[period-1] = (du[period-1] + dn[period-1]) / 2;
			end
		
		return;		
        end
		
		
     
end

