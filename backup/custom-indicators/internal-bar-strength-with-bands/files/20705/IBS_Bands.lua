-- Id: 5290
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9711

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
    indicator:name("IBS Bands indicator");
    indicator:description("IBS Bands indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method of MA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
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
    indicator.parameters:addInteger("Period", "Period of MA", "", 5);
    indicator.parameters:addString("Price", "Price", "", "Close-Low");
    indicator.parameters:addStringAlternative("Price", "Close-Low", "", "Close-Low");
    indicator.parameters:addStringAlternative("Price", "High-Close", "", "High-Close");
    indicator.parameters:addInteger("ExtrPeriod", "Extremum Period", "", 25);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("IBS_Clr", "IBS Color", "IBS Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Top_Clr", "Top Color", "Top Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Bottom_Clr", "Bottom Color", "Bottom Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "IBS width", "IBS width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "IBS style", "IBS style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("widthLinReg2", "Band width", "IBS width", 3, 1, 5);
    indicator.parameters:addInteger("styleLinReg2", "Band style", "IBS style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg2", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Method;
local Period;
local Price;
local ExtrPeriod;
local IBS=nil;
local TopBand=nil;
local BottomBand=nil;
local Price1, Price2;
local CurIBS;

function Prepare(nameOnly)
    source = instance.source;
    Method=instance.parameters.Method;
    Period=instance.parameters.Period;
    Price=instance.parameters.Price;
    ExtrPeriod=instance.parameters.ExtrPeriod;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Price .. ", " .. instance.parameters.ExtrPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    CurIBS = instance:addInternalStream(0, 0);
    MA = core.indicators:create("AVERAGES", CurIBS, Method, Period, false);
	first = MA.DATA:first();
	 
	
    IBS = instance:addStream("IBS", core.Line, name .. ".IBS", "IBS", instance.parameters.IBS_Clr, first);
    TopBand = instance:addStream("TopBand", core.Line, name .. ".TopBand", "TopBand", instance.parameters.Top_Clr, first);
    BottomBand = instance:addStream("BottomBand", core.Line, name .. ".BottomBand", "BottomBand", instance.parameters.Bottom_Clr, first);
    IBS:setWidth(instance.parameters.widthLinReg);
    IBS:setStyle(instance.parameters.styleLinReg);
    TopBand:setWidth(instance.parameters.widthLinReg2);
    TopBand:setStyle(instance.parameters.styleLinReg2);
    BottomBand:setWidth(instance.parameters.widthLinReg2);
    BottomBand:setStyle(instance.parameters.styleLinReg2);
	
	IBS:setPrecision(math.max(2, instance.source:getPrecision()));
	TopBand:setPrecision(math.max(2, instance.source:getPrecision()));
	BottomBand:setPrecision(math.max(2, instance.source:getPrecision()));
	
    IBS:addLevel(40);
    IBS:addLevel(60);
    if Price=="Close-Low" then
     Price1=source.close;
     Price2=source.low;
    else
     Price1=source.high;
     Price2=source.close;
    end
end

function Update(period, mode)
   if (period>first) then
    local Range=source.high[period]-source.low[period];
    if Range~=0 then
     CurIBS[period]=100*(Price1[period]-Price2[period])/Range; 
    else
     CurIBS[period]=0;
    end
    MA:update(mode);
    IBS[period]=MA.DATA[period];
    local Min=core.min(IBS,core.range(math.max(first,period-ExtrPeriod),period-1));
    local Max=core.max(IBS,core.range(math.max(first,period-ExtrPeriod),period-1));
    TopBand[period]=Max;
    BottomBand[period]=Min;
   end 
end

