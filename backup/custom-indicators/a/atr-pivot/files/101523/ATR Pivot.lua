-- Id: 14489
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62454

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
    indicator:name("ATR Pivot");
    indicator:description("ATR Pivot");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("TF", "Pivot Time Frame", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);

    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	
	indicator.parameters:addBoolean("Historical", "Show Historical", "", true);
	
	
	indicator.parameters:addGroup("Level Selection");
	indicator.parameters:addBoolean("On1", " Use 1. Level", "", true);
	indicator.parameters:addDouble("Level1", "Level", "", 33);
	indicator.parameters:addBoolean("On2", " Use 2. Level", "", true);
	indicator.parameters:addDouble("Level2", "Level", "", 50);
	indicator.parameters:addBoolean("On3", " Use 3. Level", "", true);
	indicator.parameters:addDouble("Level3", "Level", "", 66);
	indicator.parameters:addBoolean("On4", " Use 4. Level", "", true);
	indicator.parameters:addDouble("Level4", "Level", "", 100);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Color of Pivot", "Color of Pivot", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color1", "Color of Top", "Color of Bottom", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addColor("color2", "Color of Bottom", "Color of Bottom", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Historical;
local first;
local source = nil;
local loading;
-- Streams block
local Pivot = nil;
local Source;
local TF;
local ATR;
local On={};
local Level={};

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Historical= instance.parameters.Historical;
	TF= instance.parameters.TF;
    source = instance.source;
    first = source:first();
	
	for i= 1 ,4 do
	Level[i]=instance.parameters:getDouble("Level"..i);
	On[i]=instance.parameters:getBoolean("On"..i);
	end
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), Period*2, 100, 101);
	loading=true;
	
	ATR = core.indicators:create("ATR", Source, Period);


    if (not (nameOnly)) then
       instance:ownerDrawn(true);
	end   
	
	

end

local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	if not init then
	context:createPen (1, context:convertPenStyle(instance.parameters.style), instance.parameters.width, instance.parameters.color);
	context:createPen (2, context:convertPenStyle(instance.parameters.style1), instance.parameters.width1, instance.parameters.color1);
	context:createPen (3, context:convertPenStyle(instance.parameters.style2), instance.parameters.width2, instance.parameters.color2);
	init = true;
	end
	
	if loading then
	return;
	else
	ATR:update(core.UpdateAll)
	end 
    
	local  s, e;
	
    
	if Historical  then
	    local p1=  core.findDate (Source, source:date( context:firstBar () ), false) ; 
	    local p2=  core.findDate (Source, source:date( context:lastBar () ), false); 
	
	    p1= math.max(Period, Source:first(),p1);
	    p2= math.max( Source:size()-1 ,p2);
		
		
		for p= p1,p2,1 do
		s, e = core.getcandle(TF, Source:date(p), core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"));   
		
		visible, y = context:pointOfPrice (Source.open[p]); 
		P1=core.findDate (source, s, false);
		P2=core.findDate (source, e, false);
		
		x1, x = context:positionOfBar (P1 );
		x2, x = context:positionOfBar (P2 );
		
	    visible, y = context:pointOfPrice (Source.open[p]); 
		context:drawLine (1, x1, y, x2, y, 0);
			 
			for i= 1 , 4 ,1  do
				if On[i] then
				visible, y = context:pointOfPrice (Source.open[p]+(ATR.DATA[p]/100)*Level[i]);		
				context:drawLine (2, x1, y, x2, y, 0);
				
				visible, y = context:pointOfPrice (Source.open[p]-(ATR.DATA[p]/100)*Level[i]);		
				context:drawLine (3, x1, y, x2, y, 0);
				end
			end
		
		end
	else 
	
	    p = Source:size()-1; 
	    s, e = core.getcandle(TF, Source:date(p), core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"));   
		visible, y = context:pointOfPrice (Source.open[p]);
		P1=core.findDate (source, s, false);
		P2=core.findDate (source, e, false);
		
		x1, x=  context:positionOfBar (P1 );
		x2, x = context:positionOfBar (P2 );
		
	    visible, y = context:pointOfPrice (Source.open[p]); 
		context:drawLine (1, x1, y, x2, y, 0);
		 
		 
		for i= 1 , 4 ,1  do
				if On[i] then
				visible, y = context:pointOfPrice (Source.open[p]+(ATR.DATA[p]/100)*Level[i]);		
				context:drawLine (2, x1, y, x2, y, 0);
				
				visible, y = context:pointOfPrice (Source.open[p]-(ATR.DATA[p]/100)*Level[i]);		
				context:drawLine (3, x1, y, x2, y, 0);
				end
			end
		 
		
	end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period) 
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end


