-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62324


--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Unusual Volume Price Movement");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Volume Calculation");
	indicator.parameters:addInteger("Average_Period", "Volume Average Period", "Period", 25, 0, 100);
    indicator.parameters:addDouble("Volume_Multiplier", "Volume Multiplier", "Multiplier", 2);
	
	indicator.parameters:addGroup("Price Calculation");
	
	indicator.parameters:addString("Method", "Pip/Percentage", "Method" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Pips", "Pips" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Percentage", "Percentage" , "Percentage");
	indicator.parameters:addInteger("Price_Period", "Price Period", "Period", 25, 0, 100);
	indicator.parameters:addDouble("Value", "Value", "Value", 0);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrup", "Arrow color", "", core.rgb(0, 255,0));
    indicator.parameters:addColor("clrdown", "Arrow color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Size", "", 10);
end
 

local source;
local up, down;
local first; 
local Average_Period;
local Size;
local Volume_Multiplier;
local Method;
local Value;
local Price_Period;
function Prepare()
    source = instance.source;
    instance:name(profile:id());
	Average_Period=instance.parameters.Average_Period;
	Volume_Multiplier=instance.parameters.Volume_Multiplier;
	Price_Period=instance.parameters.Price_Period;
	Value=instance.parameters.Value;
	Method=instance.parameters.Method;
	Size=instance.parameters.Size;	
	first = source:first()+math.max(Average_Period, Price_Period)+1;
	
	local name = string.format("%s(%s, %s, %s, %s, %s, %s, %s)", profile:id(), source:name(), source:barSize(), Average_Period, Volume_Multiplier, Method,Price_Period,Value);
    instance:name(name)
	
    up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.clrup, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.clrdown, 0);    
end
 

function Update(period)
     
	 
	if period <= first then
	up:setNoData (period);
	down:setNoData (period);
	return;
	end
	
	local Average_Volume= mathex.avg(source.volume, period-1-Average_Period+1, period-1);
 
   
        if  source.volume[period]< Average_Volume*Volume_Multiplier
		then
		up:setNoData (period);
	    down:setNoData (period);
		return;
		end
		
		local  Bottom,Top=mathex.minmax(source, period-1-Price_Period+1, period-1);
 
        if Method == "Pips" then
		Top = Top+source:pipSize()*Value;
		Bottom = Bottom - source:pipSize()*Value;
		else
		Top = Top+(Top/100)*Value;
		Bottom = Bottom - (Bottom/100)*Value;
		end
		
        if   source.close[period] >  Top 
		then       
		up:set(period, source.low[period], "\233"); 		 
		down:setNoData (period);
		elseif   source.close[period] <  Bottom     
		then
		down:set(period, source.high[period], "\234");
        up:setNoData (period);		
		else
		up:setNoData (period);
		down:setNoData (period);
        end

       
end