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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=61679


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("COG Channel");
    indicator:description("COG Channel");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	 
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
    indicator.parameters:addInteger("length", "Length", "Length", 34);
    indicator.parameters:addDouble("stdevmult", "STDEV Mult", "mult", 2.5);
	indicator.parameters:addDouble("atrmult", "ATR mult", "mult", 2);
   -- indicator.parameters:addInteger("offset", "Offset", "Offset", 20);
	
	indicator.parameters:addGroup("Style");	
	
	indicator.parameters:addColor("basis_color", "Color of Basis Line", "Color of Basis Line", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("uls_color", "Color of STDEV Top", "Color of STDEV Top", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("lls_color", "Color of STDEV Bottom", "Color of STDEV Bottom", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

	
	indicator.parameters:addColor("ul_color", "Color of ATR Top", "Color of ATR Bottom", core.rgb(255,0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID );
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("ll_color", "Color of ATR Bottom", "Color of ATR Bottom", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	indicator.parameters:addGroup("Channel Style");	
	indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
	indicator.parameters:addColor("Top", "Top Color", "Top Color", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Bottom", "Bottom Color", "Bottom Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Size", "Size", "Size", 10);

	indicator.parameters:addColor("alert_color", "Color of Alert", "Color of Alert", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local length;
local stdevmult;
local atrmult;
--local offset;
local Price;
local first;
local source = nil;
local uls, lls;
-- Streams block
local ul = nil;
local ll = nil;
local TR;
local Transparency;
local Top, Bottom;
local basis;
local font, Size;
-- Routine
function Prepare(nameOnly)
    length = instance.parameters.length;
    stdevmult = instance.parameters.stdevmult;
	atrmult = instance.parameters.atrmult;
    --offset = instance.parameters.offset;
	Price = instance.parameters.Price;
	Transparency = 100- instance.parameters.Transparency;
	Size = instance.parameters.Size;
	Top = instance.parameters.Top;
	Bottom = instance.parameters.Bottom;
    source = instance.source;
    first = source:first()+length;
	
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Price).. ", " .. tostring(length) .. ", " .. tostring(stdevmult).. ", " .. tostring(atrmult)  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	font = core.host:execute("createFont", "Wingdings", Size, false, false);

	TR = instance:addInternalStream(0, 0);
   

    
        ul = instance:addStream("ul", core.Line, name .. ".stdev", "stdev", instance.parameters.ul_color, first);
		ul:setWidth(instance.parameters.width3);
        ul:setStyle(instance.parameters.style3);
        ll = instance:addStream("ll", core.Line, name .. ".stdev", "stdev", instance.parameters.ll_color, first);
		ll:setWidth(instance.parameters.width4);
        ll:setStyle(instance.parameters.style4);
		
		uls = instance:addStream("uls", core.Line, name .. ".atr", "atr", instance.parameters.uls_color, first );
		uls:setWidth(instance.parameters.width1);
        uls:setStyle(instance.parameters.style1);
        lls = instance:addStream("lls", core.Line, name .. ".atr", "atr", instance.parameters.lls_color, first );
		lls:setWidth(instance.parameters.width2);
        lls:setStyle(instance.parameters.style2);
		
		
		basis  = instance:addStream("basis", core.Line, name .. ".Basis", "Basis", instance.parameters.basis_color, first );
		basis:setWidth(instance.parameters.width5);
        basis:setStyle(instance.parameters.style5);
		
		instance:createChannelGroup("Top","Top" , ul,uls, Top, Transparency);
		instance:createChannelGroup("Bottom","Bottom" , ll,lls, Bottom, Transparency);
		
   
end
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    local x1=source.high[period]-source.low[period]
    local x2=math.abs(source.high[period]-source.close[period-1])
    local x3=math.abs(source.low[period]-source.close[period-1])
    TR[period] =math.max(x1,x2,x3);
	   
    if period < first or not  source:hasData(period) then
	return;
	end
	
	local stdev=mathex.stdev (source[Price], period-length+1, period);
	local dev = (stdevmult * stdev)
	local atr_custom= mathex.avg(TR, period-length+1,period);
	
	
    basis[period]=mathex.lreg (source[Price], period-length+1, period);
	ul[period] = (basis[period] + dev)
	ll[period] = (basis[period] - dev)
 
 
	local acustom=(atrmult*atr_custom)
	uls[period]=basis[period]+acustom;
	lls[period]=basis[period]-acustom;
	
	if (uls[period]>ul[period]) and (lls[period]<ll[period])then
	core.host:execute ("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, basis[period], core.CR_CHART, core.H_Center, core.V_Center, font, instance.parameters.alert_color, "\108");
	else
	core.host:execute ("removeLabel", source:serial(period))
	end
    
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);

end	   
