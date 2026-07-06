-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41459
-- Id: 9387

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
    indicator:name("Damiani volatmeter oscillator");
    indicator:description("Damiani volatmeter oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Viscosity", "Viscosity", "", 7);
    indicator.parameters:addInteger("Sedimentation", "Sedimentation", "", 50);
    indicator.parameters:addDouble("Threshold_level", "Threshold level", "", 1.1);
    indicator.parameters:addBoolean("Lag_suppressor", "Lag suppressor", "", true);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local first;
local source = nil;
local Viscosity;
local Sedimentation;
local Threshold_level;
local Lag_suppressor;
local ATR_V;
local ATR_S;
local StdDev_V;
local StdDev_S;
local ClBuffer;

function Prepare(nameOnly)
    source = instance.source;
    Viscosity=instance.parameters.Viscosity;
    Sedimentation=instance.parameters.Sedimentation;
    Threshold_level=instance.parameters.Threshold_level;
    Lag_suppressor=instance.parameters.Lag_suppressor;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Viscosity .. ", " .. instance.parameters.Sedimentation .. ", " .. instance.parameters.Threshold_level .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("STDDEV2") ~= nil, "Please, download and install STDDEV2.LUA indicator"); 
	
    ATR_V = core.indicators:create("ATR", source, Viscosity);
    ATR_S = core.indicators:create("ATR", source, Sedimentation);
    StdDev_V = core.indicators:create("STDDEV2", source.typical, Viscosity, "LWMA");
    StdDev_S = core.indicators:create("STDDEV2", source.typical, Sedimentation, "LWMA");
    first = math.max(ATR_V.DATA:first(), ATR_S.DATA:first())+2;
    ClBuffer = instance:addInternalStream(first, 0);
    Pbuff = instance:addStream("Pbuff", core.Line, name .. ".Pbuff", "Pbuff", instance.parameters.UPclr, first);
    Mbuff = instance:addStream("Mbuff", core.Line, name .. ".Mbuff", "Mbuff", instance.parameters.UPclr, first);
	
	Pbuff:setPrecision(math.max(2, instance.source:getPrecision()));
	Mbuff:setPrecision(math.max(2, instance.source:getPrecision()));
		
    instance:createChannelGroup("TC","TC" , Pbuff, Mbuff, instance.parameters.UPclr, 100-instance.parameters.Transparency);
end

function Update(period, mode)
   if period<first then
   return;
   end
    ATR_V:update(mode);
    ATR_S:update(mode);
    StdDev_V:update(mode);
    StdDev_S:update(mode);
    
    local s1=ClBuffer[period-1];
    local s3=ClBuffer[period-3];

    local vol;
    if Lag_suppressor then
     vol=ATR_V.DATA[period]/ATR_S.DATA[period]+(s1-s3)/2;
    else
     vol=ATR_V.DATA[period]/ATR_S.DATA[period];
    end
    
    local t=Threshold_level-StdDev_V.DATA[period]/StdDev_S.DATA[period];
    ClBuffer[period]=vol;
    
    Pbuff[period]=vol;
    Mbuff[period]=t;
    
    if Pbuff[period]>Mbuff[period] then
     Pbuff:setColor(period, instance.parameters.UPclr);
     Mbuff:setColor(period, instance.parameters.UPclr);
    else
     Pbuff:setColor(period, instance.parameters.DNclr);
     Mbuff:setColor(period, instance.parameters.DNclr);
    end
 
end

