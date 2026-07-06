-- Id: 24245
function Init()
    indicator:name("2 MA Cross Higher TF");
    indicator:description("2 MA Cross Higher TF");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

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
    indicator.parameters:addString("TF1", "Timeframe of MA1", "Timeframe of MA1", "H1");
    indicator.parameters:setFlag("TF1", core.FLAG_BARPERIODS);
    indicator.parameters:addString("Price1", "Price of MA1", "", "close");
    indicator.parameters:addStringAlternative("Price1", "close", "", "close");
    indicator.parameters:addStringAlternative("Price1", "open", "", "open");
    indicator.parameters:addStringAlternative("Price1", "high", "", "high");
    indicator.parameters:addStringAlternative("Price1", "low", "", "low");
    indicator.parameters:addStringAlternative("Price1", "median", "", "median");
    indicator.parameters:addStringAlternative("Price1", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "weighted", "", "weighted");
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
    indicator.parameters:addString("TF2", "Timeframe of MA2", "Timeframe of MA2", "H1");
    indicator.parameters:setFlag("TF2", core.FLAG_BARPERIODS);
    indicator.parameters:addString("Price2", "Price of MA2", "", "close");
    indicator.parameters:addStringAlternative("Price2", "close", "", "close");
    indicator.parameters:addStringAlternative("Price2", "open", "", "open");
    indicator.parameters:addStringAlternative("Price2", "high", "", "high");
    indicator.parameters:addStringAlternative("Price2", "low", "", "low");
    indicator.parameters:addStringAlternative("Price2", "median", "", "median");
    indicator.parameters:addStringAlternative("Price2", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "weighted", "", "weighted");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MA1_Clr", "MA1 Color", "MA1 Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("MA2_Clr", "MA2 Color", "MA2 Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("UP_Clr", "UP Color", "UP Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_Clr", "DN Color", "DN Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("ArrowSize", "Arrow size", "Arrow size", 15);
end

local first;
local source = nil;
local Period1;
local Method1;
local TF1;
local Price1;
local Period2;
local Method2;
local TF2;
local Price2;
local MA1;
local MA2;
local MA1_Buff=nil;
local MA2_Buff=nil;
local up=nil;
local down=nil;
local Source1, Source2;
local loading;

function Prepare()
    source = instance.source;
    Period1=instance.parameters.Period1;
    Method1=instance.parameters.Method1;
    TF1=instance.parameters.TF1;
    Price1=instance.parameters.Price1;
    Period2=instance.parameters.Period2;
    Method2=instance.parameters.Method2;
    TF2=instance.parameters.TF2;
    Price2=instance.parameters.Price2;
    first = source:first()+2;
    Source1 = core.host:execute("getSyncHistory", source:instrument(), TF1, source:isBid(), 0, 100, 101);    
    Source2 = core.host:execute("getSyncHistory", source:instrument(), TF2, source:isBid(), 0, 102, 103);    
    loading=true;
    if Price1=="open" then
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "AVERAGES" .. " indicator must be installed");
     MA1 = core.indicators:create("AVERAGES", Source1.open, Method1, Period1, false);
    elseif Price1=="high" then 
     MA1 = core.indicators:create("AVERAGES", Source1.high, Method1, Period1, false);
    elseif Price1=="low" then 
     MA1 = core.indicators:create("AVERAGES", Source1.low, Method1, Period1, false);
    elseif Price1=="close" then 
     MA1 = core.indicators:create("AVERAGES", Source1.close, Method1, Period1, false);
    elseif Price1=="median" then 
     MA1 = core.indicators:create("AVERAGES", Source1.median, Method1, Period1, false);
    elseif Price1=="typical" then 
     MA1 = core.indicators:create("AVERAGES", Source1.typical, Method1, Period1, false);
    else
     MA1 = core.indicators:create("AVERAGES", Source1.weighted, Method1, Period1, false);
    end 

    if Price2=="open" then
     MA2 = core.indicators:create("AVERAGES", Source2.open, Method2, Period2, false);
    elseif Price2=="high" then 
     MA2 = core.indicators:create("AVERAGES", Source2.high, Method2, Period2, false);
    elseif Price2=="low" then 
     MA2 = core.indicators:create("AVERAGES", Source2.low, Method2, Period2, false);
    elseif Price2=="close" then 
     MA2 = core.indicators:create("AVERAGES", Source2.close, Method2, Period2, false);
    elseif Price2=="median" then 
     MA2 = core.indicators:create("AVERAGES", Source2.median, Method2, Period2, false);
    elseif Price2=="typical" then 
     MA2 = core.indicators:create("AVERAGES", Source2.typical, Method2, Period2, false);
    else
     MA2 = core.indicators:create("AVERAGES", Source2.weighted, Method2, Period2, false);
    end 
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Method1 .. ", " .. instance.parameters.TF1 .. ", " .. instance.parameters.Price1 .. ", " .. instance.parameters.Period2 .. ", " .. instance.parameters.Method2 .. ", " .. instance.parameters.TF2 .. ", " .. instance.parameters.Price2 .. ")";
    instance:name(name);
    MA1_Buff = instance:addStream("MA1_Buff", core.Line, name .. ".MA1", "MA1", instance.parameters.MA1_Clr, first);
    MA2_Buff = instance:addStream("MA2_Buff", core.Line, name .. ".MA2", "MA2", instance.parameters.MA2_Clr, first);
    MA1_Buff:setWidth(instance.parameters.widthLinReg);
    MA1_Buff:setStyle(instance.parameters.styleLinReg);
    MA2_Buff:setWidth(instance.parameters.widthLinReg);
    MA2_Buff:setStyle(instance.parameters.styleLinReg);
    up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.UP_Clr, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.DN_Clr, 0);
end

function Update(period, mode)
   if (period>first and not(loading)) then
    MA1:update(mode);
    MA2:update(mode);
    local index1=core.findDate(Source1, source:date(period), false);
    local index2=core.findDate(Source2, source:date(period), false);
    if index1~=-1 and index2~=-1 then
     MA1_Buff[period]=MA1.DATA[index1];
     MA2_Buff[period]=MA2.DATA[index2];
     if MA1_Buff[period-1]<MA2_Buff[period-1] and MA1_Buff[period]>MA2_Buff[period] then
      up:set(period, MA2_Buff[period], "\226");
     end
     if MA1_Buff[period-1]>MA2_Buff[period-1] and MA1_Buff[period]<MA2_Buff[period] then
      down:set(period, MA2_Buff[period], "\225");
     end 
    end
   end 
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 100 or cookie==102 then
        loading=false;
    elseif cookie == 101 or cookie==103 then
        loading=true;
    end
end


