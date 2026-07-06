-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71129

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("VOLUME POSITIVE NEGATIVE");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "VP Period", "", 30, 1, 2000); --Ok
    indicator.parameters:addInteger("SMOOTH", "SMOOTH", "", 3, 1, 2000);	--Ok
    indicator.parameters:addInteger("VPNCRIT", "VPNCRIT", "", 10, 1, 2000);
    indicator.parameters:addInteger("MAB", "MA BARS", "", 30, 1, 2000); --Ok
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 0.1); --Ok
	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "VPN Line Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "VPN Line Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addColor("color2", "MA Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end
 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period,SMOOTH, VPNCRIT, MAB,Multiplier;
local first;
local source = nil;
local ATR;
local VPN, MAVPN;
local VMP,VMN;
local VPN_Data, EMA;
local Up, Down;
-- Routine
 function Prepare(nameOnly)   
 
    Period= instance.parameters.Period;
	SMOOTH= instance.parameters.SMOOTH;
	VPNCRIT= instance.parameters.VPNCRIT;
	MAB= instance.parameters.MAB; 
	Multiplier= instance.parameters.Multiplier;
	
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	
	local Parameters= Period..", "..SMOOTH..", "..VPNCRIT..", "..MAB..", "..Multiplier;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Period ;
	
	ATR = core.indicators:create("ATR", source, Period);
	
	VMP= instance:addInternalStream(0, 0);
	VMN= instance:addInternalStream(0, 0);   
	
	VPN_Data= instance:addInternalStream(0, 0); 

    EMA = core.indicators:create("EMA", VPN_Data, SMOOTH);	
 
	VPN = instance:addStream("VPN" , core.Line, " VPN"," VPN",instance.parameters.Up, first+1 +Period+SMOOTH);
	VPN:setWidth(instance.parameters.width1);
    VPN:setStyle(instance.parameters.style1);
    VPN:setPrecision(math.max(2, source:getPrecision()));
	
	MAVPN = instance:addStream("MA" , core.Line, " MA"," MA",instance.parameters.color2, first+1+Period +SMOOTH+MAB);
	MAVPN:setWidth(instance.parameters.width2);
    MAVPN:setStyle(instance.parameters.style2);
    MAVPN:setPrecision(math.max(2, source:getPrecision()));
	
end

-- Indicator calculation routine
function Update(period, mode)

    ATR:update(mode);
	if period < first 
	then
	return;
	end
	
	local MAV=mathex.avg(source.volume,period-Period+1, period);
    local MC=Multiplier*ATR.DATA[period];
				 
    if period < first  +1 
	then
	return;
	end
	
	
	if source[period] - source[period-1]> MC	then
	VMP[period]=source.volume[period];
	else
	VMP[period]=0;
	end

	if source[period] - source[period-1]< -MC	then
	VMN[period]=source.volume[period];
	else
	VMN[period]=0;
	end

    if period < first  +1 + Period
	then
	return;
	end

local VP = mathex.sum( VMP , period-Period+1, period);
local VN = mathex.sum( VMN , period-Period+1, period); 
 
 
VPN_Data[period]=(VP-VN)/MAV/Period*100;


EMA:update(mode);

    if period < first  +1 + Period +SMOOTH
	then
	return;
	end

VPN[period]=EMA.DATA[period];

if VPN[period] >= VPNCRIT  then
VPN:setColor(period, Up);
else
VPN:setColor(period, Down);
end


    if period < first  +1 + Period +SMOOTH +MAB 
	then
	return;
	end
	
	
MAVPN[period]=mathex.avg(VPN,period-MAB+1, period);

		 
end



 