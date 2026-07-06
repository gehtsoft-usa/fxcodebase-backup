
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63772

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



function Init()
    indicator:name("Auto Day Fibs");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    --indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1");
	--indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
 
    indicator.parameters:addInteger("daysBackForHigh", "daysBackForHigh", "", 1);
	indicator.parameters:addInteger("daysBackForLow", "Bar Size to display High/Low", "", 1);
 
    indicator.parameters:addGroup("Selector")
    indicator.parameters:addBoolean("On1" , "1. Line", "", true);
	indicator.parameters:addBoolean("On2" , "2. Line", "", true);
	indicator.parameters:addBoolean("On3" , "3. Line", "", true);
	indicator.parameters:addBoolean("On4" , "4. Line", "", true);
	indicator.parameters:addBoolean("On5" , "5. Line", "", true);
	indicator.parameters:addBoolean("On6" , "6. Line", "", true);
	indicator.parameters:addBoolean("On7" , "7. Line", "", true);
	indicator.parameters:addBoolean("On8" , "8. Line", "", true);
	indicator.parameters:addBoolean("On9" , "9. Line", "", true);
	indicator.parameters:addBoolean("On10" , "10. Line", "", true);
	indicator.parameters:addBoolean("On11" , "11. Line", "", true);
	indicator.parameters:addBoolean("On12" , "12. Line", "", true);
	indicator.parameters:addBoolean("On13" , "13. Line", "", true);
 
 
     indicator.parameters:addGroup("Levels");	 
	 indicator.parameters:addDouble("Level1", "1. Level", "", 150);
	 indicator.parameters:addDouble("Level2", "2. Level", "", 138.2);
	 indicator.parameters:addDouble("Level3", "3. Level", "", 123.6);
	 indicator.parameters:addDouble("Level4", "4. Level", "", 100);
	 indicator.parameters:addDouble("Level5", "5. Level", "", 76.4);
	 indicator.parameters:addDouble("Level6", "6. Level", "", 61.8);
	 indicator.parameters:addDouble("Level7", "7. Level", "", 50);
	 indicator.parameters:addDouble("Level8", "8. Level", "", 38.2);
	 indicator.parameters:addDouble("Level9", "9. Level", "", 23.6);
	 indicator.parameters:addDouble("Level10", "10. Level", "", 0);
	 indicator.parameters:addDouble("Level11", "11. Level", "", -23.6);
	 indicator.parameters:addDouble("Level12", "12. Level", "", -38.2);
	 indicator.parameters:addDouble("Level13", "13. Level", "", -50);
	 
	 indicator.parameters:addGroup("Style");
   
    indicator.parameters:addColor("Color1", "1. Level Color", "",core.rgb(128, 128, 128));	 	
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	
	indicator.parameters:addColor("Color2", "2. Level Color", "",core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	  

	indicator.parameters:addColor("Color3", "3. Level Color", "",core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);	 
	 
	
	indicator.parameters:addColor("Color4", "4. Level Color", "",core.rgb(0,255,0));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
	
   
	indicator.parameters:addColor("Color5", "5. Level Color", "",core.rgb(0,255,0));
	indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("Color6", "6. Level Color", "",core.rgb(0,255,0));
	indicator.parameters:addInteger("width6", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style6", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("Color7", "7. Level Color", "",core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width7", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style7", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style7", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("Color8", "8. Level Color", "",core.rgb(255,0,0));
	indicator.parameters:addInteger("width8", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style8", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style8", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("Color9", "9. Level Color", "",core.rgb(255,0,0));
	indicator.parameters:addInteger("width9", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style9", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style9", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("Color10", "10. Level Color", "",core.rgb(255,0,0));
	indicator.parameters:addInteger("width10", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style10", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style10", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("Color11", "11. Level Color", "",core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width11", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style11", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style11", core.FLAG_LINE_STYLE);
	
	
	
	indicator.parameters:addColor("Color12", "12. Level Color", "",core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width12", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style12", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style12", core.FLAG_LINE_STYLE);	
	
	
    indicator.parameters:addColor("Color13", "13. Level Color", "",core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width13", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style13", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style13", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("Label Style");
	indicator.parameters:addColor("Label", "Label", "",core.COLOR_LABEL );
	indicator.parameters:addInteger("Size", "Size", "",13);
	
	
	
end

 
local source;                   -- the source
 --local TF;
local host;
local offset;
local weekoffset;
local daysBackForHigh, daysBackForLow;
local loading,SourceData;
local Level={};
local Color={};
local Style={};
local Width={};
local Size, Label;
local On={};
function Prepare(nameOnly) 
  
    source = instance.source;
    host = core.host;
	--TF=instance.parameters.TF;
	Size=instance.parameters.Size;
	Label=instance.parameters.Label;
	
	for i= 1, 13, 1 do
	Level[i]=instance.parameters:getDouble("Level" .. i);
	Color[i]=instance.parameters:getColor("Color" .. i);
	Style[i]=instance.parameters:getInteger("style" .. i);
	Width[i]=instance.parameters:getInteger("width" .. i);
	On[i]=instance.parameters:getBoolean("On" .. i);
	end
	
	daysBackForHigh=instance.parameters.daysBackForHigh;
	daysBackForLow=instance.parameters.daysBackForLow;
	
	 local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

	
	if   (nameOnly) then
        return;
    end
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle("D1", 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
	
	SourceData = core.host:execute("getSyncHistory", source:instrument(), "D1", source:isBid(), math.max(daysBackForHigh, daysBackForLow)+1, 100, 101);
	loading=true;
	
   
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	instance:ownerDrawn(true);


end

local init = false;
 
function Draw(stage, context)
    if stage ~= 2 
	or loading
	then
	return;
	end
	
        if not init then
		
		    for i= 1, 13, 1 do 
            context:createPen (i, context:convertPenStyle (Style[i]), Width[i], Color[i])
			end
			context:createFont (20, "Arial", Size, Size, context.CENTER);
			
            init = true;
        end
 
  local period= SourceData.high:size()-1;
  local High = SourceData.high[ period - daysBackForHigh];
  local  Low =  SourceData.low[period - daysBackForLow];
  local  Range =  High-Low;
  
    for i= 1, 13, 1 do
	
	        if On[i] then
			if daysBackForHigh > daysBackForLow then
			visible, y =context:pointOfPrice (High -( Range/100)*Level[i]);
			else
			visible, y =context:pointOfPrice (Low +( Range/100)*Level[i]);
			end
			width, height =context:measureText (20, tostring(Level[i]), context.CENTER);
			context:drawText (20, tostring(Level[i]), Label, -1, context:right ()-50-width, y-height, context:right ()-50, y, context.CENTER);
			context:drawLine (i, context:left (), y, context:right (), y);
			end
	end
end 
   
 

-- the function which is called to calculate the period
function Update(period, mode)
   
end

function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end
