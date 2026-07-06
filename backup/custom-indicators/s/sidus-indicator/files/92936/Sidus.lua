-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60372
-- Id: 11252

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Sidus indicator");
    indicator:description("Sidus indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FasterPeriod", "Faster period", "", 5);
    indicator.parameters:addInteger("SlowerPeriod", "Slower period", "", 12);
    indicator.parameters:addInteger("FasterSidusPeriod", "Faster sidus period", "", 18);
    indicator.parameters:addInteger("SlowerSidusPeriod", "Slower sidus period", "", 28);
    indicator.parameters:addInteger("RSIPeriod", "RSI period", "", 21);
    indicator.parameters:addInteger("CCIPeriod", "CCI period", "", 50);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("T_UP_clr", "Tunnel UP color", "Tunnel UP color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("T_DN_clr", "Tunnel DN color", "Tunnel DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 2, 1, 5);
    indicator.parameters:addColor("Cr_UP_clr", "Cross UP color", "Cross UP color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Cr_DN_clr", "Cross DN color", "Cross DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("ArrowSize", "Arrow size", "Arrow size", 10);
end

local first;
local source = nil;
local FasterPeriod;
local SlowerPeriod;
local FasterSidusPeriod;
local SlowerSidusPeriod;
local RSIPeriod, CCIPeriod;
local FasterEMA, SlowerEMA, FasterSidusEMA, SlowerSidusEMA;
local UpTunnel, DnTunnel;
local HL;
local RSI, CCI;
local Tunnel=nil;
local CrossUp=nil;
local CrossDn=nil;

function Prepare(nameOnly)
    source = instance.source;
    FasterPeriod=instance.parameters.FasterPeriod;
    SlowerPeriod=instance.parameters.SlowerPeriod;
    FasterSidusPeriod=instance.parameters.FasterSidusPeriod;
    SlowerSidusPeriod=instance.parameters.SlowerSidusPeriod;
    RSIPeriod=instance.parameters.RSIPeriod;
    CCIPeriod=instance.parameters.CCIPeriod;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.FasterPeriod .. ", " .. instance.parameters.SlowerPeriod .. ", " .. instance.parameters.FasterSidusPeriod .. ", " .. instance.parameters.SlowerSidusPeriod .. ", " .. instance.parameters.RSIPeriod .. ", " .. instance.parameters.CCIPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
   
    UpTunnel = instance:addInternalStream(0, 0);
    DnTunnel = instance:addInternalStream(0, 0);
    HL = instance:addInternalStream(0, 0);
    FasterEMA = core.indicators:create("EMA", source.close, FasterPeriod);
    SlowerEMA = core.indicators:create("EMA", source.close, SlowerPeriod);
    FasterSidusEMA = core.indicators:create("EMA", source.close, FasterSidusPeriod);
    SlowerSidusEMA = core.indicators:create("EMA", source.close, SlowerSidusPeriod);
    RSI = core.indicators:create("RSI", source.close, RSIPeriod);
    CCI = core.indicators:create("CCI", source, CCIPeriod);
	
	 first = math.max(FasterEMA.DATA:first(),SlowerEMA.DATA:first())+10;
    Tunnel = instance:addStream("Tunnel", core.Dot, name .. ".Tunnel", "Tunnel", instance.parameters.T_UP_clr, first);
    Tunnel:setWidth(instance.parameters.DotSize);
    CrossUp = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.Cr_UP_clr, 0);
    CrossDn = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.Cr_DN_clr, 0);
end

function Update(period, mode)
   if period>first then
    HL[period]=source.high[period]-source.low[period];
    FasterEMA:update(mode);
    SlowerEMA:update(mode);
    FasterSidusEMA:update(mode);
    SlowerSidusEMA:update(mode);
    RSI:update(mode);
    CCI:update(mode);
	
	
    local Range=mathex.avg(HL, period-9, period);
    UpTunnel[period]=UpTunnel[period-1];
    DnTunnel[period]=DnTunnel[period-1];
    if FasterSidusEMA.DATA[period-1]>SlowerSidusEMA.DATA[period-1] and FasterSidusEMA.DATA[period-2]<=SlowerSidusEMA.DATA[period-2] and FasterSidusEMA.DATA[period]>SlowerSidusEMA.DATA[period] then
     UpTunnel[period]=1;
     DnTunnel[period]=0;
     Tunnel[period-1]=source.low[period-1]-Range;
     Tunnel:setColor(period-1, instance.parameters.T_UP_clr);
    end
    if FasterSidusEMA.DATA[period-1]<SlowerSidusEMA.DATA[period-1] and FasterSidusEMA.DATA[period-2]>=SlowerSidusEMA.DATA[period-2] and FasterSidusEMA.DATA[period]<SlowerSidusEMA.DATA[period] then
     UpTunnel[period]=0;
     DnTunnel[period]=1;
     Tunnel[period-1]=source.high[period-1]+Range;
     Tunnel:setColor(period-1, instance.parameters.T_DN_clr);
    end
    if ((FasterEMA.DATA[period]>FasterSidusEMA.DATA[period] and FasterEMA.DATA[period]>SlowerSidusEMA.DATA[period]) or (SlowerEMA.DATA[period]>FasterSidusEMA.DATA[period] and SlowerEMA.DATA[period]>SlowerSidusEMA.DATA[period])) and (FasterEMA.DATA[period-1]<=FasterSidusEMA.DATA[period-1] or FasterEMA.DATA[period-1]<=SlowerSidusEMA.DATA[period-1]) and (SlowerEMA.DATA[period-1]<=FasterSidusEMA.DATA[period-1] or SlowerEMA.DATA[period-1]<=SlowerSidusEMA.DATA[period-1]) and RSI.DATA[period]>50 and CCI.DATA[period]>0 and UpTunnel[period]==1 then
     UpTunnel[period]=0;
     DnTunnel[period]=0;
     CrossUp:set(period, source.low[period]-Range*1.6, "\225");
    end
    if ((FasterEMA.DATA[period]<FasterSidusEMA.DATA[period] and FasterEMA.DATA[period]<SlowerSidusEMA.DATA[period]) or (SlowerEMA.DATA[period]<FasterSidusEMA.DATA[period] and SlowerEMA.DATA[period]<SlowerSidusEMA.DATA[period])) and (FasterEMA.DATA[period-1]>=FasterSidusEMA.DATA[period-1] or FasterEMA.DATA[period-1]>=SlowerSidusEMA.DATA[period-1]) and (SlowerEMA.DATA[period-1]>=FasterSidusEMA.DATA[period-1] or SlowerEMA.DATA[period-1]>=SlowerSidusEMA.DATA[period-1]) and RSI.DATA[period]<50 and CCI.DATA[period]<0 and DnTunnel[period]==1 then
     UpTunnel[period]=0;
     DnTunnel[period]=0;
     CrossDn:set(period, source.high[period]+Range*1.6, "\226");
    end
    
   elseif period>first then
    UpTunnel[period]=0;
    DnTunnel[period]=0; 
   end 
end

