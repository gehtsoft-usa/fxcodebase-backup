-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70302

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
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


-- Indicator profile initialization routine

function Init()
    indicator:name("RSI and COMPOSITE_INDEX");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("fastLength", "fastLength", "", 13, 1, 2000);
	indicator.parameters:addInteger("slowLength", "slowLength", "", 33, 1, 2000);
	indicator.parameters:addInteger("ma_length", "SMA Length", "", 3, 1, 2000);
	indicator.parameters:addInteger("rsi_ma_length", "RSI MA Length", "", 3, 1, 2000);
	
    indicator.parameters:addInteger("rsi_mom_length", "RSI Momentum Length", "", 9, 1, 2000);
    indicator.parameters:addInteger("rsi_length", "RSI Length", "", 14, 1, 2000);	
    indicator.parameters:addInteger("Vertical", "Vertical Shift", "", 120);
	
	
 


 
 
	
	indicator.parameters:addGroup("RSI Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Central Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
		indicator.parameters:addGroup("Fast Line Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
		indicator.parameters:addGroup("Slow Line Style"); 	
    indicator.parameters:addColor("color4", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 30);
	indicator.parameters:addDouble("Level2", "2. Level","", 50);
	indicator.parameters:addDouble("Level3", "3. Level","", 70); 
 
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
	

	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
 local rsi_length, Vertical, rsi_mom_length, rsi_ma_length, ma_length, slowLength, fastLength;
local first;
local source = nil;
 
local RSI,rsi,rsidelta, Base,ma, Fast, Slow;  
 
 
-- Routine
 function Prepare(nameOnly)   
 
	
	rsi_length= instance.parameters.rsi_length;
	Vertical= instance.parameters.Vertical;
	rsi_mom_length= instance.parameters.rsi_mom_length;
	rsi_ma_length= instance.parameters.rsi_ma_length;
	ma_length= instance.parameters.ma_length;
	slowLength= instance.parameters.slowLength;
	fastLength = instance.parameters.fastLength;
	
	
	local Parameters=fastLength..", "..slowLength..", "..ma_length..", "..rsi_ma_length..", ".. rsi_mom_length..", "..rsi_length..", "..Vertical;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	rsi = core.indicators:create("RSI", source ,rsi_length );
    first=rsi.DATA:first() ;
	
	
  
 
	RSI = instance:addStream("RSI" , core.Line, " RSI","RSI", instance.parameters.color1, first);
	RSI:setWidth(instance.parameters.width1);
    RSI:setStyle(instance.parameters.style1);
    RSI:setPrecision(math.max(2, source:getPrecision()));
	
	
	  ma = core.indicators:create("RSI", RSI ,ma_length );
	  rsidelta= instance:addInternalStream(0, 0);
	  Base= instance:addInternalStream(0, 0);
	
		
	RSI:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	RSI:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	RSI:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
	Central = instance:addStream("Central" , core.Line, " Central"," Central",instance.parameters.color2, first+ma_length );
	Central:setWidth(instance.parameters.width2);
    Central:setStyle(instance.parameters.style2);
    Central:setPrecision(math.max(2, source:getPrecision()));
	
	
	Fast = instance:addStream("Fast" , core.Line, " Fast"," Fast",instance.parameters.color3, first+ma_length );
	Fast:setWidth(instance.parameters.width3);
    Fast:setStyle(instance.parameters.style3);
    Fast:setPrecision(math.max(2, source:getPrecision()));
	
	Slow = instance:addStream("Slow" , core.Line, " Slow"," Slow",instance.parameters.color4, first+ma_length );
	Slow:setWidth(instance.parameters.width4);
    Slow:setStyle(instance.parameters.style4);
    Slow:setPrecision(math.max(2, source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)
   
    rsi:update(mode);
 
	if period < first 
	then
	return;
	end
	RSI[period]=rsi.DATA[period];
	
	if period < first  +rsi_mom_length 
	then
	return;
	end
	
    rsidelta[period] = (RSI[period]-RSI[period-rsi_mom_length+1]);
	
	
	ma:update(mode);
	if period < first  +ma_length
	then
	return;
	end
	
	Base[period]=rsidelta[period]+ma.DATA[period];
	
	if period < first  +ma_length +math.max(fastLength,slowLength )
	then
	return;
	end
	
	local fast=mathex.avg(Base, period-fastLength+1, period);
	local slow=mathex.avg(Base, period-slowLength+1, period);
	
	Central[period]=  Base[period]/ 2+Vertical ;
	Fast[period]=  fast/ 2+Vertical ;
    Slow[period]=  slow/ 2+Vertical ;
end


--[[


r=rsi(close, rsi_length)
rsidelta = mom(r, rsi_mom_length)
rsisma = sma(rsi(close, rsi_ma_length), ma_length)
s=rsidelta+rsisma

 

plot(s / 2 - i1, color=red, linewidth=2)
plot(sma(s, fastLength) / 2 - i1, color=green)
plot(sma(s, slowLength) / 2 - i1, color=red)
 

]]
