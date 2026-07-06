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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

  local TABLE ={ 5,10, 20, 30, 60, 120, 250 };

function Init()
    indicator:name("Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
     indicator:type(core.Indicator);
	 
	
	
	indicator.parameters:addGroup("Calculation");	
	local i;
	for i = 1, 7 , 1 do
	indicator.parameters:addInteger("PERIOD".. i, i..". MVA Period", "", TABLE[i], 2 ,1000 );
	end
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("Position", "Vertical Position", "", 0, 0 , 500);
	indicator.parameters:addInteger("Size", "Font Size", "", 8, 0 , 100);
	
	  indicator.parameters:addString("Style", "Pips/Value", "", "Value");
    indicator.parameters:addStringAlternative("Style", "Value", "", "Value");
    indicator.parameters:addStringAlternative("Style", "Pips", "", "PIPS");
	
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("LABEL", "Label color", "", core.COLOR_LABEL);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first= 1;
local source = nil;
local MVA={};

-- Streams block


local Position;
local font1;
local LABEL;
local Size;
local Style;
local PERIOD={};
local ID;

-- Routine
function Prepare()   
	
    Size=instance.parameters.Size;
    Style=instance.parameters.Style;
    LABEL=instance.parameters.LABEL;
    Position=instance.parameters.Position;  

    source = instance.source;	
	
	first= source:first();
	
    local i;
	
	for i = 1, 7, 1 do
	  PERIOD[i]=math.abs(instance.parameters:getInteger ("PERIOD"..i));
	 MVA[i]= core.indicators:create("MVA", source.close, PERIOD[i]);
	  first = math.max(MVA[i].DATA:first(), first);
	end
	
	
  

    local name = profile:id() .. "(" .. source:name()..  ")";
    instance:name(name);
	
	 font1 = core.host:execute("createFont", "Arial", Size, false, false);	
    
end


 
 
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    	local i; 
	for i = 1, 7 , 1 do
	MVA[i]:update(mode);  	
	end


    if period < first +1  then
    return;	 
    end	
	
	 ID = 0;
	 
	
	DRAW(period, "C/L", source.close[period] - source.low[period]);
    DRAW(period, "C/L(-1)", source.close[period] - source.low[period-1]);
    DRAW(period, "H/C(-1)", source.high[period] - source.close[period]);
    DRAW(period, "H/C(-1)", source.high[period] - source.close[period-1]);
   
   
   for i = 1, 7 , 1 do
    DRAW(period, "MVA(".. PERIOD[i].. ")/Close", MVA[i].DATA[period]  -source.close[period]);
   end

	 
	 
end

function DRAW (period,TEXT, VALUE)

    if Style == "PIPS" then
	NUMBER = round( VALUE/ source:pipSize() , 0);
	else
	NUMBER = round( VALUE , 4);
	end
   
     ID = ID+1;
	core.host:execute("drawLabel1", ID, -25 - ID * 50, core.CR_BOTTOM , Position+25,core.CR_LEFT  , core.H_Right , core.H_Left, font1, LABEL,
	tostring( TEXT) );
	
	 ID = ID+1;
	core.host:execute("drawLabel1", ID, -25 - (ID-1) * 50, core.CR_BOTTOM , Position+45,core.CR_LEFT  , core.H_Right , core.H_Left, font1, LABEL,
	tostring(  NUMBER ) );
	
end
function ReleaseInstance()

       core.host:execute("deleteFont", font1); 
     
	   
 end
 
 function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end
