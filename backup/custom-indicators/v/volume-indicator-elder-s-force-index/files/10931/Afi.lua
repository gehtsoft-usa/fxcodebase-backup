-- Id: 3981
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1966

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
    indicator:name("Advanced Force Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	
	
	indicator.parameters:addGroup("Smoothing Selector");
	indicator.parameters:addBoolean("Pre", "Use Prior to Calculation Price Smoothing", "", false);	
	indicator.parameters:addBoolean("Post", "Use Post Calculation Raw Force Index Smoothing", "", false);	
	
	indicator.parameters:addGroup("Prior to Calculation Price Smoothing");
	indicator.parameters:addInteger("Pre_Period", "Averege Period", "", 20);
	indicator.parameters:addString("Pre_Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Pre_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Pre_Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Pre_Method", "LWMA", "LWMA" , "LWMA");
	indicator.parameters:addStringAlternative("Pre_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Pre_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Pre_Method", "SMMA", "SMMA" , "SMMA");	
	indicator.parameters:addStringAlternative("Pre_Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Pre_Method", "VIDYA", "VIDYA" , "VIDYA");
	
    indicator.parameters:addGroup("Post Calculation Raw  Force Index Smoothing");
	indicator.parameters:addInteger("Post_Period", "Averege Period", "", 20);
	indicator.parameters:addString("Post_Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Post_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Post_Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Post_Method", "LWMA", "LWMA" , "LWMA");
	indicator.parameters:addStringAlternative("Post_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Post_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Post_Method", "SMMA", "SMMA" , "SMMA");	
	indicator.parameters:addStringAlternative("Post_Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Post_Method", "VIDYA", "VIDYA" , "VIDYA");  
   

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrFI", "Indicator Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthFI", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleFI", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleFI", core.FLAG_LINE_STYLE);
end

local Pre;
local Post;

local Pre_Method;
local Post_Method;

local Pre_Period;
local Post_Period;

local source;
local first;
local FIRST={};

local DATA={};
local FI;

function Prepare(nameOnly)

    source = instance.source;   
	 
	assert(source:supportsVolume(), "The source must have volume");
	 
	local name;
    name = profile:id() .. "(" .. source:name() .. "," ;
	 
   
     first = source:first();
   
     Pre= instance.parameters.Pre;
	 Pre_Method= instance.parameters.Pre_Method;
	 Pre_Period= instance.parameters.Pre_Period;
	 
	 
	if Pre then
		name = name .. Pre_Method.."(" .. Pre_Period .. ")";
		if not nameOnly then
    assert(core.indicators:findIndicator(Pre_Method) ~= nil, Pre_Method .. " indicator must be installed");
			DATA["PRE"]= core.indicators:create(Pre_Method, source.close , Pre_Period);
			first = DATA["PRE"].DATA:first();
			FIRST["PRE"]=first; 
		end
	end
	 
	if not nameOnly then
		DATA["RAW"] = instance:addInternalStream(first, 0);
	end
	 
	 
	 Post= instance.parameters.Post;
	 Post_Method= instance.parameters.Post_Method;
	 Post_Period= instance.parameters.Post_Period;
	 
	if Post then
		name = name .. Post_Method.."(" .. Post_Period .. ")";
		if not nameOnly then
    assert(core.indicators:findIndicator(Post_Method) ~= nil, Post_Method .. " indicator must be installed");
			DATA["POST"]= core.indicators:create(Post_Method, DATA["RAW"] , Post_Period); 
			first = DATA["POST"].DATA:first();
			FIRST["POST"]=first; 
		end
	end

     name = name .. ")";   
   
	instance:name(name);
	if nameOnly then
		return;
	end

    FI = instance:addStream("FI", core.Line, name, "FI", instance.parameters.clrFI, first);
    FI:setPrecision(5);
    FI:setWidth(instance.parameters.widthFI);
    FI:setStyle(instance.parameters.styleFI);
    FI:addLevel(0);
end

function Update(period, mode)

        if Pre then
		    if period > FIRST["PRE"]+1 then 
			DATA["PRE"]:update(mode);
			DATA["RAW"][period] = (DATA["PRE"].DATA[period] - DATA["PRE"].DATA[period-1]) * source.volume[period];
		    end
		else
		DATA["RAW"][period] = (source.close[period] - source.close[period - 1]) * source.volume[period];
	    end		
		
		if period < first +1 then
		return;
		end
		
		if Post then
			if period > FIRST["POST"] then
			DATA["POST"]:update(mode);
			FI[period] = DATA["POST"].DATA[period];
			end
		elseif period  then
		FI[period] = DATA["RAW"][period];
	    end
    

end



