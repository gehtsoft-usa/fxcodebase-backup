-- Id: 914
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1342

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("'Smoothing The Bollinger %b' by Sylvain Vervoort");
    indicator:description("The indicator is described in the May 2010 issue of Stocks & Commodities");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("period", "%b period", "No description", 18, 1, 100);
    indicator.parameters:addInteger("TeAv", "TEMA Average", "No description", 8, 1, 100);
    indicator.parameters:addDouble("afwh", "Standard deviation high", "No description", 1.6, 0.1, 5);
    indicator.parameters:addDouble("afwl", "Standard deviation Low", "No description", 1.6, 0.1, 5);
    indicator.parameters:addInteger("afwper", "Standard deviation period", "No description", 63, 1, 200);
	
	indicator.parameters:addGroup("Style");  
    indicator.parameters:addColor("percb_color", "Color of percb", "Color of percb", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("hb_color", "Color of hb", "Color of hb", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("lb_color", "Color of lb", "Color of lb", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local period;
local TeAv;
local afwh;
local afwl;
local afwper;

local source = nil;

-- Streams block
local percb = nil;
local percb_first;
local hb = nil;
local lb = nil;
local b_first;
local haO;
local haC;
local haC_first;
local TMA1, TMA2, ZHLA;
local ZHLA_first;
local TMA_ZHLA;
local LWMA_TMA_ZHLA;

-- Routine
 function Prepare(nameOnly)   
 
 
    period = instance.parameters.period;
    TeAv = instance.parameters.TeAv;
    afwh = instance.parameters.afwh;
    afwl = instance.parameters.afwl;
    afwper = instance.parameters.afwper;
    source = instance.source;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. period .. ", " .. TeAv .. ", " .. afwh .. ", " .. afwl .. ", " .. afwper .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("TEMA1") ~= nil, "Please, download and install TEMA1.LUA indicator");   

    haC_first = source:first() + 1;
    haO = instance:addInternalStream(haC_first, 0);
    haC = instance:addInternalStream(haC_first, 0);
    TMA1 = core.indicators:create("TEMA1", haC, TeAv);
    TMA2 = core.indicators:create("TEMA1", TMA1.DATA, TeAv);
    ZHLA_first = TMA2.DATA:first() + TeAv * 3;
    ZHLA = instance:addInternalStream(ZHLA_first, 0);
    TMA_ZHLA = core.indicators:create("TEMA1", ZHLA, TeAv);
    LWMA_TMA_ZHLA = core.indicators:create("TEMA1", TMA_ZHLA.DATA, period);
    percb_first = math.max(LWMA_TMA_ZHLA.DATA:first(), TMA_ZHLA.DATA:first() + period * 2);
    b_first = percb_first + afwper;
    pip = source:pipSize();

    
    percb = instance:addStream("percb", core.Line, name .. ".percb", "percb", instance.parameters.percb_color, percb_first);
    percb:setPrecision(math.max(2, instance.source:getPrecision()));
	percb:setWidth(instance.parameters.width1);
    percb:setStyle(instance.parameters.style1);
    percb:addLevel(50);
    hb = instance:addStream("hb", core.Line, name .. ".hb", "hb", instance.parameters.hb_color, b_first);
    hb:setPrecision(math.max(2, instance.source:getPrecision()));
	hb:setWidth(instance.parameters.width2);
    hb:setStyle(instance.parameters.style2);
    lb = instance:addStream("lb", core.Line, name .. ".lb", "lb", instance.parameters.lb_color, b_first);
    lb:setPrecision(math.max(2, instance.source:getPrecision()));
	lb:setWidth(instance.parameters.width3);
    lb:setStyle(instance.parameters.style3);
end

-- Indicator calculation routine
function Update(p, mode)
    if p >= haC_first then
        local open, close;
        -- haOpen:=(Ref((O+H+L+C)/4,-1) + PREV)/2;
        open = (source.open[p - 1] + source.high[p - 1] +
                source.low[p - 1] + source.close[p - 1]) / 4;
        if p > haC_first then
            open = (open + haO[p - 1]) / 2;
        end
        haO[p] = open;
        -- haC:=((O+H+L+C)/4+haOpen+Max(H,haOpen)+Min(L,haOpen))/4;
        close = ((source.open[p] + source.high[p] +
                  source.low[p] + source.close[p]) / 4 +
                 open +
                 math.max(source.high[p], open) +
                 math.min(source.low[p], open)) / 4;
        haC[p] = close;
    end
    -- TMA1:= Tema(haC,TeAv);
    -- TMA2:= Tema(TMA1,TeAv);
    TMA1:update(mode);
    TMA2:update(mode);
    -- Diff:= TMA1 - TMA2;
    -- ZlHA:= TMA1 + Diff;
    -- equal to ZlHA:= TMA1 + TMA1 - TMA2;
    -- equal to ZlHA:= 2 * TMA1 - TMA2;
    if p >= ZHLA_first then
        ZHLA[p] = 2 * TMA1.DATA[p] - TMA2.DATA[p];
    end
    -- update Tema(ZLHA,TeAv) and Mov(Tema(ZLHA,TeAv),period,WEIGHTED)
    TMA_ZHLA:update(mode);
    LWMA_TMA_ZHLA:update(mode);
    -- percb:=(Tema(ZLHA,TeAv)+2*Stdev(Tema(ZLHA,TeAv),period)-Mov(Tema(ZLHA,TeAv),period,WEIGHTED)) /(4*Stdev(Tema(ZLHA,TeAv),period))*100;
    -- get stdev(Stdev(Tema(ZLHA,TeAv),period)
    if p >= percb_first then
        local stdev = core.stdev(TMA_ZHLA.DATA, core.rangeTo(p, period));
        percb[p] = (TMA_ZHLA.DATA[p] + 2 * stdev - LWMA_TMA_ZHLA.DATA[p]) / (4 * stdev) * 100;
    end

    --50+afwh*Stdev(percb,afwper);
    --50-afwl*Stdev(percb,afwper);
    if p >= b_first then
        local stdev = core.stdev(percb, core.rangeTo(p, afwper));
        hb[p] = 50 + afwh * stdev;
        lb[p] = 50 - afwl * stdev;
    end
end
