//Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=76277

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
function Init()
    indicator:name("PineScript DMI");
    indicator:description("PineScript version of DMI");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("diLength", "DI Length", "", 7)
    indicator.parameters:addInteger("adxSmoothing", "ADX Smoothing", "", 7)

    indicator.parameters:addColor("dip_color", "DIP Color", "DIP Color", core.colors().Green);
    indicator.parameters:addInteger("dip_width", "DIP Width", "DIP Width", 1, 1, 5);
    indicator.parameters:addInteger("dip_style", "DIP Style", "DIP Style", core.LINE_SOLID);
    indicator.parameters:setFlag("dip_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("dim_color", "DIM Color", "DIM Color", core.colors().Green);
    indicator.parameters:addInteger("dim_width", "DIM Width", "DIM Width", 1, 1, 5);
    indicator.parameters:addInteger("dim_style", "DIM Style", "DIM Style", core.LINE_SOLID);
    indicator.parameters:setFlag("dim_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("adx_color", "ADX Color", "ADX Color", core.colors().Gray);
    indicator.parameters:addInteger("adx_width", "ADX Width", "ADX Width", 1, 1, 5);
    indicator.parameters:addInteger("adx_style", "ADX Style", "ADX Style", core.LINE_SOLID);
    indicator.parameters:setFlag("adx_style", core.FLAG_LINE_STYLE);
end

local source;
local adx;
local dmi
local DIP_out;
local DIM_out;
local ADX_out;
function Prepare(nameOnly)
    source = instance.source;
    diLength = instance.parameters.diLength;
    adxSmoothing = instance.parameters.adxSmoothing;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    dmi = core.indicators:create("DMI", source, diLength)
    adx = core.indicators:create("ADX", source, adxSmoothing)
    DIP_out = instance:addStream("DIP", core.Line, "DIP", "DIP", instance.parameters.dip_color, 0, 0);
    DIP_out:setWidth(instance.parameters.dip_width);
    DIP_out:setStyle(instance.parameters.dip_style);
    DIM_out = instance:addStream("DIM", core.Line, "DIM", "DIM", instance.parameters.dim_color, 0, 0);
    DIM_out:setWidth(instance.parameters.dim_width);
    DIM_out:setStyle(instance.parameters.dim_style);
    ADX_out = instance:addStream("ADX", core.Line, "ADX", "ADX", instance.parameters.adx_color, 0, 0);
    ADX_out:setWidth(instance.parameters.adx_width);
    ADX_out:setStyle(instance.parameters.adx_style);
end

function TrueRange(p)
    local hl = math.abs(source.high[p] - source.low[p]);
    local hc = math.abs(source.high[p] - source.close[p - 1]);
    local lc = math.abs(source.low[p] - source.close[p - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end

function Update(period, mode)
    dmi:update(mode);
    DIP_out[period] = dmi.DIP[period];
    DIM_out[period] = dmi.DIM[period];
      
    adx:update(mode);
    ADX_out[period] = adx.DATA[period];
end
//Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=76277

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+