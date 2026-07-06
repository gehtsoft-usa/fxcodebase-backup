-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=60869
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://paypal.me/mariojemic
-- Patreon:       https://tiny.cc/1ybwxz
-- BuyMeACoffee:  https://tiny.cc/bj7vxz
--
-- Crypto:
--  BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
--  SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
--  ETH/BNB/USDT/XRP (ERC20 & BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
--
-- ── Copyright ──────────────────────────────────────────────────────────────────
-- © 2025 Gehtsoft USA LLC — https://fxcodebase.com

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- <https://www.gnu.org/licenses/>.

function Init()
    indicator:name("Divergence Candles");
    indicator:description("Divergence Candles");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

     indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up Trend Color","Up Trend Color", core.COLOR_UPCANDLE);
	indicator.parameters:addColor("Down", "Down Trend Color","Down Trend Color", core.COLOR_DOWNCANDLE);
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","Neutral Trend Color", core.COLOR_DOWNCANDLE);
	
	indicator.parameters:addColor("Top", "Up Trend Divergence Color","Up Trend Divergence Color",core.COLOR_UPCANDLE);
	indicator.parameters:addColor("Bottom", "Down Trend Divergence Color","Down Trend Divergence Color", core.COLOR_DOWNCANDLE);
	
	 indicator.parameters:addBoolean("Show", "Show Arrows","", true);
	 indicator.parameters:addBoolean("ShowCandles", "Show Candles","", false);	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Top, Bottom;
local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Up, Down, Neutral;
local font;
local Show,ShowCandles;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	
	Show = instance.parameters.Show; 
	ShowCandles = instance.parameters.ShowCandles;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral;
	Top = instance.parameters.Top;
	Bottom = instance.parameters.Bottom;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if  nameOnly  then
	return;
	end
	
	    
		font = core.host:execute("createFont", "Wingdings", 10, false, false);
		
		if ShowCandles then
		open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
		high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
		low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
		close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
		instance:createCandleGroup("ZONE", "", open, high, low, close);
		else
		open = instance:addInternalStream(0, 0);
		high = instance:addInternalStream(0, 0);
		low = instance:addInternalStream(0, 0);
		close = instance:addInternalStream(0, 0);		
		end
   
end


function ReleaseInstance()
       core.host:execute("deleteFont", font);
        
 end
   
   
   
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


    if ShowCandles then
    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
	end
	
   if period < first  or not source:hasData(period) then
     if ShowCandles then
	 open:setColor(period, Neutral);		
	 end
    return;
    end 
	
 
  
	--N high > high N-1 and N close =< close N-1
    if source.high[period]> source.high[period-1]
	and source.close[period]<= source.close[period-1]	
	then
	    if Show then
		core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top,font , Up, "\226");
		end
		if ShowCandles then
	    open:setColor(period, Top);	
		end
	--N low < low N-1 and N close >= close N-1
	elseif source.low[period]< source.low[period-1]
	and source.close[period]>= source.close[period-1]
	then
	   if Show then
	   core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom,font , Down, "\225");
	   end
	 if ShowCandles then
	 open:setColor(period, Bottom);	
	 end
	elseif close[period]> open[period] then
	if ShowCandles then
	open:setColor(period, Up);
	end
	elseif close[period]< open[period] then
	if ShowCandles then
	open:setColor(period,Down);
	end
	else
	if ShowCandles then
	open:setColor(period, Neutral); 
	end
	end
  
 
  
end

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=60869
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://paypal.me/mariojemic
-- Patreon:       https://tiny.cc/1ybwxz
-- BuyMeACoffee:  https://tiny.cc/bj7vxz
--
-- Crypto:
--  BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
--  SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
--  ETH/BNB/USDT/XRP (ERC20 & BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
--
-- ── Copyright ──────────────────────────────────────────────────────────────────
-- © 2025 Gehtsoft USA LLC — https://fxcodebase.com

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- <https://www.gnu.org/licenses/>.