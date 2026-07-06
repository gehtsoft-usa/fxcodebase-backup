-- Id: 4228
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3427

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Triple Spearman Rank Correlation oscillator");
    indicator:description("Triple Spearman Rank Correlation oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Range1", "Range1", "", 9);
    indicator.parameters:addInteger("Range2", "Range2", "", 26);
    indicator.parameters:addInteger("Range3", "Range3", "", 52);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Range1;
local Range2;
local Range3;
local SRC1;
local SRC2;
local SRC3;
local Buff_SRC1=nil;
local Buff_SRC2=nil;
local Buff_SRC3=nil;

function Prepare(nameOnly)
    source = instance.source;
    Range1=instance.parameters.Range1;
    Range2=instance.parameters.Range2;
    Range3=instance.parameters.Range3;
    first = source:first();
	
	assert(core.indicators:findIndicator("SPEARMAN_RANK_CORRELATION") ~= nil, "Please, download and install SPEARMAN_RANK_CORRELATION.LUA indicator");  
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Range1 .. ", " .. instance.parameters.Range2 .. ", " .. instance.parameters.Range3 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    SRC1 = core.indicators:create("SPEARMAN_RANK_CORRELATION", source, Range1);
    SRC2 = core.indicators:create("SPEARMAN_RANK_CORRELATION", source, Range2);
    SRC3 = core.indicators:create("SPEARMAN_RANK_CORRELATION", source, Range3);
    Buff_SRC1 = instance:addStream("Buff_SRC1", core.Line, name .. ".SRC1", "SRC1", instance.parameters.clr1, first+Range1);
    Buff_SRC1:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff_SRC2 = instance:addStream("Buff_SRC2", core.Line, name .. ".SRC2", "SRC2", instance.parameters.clr2, first+Range2);
    Buff_SRC2:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff_SRC3 = instance:addStream("Buff_SRC3", core.Line, name .. ".SRC3", "SRC3", instance.parameters.clr3, first+Range3);
    Buff_SRC3:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff_SRC1:setWidth(instance.parameters.widthLinReg);
    Buff_SRC1:setStyle(instance.parameters.styleLinReg);
    Buff_SRC2:setWidth(instance.parameters.widthLinReg);
    Buff_SRC2:setStyle(instance.parameters.styleLinReg);
    Buff_SRC3:setWidth(instance.parameters.widthLinReg);
    Buff_SRC3:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period>first+Range1) then
    SRC1:update(mode);
    Buff_SRC1[period]=SRC1.DATA[period];
   end 
   if (period>first+Range2) then
    SRC2:update(mode);
    Buff_SRC2[period]=SRC2.DATA[period];
   end 
   if (period>first+Range3) then
    SRC3:update(mode);
    Buff_SRC3[period]=SRC3.DATA[period];
   end 
end

