-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61243
-- Id: 12609

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
    indicator:name("Accumulation Swing Index");
    indicator:description("Gets signals from previous maximums and minimums of price.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Swing");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("T", "T", "Maximum price changing during the trade session.", 300, 2, 1000);
	
	indicator.parameters:addString("Position", "Overlay Position", "", "B");
    indicator.parameters:addStringAlternative("Position", "Bottom", "", "B");
    indicator.parameters:addStringAlternative("Position", "Top", "", "T");
	indicator.parameters:addStringAlternative("Position", "Central", "", "C");
	
	indicator.parameters:addInteger("ScreenSize", "Overlay Size as  percentage of the screen", "", 25);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrASI", "Accumulation Swing Index line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthASI","Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleASI", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleASI", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addColor("Label", "Label Color","", core.rgb(0, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local ScreenSize;
local first;
local source = nil;

-- Streams block
local SI = nil;
local ASI=nil;
local T = nil;
local Raw;
local Position;
local Label; 
local Max, Min;
local max,min;
-- Routine
function Prepare(nameOnly)

    source = instance.source;
    first = source:first() + 1;
 
	
	Position=instance.parameters.Position;
	ScreenSize=instance.parameters.ScreenSize;
	Label=instance.parameters.Label;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	
	Raw= instance:addInternalStream(first, 0);
	
    ASI = instance:addStream("ASI", core.Line, name, "ASI", instance.parameters.clrASI, first);
    ASI:setWidth(instance.parameters.widthASI);
    ASI:setStyle(instance.parameters.styleASI);
    local precision = math.max(2, source:getPrecision());
    ASI:setPrecision(precision);
    T = source:pipSize() * instance.parameters.T;
	
	
	Min=nil;
	
	instance:ownerDrawn(true);

end


function Axis (context)

    local Delta =(( context:bottom() -context:top())/100)*ScreenSize;
    local Start, End;
	
	
 
	
	  if Position == "T" then
	   Start=context:top();	   
	   End = Start+Delta;
	  Mid =Start + Delta/2;
	  elseif Position == "C" then
	  Start=context:top();
	  End=context:bottom();	   	  
	 Mid =Start + ( context:bottom() -context:top())/2;
	  elseif Position == "B" then
	  Start=context:bottom()-Delta;	  
	  End=context:bottom();
	  Mid =Start + Delta/2;
	  end
	
	x, x1, x2 = context:positionOfBar (source:size()-1);
	context:drawLine (1, x+50, Start, x+50, End, 0);
	 
	MAX = math.max(math.abs(Min), math.abs(Max));
	
	width, height =  context:measureText (2, "0", context.RIGHT) ; 
	 
	AddLabels (context,   x, Start+height, MAX );
 	AddLabels (context,   x, Mid, 0 );	
	AddLabels (context,   x, End,  -MAX );
	
	max=Start;
	min=End;
	context:drawLine (1,context:left() , Mid, x+50, Mid, 0);
	
	 Recalculate (context);
end


function Recalculate (context)

local period;

	for period = source:first(), source:size()-1, 1 do
	ASI[period]= context:priceOfPoint ( (( Raw[period] - Min)/ (Max-Min))*(max-min) +min  );
	end
end

function AddLabels ( context,  x,  y, Value)

 value = string.format("%." .. 0 .. "f", Value)

  width, height =  context:measureText (2, value, context.RIGHT) ; 
context:drawText (2, value, Label, -1,x+55, y-height, x+55+ width, y, context.RIGHT,0)
 

end

local init = false;
 
function Draw(stage, context)


if stage ~= 2
or Min== nil 
 then
return;
end



if not init then
context:createPen (1, context.SOLID, 1, Label)
context:createFont (2, "Ariel", 10, 10, 0);
init = true;
end


Axis (context)



end

-- Indicator calculation routine
function Update(period) 
 
 Calculation (period);
 
 
 
 if period <source:size()-1 then
 return;
 end
 
 Min, Max= mathex.minmax(Raw,Raw:first(), Raw:size()-1 ); 
end

function Calculation (period)
   local open, close, abs;

    if period >= first then
        open = source.open;
        close = source.close;
        abs = math.abs

        local nom = close[period] - close[period - 1]
            + (0.5 * (close[period] - open[period]))
            + (0.25 * (close[period - 1] - open[period - 1]));


        local closePrev = close[period - 1];
        local highCurr = source.high[period];
        local lowCurr = source.low[period];
        local hc = abs(highCurr - closePrev);
        local lc = abs(lowCurr - closePrev);
        local hl = abs(highCurr - lowCurr);
        local co = abs(closePrev - open[period - 1]);

        local TR = math.max(hc, lc, hl);

        local ER = 0;

        if ((closePrev >= lowCurr) and (closePrev <= highCurr)) then
            ER = 0;
        else
            if (closePrev > highCurr) then
                ER = hc;
            elseif (closePrev < lowCurr) then
                ER = lc;
            end
        end

        local SH = co;
        local K = math.max(hc, lc);
        local R = TR - 0.5 * ER + 0.25 * SH;

        if (R == 0) then
            SI = 0;
        else
            SI = 50 * nom * (K / T) / R;
        end
        Raw[period] = Raw[period - 1] + SI;
    end
	
	

end
