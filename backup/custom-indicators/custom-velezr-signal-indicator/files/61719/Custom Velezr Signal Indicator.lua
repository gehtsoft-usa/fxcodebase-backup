-- Id: 9141
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36928

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
    indicator:name("Custom Velezr Signal Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Selector");
    indicator.parameters:addBoolean("One", "Use OSMA Filter", "", true);
	indicator.parameters:addBoolean("Two", "Use MA Filter", "", true);
	indicator.parameters:addBoolean("Three", "Use Heikin Ashi Filter", "", true); 
	indicator.parameters:addBoolean("Four", "Use Awesome Oscillator Filter", "", true);
	
	
	indicator.parameters:addGroup("OSMA Calculation");
	indicator.parameters:addString("Price1" , "Data Source", "", "close");
    indicator.parameters:addStringAlternative("Price1" , "Open", "", "open");
    indicator.parameters:addStringAlternative("Price1", "High", "", "high");
    indicator.parameters:addStringAlternative("Price1" , "Low", "", "low");
	indicator.parameters:addStringAlternative("Price1" , "Close", "", "close");
	indicator.parameters:addStringAlternative("Price1", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price1" , "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price1" , "Weighted ", "", "weighted");	
	
	indicator.parameters:addInteger("SN", "Short Period", "", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long Period", "", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line Period", "", 9, 2, 1000);
	
	indicator.parameters:addGroup("MA Calculation");
	indicator.parameters:addString("Price2" , "Data Source", "", "close");
    indicator.parameters:addStringAlternative("Price2" , "Open", "", "open");
    indicator.parameters:addStringAlternative("Price2", "High", "", "high");
    indicator.parameters:addStringAlternative("Price2" , "Low", "", "low");
	indicator.parameters:addStringAlternative("Price2" , "Close", "", "close");
	indicator.parameters:addStringAlternative("Price2", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price2" , "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price2" , "Weighted ", "", "weighted");	
	
	indicator.parameters:addInteger("SP", "Short Period", "", 3, 2, 1000);
    indicator.parameters:addInteger("LP", "Long Period", "", 5, 2, 1000);
 
    indicator.parameters:addGroup("Awesome Oscillator  Calculation");
	indicator.parameters:addInteger("AS", "Short Period", "", 5, 2, 1000);
    indicator.parameters:addInteger("AL", "Long Period", "", 35, 2, 1000);
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local MA1,MA2;
local SN, LN, IN= nil;
local MACD;
local Price1, Price2;
local SP, LP;
local Signal;
local HA;
local One, Two, Three;
local Four;
local up, down;
local AO;
local AS,AL;
function Prepare(nameOnly)
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	Price1 = instance.parameters.Price1;
	AS = instance.parameters.AS;
	AL = instance.parameters.AL;
	
	SP = instance.parameters.SP;
	LP = instance.parameters.LP;
	Price2 = instance.parameters.Price2;
	
	One= instance.parameters.One;
	Two= instance.parameters.Two;
	Three= instance.parameters.Three;
	Four= instance.parameters.Four;
	
	if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end

	source = instance.source;
   
    local name = profile:id() .. "(" .. source:name() ;
	instance:name(name);
	if nameOnly then
		return;
	end
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", 9, core.H_Center, core.V_Top, instance.parameters.Up, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", 9, core.H_Center, core.V_Bottom, instance.parameters.Dn, 0);
	MACD=core.indicators:create("MACD",  source[Price1], SN, LN, IN);
	MA1=core.indicators:create("MVA",  source[Price2], SP);
	MA2=core.indicators:create("MVA",  source[Price2], LP);
	HA=core.indicators:create("HA",  source ); 
	AO=core.indicators:create("AO",  source, AS,AL ); 
	
	first= math.max(  MACD.HISTOGRAM:first(),MA1.DATA:first(), MA2.DATA:first(), HA.DATA:first() , AO.DATA:first());

    Signal = instance:addInternalStream(source:first(), 0);	
	
		
end

-- Indicator calculation routine
function Update(period, mode)


            MACD:update(mode);
			MA1:update(mode);
			MA2:update(mode);
			HA:update(mode);
			AO:update(mode);
	
			if period < first then
			return;
			end
	
    
	up:setNoData (period);
	down:setNoData (period);
	
    local ONE=nil;
	local TWO=nil;
	local THREE=nil;
	local FOUR=nil;
			  
		
			   
		if One then
			if MACD.HISTOGRAM[period] > 0 then
			ONE = true;
			elseif MACD.HISTOGRAM[period] < 0  then
			ONE = false;
			end
        end
		
		if Two then
		   if MA1.DATA[period] > MA2.DATA[period] then
			TWO = true;
			elseif MA1.DATA[period] < MA2.DATA[period] then
			TWO = false;
			end  
		end
	 	
		if Three then
		    if HA.open[period] < HA.close[period]  then
			THREE = true;
			elseif HA.open[period] > HA.close[period] then
			THREE = false;
			end  
		end
		
		if Four then
		    if AO.DATA[period] > 0   then
			FOUR = true;
			elseif AO.DATA[period] < 0   then
			FOUR = false;
			end  
		end
 		
		
		 
		
		if One == false   and  Two == false  and Three == false and Four == false then
		Signal[period]= 0;
		elseif  (ONE == true or One == false)  and  ( TWO == true or Two == false) and ( THREE == true or Three == false) and ( FOUR == true or Four == false)    then		
		Signal[period]= 1;
        elseif (ONE == false or One == false)  and  ( TWO == false or Two == false) and ( THREE == false or Three == false)  and ( FOUR == false or Four == false) then
		Signal[period]= -1;
		else
		Signal[period]= 0;		
		end
		
		if Signal[period] == 1 and  Signal[period-1] ~= 1 then
		up:set(period, source.high[period], "\217", source.high[period]);
		elseif Signal[period] == -1  and  Signal[period-1] ~= -1  then
		down:set(period, source.low[period], "\218", source.low[period]);
		end
 end


