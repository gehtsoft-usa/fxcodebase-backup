-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65839

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("On Chart Colored RSI Moving Average");
    indicator:description("On Chart Colored RSI Moving Average");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Indicator Calculation");
	
	indicator.parameters:addString("Position", "Overlay Position", "", "B");
    indicator.parameters:addStringAlternative("Position", "Bottom", "", "B");
    indicator.parameters:addStringAlternative("Position", "Top", "", "T");
	indicator.parameters:addStringAlternative("Position", "Central", "", "C");
	
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI_Period", "RSI period", "", 14);
    indicator.parameters:addInteger("MA_Period", "MA period", "", 14);
    indicator.parameters:addString("MA_Method", "MA method", "", "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MA_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MA_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MA_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MA_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MA_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MA_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MA_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MA_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MA_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MA_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MA_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MA_Method", "JSmooth", "", "JSmooth");

    indicator.parameters:addGroup("Style");
	
	indicator.parameters:addBoolean("Show", "Show RSI", "", false);
	
    indicator.parameters:addColor("color1", "RSI Color", "RSI Color", core.rgb(0, 0, 288));
	
	indicator.parameters:addInteger("width1", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Up", "MA Color Up", "MA Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "MA Color Down", "MA Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	

	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
 
local first;
local source = nil;

local RSI_Period;
local MA_Period;
local MA_Method;
local RSI_Buff = nil;
local MA_Buff = nil;
local RSI;
local MA;
local Show;
-- Routine
 function Prepare(nameOnly)   
 
    RSI_Period=instance.parameters.RSI_Period;
    MA_Period=instance.parameters.MA_Period;
    MA_Method=instance.parameters.MA_Method;
	Show=instance.parameters.Show;
	 
	 
	source = instance.source;
	 
	 local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSI_Period .. ", " .. instance.parameters.MA_Period .. ", " .. instance.parameters.MA_Method .. ")";
    instance:name(name);
	
	
	 if   (nameOnly) then
        return;
    end

	
	
    Position = instance.parameters.Position;   
    
 
   
   assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    RSI = core.indicators:create("RSI", source, RSI_Period);
    MA = core.indicators:create("AVERAGES", RSI.DATA, MA_Method, MA_Period, false);
	
	first =MA.DATA:first();
	
 
    instance:ownerDrawn(true);

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)    
	
	RSI:update(mode);
    MA:update(mode);
	
	
end


local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	
        if not init then
            context:createPen (1, context:convertPenStyle (instance.parameters.style1), instance.parameters.width1, instance.parameters.color1);
	        context:createPen (2, context:convertPenStyle (instance.parameters.style2), instance.parameters.width2, instance.parameters.Up);
			context:createPen (3, context:convertPenStyle (instance.parameters.style2), instance.parameters.width2, instance.parameters.Down);
			
            init = true;
        end
		
	   local Delta=(context:bottom ()-context:top ())/4;
	   
	   if Position== "T" then
	   Top =  context:top (); 
       Bottom =  context:top()+Delta; 
	   elseif Position== "B" then
	   Top =  context:bottom ()-Delta; 
       Bottom =  context:bottom(); 
	   else
	   Top =  context:bottom ()-(context:bottom ()-context:top ())/2 -Delta/2; 
       Bottom =  context:bottom()-(context:bottom ()-context:top ())/2+ Delta/2; 
	   end
	   
	   y1= Bottom - (Delta/100) * 50;
	   
	   
	   context:drawLine (2, context:left (), y1, context:right (), y1);
	 --  context:drawLine (3, context:left (), y2, context:right (), y2);
		
		for period=math.max(RSI.DATA:first(), MA.DATA:first(),context:firstBar ())+1, math.min(source:size()-1, context:lastBar ()), 1 do
		
		
		
		x1, x, x = context:positionOfBar (period-1);
		x2, x, x =  context:positionOfBar (period);
		
			if Show then
			y1= Bottom - (Delta/100) * RSI.DATA[period-1];
			y2= Bottom - (Delta/100) *  RSI.DATA[period];
			context:drawLine (1, x1, y1, x2, y2);
			end 
			
			
			if MA.DATA[period]> 50 then
			
			   y1= Bottom - (Delta/100) * MA.DATA[period-1];
			   y2= Bottom - (Delta/100) *  MA.DATA[period];
			   context:drawLine (2, x1, y1, x2, y2);
			
			else
			   y1= Bottom - (Delta/100) * MA.DATA[period-1];
			   y2= Bottom - (Delta/100) *  MA.DATA[period];
			   context:drawLine (3, x1, y1, x2, y2);
			
			end
			
		end
		
 
 
	
 
	
	 
end	

 

 

 