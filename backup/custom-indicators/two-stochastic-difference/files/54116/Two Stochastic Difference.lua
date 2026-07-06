-- Id: 8453
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=31736

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
    indicator:name("Two Stochastic Difference");
    indicator:description("Two Stochastic Difference");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	

		
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addBoolean("inverse", "Inverse Calculation", "", false);	
	
	indicator.parameters:addDouble("Period", "Signal Smoothing Period","", 7);
	indicator.parameters:addString("Method", "Signal Smoothing Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
		
	Parameters (1  );
	Parameters (2  );
	

	
	indicator.parameters:addGroup("Line Style");
	indicator.parameters:addColor("first", "Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("firstwidth", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("firststyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("firststyle", core.FLAG_LEVEL_STYLE);
		
	indicator.parameters:addColor("color1", "Signal Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width1", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	
	indicator.parameters:addGroup("Levels Style" ); 
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 50, -100, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", -50, -100, 100);
	
    indicator.parameters:addInteger("level_overboughtsold_width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Sryle", "", core.LINE_SOLID);
	indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Color", "", core.rgb(0, 0, 255));
	
	
end

function Parameters (id )
    
	indicator.parameters:addGroup(id .. ". Stochastic");
    indicator.parameters:addInteger("K"..id , "Number of periods for %K", "", 5*id, 2, 1000);
    indicator.parameters:addInteger("SD"..id, "%D slowing periods", "", 3*id, 2, 1000);


    indicator.parameters:addString("KS"..id, "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("KS"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("KS"..id, "EMA","", "EMA");
    indicator.parameters:addStringAlternative("KS"..id, "MT4","", "FS");
	 
	
	

end

local Method, Period
local K={};
local SD={};
local D={};
local KS={};
local DS={};
local out;
local source;
local Indicator= {};

local first;

local inverse;
local MA, Signal;

function Prepare(nameOnly) 
   inverse=instance.parameters.inverse;
   Method=instance.parameters.Method;
   Period=instance.parameters.Period;
    
    source = instance.source;
   
    local name =  profile:id()  ;
	
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	local i;

	for i = 1 , 2 , 1 do    
	
	K[i] = instance.parameters:getInteger ("K"..i);
	SD[i] = instance.parameters:getInteger  ("SD"..i);
	KS[i] = instance.parameters:getString ("KS"..i);
    Indicator[i]= core.indicators:create("STOCHASTIC", source,  K[i] , SD[i],nil , KS[i],nil);	  
	end	
	
	

	first= math.max(Indicator[1].DATA:first(), Indicator[2].DATA:first());
	
	
	out= instance:addStream("Difference", core.Line, "Difference", "Difference", instance.parameters.first, first);
	
   
    out:setWidth(instance.parameters.firstwidth);
    out:setStyle(instance.parameters.firststyle);
    out:setPrecision(2);
	out:addLevel(-100);
	out:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    out:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    out:addLevel(100);
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA= core.indicators:create(Method, out, Period);	
	
	Signal= instance:addStream("Signal", core.Line, "Signal", "Signal", instance.parameters.color1, MA.DATA:first());	
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
   
    Signal:setWidth(instance.parameters.width1);
    Signal:setStyle(instance.parameters.style1);
	
end


function Update(period, mode)

    
	Indicator[1]:update(mode);
	Indicator[2]:update(mode);
	
		if period < first then
        return;
        end
		
								
									 
									      if inverse then										    
											 out[period]=  Indicator[2].DATA[period]- Indicator[1].DATA[period];											
                                          else 										  
											out[period]=  Indicator[1].DATA[period]- Indicator[2].DATA[period];		
								     	 end
								
	MA:update(mode);

    if period < MA.DATA:first() then
	return;
	end
	
	Signal[period]=MA.DATA[period];
	
end
