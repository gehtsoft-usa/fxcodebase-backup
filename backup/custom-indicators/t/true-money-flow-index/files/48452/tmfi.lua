-- Id: 8098
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27688

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
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("True Money Flow Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Periods", "", 14, 1, 1000);
	
	indicator.parameters:addString("Method", "Smoothing Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addInteger("Period", "Smoothing Periods", "", 14, 1, 1000);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrMFI", "Indicator Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthMFI", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleMFI", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleMFI", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("clr", "Signal Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Signal Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Signal Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 68.16);
    indicator.parameters:addDouble("oversold","Oversold Level","", 31.83);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

end

local source;
local N;
local first;
local first1;
local MFI;
local Prev;
local POS, NEG;
local Method, Period;
local MA, SIGNAL;
function Prepare(nameOnly) 
    source = instance.source;
    N = instance.parameters.N;
    first = source:first() + N + 1;
    first1 = source:first() + 1;
    Prev = instance.parameters.Prev;
	Method = instance.parameters.Method;
	Period = instance.parameters.Period;

    name = profile:id() .. "(" .. source:name() .. "," .. N .. "," .. Method .. "," .. Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	  assert(source:supportsVolume(), "The source must have volume");

    POS = instance:addInternalStream(0, 0);
    NEG = instance:addInternalStream(0, 0);

    MFI = instance:addStream("TMFI", core.Line, name, "TMFI", instance.parameters.clrMFI, first);
    MFI:setPrecision(2);
    MFI:setWidth(instance.parameters.widthMFI);
    MFI:setStyle(instance.parameters.styleMFI);
    MFI:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	MFI:addLevel(50, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	MFI:addLevel(100, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
    MFI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	MFI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA = core.indicators:create(Method, MFI, Period);
	
	SIGNAL = instance:addStream("SIGNAL", core.Line, name, "Signal", instance.parameters.clr, MA.DATA:first());
    SIGNAL:setPrecision(2);
    SIGNAL:setWidth(instance.parameters.width);
    SIGNAL:setStyle(instance.parameters.style);
end

function Update(period, mode)
    POS[period] = 0;
    NEG[period] = 0;
    
	
    local pos=0;
	local neg=0;

    if period >= first1 then
        if source.close[period] > source.close[period - 1] then
             pos =  source.volume[period];
        elseif source.close[period] < source.close[period - 1] then
             neg =  source.volume[period];
        end
    end

    if period >= first then 
	
      local positive=(POS[period-1]*(N-1)+pos)/N;
      local negative=(NEG[period-1]*(N-1)+neg)/N;
		
	  POS[period]=positive;
      NEG[period]=negative;
	  
	  
	  if(negative==0.0) then
	  MFI[period]=0.0;
      else
	  MFI[period]=100.0*(1.0-1.0/(1.0+positive/negative));
	  end
	  
    end
	MA:update(mode);
	if period < MA.DATA:first() then
	return;
	end
	
	SIGNAL[period]=MA.DATA[period];
end
