-- Id: 7908
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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=627


-- The indicator corresponds to the Ichimoku Kinko Hyo indicator in MetaTrader.

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Alternate Ichimoku Bar Overlay");
    indicator:description("Alternate Ichimoku Bar Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Custom");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SSP", "SSP", "Period Priority Line", 75);
    indicator.parameters:addInteger("SSK", "SSK", "Tolerance Second Line", 75);

    indicator.parameters:addGroup("Selector");
    indicator.parameters:addBoolean("One", "Use SA/SB Line Filter", "", true);
	indicator.parameters:addBoolean("Two", "Price / SA Line Filter", "", true);
	indicator.parameters:addBoolean("Three", "Price / SB Line Filter", "", false);
	indicator.parameters:addBoolean("Four", "SL / ML Line Filter", "", false);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral color", "", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);


end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SSP;
local SSK;

local firstPeriod;
local source = nil;

local csFirst = nil;
local slFirst = nil;
local tlFirst = nil;
local saFirst = nil;
local sbFirst = nil;
local Transparency;
local SsMax, SsMin, SsMax05, SsMin05, Rsmin, Rsmax, Tsmin, Tsmax;


-- Streams block
local SL = nil;
local TL = nil;
local CS = nil;
local SA = nil;
local SB = nil;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local One, Two, Three, Four;
-- Routine
function Prepare()
    SSP = instance.parameters.SSP;
    SSK = instance.parameters.SSK;
	Transparency= (100 -instance.parameters.Transparency);
	One= instance.parameters.One;
	Two= instance.parameters.Two;
	Three= instance.parameters.Three;
	Four= instance.parameters.Four;
	
    
    source = instance.source;
    firstPeriod = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. SSP .. ", " .. SSK .. ")";
    instance:name(name);
    
    
     SL = instance:addInternalStream(SSP*2, 0);
	 ML  = instance:addInternalStream(firstPeriod + SSP*2 - 1, 0);
	 CS  = instance:addInternalStream(firstPeriod, -SSP, 0);
	 SA	 = instance:addInternalStream(SSP*2, 0);
	 SB  = instance:addInternalStream(SSP*2, 0);

    csFirst = CS:first() + SSP*2;
    slFirst = SL:first();
    tlFirst = ML:first();
    saFirst = SA:first();
    sbFirst = SB:first();
	
	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), firstPeriod);
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), firstPeriod);   
    close:setPrecision(math.max(2, instance.source:getPrecision()));
   instance:createChannelGroup("UpGroup","Up" , open, close, instance.parameters.Up, Transparency);
end

-- Indicator calculation routine
function Update(period)


    open[period] = 1;
	close[period] = 0;

	
	open:setColor(period, instance.parameters.No);	

    if period >= SSP*2 + SSK then
        SsMax = core.max(source.high,core.rangeTo(period,SSP))
        SsMin = core.min(source.low,core.rangeTo(period,SSP))
        SsMax05 = core.max(source.high,core.rangeTo(period-SSK,SSP))
        SsMin05 = core.min(source.low,core.rangeTo(period-SSK,SSP))
        SA[period] = (SsMax+SsMin)/2;
        SB[period] = (SsMax05+SsMin05)/2;
        Tsmax = core.max(source.high,core.rangeTo(period,SSP*1.62))
        Tsmin = core.min(source.low,core.rangeTo(period,SSP*1.62))
        SL[period] = (Tsmax + Tsmin) / 2;       
        ML[period] = ((SsMax+SsMin)/2 + (SsMax05+SsMin05)/2)/2;
        CS[period - SSP] = source.close[period];
       
		--Overlay
		
	local ONE=nil;
	local TWO=nil;
	local THREE=nil;
	local FOUR=nil;
		
		if One then
			if SA[period] > SB[period] then
			ONE = true;
			else
			ONE = false;
			end
        end
		
		if Two then
		   if source.close[period] > SA[period] then
			TWO = true;
			else
			TWO = false;
			end  
		end
		
		if Three then
		    if source.close[period] > SB[period] then
			THREE = true;
			else
			THREE = false;
			end  
		end
		
		if Four then
		    if SL[period] > ML[period] then
			FOUR  = true;
			else
			FOUR = false;
			end  
		end
		
 		
		
		 
		
		if ONE == nil   and  TWO == nil  and THREE == nil and FOUR== nil  then
		open:setColor(period, instance.parameters.No);	   
		elseif ONE ~= false and  TWO ~= false  and THREE ~= false  and FOUR~= false   then		
		open:setColor(period, instance.parameters.Up);
        elseif ONE ~= true and  TWO ~= true  and THREE ~= true  and FOUR ~= true then
		open:setColor(period, instance.parameters.Dn);
		else
		open:setColor(period, instance.parameters.No);			
		end
		
		
		
        
    end

end






