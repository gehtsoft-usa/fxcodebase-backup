-- Id: 17845
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64533

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
    indicator:name("Weighted Compound Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("MFI Calculation");
	indicator.parameters:addInteger("MFIweight", "Weight", "Weight" , 1);
	indicator.parameters:addInteger("MFIperiod", "Period", "Period" , 14);
	indicator.parameters:addGroup("RSI Calculation");
	indicator.parameters:addInteger("RSIweight", "Weight", "Weight" , 1);
	indicator.parameters:addInteger("RSIperiod", "Period", "Period" , 14);
	
	   indicator.parameters:addGroup("DeMarker Calculation");
	indicator.parameters:addInteger("DMKweight", "Weight", "Weight" , 1);
	indicator.parameters:addInteger("DMKperiod", "Period", "Period" , 14);
	
	indicator.parameters:addGroup(" Williams Percent Range Calculation");
	indicator.parameters:addInteger("WPRweight", "Weight", "Weight" , 1);
	indicator.parameters:addInteger("WPRperiod", "Period", "Period" , 14);
	
    indicator.parameters:addGroup("MA Calculation");
    indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA"); 
    indicator.parameters:addInteger("Period", "Period", "", 5);
 

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Bar color", "Bar color", core.rgb(0, 255, 0));
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 20);
    indicator.parameters:addDouble("oversold","Oversold Level","", -20);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
  
 
end
local MFIweight, RSIweight, WPRweight, DMKweight;
local MFIperiod, RSIperiod, WPRperiod, DMKperiod;
local  MFI, RSI, WPR, DMK;
local first,FIRST;
local Oscillator;
local source;
local weight;
local MA, Method, Period;

function Prepare(onlyName)
    source = instance.source;
   
	 name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
	
	
	Method= instance.parameters.Method;
	Period= instance.parameters.Period;
	
	MFIperiod= instance.parameters.MFIperiod;
	RSIperiod= instance.parameters.RSIperiod;
	WPRperiod= instance.parameters.WPRperiod;
	DMKperiod= instance.parameters.DMKperiod;
	
	MFIweight= instance.parameters.MFIweight;
	RSIweight= instance.parameters.RSIweight;
	WPRweight= instance.parameters.WPRweight;
	DMKweight= instance.parameters.DMKweight;
	
	assert(core.indicators:findIndicator("MFI") ~= nil, "Please, download and install MFI.LUA indicator"); 
    assert(core.indicators:findIndicator("DEM") ~= nil, "Please, download and install DEM.LUA indicator");    	
	
	MFI= core.indicators:create("MFI", source, MFIperiod);
	RSI= core.indicators:create("RSI", source.close, RSIperiod);
	WPR= core.indicators:create("RLW", source, WPRperiod);
	DMK= core.indicators:create("DEM", source, DMKperiod,  "MVA");
	
	FIRST=math.max(MFI.DATA:first(), RSI.DATA:first(), WPR.DATA:first(), DMK.DATA:first()); 
	
	weight= instance:addInternalStream(FIRST, 0);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA = core.indicators:create(Method, weight, Period);
	first=MA.DATA:first();
	
	
	 

    Oscillator = instance:addStream("Oscillator", core.Bar, name .. ".Oscillator", "Oscillator", instance.parameters.Color, first);
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	
    Oscillator:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Oscillator:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
 
 
end

function Update(period, mode)

MFI:update(mode); 
RSI:update(mode);
WPR:update(mode);
DMK:update(mode);
    
	if period < FIRST then
	return;
	end
	
	 weight [ period ] = ( MFIweight * ( MFI.DATA [ period ] - 50 ) 
                         +   RSIweight * ( RSI.DATA [ period ] - 50 ) 
                         +   WPRweight * ( WPR.DATA [ period ] + 100 - 50 ) 
                         +   DMKweight * ( DMK.DATA [ period ] * 100 - 50 ) ) / ( MFIweight + RSIweight + WPRweight + DMKweight ) ;
						 
	
	MA:update(mode);
	
	if period < first then
    return;
    end
	
	Oscillator[period]= MA.DATA[period];
	
end
  