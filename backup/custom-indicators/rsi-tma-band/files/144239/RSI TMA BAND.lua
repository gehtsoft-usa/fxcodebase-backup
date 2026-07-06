-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71638

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
--|SOL Address            : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                           |
--|Cardano/ADA            : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv             |  
--|Dogecoin Address       : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                     |
--|SHIB Address           : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                             |                                
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("RSI TMA BAND");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("RsiLength", "Rsi Length", "", 14, 1, 2000);
    indicator.parameters:addInteger("HalfLength", "Half Length", "", 12, 1, 2000);
    indicator.parameters:addInteger("DevPeriod", "Dev Period", "", 100, 1, 2000);	
    indicator.parameters:addDouble("DeviationInt", "DeviationInt", "", 1);	
    indicator.parameters:addDouble("DeviationExt", "DeviationExt", "", 1.5);		

	
	indicator.parameters:addGroup("Central Line Style"); 	
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("RSI Line Style"); 	
    indicator.parameters:addColor("color6", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style6", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width6", "Line Width", "", 3, 1, 5);	
	
	
	indicator.parameters:addGroup("1. Top Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);

	indicator.parameters:addGroup("2. Top Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("1. Bottom Line Style"); 	
    indicator.parameters:addColor("color4", "Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 3, 1, 5);	
	
	indicator.parameters:addGroup("2. Bottom Line Style"); 	
    indicator.parameters:addColor("color5", "Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style5", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width5", "Line Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local RsiLength, HalfLength, DevPeriod, DeviationInt,DeviationExt; 
 
local first;
local source = nil;
local sum, sumw; 
local RSI, rsi;
-- Routine
 function Prepare(nameOnly)   
 
    RsiLength= instance.parameters.RsiLength;
	HalfLength= instance.parameters.HalfLength;
	DevPeriod= instance.parameters.DevPeriod;
	DeviationInt= instance.parameters.DeviationInt;
	DeviationExt= instance.parameters.DeviationExt;
  
	local Parameters= RsiLength..", "..HalfLength..", "..DevPeriod..", "..DeviationInt..", "..DeviationExt;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	RSI = core.indicators:create("RSI", source, RsiLength);
    first=RSI.DATA:first();
	
	sum= instance:addInternalStream(0, 0);
 	sumw= instance:addInternalStream(0, 0);  
	
	rsi = instance:addStream("RSI" , core.Line, " RSI"," RSI",instance.parameters.color6, first+DevPeriod+HalfLength);
	rsi:setWidth(instance.parameters.width6);
    rsi:setStyle(instance.parameters.style6);
    rsi:setPrecision(math.max(2, source:getPrecision()));	
	
	Top1 = instance:addStream("Top1" , core.Line, " Top1"," Top1",instance.parameters.color1, first+DevPeriod+HalfLength);
	Top1:setWidth(instance.parameters.width1);
    Top1:setStyle(instance.parameters.style1);
    Top1:setPrecision(math.max(2, source:getPrecision()));

	Top2 = instance:addStream("Top2" , core.Line, " Top2"," Top2",instance.parameters.color2, first+DevPeriod+HalfLength);
	Top2:setWidth(instance.parameters.width2);
    Top2:setStyle(instance.parameters.style2);
    Top2:setPrecision(math.max(2, source:getPrecision()));
 
	Central = instance:addStream("Central" , core.Line, " Central"," Central",instance.parameters.Up, first+DevPeriod+HalfLength);
	Central:setWidth(instance.parameters.width3);
    Central:setStyle(instance.parameters.style3);
    Central:setPrecision(math.max(2, source:getPrecision()));
	
	
	Bottom1 = instance:addStream("Bottom1" , core.Line, " Bottom1"," Bottom1",instance.parameters.color4, first+DevPeriod+HalfLength);
	Bottom1:setWidth(instance.parameters.width4);
    Bottom1:setStyle(instance.parameters.style4);
    Bottom1:setPrecision(math.max(2, source:getPrecision()));
	
	
	Bottom2 = instance:addStream("Bottom2" , core.Line, " Bottom2"," Bottom2",instance.parameters.color5, first+DevPeriod+HalfLength);
	Bottom2:setWidth(instance.parameters.width5);
    Bottom2:setStyle(instance.parameters.style5);
    Bottom2:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    RSI:update(mode);  
	
	if period <  first + DevPeriod +HalfLength
	then
	return;
	end
	
	rsi[period]= RSI.DATA[period];
	
	
	local dev= mathex.stdev (RSI.DATA, period-DevPeriod, period);
    
	local Sum,Sumw=0,0;
	
    for i= 1, HalfLength, 1 do
	
	    Sum  = Sum+  HalfLength*RSI.DATA[period-i+1];
		Sumw  = Sumw + HalfLength;
	end
	
	
    Central[period] = Sum/Sumw;
	
	if Central[period]> Central[period-1] then
	Central:setColor(period,instance.parameters.Up);
	else
 	Central:setColor(period,instance.parameters.Down);
	end
	
    Top2[period] = Central[period]+dev*DeviationExt;
	Top1[period] = Central[period]+dev*DeviationInt;
	
	Bottom2[period] = Central[period]-dev*DeviationExt; 
	Bottom1[period] = Central[period]-dev*DeviationInt;
				  
end


