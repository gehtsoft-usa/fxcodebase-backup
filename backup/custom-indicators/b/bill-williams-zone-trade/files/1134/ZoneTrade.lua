-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=638
-- Id: 2836

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

-- Indicator profile initialization routine
-- If the current bars of AC and AO are green, it shows that the zone is green.
-- If the current bars of �� and �� red, it shows that the zone is red.
-- If the bars of AC and AO are differently directed then the bar is colored grey (grey zone).
function Init()
    indicator:name("Bill Williams Zone Trade");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FM", "AC/AO fast moving average", "No description", 5);
    indicator.parameters:addInteger("SM", "AC/AO slow moving average", "No description", 35);
    indicator.parameters:addInteger("AM", "A/C moving average", "No description", 5);
	indicator.parameters:addGroup("Zone Trade or AO and AC Separately");
	indicator.parameters:addInteger("MT" , "Zone Trade", "" , 1);	
    indicator.parameters:addIntegerAlternative("MT", "Awesome oscillator(AO)", "ZONE" , 2);
    indicator.parameters:addIntegerAlternative("MT", "Acceleration/Deceleration (AC)", "" , 3);
	indicator.parameters:addIntegerAlternative("MT", "B.W. Zone AC + AO", "" , 1);
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up Trend Color","Up Trend Color", core.rgb(0,255,0));
	indicator.parameters:addColor("Down", "Down Trend Color","Down Trend Color", core.rgb(255,0,0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","Neutral Trend Color", core.rgb(128,128,128));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local FM;
local SM;
local AM;

local Method=nil;

local AO;
local AC;

local first;
local source = nil;

-- Streams block
--local HZU = nil;
--local HZL = nil;

local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Up, Down, Neutral;
-- Routine
function Prepare(nameOnly)
    FM = instance.parameters.FM;
    SM = instance.parameters.SM;
    AM = instance.parameters.AM;
	Method= instance.parameters.MT;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral; 
	
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", "  .. FM .. ", " .. SM .. ", " .. AM .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
    AC = core.indicators:create("AC", source, FM, SM, AM);
    AO = core.indicators:create("AO", source, FM, SM);
    first = math.max( AC.DATA:first(), AO.DATA:first());	
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	
end

-- Indicator calculation routine
function Update(period, mode)


    AC:update(mode);
    AO:update(mode);
	
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
     
	if period < first  or not source:hasData(period) then
	 open:setColor(period, Neutral);		
    return;
    end 
  
				   
   
        local acdir, aodir;      
		
        if AO.DATA[period] > AO.DATA[period - 1] then
            aodir = true;
        elseif AO.DATA[period] < AO.DATA[period - 1] then
            aodir = false;
        end
        if AC.DATA[period] > AC.DATA[period - 1] then
            acdir = true;
        elseif AC.DATA[period] < AC.DATA[period - 1] then
            acdir = false;
        end
		
		
		if   Method== 1 then
				if aodir  and acdir then 
				open:setColor(period, Up);
				elseif  not aodir  and  not acdir then
				open:setColor(period, Down);	
				else
				open:setColor(period, Neutral);
				end
		elseif 	Method== 2 then
		            
				if aodir   then
				open:setColor(period, Up);
				elseif  not aodir then
				open:setColor(period, Down);				  
		        end
		  
		elseif  Method== 3 then
		
		        if  acdir then
				open:setColor(period, Up);
				elseif  not acdir then
				open:setColor(period, Down);				  
			    end 
		end	              
				   
				  
    end

