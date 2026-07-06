-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7183

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
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 0 , 100);
	
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
function Prepare(nameOnly)   
	
    Size=instance.parameters.Size;
    Style=instance.parameters.Style;
    LABEL=instance.parameters.LABEL;
    Position=instance.parameters.Position;  

    source = instance.source;	
	
	first= source:first();
	local name = profile:id() .. "(" .. source:name()..  ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
    local i;
	
	for i = 1, 7, 1 do
		PERIOD[i]=math.abs(instance.parameters:getInteger ("PERIOD"..i));
		MVA[i]= core.indicators:create("MVA", source.close, PERIOD[i]);
		first = math.max(MVA[i].DATA:first(), first);
	end
	
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
	 
	  ID = ID+1;
	 if Style == "PIPS" then  
	core.host:execute("drawLabel1", ID, -50, core.CR_BOTTOM , Position+ ID * 25,core.CR_LEFT  , core.H_Right , core.H_Left, font1, LABEL,  "PIPS");
	else
	core.host:execute("drawLabel1", ID, -50, core.CR_BOTTOM , Position+ ID * 25,core.CR_LEFT  , core.H_Right , core.H_Left, font1, LABEL,  "Value");
	end
	
	DRAW(period, "Close/Low", source.close[period] - source.low[period]);
    DRAW(period, "Close/Low(-1)", source.close[period] - source.low[period-1]);
    DRAW(period, "High/Close(-1)", source.high[period] - source.close[period]);
    DRAW(period, "High/Close(-1)", source.high[period] - source.close[period-1]);
   
   
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
	core.host:execute("drawLabel1", ID, -150, core.CR_BOTTOM , Position+ ID * 25,core.CR_LEFT  , core.H_Right , core.H_Left, font1, LABEL,
	tostring( TEXT.. " : " .. NUMBER ) );
	--tostring( TEXT .. " :" ));
	
	--core.host:execute("drawLabel1", 1000+ ID, -50, core.CR_BOTTOM , Position+ ID * 25,core.CR_LEFT  , core.H_Right , core.H_Right, font1, LABEL,
	--tostring(  NUMBER ) );
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
