-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71129

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("VOLUME POSITIVE NEGATIVE");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
	
	
	indicator.parameters:addString("TF", "Base Time Frame", "Base Time Frame" , "Chart");
    indicator.parameters:addStringAlternative("TF", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("TF", "m1", "m1" , "m1");
	indicator.parameters:addStringAlternative("TF", "m5", "m5" , "m5");
	indicator.parameters:addStringAlternative("TF", "m15", "m15" , "m15");
	indicator.parameters:addStringAlternative("TF", "m30", "m30" , "m30");
	indicator.parameters:addStringAlternative("TF", "H1", "H1" , "H1");
	indicator.parameters:addStringAlternative("TF", "H2", "H2" , "H2");
	indicator.parameters:addStringAlternative("TF", "H3", "H3" , "H3");
	indicator.parameters:addStringAlternative("TF", "H4", "H4" , "H4");
	indicator.parameters:addStringAlternative("TF", "H6", "H6" , "H6");
	indicator.parameters:addStringAlternative("TF", "H8", "H8" , "H8");	
    indicator.parameters:addStringAlternative("TF", "D1", "D1" , "D1");
	indicator.parameters:addStringAlternative("TF", "W1", "W1" , "W1");
	indicator.parameters:addStringAlternative("TF", "M1", "M1" , "M1");
	
	indicator.parameters:addString("Instrument", "Instrument", "", "Chart");
    indicator.parameters:setFlag("Instrument", core.FLAG_INSTRUMENTS);
	
	
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

local Instrument; 
local Period,SMOOTH, VPNCRIT, MAB,Multiplier;
local first;
local source = nil;
local ATR;
local VPN, MAVPN;
local VMP,VMN;
local VPN_Data, EMA;
local Up, Down;
local dayoffset, weekoffset;
local Source,loading;
local Instrument,TF;
-- Routine
 function Prepare(nameOnly)   
 
    Period= instance.parameters.Period;
	SMOOTH= instance.parameters.SMOOTH;
	VPNCRIT= instance.parameters.VPNCRIT;
	MAB= instance.parameters.MAB; 
	Multiplier= instance.parameters.Multiplier;
	Instrument= instance.parameters.Instrument;
	TF= instance.parameters.TF;
	
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	
	local Parameters= Period..", "..SMOOTH..", "..VPNCRIT..", "..MAB..", "..Multiplier;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 
 

    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()  ;
	
	
	if Instrument == "Chart" then
	Instrument=source:instrument();
	end
	
	if TF == "Chart" then
	TF=source:barSize();
	end
	
	Source = core.host:execute("getSyncHistory", Instrument, TF, source:isBid(),  300 , 100, 101);
	loading=true;
	
	ATR = core.indicators:create("ATR", Source, Period);
	
	VMP= instance:addInternalStream(0, 0);
	VMN= instance:addInternalStream(0, 0);   
	
	VPN_Data= instance:addInternalStream(0, 0); 

    EMA = core.indicators:create("EMA", VPN_Data, SMOOTH);	
 
	VPN = instance:addStream("VPN" , core.Line, " VPN"," VPN",instance.parameters.Up, first+1 +Period+SMOOTH);
	VPN:setWidth(instance.parameters.width1);
    VPN:setStyle(instance.parameters.style1);
    VPN:setPrecision(math.max(2, Source:getPrecision()));
	
	MAVPN = instance:addStream("MA" , core.Line, " MA"," MA",instance.parameters.color2, first+1+Period +SMOOTH+MAB);
	MAVPN:setWidth(instance.parameters.width2);
    MAVPN:setStyle(instance.parameters.style2);
    MAVPN:setPrecision(math.max(2, Source:getPrecision()));
	
end

function   Initialization(period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
    if loading or Source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	



-- Indicator calculation routine
function Update(period, mode)


    local p =  Initialization(period) 
     
	    if not p then
		return;
		end
		

    ATR:update(mode);
	if p < Period 
	then
	return;
	end
	
	local MAV=mathex.avg(Source.volume,p-Period+1, p);
    local MC=Multiplier*ATR.DATA[p];
				 
    if p < Period  +1 
	then
	return;
	end
	
	
	if Source[p] - Source[p-1]> MC	then
	VMP[period]=Source.volume[p];
	else
	VMP[period]=0;
	end

	if Source[p] - Source[p-1]< -MC	then
	VMN[period]=Source.volume[p];
	else
	VMN[period]=0;
	end

    if period < Period  +1 + Period
	then
	return;
	end

local VP = mathex.sum( VMP , period-Period+1, period);
local VN = mathex.sum( VMN , period-Period+1, period); 
 
 
VPN_Data[period]=(VP-VN)/MAV/Period*100;


EMA:update(mode);

    if period < Period  +1 + Period +SMOOTH
	then
	return;
	end

VPN[period]=EMA.DATA[period];

if VPN[period] >= VPNCRIT  then
VPN:setColor(period, Up);
else
VPN:setColor(period, Down);
end


    if period < Period  +1 + Period +SMOOTH +MAB 
	then
	return;
	end
	
	
MAVPN[period]=mathex.avg(VPN,period-MAB+1, period);

		 
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end

 