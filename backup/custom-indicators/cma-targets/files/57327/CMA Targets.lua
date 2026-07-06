-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33783
-- Id: 8793

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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

    indicator:name("CMA Targets");
    indicator:description("CMA Targets");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Short", "Short CMA Period", "Short CMA Period", 30);
    indicator.parameters:addInteger("Long", "Long CMA Period", "Long CMA Period", 60);
    indicator.parameters:addInteger("Length", "Line Length", "Line Length", 0);	
	indicator.parameters:addBoolean("Show"  , "Show CMA Lines", "", false);	
	
    indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("SHORT_color", "Color of SHORT", "Color of SHORT", core.rgb(0, 288, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("LONG_color", "Color of LONG", "Color of LONG", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("Projection Style");
    indicator.parameters:addColor("Color3", "Color of Initialization Lines", "Color of Initialization Lines", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	 
 
    indicator.parameters:addColor("Color4", "Color of Projection Lines", "Color of Projection Lines", core.rgb(0, 0,255));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Label", "Label Color", "Label Color", core.rgb(0, 0,255));
	 indicator.parameters:addInteger("Size", "Font Size", "", 20);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Short;
local Long;
local Length;
local Show;
local first;
local source = nil;
 
-- Streams block
local SHORT = nil;
local LONG = nil;
local MA1, MA2;
local Cross={};
local SIZE;
local Color3, Color4;
local style4, style3;
local width3, width4;
local Label;
local font;
local Size;
-- Routine
function Prepare(nameOnly)
    Short = instance.parameters.Short;
	Show = instance.parameters.Show;
    Long = instance.parameters.Long;
    Length = instance.parameters.Length;
    source = instance.source;
	Color3 = instance.parameters.Color3;
	Color4 = instance.parameters.Color4;
	Label= instance.parameters.Label;
	Size= instance.parameters.Size;
	 style4 = instance.parameters.style4;
      width4 = instance.parameters.width4;
     style3 = instance.parameters.style3;
     width3 = instance.parameters.width3;
	 
	  local  offset = core.host:execute("getTradingDayOffset");
    local  weekoffset = core.host:execute("getTradingWeekOffset");
	
    s, e = core.getcandle(source:barSize(), core.now(), offset, weekoffset);
	SIZE= e-s;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Short) .. ", " .. tostring(Long) .. ", " .. tostring(Length) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
        font = core.host:execute("createFont", "Ariel", Size, true, false);
            assert(core.indicators:findIndicator("CMA") ~= nil, "Please, download and install CMA.LUA indicator");
            MA1 = core.indicators:create( "CMA" , source.close, Short);
            MA2 = core.indicators:create( "CMA" , source.close, Long);
        
        
        first = math.max(MA1.DATA:first(), MA2.DATA:first());
	    if Show then
        SHORT = instance:addStream("SHORT", core.Line, name .. ".SHORT", "SHORT", instance.parameters.SHORT_color, first);
		SHORT:setWidth(instance.parameters.width1);
        SHORT:setStyle(instance.parameters.style1);
        LONG = instance:addStream("LONG", core.Line, name .. ".LONG", "LONG", instance.parameters.LONG_color, first);
		LONG:setWidth(instance.parameters.width2);
        LONG:setStyle(instance.parameters.style2);
		else
		SHORT = instance:addInternalStream(0, 0);
		LONG = instance:addInternalStream(0, 0);
		end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    if period < first then
	return;
	end


    if period < source:size()-1 - math.max(Short/2, Long/2) then
	MA1:update(mode);
	MA2:update(mode);
	SHORT[period]= MA1.DATA[period];
	LONG[period]= MA2.DATA[period];
	else	
	MA1:update(core.UpdateAll);
    MA2:update(core.UpdateAll);
	
	local i;
		for i=period-math.max(Short/2, Long/2), period , 1 do 
		SHORT[i]= MA1.DATA[i];
		LONG[i]= MA2.DATA[i];
		end
	end
	
	   if period == source:size()-1 then
      Draw ();
      end
end

function Draw ()
    local value,pos;  
    value, pos = Find();
  
    -- First Line
   
    -- Second Line
    local VShift = MA2.DATA[Cross[1]] - value;
   
    local HShift2 = source:date(Cross[1]) + (Cross[1] - pos + Length) * SIZE;
    if HShift2 < source:date(source:size() - 1) and Length == 0 then
        HShift2 = source:date(source:size() - 1);
    end
    
   
    local X11 = source:date(pos);
    local X12 = source:date(Cross[1]);
    local length = (X12 - X11);
    local length2 = source:date(NOW) - source:date(Cross[1]);
    local X21 = source:date(Cross[1]);
    local X22;
    local lastBar = Cross[1] + (Cross[1] - pos);
    if lastBar >= source:size() then
        local nBarsAfterLast = Cross[1] + (Cross[1] - pos) - source:size() + 1;
        X22 = source:date(NOW) + nBarsAfterLast * SIZE;
    else
        X22 = source:date(lastBar);
    end
    
    local X31 = source:date(Cross[1]);
    local X32 = HShift2;
   
    core.host:execute("drawLine", 1, X11, value,                   X12, LONG[Cross[1]],          Color3, style3, width3);
    core.host:execute("drawLine", 2, X21, LONG[Cross[1]],          X22, LONG[Cross[1]] + VShift, Color4, style4, width4);
    core.host:execute("drawLine", 3, X31, LONG[Cross[1]] + VShift, X32, LONG[Cross[1]] + VShift, Color4, style4, width4, string.format("%." .. source:getPrecision() .. "f",  LONG[Cross[1]]+ VShift));
    
    core.host:execute("drawLabel1", 4, HShift2, core.CR_CHART, LONG[Cross[1]] + VShift + source:pipSize(), core.CR_CHART, core.H_Left, core.V_Top, font, Label, string.format("%." .. source:getPrecision() .. "f",  LONG[Cross[1]]+ VShift) );
end
  
function Find() 
    local Count = 0;
    local i;

    for i = source:size() - 1, first, -1 do
        if core.crosses(MA1.DATA, MA2.DATA, i) then 
            Count = Count + 1;
            Cross[Count] = i;
        end

        if Count == 2 then
            break;
        end
    end
    
    local value, pos;
    if SHORT[Cross[1]] > LONG[Cross[1]] then
        value, pos = mathex.min(source.low, Cross[2], Cross[1]);
    else
        value, pos = mathex.max(source.high, Cross[2], Cross[1]);
    end

    return value, pos;
end

function ReleaseInstance()
    core.host:execute("deleteFont", font);      
end
