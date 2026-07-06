-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2060
-- Id: 16309

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Silver Trend Overlay");
    indicator:description("Silver Trend Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SSP", "SSP", "", 6);
    indicator.parameters:addDouble("Kmin", "Kmin", "", 1.6);
    indicator.parameters:addDouble("Kmax", "Kmax", "", 50.6);
	
	indicator.parameters:addString("Type" , "Overlay Type", "", "S1");
    indicator.parameters:addStringAlternative("Type" , "S1/Price", "", "S1");
    indicator.parameters:addStringAlternative("Type", "S2/Price", "", "S2");
	 indicator.parameters:addStringAlternative("Type", "S1/S2", "", "S3");
 
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SSP;
local Kmin;
local Kmax;

local first;
local source = nil;

-- Streams block
local S1 = nil;
local S2 = nil;

local Up,Down, Neutral;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local Type;
-- Routine
function Prepare(nameOnly)
    SSP = instance.parameters.SSP;
    Kmin = instance.parameters.Kmin;
    Kmax = instance.parameters.Kmax;
	
	Type= instance.parameters.Type;
	
	Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
	
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. SSP .. ", " .. Kmin .. ", " .. Kmax .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    S1 = instance:addInternalStream(first+SSP, 0); 
    S2  = instance:addInternalStream(first, 0); 
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
			
    if period < first+SSP  or not  source:hasData(period) then
	open:setColor(period, Neutral);	
	return;
	end	
	
			local SsMin,  SsMax = mathex.minmax(source,period-SSP+1,period);
		--	local SsMin = core.min(source.low,core.range(period-SSP+1,period));
		   
			local  smin =((SsMin - (SsMax - SsMin)*Kmin / 100));
			local  smax = ((SsMax - (SsMax - SsMin)*Kmax / 100));
			
	
        S1[period] = smax;
        S2[period-SSP+1] = smax;
		
	if Type == "S1" then	
		if source.close[period]> S1[period] then
		open:setColor(period,Up);	   
		elseif source.close[period]< S1[period]    then		
		open:setColor(period,  Down);
        else
		open:setColor(period, Neutral);			
		end
     elseif Type == "S2" then	
	 
	    open:setColor(period, Neutral);		
	    
		period= period-SSP+1;
	    if source.close[period]> S1[period] then
		open:setColor(period,Up);	   
		elseif source.close[period]< S1[period]    then		
		open:setColor(period,  Down);
        else
		open:setColor(period, Neutral);			
		end
	else 
	 
	    open:setColor(period, Neutral);		
	    
		period= period-SSP+1;
	    if S1[period]> S2[period] then
		open:setColor(period,Up);	   
		elseif S1[period] < S2[period]    then		
		open:setColor(period,  Down);
        else
		open:setColor(period, Neutral);			
		end	
	 end
end 