-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68639

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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


-- Indicator profile initialization routine

function Init()
    indicator:name("Range Filter");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
 
 
    indicator.parameters:addInteger("Sampling_Period", "Sampling Period", "", 100, 1, 2000);
    indicator.parameters:addDouble("Range_Multiplier", "Range_Multiplier", "", 3, 0, 2000);
	
	
	indicator.parameters:addGroup("Color Style"); 	
	
	indicator.parameters:addColor("Up", "Up Trend Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral Line Color", "", core.rgb(128, 128,128));
	
	indicator.parameters:addGroup("Central Line Style"); 	
 
	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("Top Line Style"); 	
 
	
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("Bottom Line Style"); 	
 
	
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Range_Multiplier, Sampling_Period;
local first;
local source = nil;
local Up, Down, Neutral; 
local rng, avrng,smoothrng;
local Top, Bottom,Central;
local upward,downward;
-- Routine
 function Prepare(nameOnly)   
   
   
    Range_Multiplier= instance.parameters.Range_Multiplier;
	Sampling_Period= instance.parameters.Sampling_Period;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral = instance.parameters.Neutral;
	
	

	
	local Parameters=Range_Multiplier..", "..Sampling_Period ;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
  
    rng= instance:addInternalStream(0, 0);
	upward= instance:addInternalStream(0, 0);
	downward = instance:addInternalStream(0, 0);
			
    source = instance.source; 
    first=source:first() +1;
	
 
    avrng= core.indicators:create("EMA", rng, Sampling_Period);
	smoothrng= core.indicators:create("EMA", avrng.DATA, ( (Sampling_Period*2) - 1));
 
	
	Central = instance:addStream("Central" , core.Line, " Central"," Central", Neutral, first );
	Central:setWidth(instance.parameters.width);
    Central:setStyle(instance.parameters.style);
    Central:setPrecision(math.max(2, source:getPrecision()));
	
	Top = instance:addStream("Top" , core.Line, " Top"," Top", Neutral, first );
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
    Top:setPrecision(math.max(2, source:getPrecision()));
	
	
	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom", Neutral, first );
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
    Bottom:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)
 
	
    if period < first then
	return;
	end
	
	rng[period]=math.abs(source[period]-source[period-1]);
	
	
	if period < first +Sampling_Period then
	return;
	end
	
	avrng:update(mode);
	
	
	
	if period < first +( (Sampling_Period*2) - 1) then
	return;
	end
	
	smoothrng:update(mode);
	local smooth= smoothrng.DATA[period]*Range_Multiplier;
	
	Central[period]=Central[period-1];
	 
    if  source[period] >  Central[period-1]  then
			 if  (source[period] - smooth) <  Central[period-1]   then
			   Central[period]=  Central[period-1] 
			   
			 else    	 
			  Central[period]= (source[period] - smooth)
			 end
	 else
			 if  (source[period] + smooth) >  Central[period-1]  then
			   Central[period]=  Central[period-1]  
			 else 
			   Central[period]=(source[period] + smooth)
			 end
	 end
	 
 

 
if Central[period] > Central[period-1] then
upward [period]=upward[period-1]  + 1 
elseif  Central[period] < Central[period-1] then
upward[period]=0;
else
 upward[period]= upward[period-1];
end 


if Central[period] < Central[period-1] then
downward [period]=downward[period-1]  + 1 
elseif  Central[period] < Central[period-1] then
downward[period]=0;
else
 downward[period]= downward[period-1];
end 
 
 
Top[period] = Central[period] +  smooth;
Bottom[period] = Central[period] -   smooth;


	if upward[period] > 0 then
	Central:setColor(period, Up);
	Top:setColor(period, Up);
	Bottom:setColor(period, Up);
	elseif downward[period] > 0 then 
	Central:setColor(period, Down);
	Top:setColor(period, Down);
	Bottom:setColor(period, Down);
	else
	Central:setColor(period, Neutral);
	Top:setColor(period, Neutral);
	Bottom:setColor(period, Neutral);
	end
	
end

 
