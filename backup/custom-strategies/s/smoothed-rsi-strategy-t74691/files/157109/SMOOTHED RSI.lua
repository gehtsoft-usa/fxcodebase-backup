
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2675

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Smoothed RSI");
    indicator:description("Smoothed RSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("RSIFrame", "RSI Period", "No description", 14);
	
	indicator.parameters:addGroup("MA Parameters");
    indicator.parameters:addInteger("MAFrame", "MA Period", "No description", 10);
	indicator.parameters:addString("Method", "MA Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "", "TMA"); 
	
		
	indicator.parameters:addGroup("Overbought/oversold Level");
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 70, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 30, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", "Over Bought/Sold Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Over Bought/Sold Line Style", "", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Over Bought/Sold Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addGroup("MA Line Style");	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("signal_color", "MALine Color", "", core.rgb(128, 128, 128));
	
	indicator.parameters:addGroup("Cloud Style");	
	indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb( 0, 255, 0));   
    indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	
	indicator.parameters:addGroup("Alert Style");
	indicator.parameters:addInteger("Size", "Alert Size", "", 10);
	indicator.parameters:addColor("UpSignal", "Color of Up", "Color of Up", core.rgb( 0, 255, 0));   
    indicator.parameters:addColor("DownSignal", "Color of Down", "Color of Down", core.rgb(255, 0, 0));

	indicator.parameters:addBoolean("strategy_mode", "Is run under strategy?", "", false);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RSIFrame;
local MAFrame;
local Method;
local Transparency,UpColor, DownColor,UpSignal,DownSignal;

local Up=nil;
local Down=nil;

local first;
local source = nil;

-- Streams block
local Size;
local MA = nil;
local Indicator={};
local Zero ;
local Long;
local Short; 

-- Routine
function Prepare(nameOnly)
    Method = instance.parameters.Method;
    RSIFrame = instance.parameters.RSIFrame;
    MAFrame = instance.parameters.MAFrame;
	Transparency=instance.parameters.Transparency;
	UpColor=instance.parameters.Up;
	DownColor=instance.parameters.Down;
	Size=instance.parameters.Size;
	Transparency= 100-Transparency;
	UpSignal=instance.parameters.UpSignal;
	DownSignal=instance.parameters.DownSignal;
	
    source = instance.source; 
	local name = profile:id() .. "(" .. source:name() .. ", " .. RSIFrame .. ", " .. MAFrame .. "," .. Method.. ")";
    instance:name(name);	
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install "..Method.." indicator");
	
	Indicator[1]= core.indicators:create("RSI", source, RSIFrame);	 
	
	Long = instance:createTextOutput ("Long", "Long", "Wingdings", Size, core.H_Center, core.V_Bottom, UpSignal, 0);
    Short = instance:createTextOutput ("Short", "Short", "Wingdings", Size, core.H_Center, core.V_Top, DownSignal, 0);
	if not instance.parameters.strategy_mode then
		core.host:execute ("attachTextToChart", "Long")
		core.host:execute ("attachTextToChart", "Short")
	end
	
	Indicator[2]= core.indicators:create(Method, Indicator[1].DATA, MAFrame);	
	 first= Indicator[2].DATA:first();
	MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.signal_color, first);
    MA:setWidth(instance.parameters.width);
    MA:setStyle(instance.parameters.style);	
    
	MA:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    MA:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	MA:setPrecision(2);

	Zero=instance:addInternalStream (first, 0); 
	 
	instance:createChannelGroup("ChannelGroup","ChannelGroup" , MA, Zero, UpColor, Transparency); 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	
 
	
		Indicator[1]:update(mode);	 
		Indicator[2]:update(mode);
		
		Short:setNoData (period);	
		Long:setNoData (period);  
		
			if not Indicator[2].DATA:hasData(period) 
			or not Indicator[2].DATA:hasData(period-1) 
			then
			return
			end
		
			

			   if core.crossesOver (Indicator[2].DATA, 50, period) then
			   Long:set(period, source[period], "\108");
			   elseif core.crossesUnder (Indicator[2].DATA, 50, period) then
			   Short:set(period, source[period], "\108");
			   end
			
			   MA[period]= Indicator[2].DATA[period];
			 
			   
			   Zero[period]= 50;
			   
			   if MA[period] > 50 then
			   MA:setColor(period, UpSignal);
			   else 
			   MA:setColor(period, DownSignal);  	   
			   end
	 
			
	end	

