-- Id: 14379

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62378

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

-- Indicator profile initialization routine
-- If the current bars of AC and AO are green, it shows that the zone is green.
-- If the current bars of �� and �� red, it shows that the zone is red.
-- If the bars of AC and AO are differently directed then the bar is colored grey (grey zone).
function Init()
    indicator:name("Transactional Value Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("lbl", "Look Back Period Length", "Look Back Period Length", 5);
    indicator.parameters:addDouble("sd", "Zone Multiplier", "Zone Multiplier", 0.2);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up Trend Color","Up Trend Color", core.rgb(0,255,0));
	indicator.parameters:addColor("Down", "Down Trend Color","Down Trend Color", core.rgb(255,0,0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","Neutral Trend Color", core.rgb(128,128,128));
	
	
	indicator.parameters:addGroup("Zero Level");
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("Fair Value Levels");	
    indicator.parameters:addDouble("overbought1", "Overbought Level","", 4);
    indicator.parameters:addDouble("oversold1","Oversold Level","", -4);
	indicator.parameters:addColor("level_overboughtsold_color1", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width1","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style1", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style1", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("Over Value Levels");	
    indicator.parameters:addDouble("overbought2", "Overbought Level","", 8);
    indicator.parameters:addDouble("oversold2","Oversold Level","", -8);
	indicator.parameters:addColor("level_overboughtsold_color2", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width2","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style2", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style2", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("Extremely Over Value Levels");	
    indicator.parameters:addDouble("overbought3", "Overbought Level","", 12);
    indicator.parameters:addDouble("oversold3","Oversold Level","", -12);
	indicator.parameters:addColor("level_overboughtsold_color3", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width3","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style3", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style3", core.FLAG_LEVEL_STYLE);
	
	


	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 

local first;
local source = nil;

-- Streams block
 local lbl,sd;

local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Up, Down, Neutral;
local ATR;
-- Routine
function Prepare(nameOnly)
    
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral; 
	
	sd = instance.parameters.sd;
	lbl = instance.parameters.lbl;
	
	
    source = instance.source; 
    first = source:first()+lbl;	

    local name = profile:id() .. "(" .. source:name() .. ", "  .. lbl .. ", " .. sd .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	ATR = core.indicators:create("ATR", source,lbl );
    
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    low:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    close:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	
	open:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
	open:addLevel(instance.parameters.oversold1, instance.parameters.level_overboughtsold_style1, instance.parameters.level_overboughtsold_width1, instance.parameters.level_overboughtsold_color1);
	open:addLevel(instance.parameters.overbought1, instance.parameters.level_overboughtsold_style1, instance.parameters.level_overboughtsold_width1, instance.parameters.level_overboughtsold_color1);    
	
    open:addLevel(instance.parameters.oversold2, instance.parameters.level_overboughtsold_style2, instance.parameters.level_overboughtsold_width2, instance.parameters.level_overboughtsold_color2);
	open:addLevel(instance.parameters.overbought2, instance.parameters.level_overboughtsold_style2, instance.parameters.level_overboughtsold_width2, instance.parameters.level_overboughtsold_color2);    	
	
	open:addLevel(instance.parameters.oversold3, instance.parameters.level_overboughtsold_style3, instance.parameters.level_overboughtsold_width3, instance.parameters.level_overboughtsold_color3);
	open:addLevel(instance.parameters.overbought3, instance.parameters.level_overboughtsold_style3, instance.parameters.level_overboughtsold_width3, instance.parameters.level_overboughtsold_color3);    
	
end

-- Indicator calculation routine
function Update(period, mode)

   
    ATR:update(mode);
	
   	if period < first  or not source:hasData(period) then
	open:setColor(period, Neutral);		
    return;
    end 
	
	 local sma= mathex.avg(source.close, period-lbl+1, period);
	
	
	open[period] = ((source.open[period]-sma)/ATR.DATA[period])/sd
    close[period] = ((source.close[period]-sma)/ATR.DATA[period])/sd
    high[period]  = ((source.high[period]-sma)/ATR.DATA[period])/sd
    low[period] = ((source.low[period]-sma)/ATR.DATA[period])/sd
     

  
				   

		        if close[period]> open[period] then
				open:setColor(period, Up);
				elseif close[period]< open[period] then
				open:setColor(period, Down);				  
			    else
		        open:setColor(period, Down);	
				end  
    end

	