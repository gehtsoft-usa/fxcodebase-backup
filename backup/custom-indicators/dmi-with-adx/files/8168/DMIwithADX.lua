-- Id: 3121
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("DMI with ADX");
    indicator:description("Identifies and determines the strength of a prevailing trend.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Trend Strength");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ADXF", "ADX Number of periods", "ADX The number of periods.", 14, 2, 1000);
	indicator.parameters:addInteger("DMIF", "DMI Number of periods", "DMI The number of periods.", 14, 2, 1000);
	
	indicator.parameters:addBoolean("ShowADX", "Show the ADX line", "", true);
	indicator.parameters:addBoolean("ShowDMI", "Show the DMI line", "", true);
	indicator.parameters:addBoolean("ShowSignal", "Show the Signal line", "", true);
    indicator.parameters:addGroup("DMI LineStyle");
    indicator.parameters:addColor("clrDIP", "Color of DI+", "The color of the DI+ line.", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("widthDIP", "DIP Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleDIP", "DIP Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDIP", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrDIM", "Color of DI-", "The color of the DI- line.", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("widthDIM", "DIM Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleDIM", "DIM Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDIM", core.FLAG_LINE_STYLE);
	indicator.parameters:addGroup("ADX Line Style"); 	
	indicator.parameters:addColor("clrADX", "Color of ADX", "The color of the ADX line.", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("widthADX", "ADX Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleADX", "ADX Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleADX", core.FLAG_LINE_STYLE);

	
	indicator.parameters:addGroup("1. Line Style"); 
    indicator.parameters:addBoolean("One", "First Line", "", true);	
	indicator.parameters:addInteger("OneLevel", "Line Level", "", 20);

	indicator.parameters:addColor("Color1", "Color of Line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("2. Line Style");
	indicator.parameters:addBoolean("Two", "Second Line", "", false);
	indicator.parameters:addInteger("TwoLevel", "Line Level", "", 40);
	indicator.parameters:addColor("Color2", "Color of  Line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "Line Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line Line width", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local ADXF, DMIF;
local OneLevel,TwoLevel
local One,Two;


local first;
local source = nil;
local avgPlusDM = nil;
local avgMinusDM = nil;

local ShowADX=nil;
local ShowDMI=nil;
local ShowSignal=nil;

local buffer = nil;

-- Streams block
local DIP = nil;
local DIM = nil;
local ADX = nil;

local emaDIP = nil;
local emaDIM = nil;

-- Routine
function Prepare(nameOnly)
    One= instance.parameters.One;
	Two= instance.parameters.Two;
    TwoLevel= instance.parameters.TwoLevel;
	OneLevel= instance.parameters.OneLevel;
    ADXF = instance.parameters.ADXF;
	DMIF = instance.parameters.DMIF;
	ShowADX = instance.parameters.ShowADX;
	ShowDMI = instance.parameters.ShowDMI;
	ShowSignal = instance.parameters.ShowSignal;
	
	
    source = instance.source;
    first = source:first() + 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. ADXF.. ", ".. DMIF  ..")";
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
	
	if source:size()-1 == period then
		if One then
			core.host:execute ("drawLine", 1,  source:date(first), OneLevel, source:date(period), OneLevel, instance.parameters.Color1, instance.parameters.style1, instance.parameters.width1);	
		end	
		if Two then	
			core.host:execute ("drawLine", 2, source:date(first), TwoLevel, source:date(period), TwoLevel,instance.parameters.Color2 , instance.parameters.style2, instance.parameters.width2);	
		end
	end
		
    if period < first then	
	return;
	end
	
	
	
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