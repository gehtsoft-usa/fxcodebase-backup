
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=16809

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


-- The indicator corresponds to the ADX indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 23 "Risk Control" (page 609-611)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Tick ADX");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Trend Strength");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("AN","ADX Period", 22, 14, 1, 1000);
    indicator.parameters:addInteger("DN","DMI Period", 22, 14, 1, 1000);
	
	indicator.parameters:addGroup("DIP Style");
    indicator.parameters:addColor("clrDIP", "Line color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthDIP", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleDIP", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDIP", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addGroup("DIM Style");
    indicator.parameters:addColor("clrDIM", "Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthDIM", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleDIM", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDIM", core.FLAG_LEVEL_STYLE);
	
		 indicator.parameters:addGroup("ADX Style");
    indicator.parameters:addColor("clrADX", "Line Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthADX", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleADX","Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleADX", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local an, dn;

local first;
local source = nil;
local avgPlusDM = nil;
local avgMinusDM = nil;
local tAbs = math.abs;

-- Streams block
local DIP = nil;
local DIM = nil;
local emaDIP = nil;
local emaDIM = nil;
local sfirst;
local buffer;
local ema;
local dmifirst;
-- Routine
function Prepare(nameOnly)
    an = instance.parameters.AN;
	dn = instance.parameters.DN;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. an.. ", " .. dn .. ")";
    instance:name(name);
    
	if   (nameOnly) then
        return;
    end
	
        

    sfirst = source:first() + 1;

    avgPlusDM = instance:addInternalStream(sfirst, 0);
    avgMinusDM = instance:addInternalStream(sfirst, 0);
    emaDIP = core.indicators:create("EMA", avgPlusDM, dn);	
    emaDIM = core.indicators:create("EMA", avgMinusDM, dn);
    first = math.max(emaDIP.DATA:first(), emaDIM.DATA:first());
	
	dmifirst=first;
	 buffer = instance:addInternalStream(dmifirst, 0);

    ema = core.indicators:create("EMA", buffer, an);

    DIP = instance:addStream("DIP", core.Line, name .. ".DIP", "DI+", instance.parameters.clrDIP, first)
    DIP:setWidth(instance.parameters.widthDIP);
    DIP:setStyle(instance.parameters.styleDIP);
    DIP:setPrecision(4);
    DIM = instance:addStream("DIM", core.Line, name .. ".DIM", "DI-", instance.parameters.clrDIM, first)
    DIM:setWidth(instance.parameters.widthDIM);
    DIM:setStyle(instance.parameters.styleDIM);
    DIM:setPrecision(4);
	
	 ADX = instance:addStream("ADX", core.Line, name, "ADX", instance.parameters.clrADX, ema.DATA:first())
    ADX:setPrecision(2);
    ADX:setWidth(instance.parameters.widthADX);
    ADX:setStyle(instance.parameters.styleADX);
	

end

function TrueRangeCustom(period)    
    return tAbs(source[period - 1] - source[period]);
end

-- Indicator calculation routine
   
function Update(period, mode)

 _DMI (period, mode)
 _ADX (period, mode)
end

function _ADX (period, mode)

     if period >= dmifirst then
        local plus = DIP[period];
        local minus = DIM[period];

        local div = plus + minus;
        if (div == 0) then
            buffer[period] = 0;
        else
            buffer[period] = 100 * (math.abs(plus - minus) / div)
        end
    end

    if period >= ema.DATA:first() then
        ema:update(mode);
        ADX[period] = ema.DATA[period];
    end

end



function _DMI (period, mode)
avgPlusDM[period] = 0;
    avgMinusDM[period] = 0;

    if period >= sfirst then
        local upperMove = 0;
        local lowerMove = 0;
        local TR = 0;

        upperMove = source[period] - source[period - 1];
        lowerMove = source[period - 1] - source[period];
        if (upperMove < 0) then upperMove = 0 end
        if (lowerMove < 0) then lowerMove = 0 end
        if (upperMove == lowerMove) then
            upperMove = 0;
            lowerMove = 0;
        elseif (upperMove < lowerMove) then
            upperMove = 0;
        elseif (lowerMove < upperMove) then
            lowerMove = 0;
        end

        TR = TrueRangeCustom(period);
        if (TR == 0) then
            avgPlusDM[period] = 0;
            avgMinusDM[period] = 0;
        else
            avgPlusDM[period] = 100 * upperMove / TR;
            avgMinusDM[period] = 100 * lowerMove / TR;
        end
    end

    if period >= first then
        emaDIP:update(mode);
        emaDIM:update(mode);

        DIP[period] = emaDIP.DATA[period];
        DIM[period] = emaDIM.DATA[period];
    end

end






