-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61107

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

function Init()
    indicator:name("Multiple Equidistant Lines");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator); 

    indicator.parameters:addGroup("Channel Calculation");
	
		 indicator.parameters:addDouble("iLevel", "Level", "" , 0); 

	 indicator.parameters:addInteger("Calculation", "Calculation Type", "" , 1); 
    indicator.parameters:addIntegerAlternative("Calculation", "Pips", " Pips" ,   1);
   indicator.parameters:addIntegerAlternative("Calculation", "Percentage", "Percentage" , 2);
  
   indicator.parameters:addIntegerAlternative("Calculation", "Standard deviation", "Standard deviation" , 4);
   	indicator.parameters:addInteger("Helper", "ATR/Standard deviation Period ", "ATR/Standard deviation Period", 14);
	
	indicator.parameters:addInteger("ID", "Indicator ID", "" , 1); 
	

    Add(1, 0.1, 10, 0.01);
	Add(2, 0.2, 20, 0.02);
	Add(3, 0.3, 30, 0.03);
	Add(4, 0.4, 40, 0.04);
	Add(5, 0.5, 50, 0.05);
	Add(6, 0.6, 60, 0.06);
	Add(7, 0.7, 70, 0.07);
	Add(8, 0.8, 80, 0.08);
	Add(9, 0.9, 90, 0.09)
	Add(10, 1, 100, 0.10)
	Add(11, 1.1, 110, 0.11)
	Add(12, 1.2, 120, 0.12)
	Add(13, 1.3, 130, 0.13)
	Add(14, 1.4, 140, 0.14)
	Add(15, 1.5, 150, 0.15)
	Add(16, 1.6, 160, 0.16)
	Add(17, 1.7, 170, 0.17)
	Add(18, 1.8, 180, 0.18)
	Add(19, 1.9, 190, 0.19)
	Add(20, 2, 200, 0.20)
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Bands Line Color","", core.rgb(128, 128, 128));
	 indicator.parameters:addColor("Marker", "Marker Bands Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Cental", "Central Line Color","", core.rgb(0, 0, 255));
	
	indicator.parameters:addColor("Label", "Label Color","", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("points", "Fint Size","", 10);
	indicator.parameters:addBoolean("Show", "Show Label ", "", false);  

end

function Add(id, Value2 ,Value1 ,Value3   )
 
    indicator.parameters:addGroup(id .. ". Level");
    indicator.parameters:addDouble("Percentage"..id, id.. ". Percentage Range", "Percentage Range", Value3);--0,05
	indicator.parameters:addDouble("Pip"..id, id.. ". Pip Range", "Pip Range", Value1);--100
	indicator.parameters:addDouble("Multiplier"..id, id.. ". ATR/Standard deviation Multiplier ", "ATR/Standard deviation Multiplier", Value2);--2
    if id% 5 == 0  then
	indicator.parameters:addColor("Color"..id, "Line Color","", core.rgb(0, 0, 255));
	else
	indicator.parameters:addColor("Color"..id, "Line Color","", core.rgb(128, 128, 128));
	end
	
	indicator.parameters:addInteger("Width".. id , "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style".. id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style".. id, core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Helper;
local Calculation={};
local db; 
local pattern = "([^;]*);([^;]*)";
local firstPeriod;
local source = nil;
local Show;
-- Streams block
 
local Percentage={};
local Pip ={};
local Multiplier={};
local Color={};
local Style={};
local Width={};
local ATR;
local ID;
local iLevel;
-- Routine
function Prepare(nameOnly)
    Helper = instance.parameters.Helper;
	Calculation = instance.parameters.Calculation;
	iLevel = instance.parameters.iLevel;
	ID= instance.parameters.ID;
	
	points= instance.parameters.points;
	Label = instance.parameters.Label;
	Show= instance.parameters.Show;
    
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() ..", " .. ID  ..", " .. iLevel..")";
    instance:name(name);
	if nameOnly then
		return;
	end

	for i= 1 , 20, 1 do
	
	Color[i]=instance.parameters:getColor("Color" .. i);
	Width[i]=instance.parameters:getInteger("Width" .. i);
	Style[i]=instance.parameters:getInteger("Style" .. i);
	Pip[i]=instance.parameters:getDouble("Pip" .. i);
	Percentage[i]=instance.parameters:getDouble("Percentage" .. i);
	Multiplier[i]=instance.parameters:getDouble("Multiplier" .. i);
     
	end
	
	 instance:ownerDrawn(true);
	

	end

-- Indicator calculation routine
function Update(period,mode)
 
   
end
 
local init= true;
function Draw(stage, context)
    if stage ~= 2  
	then
        return ;
    end
	
	
	if init then	
	init=false;
	context:createFont (22, "Arial", context:pointsToPixels (points), context:pointsToPixels (points), 0)
	end

      local Level={};
	   Level[0]=iLevel;
    
 
       visible, y =context:pointOfPrice (Level[0] )
	   context:createPen (1, context.SOLID, 1, instance.parameters.Cental) 	   
	   context:drawLine (1, context:right(), y, context:left(), y, 0);
    for i=1, 20, 1 do  
              if Calculation  == 1 then
			    Value=Pip[i]*source:pipSize(); 				
				elseif Calculation  == 2 then
				Value =(Level[0]/100)*Percentage[i]; 
			 
				elseif Calculation  == 4 then			
                Value= mathex.stdev (source, source:size()-1-Helper+1, source:size()-1)*Multiplier[i];		 
				end
				
				
				context:createPen (2, context:convertPenStyle (Style[i]), Width[i], Color[i]); 	   
	          
	            
				 Level[i]=Level[0] +Value;
				Level[i+20]=Level[0] -Value;
				
				 visible, y1 =context:pointOfPrice (Level[i] )
				 visible, y2 =context:pointOfPrice (Level[i+20] )
	   
			context:drawLine (2, context:right(), y1, context:left(), y1, 0);
			context:drawLine (2, context:right(), y2, context:left(), y2, 0);

		end			
		
		for i=1, 20, 1 do  
		
			if Show then 
			visible, y1 =context:pointOfPrice ( Level[i]);			
			visible, y2 =context:pointOfPrice ( Level[20+i]);
			Text1=string.format("%." .. 2 .. "f",  ( Level[i]- Level[i-1])/source:pipSize())
			if i== 1 then 
			Text2=string.format("%." .. 2 .. "f", math.abs( Level[20+i]- Level[0])/source:pipSize())
			else
			Text2=string.format("%." .. 2 .. "f", math.abs( Level[20+i]- Level[20+i-1])/source:pipSize())
			end
			width1, height1= context:measureText (2, Text1, 0);
			width2, height2= context:measureText (2, Text2, 0);
			context:drawText (22,Text1,Label , -1,context:right()-width1, y1-height1, context:right(), y1, 0);
			context:drawText (22,Text2,Label , -1,context:right()-width2, y2-height2, context:right(), y2, 0);
			end
			

		
		end
end


