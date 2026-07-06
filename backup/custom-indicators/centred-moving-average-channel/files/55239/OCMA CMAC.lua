-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32423

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("OCMA Centred moving average Channel");
    indicator:description("OCMA Centred moving average Channel");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
     indicator.parameters:addGroup("CMA Calculation");
	 
	 	indicator.parameters:addString("Method", "CMA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addString("Mode", "Calculation Mode", "", "Dynamic");
    indicator.parameters:addStringAlternative("Mode", "Dynamic", "", "Dynamic");
    indicator.parameters:addStringAlternative("Mode", "Static", "", "Static");
	
	indicator.parameters:addGroup("Channel Calculation");
	 indicator.parameters:addInteger("Calculation", "Calculation Type", "" , 1); 
    indicator.parameters:addIntegerAlternative("Calculation", "Pips", " Pips" ,   1);
   indicator.parameters:addIntegerAlternative("Calculation", "Percentage", "Percentage" , 2);
   indicator.parameters:addIntegerAlternative("Calculation", "ATR", "ATR" , 3);
   indicator.parameters:addIntegerAlternative("Calculation", "Standard deviation", "Standard deviation" , 4);
   
    indicator.parameters:addDouble("Percentage", "Percentage Range", "Percentage Range", 0.5);
	indicator.parameters:addDouble("Pip", "Pip Range", "Pip Range", 100);
	indicator.parameters:addInteger("Helper", "ATR/Standard deviation Period ", "ATR/Standard deviation Period", 14);
	indicator.parameters:addDouble("Multiplier", "ATR/Standard deviation Multiplier ", "ATR/Standard deviation Multiplier", 2);
	
	

	 indicator.parameters:addGroup("Style");
	 
	 indicator.parameters:addBoolean("Show", "Show Indicator Output", "", true);
	 
     indicator.parameters:addColor("color11", "Top Line Actual Color ", "", core.rgb(0, 0,255));	 
	 indicator.parameters:addColor("color12", "Top Line Predicted Color", "", core.rgb(0, 0,255));	 

	 indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color21", "Bottom Line  Actual Color", "", core.rgb(0, 0,255));	 
	 indicator.parameters:addColor("color22", "Bottom Line Predicted Color", "", core.rgb(0,0,255));	 
	 indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color31", "Central Line Actual Color ", "", core.rgb(0, 255, 0));	 
	 indicator.parameters:addColor("color32", "Central Line Predicted Color ", "", core.rgb(255, 0, 0));	  
	 indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local first;
local source = nil;
local Calculation;
-- Streams block
local CMA = nil;
local Top, Bottom, Central;
local Mode,Percentage,Pip; 
local Method;
local Helper;
local ATR;
local Dev;
local Multiplier;
local Show;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    Mode = instance.parameters.Mode;
	Calculation = instance.parameters.Calculation;
	Helper = instance.parameters.Helper;
	Method = instance.parameters.Method;
    Period = instance.parameters.Period;
	Pip = instance.parameters.Pip;
	Percentage = instance.parameters.Percentage;
	Multiplier = instance.parameters.Multiplier;
	Show = instance.parameters.Show;
    source = instance.source;
   
   local Note;
   
   if Calculation == 1 then
   Note ="Pip";
   elseif Calculation == 2 then
   Note = "Percentage";
   elseif Calculation == 3 then
   Note = "ATR";
    elseif Calculation == 4 then
   Note = "Standard deviation";
   Dev = instance:addInternalStream(0, 0);
   end
 
	
	assert(core.indicators:findIndicator("OCMA") ~= nil, "Please, download and install OCMA.LUA indicator");
    CMA = core.indicators:create( "OCMA" , source.close, Period,Method);
    ATR= core.indicators:create( "ATR" , source, Helper);
	 
	 first =math.max(CMA.DATA:first(), ATR.DATA:first())+Period/2+1;
	 
	
	 

    
	    if Show then
        Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color11, first);
		Top:setWidth(instance.parameters.width1);
        Top:setStyle(instance.parameters.style1);
		
		Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color21, first);
		Bottom:setWidth(instance.parameters.width2);
        Bottom:setStyle(instance.parameters.style2);
		
		Central = instance:addStream("Central", core.Line, name, "Central", instance.parameters.color31, first);
		Central:setWidth(instance.parameters.width3);
        Central:setStyle(instance.parameters.style3);
		 
	 
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period , mode)
  
   if not Show then
   return;
   end 
   
   if Calculation == 3 then
   ATR:update(mode);
   
	   if period < ATR.DATA:first() then
	   return;
	   end
    elseif Calculation == 4 then  


		if period < Helper then
		   return;
		   end	
		Dev[period]= mathex.stdev (source.close, period-Helper+1, period);
   end
    
   
   if   Mode == "Dynamic" and period > (period - Period /2 ) then
   
     CMA:update(core.UpdateAll);
   
       local i;
		for i= period - Period /2 , period, 1 do
		
		
		   if i > CMA.DATA:first() then
				Central[i]=  CMA.DATA[i];	
				
				if Calculation  == 1 then
				Top[i]=Central[i] +Pip*source:pipSize();
				Bottom[i]=Central[i] -Pip*source:pipSize();
				elseif Calculation  == 2 then
				
				Top [i]= Central[i] +(Central[i]/100)*Percentage;
				Bottom [i]= Central[i] - (Central[i]/100)*Percentage;
				elseif Calculation  == 3 then				
				Top [i]= Central[i] +ATR.DATA[i]*Multiplier;
				Bottom [i]= Central[i] - ATR.DATA[i]*Multiplier;
				elseif Calculation  == 4 then				
				Top [i]= Central[i] +Dev[i]*Multiplier;
				Bottom [i]= Central[i] - Dev[i]*Multiplier;
				end

				
				Central:setColor(i, instance.parameters.color32);
				Top:setColor(i, instance.parameters.color12);
				Bottom:setColor(i, instance.parameters.color22);
		    end
		end		
		
		if period- Period/2-1 >= Central:first() then
		 Central:setColor(period- Period/2-1 , instance.parameters.color31);
		Top:setColor(period- Period/2-1, instance.parameters.color11);
		Bottom:setColor(period- Period/2-1, instance.parameters.color21);
		end
		
   else    
   
        CMA:update(mode);
      Central[period]=  CMA.DATA[period];	
	  
	   if Calculation == 1 then
		Top[period]=Central[period] +Pip*source:pipSize();
		Bottom[period]=Central[period] -Pip*source:pipSize();
		elseif Calculation == 2 then
		
		Top [period]= Central[period] +(Central[period]/100)*Percentage;
		Bottom [period]= Central[period] - (Central[period]/100)*Percentage;
		elseif Calculation  == 3 then				
				Top [period]= Central[period] +ATR.DATA[period]*Multiplier;
				Bottom [period]= Central[period] - ATR.DATA[period]*Multiplier;
		elseif Calculation  == 4 then				
				Top [period]= Central[period] +Dev[period]*Multiplier;
				Bottom [period]= Central[period] - Dev[period]*Multiplier;
		end
		
   end
   
  
   
    
end

