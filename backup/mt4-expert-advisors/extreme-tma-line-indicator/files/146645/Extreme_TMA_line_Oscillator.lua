--[[ Extreme TMA line Oscillator ]]

function Init()
    indicator:name("0607.2022.1521");
    indicator:description("Extreme TMA line Oscillator");
    indicator:requiredSource(core.Bar);
    --indicator:type(core.Indicator);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("TMA_Period", "TMA period", "", 56);
    indicator.parameters:addInteger("ATR_Period", "ATR period", "", 100);
    indicator.parameters:addDouble("ATR_Mult", "ATR multiplier", "", 2);
    indicator.parameters:addDouble("TrendThreshold", "TrendThreshold", "", 0.5);
    indicator.parameters:addBoolean("Redraw", "Redraw", "", true);


	indicator.parameters:addString("Method", "Method", "Method" , "Absolute");
    indicator.parameters:addStringAlternative("Method", "Absolute", "Absolute" , "Absolute");
    indicator.parameters:addStringAlternative("Method", "Relative", "Relative" , "Relative");
	

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TMA_NEclr", "TMA neutral Color", "TMA neutral Color", core.rgb(128, 128, 128));
    indicator.parameters:addColor("TMA_UPclr", "TMA UP Color", "TMA UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("TMA_DNclr", "TMA DN Color", "TMA DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("TMAwidth", "TMA width", "TMA width", 2, 1, 5);
    indicator.parameters:addInteger("TMAstyle", "TMA style", "TMA style", core.LINE_SOLID);
    indicator.parameters:setFlag("TMAstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Bandclr", "Band Color", "Band Color", core.rgb(128, 128, 0));
    indicator.parameters:addInteger("Bandwidth", "Band width", "Band width", 1, 1, 5);
    indicator.parameters:addInteger("Bandstyle", "Band style", "Band style", core.LINE_DASH);
    indicator.parameters:setFlag("Bandstyle", core.FLAG_LINE_STYLE);
    
end

local first;
local source = nil;

local TMA_Period;
local ATR_Period;
local ATR_Mult;
local TrendThreshold;
local Redraw;
local TMA=nil;

local ATR;

local EMAS = nil; 
local EMAL = nil;
local MVAI = nil;
local OSCILLATOR;
local MACD = nil;

local Method;

function Prepare(nameOnly)

    source = instance.source;

    TMA_Period=instance.parameters.TMA_Period;
    ATR_Period=instance.parameters.ATR_Period;
    ATR_Mult=instance.parameters.ATR_Mult;
    TrendThreshold=instance.parameters.TrendThreshold;
    Redraw=instance.parameters.Redraw;
	
	Method=instance.parameters.Method;

    local name = profile:id()
    .."(".. 
    source:name()
    ..", "..
    instance.parameters.TMA_Period
    ..", "..
    instance.parameters.ATR_Period
    ..", "..
    instance.parameters.ATR_Mult
    ..", "..
    instance.parameters.TrendThreshold
    .. ")";

    instance:name(name);
	
    if (nameOnly) then return; end;



    assert(core.indicators:findIndicator("EXTREME_TMA_LINE") ~= nil, "Please, download and install EXTREME_TMA_LINE.LUA indicator");

    Range = instance:addInternalStream(0, 0);
	
 
	
    ATR = core.indicators:create("ATR", source, ATR_Period); 
    TMA = core.indicators:create(
        "EXTREME_TMA_LINE",
        source,
        TMA_Period,
        ATR_Period,
        ATR_Mult,
        TrendThreshold,
        true,
        Redraw,
        core.rgb(128, 128, 128),
        core.rgb(0, 255, 0),
        core.rgb(255, 0, 0)
    )

 

	first = source:first();
	
    OSCILLATOR = instance:addStream("OSCILLATOR", core.Bar, name .. "OSCILLATOR", "OSCILLATOR", instance.parameters.TMA_NEclr, first);
    OSCILLATOR:setPrecision(math.max(2, instance.source:getPrecision())); 
    OSCILLATOR:addLevel(0, core.LINE_SOLID, 1, core.rgb(192, 192, 192));
 

    Upper = instance:addStream("Upper", core.Line, name .. "Upper", "Upper", instance.parameters.TMA_NEclr, first);
    Upper:setPrecision(math.max(2, instance.source:getPrecision()));
 
	
    Lower = instance:addStream("Lower", core.Line, name .. "Lower", "Lower", instance.parameters.TMA_NEclr, first);
    Lower:setPrecision(math.max(2, instance.source:getPrecision()));
 	

end
--
function Update(period, mode)

    ATR:update(mode); 
    TMA:update(mode); 
	
    if (period < first) then return; end; 

    Range[period] = ATR.DATA[period] * ATR_Mult;



    if Method == "Relative" then
    OSCILLATOR[period] = (source[period] - TMA.DATA[period]);
	Upper[period]= Range[period]
	Lower[period]= -Range[period]	
    else
    OSCILLATOR[period] = (source[period] - TMA.DATA[period]) / (Range[period]/100);	
	Upper[period]= 100
	Lower[period]= -100	
	end
	
	
    local Slope=(TMA.DATA[period]-TMA.DATA[period-1])/(0.1* ATR.DATA[period]);
	
	if (Slope>TrendThreshold) then
    OSCILLATOR:setColor(period, instance.parameters.TMA_DNclr);
    elseif (Slope<-TrendThreshold) then
    OSCILLATOR:setColor(period, instance.parameters.TMA_UPclr);	
    else
    OSCILLATOR:setColor(period, instance.parameters.TMA_NEclr);		
	end
	 

end