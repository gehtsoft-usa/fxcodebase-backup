-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41450
-- Id: 9375

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
    indicator:name("Wilders DMI oscillator");
    indicator:description("Wilders DMI oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MA_Period", "MA period", "", 1);
    indicator.parameters:addInteger("DMI_Period", "DMI period", "", 14);
    indicator.parameters:addInteger("ADX_Period", "ADX period", "", 14);
    indicator.parameters:addInteger("ADXR_Period", "ADXR period", "", 14);
    indicator.parameters:addBoolean("UseADX", "Use ADX", "", true);
    indicator.parameters:addBoolean("UseADXR", "Use ADXR", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ADXclr", "ADX color", "ADX color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("ADXwidth", "ADX width", "ADX width", 3, 1, 5);
    indicator.parameters:addInteger("ADXstyle", "ADX style", "ADX style", core.LINE_SOLID);
    indicator.parameters:setFlag("ADXstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("DMIPclr", "DMI+ color", "DMI+ color", core.rgb(0, 128, 0));
    indicator.parameters:addInteger("DMIPwidth", "DMIP width", "DMIP width", 1, 1, 5);
    indicator.parameters:addInteger("DMIPstyle", "DMIP style", "DMIP style", core.LINE_DASH);
    indicator.parameters:setFlag("DMIPstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("DMIMclr", "DMI- color", "DMI- color", core.rgb(255, 128, 128));
    indicator.parameters:addInteger("DMIMwidth", "DMIM width", "DMIM width", 1, 1, 5);
    indicator.parameters:addInteger("DMIMstyle", "DMIM style", "DMIM style", core.LINE_DASH);
    indicator.parameters:setFlag("DMIMstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("ADXRclr", "ADXR color", "ADXR color", core.rgb(255, 128, 64));
    indicator.parameters:addInteger("ADXRwidth", "ADXR width", "ADXR width", 3, 1, 5);
    indicator.parameters:addInteger("ADXRstyle", "ADXR style", "ADXR style", core.LINE_SOLID);
    indicator.parameters:setFlag("ADXRstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local MA_Period;
local DMI_Period;
local ADX_Period;
local ADXR_Period;
local UseADX;
local UseADXR;
local EMA_C, EMA_H, EMA_L;
local sPDI, sMDI, STR;
local ADX=nil;
local DMIP=nil;
local DMIM=nil;
local ADXR=nil;
local Alpha1, Alpha2;

function Prepare(nameOnly)
    source = instance.source;
    MA_Period=instance.parameters.MA_Period;
    DMI_Period=instance.parameters.DMI_Period;
    ADX_Period=instance.parameters.ADX_Period;
    ADXR_Period=instance.parameters.ADXR_Period;
    UseADX=instance.parameters.UseADX;
    UseADXR=instance.parameters.UseADXR;
	
	first= source:first()+ADXR_Period 
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MA_Period .. ", " .. instance.parameters.DMI_Period .. ", " .. instance.parameters.ADX_Period .. ", " .. instance.parameters.ADXR_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
  
    sPDI=instance:addInternalStream(0, 0);
    sMDI=instance:addInternalStream(0, 0);
    STR=instance:addInternalStream(0, 0);
    EMA_C = core.indicators:create("EMA", source.close, MA_Period);
    EMA_H = core.indicators:create("EMA", source.high, MA_Period);
    EMA_L = core.indicators:create("EMA", source.low, MA_Period);
    ADX = instance:addStream("ADX", core.Line, name .. ".ADX", "ADX", instance.parameters.ADXclr, EMA_L.DATA:first());
    ADX:setPrecision(math.max(2, instance.source:getPrecision()));
    ADX:setWidth(instance.parameters.ADXwidth);
    ADX:setStyle(instance.parameters.ADXstyle);
    DMIP = instance:addStream("DMIP", core.Line, name .. ".DMIP", "DMIP", instance.parameters.DMIPclr, EMA_L.DATA:first());
    DMIP:setPrecision(math.max(2, instance.source:getPrecision()));
    DMIP:setWidth(instance.parameters.DMIPwidth);
    DMIP:setStyle(instance.parameters.DMIPstyle);
    DMIM = instance:addStream("DMIM", core.Line, name .. ".DMIM", "DMIM", instance.parameters.DMIMclr, EMA_L.DATA:first());
    DMIM:setPrecision(math.max(2, instance.source:getPrecision()));
    DMIM:setWidth(instance.parameters.DMIMwidth);
    DMIM:setStyle(instance.parameters.DMIMstyle);
    ADXR = instance:addStream("ADXR", core.Line, name .. ".ADXR", "ADXR", instance.parameters.ADXRclr, first);
    ADXR:setPrecision(math.max(2, instance.source:getPrecision()));
    ADXR:setWidth(instance.parameters.ADXRwidth);
    ADXR:setStyle(instance.parameters.ADXRstyle);
    Alpha1=1/DMI_Period;
    Alpha2=1/ADX_Period;
end

function Update(period, mode)
  
    EMA_C:update(mode);
    EMA_H:update(mode);
    EMA_L:update(mode);
	
	 if period<EMA_L.DATA:first() then
	 return;
	 end
	 
    local hres=EMA_H.DATA[period]-EMA_H.DATA[period-1];
    local lres=EMA_L.DATA[period-1]-EMA_L.DATA[period];
    local Bulls, Bears = 0, 0;
    if hres>0 and lres<0 then
     Bulls=1;
    elseif hres<0 and lres>0 then
     Bears=1;
    end
    sPDI[period]=sPDI[period-1]+Alpha1*(Bulls-sPDI[period-1]);
    sMDI[period]=sMDI[period-1]+Alpha1*(Bears-sMDI[period-1]);
    local TR=math.max(EMA_H.DATA[period]-EMA_L.DATA[period], EMA_H.DATA[period]-EMA_C.DATA[period-1]);
    STR[period]=STR[period-1]+Alpha1*(TR-STR[period-1]);
    if STR[period]>0 then
     DMIP[period]=0.1*sPDI[period]/STR[period];
     DMIM[period]=0.1*sMDI[period]/STR[period];
    else
     DMIP[period]=0;
     DMIM[period]=0;
    end
    
    if UseADX then
     local res=DMIP[period]+DMIM[period];
     local DX=0;
     if res>0 then
      DX=100*math.abs(DMIP[period]-DMIM[period])/res;
     end
     ADX[period]=ADX[period-1]+Alpha2*(DX-ADX[period-1]);
     if UseADXR  and period > first then
      ADXR[period]=(ADX[period]+ADX[period-ADXR_Period])/2;
     end
    end
   
end

