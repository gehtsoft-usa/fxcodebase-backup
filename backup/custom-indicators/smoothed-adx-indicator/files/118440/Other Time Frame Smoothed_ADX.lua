-- Id: 20797
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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=7635&p=111559&hilit=Smoothed+ADX#p111559


function Init()
    indicator:name("Smoothed ADX indicator");
    indicator:description("Smoothed ADX indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    
    indicator.parameters:addString("TF", "Indicator Time Frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_BARPERIODS_EDIT);
    
    indicator.parameters:addInteger("Period", "Period", "", 14);
    indicator.parameters:addDouble("Alpha1", "Alpha1", "", 0.25);
    indicator.parameters:addDouble("Alpha2", "Alpha2", "", 0.33);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("DIPclr", "DIP Color", "DIP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DIMclr", "DIM Color", "DIM Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("ADXclr", "ADX Color", "ADX Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addGroup("OB/OS Levels");    
    
    indicator.parameters:addBoolean("S1", "Show 1. Line", "", true);
    indicator.parameters:addDouble("level1", "1. Level","", 15); 
    indicator.parameters:addColor("color1", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width1","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addBoolean("S2", "Show 2. Line", "", true);
    indicator.parameters:addDouble("level2", "2. Level","", 20); 
    indicator.parameters:addColor("color2", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width2","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addBoolean("S3", "Show 3. Line", "", true);
    indicator.parameters:addDouble("level3", "3. Level","", 25); 
    indicator.parameters:addColor("color3", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width3","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addBoolean("S4", "Show 4. Line", "", true);
    indicator.parameters:addDouble("level4", "4. Level","", 40); 
    indicator.parameters:addColor("color4", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width4","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addBoolean("S5", "Show 5. Line", "", true);
    indicator.parameters:addDouble("level5", "5. Level","", 50); 
    indicator.parameters:addColor("color5", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width5","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addBoolean("S6", "Show 6. Line", "", true);
    indicator.parameters:addDouble("level6", "6. Level","", 60); 
    indicator.parameters:addColor("color6", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width6","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style6", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addBoolean("S7", "Show 7. Line", "", true);
    indicator.parameters:addDouble("level7", "7. Level","", 70); 
    indicator.parameters:addColor("color7", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width7","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style7", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style7", core.FLAG_LEVEL_STYLE);
end

local first;
local source = nil;
local Period;
local Alpha1;
local Alpha2;

local Indicator;
   
local DIP=nil;
local DIM=nil;
local ADX=nil;
local TF;

 
    local dayoffset;
    local weekoffset;
    local SourceData;
    local loading = false;
    
 function Prepare(nameOnly) 
    source = instance.source;
    Period=instance.parameters.Period;
    Alpha1=instance.parameters.Alpha1;
    Alpha2=instance.parameters.Alpha2;
    TF=instance.parameters.TF;
    
     dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
 
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Alpha1 .. ", " .. instance.parameters.Alpha2 .. ", " .. instance.parameters.TF.. ")";
    instance:name(name);
    
    if   (nameOnly) then
        return;
    end
    
    
    assert(core.indicators:findIndicator("SMOOTHED_ADX") ~= nil, "Please, download and install SMOOTHED_ADX.LUA indicator");
    
    
     local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
    
    
    SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
    loading=true;
    
    
    Indicator = core.indicators:create("SMOOTHED_ADX", SourceData, Period,Alpha1,Alpha2);    
    first =Indicator.DATA:first();
    
    
    DIP = instance:addStream("DIP", core.Line, name .. ".DIP", "DIP", instance.parameters.DIPclr, first);
    DIP:setPrecision(math.max(2, instance.source:getPrecision()));
    DIM = instance:addStream("DIM", core.Line, name .. ".DIM", "DIM", instance.parameters.DIMclr, first);
    DIM:setPrecision(math.max(2, instance.source:getPrecision()));
    ADX = instance:addStream("ADX", core.Line, name .. ".ADX", "ADX", instance.parameters.ADXclr, first);
    ADX:setPrecision(math.max(2, instance.source:getPrecision()));
    DIP:setWidth(instance.parameters.widthLinReg);
    DIP:setStyle(instance.parameters.styleLinReg);
    DIM:setWidth(instance.parameters.widthLinReg);
    DIM:setStyle(instance.parameters.styleLinReg);
    ADX:setWidth(instance.parameters.widthLinReg);
    ADX:setStyle(instance.parameters.styleLinReg);
    
    if instance.parameters.S1 then
    ADX:addLevel(instance.parameters.level1, instance.parameters.style1, instance.parameters.width1, instance.parameters.color1);
    end
    
    if instance.parameters.S2 then
    ADX:addLevel(instance.parameters.level2, instance.parameters.style2, instance.parameters.width2, instance.parameters.color2);
    end
    
    if instance.parameters.S3 then
    ADX:addLevel(instance.parameters.level3, instance.parameters.style3, instance.parameters.width3, instance.parameters.color3);
    end
    
    
    if instance.parameters.S4 then
    ADX:addLevel(instance.parameters.level4, instance.parameters.style4, instance.parameters.width4, instance.parameters.color4);
    end
    
    if instance.parameters.S5 then
    ADX:addLevel(instance.parameters.level5, instance.parameters.style5, instance.parameters.width5, instance.parameters.color5);
    end
    
    if instance.parameters.S6 then
    ADX:addLevel(instance.parameters.level6, instance.parameters.style6, instance.parameters.width6, instance.parameters.color6);
    end
    
    if instance.parameters.S7 then
    ADX:addLevel(instance.parameters.level7, instance.parameters.style7, instance.parameters.width7, instance.parameters.color7);
    end
end

function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
    else return p;    
    end
    
end    


function Update(period, mode)
   if (period<first) then
   return;
   end
   
    Indicator:update(mode);
    
       local p =  Initialization(period) 
     
        if not p then
        return;
        end
        
    if Indicator.DATA:hasData(p) then    
    DIP[period]=Indicator.DIP[p];
    DIM[period]=Indicator.DIM[p];
    ADX[period]=Indicator.ADX[p];
    end
 
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end