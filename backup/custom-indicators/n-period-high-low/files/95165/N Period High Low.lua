-- Id: 12234
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60992

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
    indicator:name("N Period High Low");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation"); 	 
    indicator.parameters:addInteger("Period", "Period", "", 4);
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("HighColor", "High Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("LowColor", "Low Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("Style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("Width", "Line Width", "", 1, 1, 5);
	indicator.parameters:addInteger("Size", "Font Size", "", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	local Period;
 
	local source = nil;
	local TF;
	local host;
	local offset;
	local weekoffset;
	local SourceData;
	local loading = false;   
    local HighColor,LowColor,Size;
   local Width,Style,Label;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	HighColor = instance.parameters.HighColor;
	LowColor = instance.parameters.LowColor;
	Label = instance.parameters.Label;
	Width = instance.parameters.Width;
	Style = instance.parameters.Style;
	Size = instance.parameters.Size;
    source = instance.source;
     
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    TF = instance.parameters.TF;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(TF) .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), math.max(300,Period+1), 100, 101);
	loading=true;
	
    
	 instance:ownerDrawn(true);

end
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 
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

local init = false;

function Draw(stage, context)
    if stage ~= 0 then
	return;
	end
        if not init then
            context:createPen (1, context:convertPenStyle (Style),Width, HighColor);
			context:createPen (2, context:convertPenStyle (Style), Width, LowColor);
			context:createFont (3, "Arial", Size, Size, context.RIGHT);
            init = true;
        end
		
	local x1=context:left ();
	local x2=context:right ()
	
	local High,Low;
		
	for i= 1,Period,1 do
	
	   j = SourceData:size()-1 - i+1;
	   
	  
	            if SourceData:hasData(j) then
				index = core.findDate (source, SourceData:date(j), false);
				 
				High=SourceData.high[j];
				Low=SourceData.low[j]; 
				
				visible, y = context:pointOfPrice (High);
					if visible then
					context:drawLine (1, x1, y, x2, y );
					text1= tostring (i) .. ". H";
					text2=" : " ..  string.format("%." ..  source:getPrecision()  .. "f", High);
					width, height =context:measureText (3, text1..text2,  context.RIGHT)
					context:drawText (3, text1..text2, Label, -1, x2-width, y-height, x2, y, context.RIGHT);
					x, o, o= context:positionOfBar (index);
					width, height =context:measureText (3, text1,  context.RIGHT);
					context:drawText (3, text1, Label, -1, x-width, y-height, x, y, context.RIGHT);
					end
				visible, y =context:pointOfPrice (Low);	
					if visible then
					context:drawLine( 2, x1, y, x2, y );
					text1= tostring (i) .. ". L";
					text2= " : " .. string.format("%." ..  source:getPrecision()  .. "f", Low);
					width, height =context:measureText (3, text1..text2,  context.RIGHT)
					context:drawText (3, text1..text2, Label, -1, x2-width, y-height, x2, y, context.RIGHT);
					x, o, o= context:positionOfBar (index);
					width, height =context:measureText (3, text1,  context.RIGHT);
					context:drawText (3, text1, Label, -1, x-width, y-height, x, y, context.RIGHT);
					end
				end	
	end
	
end


