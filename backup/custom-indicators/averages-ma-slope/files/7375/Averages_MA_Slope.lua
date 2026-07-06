-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3145

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
    indicator:name("Averages MA Slope indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");	
	
	indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
 
    indicator.parameters:addInteger("Period", "Period", "", 20);
    
    indicator.parameters:addDouble("Slope", "Slope", "pip/minute", 0.01);
    indicator.parameters:addInteger("Bars", "Bars", "No description", 1);
   
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN_color", "Color of DN", "Color of DN", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Flat_color", "Color of Flat", "Color of Flat", core.rgb(128, 128, 128));
	
	indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end


local MA_Period;
local MA_Method;
local Slope;
local Bars;

local first;
local source = nil;

local MA;
local DATA;


 function Prepare(nameOnly)  
	
    MA_Period = instance.parameters.Period;
    MA_Method = instance.parameters.Method;
    Slope = instance.parameters.Slope;
    Bars = instance.parameters.Bars;
    source = instance.source;	
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. MA_Period .. ", " .. MA_Method .. ", " .. Slope .. ", " .. Bars .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");	
	
    DATA=core.indicators:create("AVERAGES", source, MA_Method, MA_Period, false);
	
	
    first = DATA.DATA:first()+Bars;
   
	
    MA = instance:addStream("Slope", core.Line, name .. ".Slope", "Slope", core.rgb(0, 255, 0), first);
	MA:setWidth(instance.parameters.width);
    MA:setStyle(instance.parameters.style);
   
end

function Update(period, mode)
    if (period< first) then
	return;
	end
	
	
     DATA:update(mode);
     local d,t,d1,t1;
     d,t=source:date(period);
     d1,t1=source:date(period-1);
     local TimeSize=(d-d1)*1440;
     local Sl=(DATA.DATA[period]-DATA.DATA[period-Bars])/(source:pipSize()*TimeSize)
	 
	 
    
	MA[period] = DATA.DATA[period];
	
		 if Sl>Slope then
		 MA:setColor(period, instance.parameters.UP_color);		 
		 elseif Sl<-Slope then
		 MA:setColor(period, instance.parameters.DN_color);	
		 else
		MA:setColor(period, instance.parameters.Flat_color);	
		 end
    
end

