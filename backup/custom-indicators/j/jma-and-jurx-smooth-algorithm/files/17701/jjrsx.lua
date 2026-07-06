-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7895

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
    indicator:name("Jurik Smoothed RSX");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N1", "Number of periods to price delta", "", 8, 1, 10000);
    indicator.parameters:addInteger("N2", "Number of periods to final smooth", "", 3, 1, 10000);
    indicator.parameters:addInteger("P", "Phase to final smooth", "", 100, -1000, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addGroup("Levels");
    indicator.parameters:addDouble("l1", "Level1", "", 0.5, -1, 1);
    indicator.parameters:addDouble("l2", "Level2", "", 0, -1, 1);
    indicator.parameters:addDouble("l3", "Level3", "", -0.5, -1, 1);
    indicator.parameters:addColor("lclr", "Color", "", core.COLOR_CUSTOMLEVEL);
    indicator.parameters:addInteger("lwidth", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("lstyle", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("lstyle", core.FLAG_LEVEL_STYLE);
end

local diff, adiff, jrx1, jrx2, jrx, jma, output;
local first, first1, first2;
local source;
local n1, n2, p;

function Prepare(onlyName)
    assert(core.indicators:findIndicator("JMA") ~= nil, "JMA indicator must be installed");
    assert(core.indicators:findIndicator("JRX") ~= nil, "JRX indicator must be installed");

    source = instance.source;
    n1 = instance.parameters.N1;
    n2 = instance.parameters.N2;
    p = instance.parameters.P;

    local name = profile:id() .. "(" .. source:name() .. "," .. n1 .. "," .. n2 .. "," .. p .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    first1 = source:first() + 1;
    diff = instance:addInternalStream(first1, 0);
    adiff = instance:addInternalStream(first1, 0);
    jrx1 = core.indicators:create("JRX", diff, n1);
    jrx2 = core.indicators:create("JRX", adiff, n1);
    first2 = math.max(jrx1.DATA:first(), jrx2.DATA:first());
    jrx = instance:addInternalStream(first2, 0);
    jma = core.indicators:create("JMA", jrx, n2, p);
    first = jma.DATA:first();

    data = instance:addStream("JJRSX", core.Bar, name .. ".JJRSX", "JJRSX", instance.parameters.Up, first);
    data:setPrecision(4);
    data:setWidth(instance.parameters.width);
    data:setStyle(instance.parameters.style);
    data:addLevel(instance.parameters.l1, instance.parameters.lstyle, instance.parameters.lwidth, instance.parameters.lclr);
    data:addLevel(instance.parameters.l2, instance.parameters.lstyle, instance.parameters.lwidth, instance.parameters.lclr);
    data:addLevel(instance.parameters.l3, instance.parameters.lstyle, instance.parameters.lwidth, instance.parameters.lclr);
end

function Update(period, mode)
    if period >= first1 then
        local v = source[period] - source[period - 1];
        diff[period] = v
        adiff[period] = math.abs(v);
        if period >= first2 then
            jrx1:update(mode);
            jrx2:update(mode);
            local u, w;
            u = jrx1.DATA[period];
            w = jrx2.DATA[period];
            if w ~= 0 then
                v = u / w;
            else
                v = 0;
            end
            jrx[period] = math.max(math.min(v, 1), -1);
            if period >= first then
                jma:update(mode);
                data[period] = jma.DATA[period];
				
				if data[period] > data[period-1] then
                data:setColor(period, instance.parameters.Up);				
				else 
				data:setColor(period, instance.parameters.Down);
				end
            end		
			
        end
    end
end

