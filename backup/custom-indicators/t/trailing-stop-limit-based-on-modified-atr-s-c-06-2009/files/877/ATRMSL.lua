-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=514

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
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
 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("ATR Modified Stop/Loss");
    indicator:description("The Stop/Loss indicator based on the modified ATR published in the Stock & Commodities 06/2009");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods to smooth ATR", "No description", 5);
    indicator.parameters:addDouble("Factor", "The factor to calculate stop/loss", "No description", 3.5);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("SL_color", "Color of SL", "Color of SL", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
end
 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local Factor;

local firstHL;
local source = nil;
local HL = nil;
local HLMVA = nil;
local firstDIFF;
local DIFF = nil;
local DIFFEMA = nil;
local first;

-- Streams block
local SL = nil;

 

-- Routine
function Prepare(nameOnly) 
    N = instance.parameters.N;
    Factor = instance.parameters.Factor;
    source = instance.source;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. Factor .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    firstHL = source:first();
    HL = instance:addInternalStream(firstHL, 0);
    HLMVA = core.indicators:create("MVA", HL, N);

    firstDIFF = HLMVA.DATA:first();
    DIFF = instance:addInternalStream(firstDIFF, 0);

    DIFFEMA = core.indicators:create("EMA", DIFF, 2 * N - 1);
    first = DIFFEMA.DATA:first();
    
    SL = instance:addStream("SL", core.Line, name, "SL", instance.parameters.SL_color, first);
	SL:setWidth(instance.parameters.width);
    SL:setStyle(instance.parameters.style);
	 
end
 
-- Indicator calculation routine
function Update(period, mode)
    
	Calculation (period, mode);
   
     
end

function Calculation(period, mode)

if period < firstHL then
	return;
	end
        HL[period] = source.high[period] - source.low[period];
        HLMVA:update(mode);
    

    if period < firstDIFF then
	return;
	end
        local chl, cmov;
        local hilo, href, lref;

        chl = HL[period];
        cmov = HLMVA.DATA[period];

        if chl < 1.5 * cmov then
            hilo = chl;
        else
            hilo = 1.5 * cmov;
        end

        if source.low[period] <= source.high[period - 1] then
            href = source.high[period] - source.close[period - 1];
        else
            href = (source.high[period] - source.close[period - 1]) - (source.low[period] - source.high[period - 1]) / 2;
        end

        if source.high[period] >= source.low[period - 1] then
            lref = source.close[period - 1] - source.low[period];
        else
            lref = source.close[period - 1] - source.low[period] - (source.low[period - 1] - source.high[period]) / 2;
        end

        DIFF[period] = math.max(hilo, href, lref);
        DIFFEMA:update(mode);
   

    if period < first then
	SL[period] = source.close[period];
	return;
	end
        local loss;
        loss = DIFFEMA.DATA[period] * Factor;

        if source.close[period] > SL[period - 1] and source.close[period - 1] > SL[period - 2] then
            SL[period] = math.max(SL[period - 1], source.close[period] - loss);
        elseif source.close[period] < SL[period - 1] and source.close[period - 1] < SL[period - 2] then
            SL[period] = math.min(SL[period - 1], source.close[period] + loss);
        elseif source.close[period] > SL[period - 1] then
            SL[period] = source.close[period] - loss;
        else
            SL[period] = source.close[period] + loss;
        end
   
   end
   
   