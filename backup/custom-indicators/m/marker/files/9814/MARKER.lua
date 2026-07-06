-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3963
-- Id: 3675

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Marker");
    indicator:description("Marker");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("LookBack", "LookBack Period", "", 0);
	
	 indicator.parameters:addGroup("Mode");
	 indicator.parameters:addString("Mode", "Market Type", "", "Trailing");
    indicator.parameters:addStringAlternative("Mode", "Trailing", "", "Trailing");
	indicator.parameters:addStringAlternative("Mode", "Locked", "", "Locked");

	 indicator.parameters:addGroup("Marker Style");
	  indicator.parameters:addColor("Color", "Bar Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("Width", "Width", "The width of the marker, range is 5 to 20.", 15, 5, 20);
	indicator.parameters:addString("Type", "Market Type", "", "Candle");
    indicator.parameters:addStringAlternative("Type", "Candle", "", "Candle");
	indicator.parameters:addStringAlternative("Type", "Marker", "", "Marker");
	indicator.parameters:addStringAlternative("Type", "Label", "", "Label");

	indicator.parameters:addGroup("Label Settings");
	indicator.parameters:addString("LabelText", "Label Text", "The label text.", "Label");
	indicator.parameters:addColor("LabelColor", "Label Color", "The text color.", core.rgb(0, 128, 0));
	indicator.parameters:addString("LabelFontFamily", "Label Font", "The label font.", "Verdana");
	indicator.parameters:addStringAlternative("LabelFontFamily", "Verdana", "", "Verdana");
	indicator.parameters:addStringAlternative("LabelFontFamily", "Arial", "", "Arial");
	indicator.parameters:addStringAlternative("LabelFontFamily", "Tahoma", "", "Tahoma");
	indicator.parameters:addStringAlternative("LabelFontFamily", "Times New Roman", "", "Times New Roman");
	indicator.parameters:addInteger("LabelFontSize", "Label Font Size", "The font size of the label.", 10, 5, 72);
	
	indicator.parameters:addGroup("Default candles color Settings (Do not change it)");
	 indicator.parameters:addColor("UpColor", "Default color of ascending candles", "Do not change it", core.COLOR_UPCANDLE);
	  indicator.parameters:addColor("DownColor", "Default color of descending candles", "Do not change it", core.COLOR_DOWNCANDLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Color;
local Width;
local LookBack=0;
local Type;

local LabelText;
local LabelColor;
local LabelFontFamily;
local LabelFontSize;

local first;
local source = nil;

-- Streams block
local open=nil;
local close=nil;
local high=nil;
local low=nil;

local MARKER;
local Mode;
local LAST=nil;
local FIRST= true;
-- Routine
function Prepare(nameOnly)
    Mode = instance.parameters.Mode;
    Type = instance.parameters.Type;
    Color = instance.parameters.Color;
    Width = instance.parameters.Width;

    LabelText = instance.parameters.LabelText;
    LabelColor = instance.parameters.LabelColor;
    LabelFontFamily = instance.parameters.LabelFontFamily;
    LabelFontSize = instance.parameters.LabelFontSize;

	 LookBack = instance.parameters.LookBack;
    source = instance.source;
    first = source:first();


    local name

    if LookBack ~= 0 then
	name = profile:id() .. "(" .. source:name() .. ", " .. tostring(LookBack) .. ", " .. tostring(Type).. ", " .. tostring(Mode) .. ")";
	else
	name = profile:id() .. "(" .. source:name() .. ")";
	end
    instance:name(name);

    if (not (nameOnly)) then
			if Type  == "Candle" then
				open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
				high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
				low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
				close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
				instance:createCandleGroup("MARKER", "", open, high, low, close);
			elseif Type == "Marker" then
				MARKER = instance:createTextOutput ("MARKER", "MARKER", "Wingdings", Width, core.H_Center, core.V_Bottom, instance.parameters.Color, 0);
			else
				MARKER = instance:createTextOutput ("MARKER", "MARKER", LabelFontFamily, LabelFontSize, core.H_Center, core.V_Bottom, LabelColor, 0);
			end
    end
	
	FIRST= true
    LAST=nil;
end


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period >= first and source:hasData(period) then

	
			if Mode == "Trailing" then
			
						if source:serial(source:size()-1) ~= LAST  and period == source:size()-1 then
						  
						  
						  
						   if LookBack ~= 0  and LookBack+1 < period  then
						  
						   LAST  = source:serial(source:size()-1);

								if Type  == "Candle" then
									high[period-LookBack]= source.high[period-LookBack];
									low[period-LookBack]= source.low[period-LookBack];
									close[period-LookBack] = source.close[period-LookBack];
									open[period-LookBack]  = source.open[period-LookBack];
									open:setColor(period-LookBack, Color);
									
									
									if open[period-LookBack-1] <  close[period-LookBack-1] then
									open:setColor(period-LookBack-1,  instance.parameters.UpColor );
									else
									open:setColor(period-LookBack-1, instance.parameters.DownColor );
									end
									
													
								elseif Type == "Marker" then
									MARKER:set(period-LookBack, source.low[period-LookBack] , "\108");				
									MARKER:setNoData (period-LookBack-1);
								else
									MARKER:set(period-LookBack, source.low[period-LookBack] , LabelText);
									MARKER:setNoData (period-LookBack-1);
								end

							end
						  
						  
						end  
			
				 else
					
					
					 if  FIRST and  period == source:size()-1 then	
					     FIRST = false;
						  
							if LookBack ~= 0  and LookBack+1 < period  then							

								if Type  == "Candle" then
									high[period-LookBack]= source.high[period-LookBack];
									low[period-LookBack]= source.low[period-LookBack];
									close[period-LookBack] = source.close[period-LookBack];
									open[period-LookBack]  = source.open[period-LookBack];
									open:setColor(period-LookBack, Color);
									
									
									if open[period-LookBack-1] <  close[period-LookBack-1] then
									open:setColor(period-LookBack-1,  instance.parameters.UpColor );
									else
									open:setColor(period-LookBack-1, instance.parameters.DownColor );
									end
									
													
								elseif Type == "Marker" then
									MARKER:set(period-LookBack, source.low[period-LookBack] , "\108");				
									MARKER:setNoData (period-LookBack-1);
								else
									MARKER:set(period-LookBack, source.low[period-LookBack] , LabelText);
									MARKER:setNoData (period-LookBack-1);
								end

							end
						  
						  
					end	  
				 

				 end
      
    end
end