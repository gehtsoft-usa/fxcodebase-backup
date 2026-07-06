-- Id: 7226
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Two MA cross indicator");
    indicator:description("Two MA cross indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Period of MA1", "", 100);
    indicator.parameters:addString("Method1", "Method of MA1", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Period2", "Period of MA2", "", 30);
    indicator.parameters:addString("Method2", "Method of MA2", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MA1_Clr", "MA1 Color", "MA1 Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("MA2_Clr", "MA2 Color", "MA2 Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("UP_Clr", "UP Color", "UP Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_Clr", "DN Color", "DN Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("ArrowSize", "Arrow size", "Arrow size", 15);
	
	 indicator.parameters:addColor("colorP", "Price Line Color", "Price Line Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthP", "Price Line width", "Price Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleP", "Price Line style", "Price Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleP", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period1;
local Method1;
local Period2;
local Method2;
local MA1;
local MA2;
local MA1_Buff=nil;
local MA2_Buff=nil;
local up=nil;
local down=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period1=instance.parameters.Period1;
    Method1=instance.parameters.Method1;
    Period2=instance.parameters.Period2;
    Method2=instance.parameters.Method2;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Method1 .. ", " .. instance.parameters.Period2 .. ", " .. instance.parameters.Method2 .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    

 
    MA1 = core.indicators:create("AVERAGES", source, Method1, Period1, false);
    MA2 = core.indicators:create("AVERAGES", source, Method2, Period2, false);
	first = math.max(MA1.DATA:first(),MA2.DATA:first());
	
    
	
    MA1_Buff = instance:addStream("MA1_Buff", core.Line, name .. ".MA1", "MA1", instance.parameters.MA1_Clr, first);
    MA2_Buff = instance:addStream("MA2_Buff", core.Line, name .. ".MA2", "MA2", instance.parameters.MA2_Clr, first);
    MA1_Buff:setWidth(instance.parameters.widthLinReg);
    MA1_Buff:setStyle(instance.parameters.styleLinReg);
    MA2_Buff:setWidth(instance.parameters.widthLinReg);
    MA2_Buff:setStyle(instance.parameters.styleLinReg);
    up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.UP_Clr, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.DN_Clr, 0);
	
	
	MA1_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
	MA2_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
 
    MA1:update(mode);
    MA2:update(mode);
	
	if (period>first) then
    MA1_Buff[period]=MA1.DATA[period];
    MA2_Buff[period]=MA2.DATA[period];
    if MA1.DATA[period-1]<MA2.DATA[period-1] and MA1.DATA[period]>MA2.DATA[period] then
     up:set(period, MA2.DATA[period], "\226");
    end
    if MA1.DATA[period-1]>MA2.DATA[period-1] and MA1.DATA[period]<MA2.DATA[period] then
     down:set(period, MA2.DATA[period], "\225");
    end
   end 
   
   if period == source:size()-1 then	
	core.host:execute("drawLine", 1, source:date(first), source[period], source:date(period-1), source[period], instance.parameters.colorP, instance.parameters.styleP, instance.parameters.widthP);
 
	end
end

