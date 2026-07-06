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
    indicator:name("Centred moving average Channel");
    indicator:description("Centred moving average Channel");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
     indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addString("Mode", "Calculation Mode", "", "Dynamic");
    indicator.parameters:addStringAlternative("Mode", "Dynamic", "", "Dynamic");
    indicator.parameters:addStringAlternative("Mode", "Static", "", "Static");
	
	 indicator.parameters:addInteger("Calculation", "Calculation Type", "" , 1); 
    indicator.parameters:addIntegerAlternative("Calculation", "Pips", " Pips" ,   1);
   indicator.parameters:addIntegerAlternative("Calculation", "Percentage", "Percentage" , 2);
   
    indicator.parameters:addDouble("Percentage", "Percentage Range", "Percentage Range", 0.5);
	indicator.parameters:addDouble("Pip", "Pip Range", "Pip Range", 100);

	 indicator.parameters:addGroup("Style");
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
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    Mode = instance.parameters.Mode;
	Calculation = instance.parameters.Calculation;
    Period = instance.parameters.Period;
	Pip = instance.parameters.Pip;
	Percentage = instance.parameters.Percentage;
    source = instance.source;
   
   local Note;
   
   if Calculation == 1 then
   Note ="Pip";
   else
   Note = "Percentage";
   end
 
	
	assert(core.indicators:findIndicator("CMA") ~= nil, "Please, download and install CMA.LUA indicator");
    CMA = core.indicators:create( "CMA" , source, Period);

	 first =CMA.DATA:first()+Period/2+1;

    
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

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period , mode)

 
   
   

	
	
	  
   if   Mode == "Dynamic" and period > (period - Period /2 ) then
   
     CMA:update(core.UpdateAll);
   
       local i;
		for i= period - Period /2 , period, 1 do
		
		
		   if i > CMA.DATA:first() then
				Central[i]=  CMA.DATA[i];	
				
				if Calculation  == 1 then
				Top[i]=Central[i] +Pip*source:pipSize();
				Bottom[i]=Central[i] -Pip*source:pipSize();
				else
				
				Top [i]= Central[i] +(Central[i]/100)*Percentage;
				Bottom [i]= Central[i] - (Central[i]/100)*Percentage;
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
		else
		
		Top [period]= Central[period] +(Central[period]/100)*Percentage;
		Bottom [period]= Central[period] - (Central[period]/100)*Percentage;
		end
		
   end
   
  
   
    
end

