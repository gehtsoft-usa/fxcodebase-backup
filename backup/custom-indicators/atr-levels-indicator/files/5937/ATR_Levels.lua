-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2635

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

function Init()
    indicator:name("ATR levels indicator");
    indicator:description("ATR levels indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ATRPeriod", "ATRPeriod", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("H4clr", "Color of H4 line", "Color of H4 line", core.rgb(0, 255, 0));
    indicator.parameters:addColor("L4clr", "Color of L4 line", "Color of L4 line", core.rgb(0, 255, 0));
    indicator.parameters:addColor("H4Tclr", "Color of H4T line", "Color of H4T line", core.rgb(255, 0, 0));
    indicator.parameters:addColor("L4Tclr", "Color of L4T line", "Color of L4T line", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 3, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local ATRPeriod;
local ATR;
local buffH4=nil;
local buffL4=nil;
local buffH4T=nil;
local buffL4T=nil;

function Prepare(nameOnly)
    source = instance.source;
    ATRPeriod=instance.parameters.ATRPeriod;
	
	assert(core.indicators:findIndicator("BF_ATR") ~= nil, "Please, download and install BF_ATR.LUA indicator");
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ATRPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    ATR = core.indicators:create("BF_ATR", source, "D1", ATRPeriod);
    first = ATR.DATA:first()+2;
    buffH4 = instance:addStream("buffH4", core.Line, name .. ".H4", "H4", instance.parameters.H4clr, first);
    buffL4 = instance:addStream("buffL4", core.Line, name .. ".L4", "L4", instance.parameters.L4clr, first);
    buffH4T = instance:addStream("buffH4T", core.Line, name .. ".H4T", "H4T", instance.parameters.H4Tclr, first);
    buffL4T = instance:addStream("buffL4T", core.Line, name .. ".L4T", "L4T", instance.parameters.L4Tclr, first);
    buffH4:setWidth(instance.parameters.widthLinReg);
    buffH4:setStyle(instance.parameters.styleLinReg);
    buffL4:setWidth(instance.parameters.widthLinReg);
    buffL4:setStyle(instance.parameters.styleLinReg);
    buffH4T:setWidth(instance.parameters.widthLinReg);
    buffH4T:setStyle(instance.parameters.styleLinReg);
    buffL4T:setWidth(instance.parameters.widthLinReg);
    buffL4T:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period>first and period==source:size()-1) then
    ATR:update(mode);
    local d1,t1;
    d1,t1=source:date(period);
    local table1=core.dateToTable(d1);
    local CurD;
    CurD=table1.day;
    local L4=100000000;
    local H4=-100000000;
    local L4T=100000000;
    local H4T=-100000000;
    local shift=period;
    local PrevD=CurD;
    while PrevD==CurD and shift>first do
     local d2,t2;
     d2,t2=source:date(shift);
     local table2=core.dateToTable(d2);
     PrevD=table2.day;
     L4T=math.min(L4T,source.low[shift]);
     H4T=math.max(H4T,source.high[shift]);
     shift=shift-1;
    end
    local FullATR=ATR.DATA[shift];
    CurD=PrevD;
    while PrevD==CurD and shift>first do
     local d2,t2;
     d2,t2=source:date(shift);
     local table2=core.dateToTable(d2);
     PrevD=table2.day;
     L4=math.min(L4,source.low[shift]);
     H4=math.max(H4,source.high[shift]);
     shift=shift-1;
    end
    
    L4=L4-FullATR;
    H4=H4+FullATR;
    L4T=L4T-FullATR;
    H4T=H4T+FullATR;
    
    core.drawLine(buffH4T,core.range(first,period),H4T,first,H4T,period);
    core.drawLine(buffL4T,core.range(first,period),L4T,first,L4T,period);
    core.drawLine(buffH4,core.range(first,period),H4,first,H4,period);
    core.drawLine(buffL4,core.range(first,period),L4,first,L4,period);
    
   end 
    
end

