-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60320
-- Id: 11161

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


function Init()
    indicator:name("Rate of Change with Smoothing");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Prior to Calculation Price Smoothing");
	
	indicator.parameters:addString("Pre_Method", "Method", "Method" , "EMA");
	 indicator.parameters:addStringAlternative("Pre_Method", "Don't use", "Don't use" , "Don't use");
    indicator.parameters:addStringAlternative("Pre_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Pre_Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Pre_Method", "LWMA", "LWMA" , "LWMA");
	indicator.parameters:addStringAlternative("Pre_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Pre_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Pre_Method", "SMMA", "SMMA" , "SMMA");	
	indicator.parameters:addStringAlternative("Pre_Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Pre_Method", "VIDYA", "VIDYA" , "VIDYA");
	indicator.parameters:addInteger("Pre_Period", "Averege Period", "", 16);
	
    indicator.parameters:addGroup("ROC Calculation");
    indicator.parameters:addInteger("Period", "ROC Period", "", 16, 2, 1000);

	
	
    indicator.parameters:addGroup("Post Calculation ROC Smoothing");
	indicator.parameters:addString("Post_Method", "Method", "Method" , "Don't use");
	indicator.parameters:addStringAlternative("Post_Method", "Don't use", "Don't use" , "Don't use");
    indicator.parameters:addStringAlternative("Post_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Post_Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Post_Method", "LWMA", "LWMA" , "LWMA");
	indicator.parameters:addStringAlternative("Post_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Post_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Post_Method", "SMMA", "SMMA" , "SMMA");	
	indicator.parameters:addStringAlternative("Post_Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Post_Method", "VIDYA", "VIDYA" , "VIDYA");  	
	indicator.parameters:addInteger("Post_Period", "Averege Period", "", 16);	 
	
	
	    indicator.parameters:addGroup("ROC Style");
    indicator.parameters:addColor("clrRSI", "Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthRSI", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleRSI", "Line Style", "", core.FLAG_LEVEL_STYLE);
	
    
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Period; 
local source ;  
-- Streams block
local ROC, roc;
	    local  pre;
		local  post;

		local Pre_Method;
		local Post_Method;

		local Pre_Period;
		local Post_Period;

-- Routine
function Prepare(nameOnly)   	 
	
	
	 Pre_Method= instance.parameters.Pre_Method;
	 Pre_Period= instance.parameters.Pre_Period;	
	 Post_Method= instance.parameters.Post_Method;
	 Post_Period= instance.parameters.Post_Period;
	
	

    Period = instance.parameters.Period;
    source = instance.source;	

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
	
	
	if Pre_Method =="Don't use" then	 
	roc = core.indicators:create("ROC", source, Period);	
	else
    assert(core.indicators:findIndicator(Pre_Method) ~= nil, Pre_Method .. " indicator must be installed");
	pre = core.indicators:create(Pre_Method, source, Pre_Period);	
	roc = core.indicators:create("ROC", pre.DATA, Period);	
	end
	 
	 
	
	
	if Post_Method == "Don't use" then
	 first = roc.DATA:first() ;	
	else
    assert(core.indicators:findIndicator(Post_Method) ~= nil, Post_Method .. " indicator must be installed");
    post = core.indicators:create(Post_Method, roc.DATA, Post_Period);
	first = post.DATA:first() ;
	end
	
    ROC = instance:addStream("ROC", core.Line, name, "ROC", instance.parameters.clrRSI, first);
    ROC:setWidth(instance.parameters.widthRSI);
    ROC:setStyle(instance.parameters.styleRSI);
    ROC:setPrecision(2);    
    ROC:addLevel(0);
 
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    if Pre_Method== "Don't use" then
	 roc:update(mode);
	else	
	pre:update(mode);	
	roc:update(mode);
 	end	
	
 
   
             
	if Post_Method == "Don't use" then
	ROC[period]= roc.DATA[period];	
		if period < roc.DATA:first() then
		return;
		end
	else	   
	post:update(mode);
	     if period < post.DATA:first() then
		return;
		end
	ROC[period]= post.DATA[period];
	end		
	
	
end