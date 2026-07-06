-- Id: 14462
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62435

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Average True Range Bands");
    indicator:description("Average True Range Bands");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 2);
	
	indicator.parameters:addString("Method", "Method", "Method" , "Close");
    indicator.parameters:addStringAlternative("Method", "Close", "Close" , "Close");
    indicator.parameters:addStringAlternative("Method", "High/Low", "High/Low" , "High/Low");
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addColor("color1", "Color of Top Line", "Color of Line", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

	indicator.parameters:addColor("color2", "Color of Bottom Line", "Color of Line", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Deviation Line Style");	
	indicator.parameters:addBoolean("Show", "Show Deviation Lines", "", false);
    indicator.parameters:addColor("color3", "Color of Top Line", "Color of Line", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);

	indicator.parameters:addColor("color4", "Color of Bottom Line", "Color of Line", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
	
	
	end



-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Deviation;
local Method;
local first;
local source = nil;
local ATR;
-- Streams block
local Show, top,bottom;
local Top,Bottom;
local Trend;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Deviation = instance.parameters.Deviation;
	Method= instance.parameters.Method;
    source = instance.source;
	
	Show= instance.parameters.Show;
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Deviation) .. ", " .. tostring(Method).. ")";
    instance:name(name);

    if (not (nameOnly)) then
		ATR = core.indicators:create("ATR", source, Period);
		first = ATR.DATA:first();
		
		Trend= instance:addInternalStream(0, 0);
        Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first);
		Top:setWidth(instance.parameters.width1);
        Top:setStyle(instance.parameters.style1);
		
		Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, first);
		Bottom:setWidth(instance.parameters.width2);
        Bottom:setStyle(instance.parameters.style2)
		if Show then
		top = instance:addStream("Top_Deviation", core.Line, name, "Top Deviation", instance.parameters.color3, first);
		top:setWidth(instance.parameters.width3);
        top:setStyle(instance.parameters.style3);
		
		bottom = instance:addStream("Bottom_Deviation", core.Line, name, "Bottom Deviation", instance.parameters.color4, first);
		bottom:setWidth(instance.parameters.width4);
        bottom:setStyle(instance.parameters.style4)
		else
		top= instance:addInternalStream(0, 0);
		bottom= instance:addInternalStream(0, 0);
		end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    ATR:update(mode)
	
	if period< first or not source:hasData(period) then
	return;
	end
	
	if source.close[period]> Top[period-1] then
	Trend[period]= 1;
	elseif source.close[period]< Bottom[period-1] then
	Trend[period]= -1; 
	else
	Trend[period]= Trend[period-1];
	end
	
	if Trend[period]== 1  then
	
	          
			 
			   if Method== "Close" then
			   Bottom[period]=source.close[period]-ATR.DATA[period]*Deviation;
			   Top[period]=source.close[period]+ATR.DATA[period]*Deviation;
			   else
			    Top[period]=source.low[period]+ATR.DATA[period]*Deviation;
			   Bottom[period]=source.high[period]-ATR.DATA[period]*Deviation;   
			   end
	        
			  if Bottom[period]< Bottom[period-1] then
			  Bottom[period]=Bottom[period-1];
			  end
		    
	elseif Trend[period]==-1 then
	
	          
			   
			   if Method== "Close" then
			   Bottom[period]=source.close[period]-ATR.DATA[period]*Deviation;
			   Top[period]=source.close[period]+ATR.DATA[period]*Deviation;
			   else
			   Bottom[period]=source.high[period]-ATR.DATA[period]*Deviation; 
			    Top[period]=source.low[period]+ATR.DATA[period]*Deviation;
			   end
			   
			  if Top[period]> Top[period-1] then
			  Top[period]= Top[period-1];
			  end
 
	end
	
	if Show then
	
	           if Method== "Close" then
			   bottom[period]=source.close[period]+ATR.DATA[period]*Deviation;
			   else
			   bottom[period]=source.low[period]+ATR.DATA[period]*Deviation;   
			   end
			   
			   if Method== "Close" then
			   top[period]=source.close[period]-ATR.DATA[period]*Deviation;
			   else
			   top[period]=source.high[period]-ATR.DATA[period]*Deviation;
			   end
	
	end
	
	 
    
end
 

