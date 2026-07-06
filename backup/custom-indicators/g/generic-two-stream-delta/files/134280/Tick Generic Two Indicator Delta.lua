-- More information about this indicator can be found at:
-- http://fxcodebase.com 
--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Generic Two Indicator Delta")
    indicator:description("")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Oscillator)
  
     indicator.parameters:addGroup("Calculation")
  
     indicator.parameters:addBoolean("Inverse", "Inverse", "Inverse", true);
  
    indicator.parameters:addGroup("1. Indicator Calculation")
	indicator.parameters:addInteger("Index1", "Stream Index", "", 1, 1, 100);
	
	indicator.parameters:addString("INDICATOR1", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR1",core.FLAG_INDICATOR);
	
	indicator.parameters:addGroup("2. Indicator Calculation")
	
	indicator.parameters:addInteger("Index2", "Stream Index", "", 1, 1, 100);
	
	indicator.parameters:addString("INDICATOR2", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR2",core.FLAG_INDICATOR);

 
	


    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("color1", "1. Line Line Color", "Line Color", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "2. Line Line Color", "Line Color", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color3", "Delta Bar Color", "Bar Color", core.rgb(0, 0,255))
end

local Inverse, First, Second;
local Index1, Index2; 
local Delta, Line1, Line2, first, source; 

local Indicator1, Indicator2;
function Prepare(nameOnly)
     
    source = instance.source
   
	
	Index1=instance.parameters.Index1-1;
	Index2=instance.parameters.Index2-1;

    local name =
    profile:id() ..  "(" .. source:name()  .. ")"
    instance:name(name)

    if nameOnly then
        return
    end
	
	local iprofile1 = core.indicators:findIndicator(instance.parameters:getString("INDICATOR1"));
	local iparams1 = instance.parameters:getCustomParameters("INDICATOR1");
	
	
	local iprofile2 = core.indicators:findIndicator(instance.parameters:getString("INDICATOR2"));
	local iparams2 = instance.parameters:getCustomParameters("INDICATOR2");
	
	if  iprofile1:requiredSource() == core.Tick then			
			Indicator1 = iprofile1:createInstance( source , iparams1);
	else
		   error("Indicators that require a bar source are not supported.");
	end
		
    
	if  iprofile2:requiredSource() == core.Tick then			
			Indicator2 = iprofile1:createInstance( source , iparams2);
	else
			 error("Indicators that require a bar source are not supported.");
	end
	
	if (Indicator1:getStreamCount ()-1) <  Index1  then
	assert(false, "1. Indicator only has" .. (Indicator1:getStreamCount ()-1) .. "streams.");
	end
	
	if (Indicator2:getStreamCount ()-1) <  Index2  then
	assert(false, "1. Indicator only has" .. (Indicator2:getStreamCount ()-1) .. "streams.");
	end
	
	First= Indicator1:getStream(Index1);
	Second= Indicator2:getStream(Index2);
	
	 first = math.max(Indicator1:getStream(Index1):first(), Indicator2:getStream(Index2):first());

    Delta = instance:addStream("Delta" , core.Bar, " Delta"," Delta",instance.parameters.color3, first );
	
	Line1 = instance:addStream("Line1" , core.Line, "1. Line","1. Line",instance.parameters.color1, first  );
	Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);
    Line1:setPrecision(math.max(2, source:getPrecision()));    
	
	Line2 = instance:addStream("Line2" , core.Line, "2. Line","2. Line",instance.parameters.color2, first  );
	Line2:setWidth(instance.parameters.width2);
    Line2:setStyle(instance.parameters.style2);
    Line2:setPrecision(math.max(2, source:getPrecision()));  
end


function Update(period, mode)

    Indicator1:update(mode);
	Indicator2:update(mode);
	
    if period < first or not source:hasData(period) then
        return
    end
	
	
	
	Line1[period]=First[period];
	Line2[period]=Second[period];
	
	
	if Inverse then
	Delta[period]=First[period]-Second[period];
	else
	Delta[period]=Second[period]-First[period];
	end
	
	
	

 end