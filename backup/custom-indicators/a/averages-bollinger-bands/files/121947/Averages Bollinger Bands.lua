
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66888

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

function Init()
    indicator:name("Averages Bollinger Bands");
    indicator:description("Original Bollinger Bands with an Averages instead of a simple ma");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("N", "Number of periods", "Number of periods", 20.0);
    indicator.parameters:addDouble("Dev", "Number of standard deviations", "Number of standard deviations", 2.0);
	

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
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "", "VIDYA");
  --  indicator.parameters:addStringAlternative("Method", "HPF", "", "HPF");
  --  indicator.parameters:addStringAlternative("Method", "VAMA", "", "VAMA");



    
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("clrBBP", "Top Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrBBM", "Bottom Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrBBA", "Cental Line Color", "Line Color", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

local N;
local D;

local first;
local source = nil;

local TL = nil;
local BL = nil;

local MA=nil;
local Method;


-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    D = instance.parameters.Dev;
	Method = instance.parameters.Method;
    
    source = instance.source;
   

    local name = "Bollinger Bands with Averages (" .. N .. ", " .. D .. ", " .. Method.. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
    
    MA = core.indicators:create("AVERAGES", source,Method, N);
	 first = source:first()+N-1;
    
    TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.clrBBP, first);
	TL:setWidth(instance.parameters.width1);
    TL:setStyle(instance.parameters.style1);
    BL = instance:addStream("BL", core.Line, name .. ".BL", "BL", instance.parameters.clrBBM, first);
	BL:setWidth(instance.parameters.width2);
    BL:setStyle(instance.parameters.style2);
    AL = instance:addStream("AL", core.Line, name .. ".AL", "AL", instance.parameters.clrBBA, first);
	AL:setWidth(instance.parameters.width3);
    AL:setStyle(instance.parameters.style3);
end

-- Indicator calculation routine
function Update(period,mode)
    MA:update(mode);
	
    if(period < first) then
	return;
	end
	
     local ml=MA.DATA[period];
     local d = mathex.stdev(source, period-N+1, period);
     TL[period] = ml + D * d;
     BL[period] = ml - D * d;
     AL[period] = ml;
    
end





