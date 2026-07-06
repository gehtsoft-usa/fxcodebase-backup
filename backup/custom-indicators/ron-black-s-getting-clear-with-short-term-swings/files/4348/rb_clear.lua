-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2107


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- The CLEAR method is described in the Stock & Commodities Sep 2010 issue
-- in Ron Black articles "Getting Clear With Short-Term Swings"
function Init()
    indicator:name("Clear Method");
    indicator:description("The indicator detects market direction changes using Ron Black's 'Getting Clear With Short-Term Swings' described in Sep 2010 issue of Stock & Commodities");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUpSw", "Up Swing Line Color", "", core.rgb(0, 255, 255));
    indicator.parameters:addColor("clrDnSw", "Down Swing Line Color", "", core.rgb(255, 0, 255));
    indicator.parameters:addInteger("width", "Line Width", "", 2, 1, 5);

end

local source;
local hh, hl, lh, ll, swing; -- internal data
local UpSw, DnSw;            -- indicator lines

function Prepare(nameOnly)
    local name;

    source = instance.source;
    first = source:first();

    name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    hh = instance:addInternalStream(0, 0);
    ll = instance:addInternalStream(0, 0);
    lh = instance:addInternalStream(0, 0);
    hl = instance:addInternalStream(0, 0);
    swing = instance:addInternalStream(0, 0);

    UpSw = instance:addStream("Up", core.Dot, name .. ".Up", "Up", instance.parameters.clrUpSw, first);
    UpSw:setWidth(instance.parameters.width);
    DnSw = instance:addStream("Dn", core.Dot, name .. ".Dn", "Dn", instance.parameters.clrDnSw, first);
    DnSw:setWidth(instance.parameters.width);
end

function Update(period, mode)
    if period < first then
        swing[period] = 0;
    elseif period == first then
        swing[period] = 0;
        hh[period] = source.high[period];
        lh[period] = source.high[period];
        hl[period] = source.low[period];
        ll[period] = source.low[period];
    elseif period > first then
        swing[period] = swing[period - 1];
        hh[period] = math.max(source.high[period], hh[period - 1]);
        lh[period] = math.min(source.high[period], lh[period - 1]);
        hl[period] = math.max(source.low[period], hl[period - 1]);
        ll[period] = math.min(source.low[period], ll[period - 1]);
    end

    if swing[period] > 0 then
        if source.high[period] < hl[period] then
            swing[period] = -1;      -- up swing
            ll[period] = source.low[period];
            lh[period] = source.high[period];
        end
    elseif swing[period] < 0 then
        if source.low[period] > lh[period] then
            swing[period] = 1;     -- down swing
            hh[period] = source.high[period];
            hl[period] = source.low[period];
        end
    else
        -- look for initial
        if source.high[period] < hl[period] then
            swing[period] = -1;      -- up swing
            ll[period] = source.low[period];
            lh[period] = source.high[period];
        elseif source.low[period] > hl[period] then
            swing[period] = 1;     -- down swing
            hh[period] = source.high[period];
            hl[period] = source.low[period];
        end
    end

    if swing[period] > 0 then
        UpSw[period] = hl[period];
        DnSw[period] = nil;
    elseif swing[period] < 0 then
        DnSw[period] = lh[period];
        UpSw[period] = nil;
    end
end
