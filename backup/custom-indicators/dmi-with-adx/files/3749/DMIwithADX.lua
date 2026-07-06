-- Id: 1492
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1867

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("DMI with ADX");
    indicator:description("Identifies and determines the strength of a prevailing trend.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Trend Strength");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ADXF", "ADX Number of periods", "ADX The number of periods.", 14, 2, 1000);
	indicator.parameters:addInteger("DMIF", "DMI Number of periods", "DMI The number of periods.", 14, 2, 1000);
	indicator.parameters:addInteger("Level", "Signal Line Level", "Signal Line Level", 20, 0, 100);

	indicator.parameters:addBoolean("ShowADX", "Show the ADX line", "", true);
	indicator.parameters:addBoolean("ShowDMI", "Show the DMI line", "", true);
	indicator.parameters:addBoolean("ShowSignal", "Show the Signal line", "", true);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrDIP", "Color of DI+", "The color of the DI+ line.", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("widthDIP", "DIP Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleDIP", "DIP Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDIP", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrDIM", "Color of DI-", "The color of the DI- line.", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("widthDIM", "DIM Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleDIM", "DIM Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDIM", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("clrADX", "Color of ADX", "The color of the ADX line.", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("widthADX", "ADX Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleADX", "ADX Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleADX", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Signal_color", "Color of Signal Line", "", core.rgb(255, 255, 255));
	indicator.parameters:addInteger("widthSignal", "Signal Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSignal", "Signal Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSignal", core.FLAG_LINE_STYLE);

	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local ADXF, DMIF;

local first;
local source = nil;
local avgPlusDM = nil;
local avgMinusDM = nil;

local ShowADX=nil;
local ShowDMI=nil;
local ShowSignal=nil;
local Level =nil;

local buffer = nil;

-- Streams block
local DIP = nil;
local DIM = nil;
local ADX = nil;

local emaDIP = nil;
local emaDIM = nil;

-- Routine
function Prepare(nameOnly)
    ADXF = instance.parameters.ADXF;
	DMIF = instance.parameters.DMIF;
	ShowADX = instance.parameters.ShowADX;
	ShowDMI = instance.parameters.ShowDMI;
	ShowSignal = instance.parameters.ShowSignal;
	Level  = instance.parameters.Level;
	
    source = instance.source;
    first = source:first() + 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. ADXF.. ", ".. DMIF ..  ", ".. Level ..")";
    instance:name(name);
    if nameOnly then
        return;
    end
    avgPlusDM = instance:addInternalStream(0, 0);
    avgMinusDM = instance:addInternalStream(0, 0);
	buffer = instance:addInternalStream(0, 0);
    
	if not ShowADX then
    ADX=instance:addInternalStream(0, 0);
	end
	
	if not ShowDMI then
    DIP=instance:addInternalStream(0, 0);
    DIM=instance:addInternalStream(0, 0); 
    end	
     
	if  ShowDMI then 
    DIP = instance:addStream("DIP", core.Line, name .. ".DIP", "DI+", instance.parameters.clrDIP, first+DMIF)
	DIP:setWidth(instance.parameters.widthDIP);
    DIP:setStyle(instance.parameters.styleDIP);
    DIM = instance:addStream("DIM", core.Line, name .. ".DIM", "DI-", instance.parameters.clrDIM, first+DMIF)
	DIM:setWidth(instance.parameters.widthDIM);
    DIM:setStyle(instance.parameters.styleDIM);
	DIM:setPrecision(math.max(2, instance.source:getPrecision()));
	end
	
	if ShowADX then
	ADX = instance:addStream("ADX", core.Line, name, "ADX", instance.parameters.clrADX, first+DMIF+ADXF)
	ADX:setWidth(instance.parameters.widthADX);
    ADX:setStyle(instance.parameters.styleADX);
	ADX:setPrecision(math.max(2, instance.source:getPrecision()));
	end
	
    emaDIP = core.indicators:create("EMA", avgPlusDM, DMIF);
    emaDIM = core.indicators:create("EMA", avgMinusDM, DMIF);
	ema = core.indicators:create("EMA", buffer, ADXF);
end

function TrueRangeCustom(period)
    local num1 = math.abs(source.high[period] - source.low[period]);
    local num2 = math.abs(source.high[period] - source.close[period - 1]);
    local num3 = math.abs(source.close[period - 1] - source.low[period]);
    return math.max(num1, num2, num3);
end

-- Indicator calculation routine
function Update(period, mode)
    avgPlusDM[period] = 0;
    avgMinusDM[period] = 0;

    if period < first then
	return;
	end
	
	
	 core.host:execute("drawLine", 1, source:date(first), Level, source:date(period), Level, instance.parameters.Signal_color,instance.parameters.styleSignal,  instance.parameters.widthSignal);
	
	
        local upperMove = 0;
        local lowerMove = 0;
        local TR = 0;

        upperMove = source.high[period] - source.high[period - 1];
        lowerMove = source.low[period - 1] - source.low[period];
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
		
		
		if period < emaDIP.DATA:first() then
		return;
		end
		
        
        emaDIP:update(mode);
        emaDIM:update(mode);

        DIP[period] = emaDIP.DATA[period];
        DIM[period] = emaDIM.DATA[period];
				

        local div = DIP[period] + DIM[period];
        if (div == 0) then
            buffer[period] = 0;
        else
            buffer[period] = 100 * (math.abs(DIP[period] - DIM[period]) / div)
        end
 
 
        if period < ema.DATA:first() then
		return;
		end
		
        ema:update(mode);
		
        ADX[period] = ema.DATA[period];
   
	 
end