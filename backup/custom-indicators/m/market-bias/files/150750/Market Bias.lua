-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73693

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Market Bias");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "Period", "", 100, 1, 2000);
    indicator.parameters:addInteger("Period2", "Smoothing", "", 100, 1, 2000);
    indicator.parameters:addInteger("Period", "Oscillator Period", "", 7, 1, 2000);	
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 	
	 
	 
	 indicator.parameters:addGroup("HA Style");		
	 indicator.parameters:addBoolean("HA", "Show HA", "" , true); 	 
	 indicator.parameters:addColor("color1", "Up Bar Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Bar Color", "", core.rgb(255, 0, 0)); 
	 
	 indicator.parameters:addGroup("Cloud Style");
	 indicator.parameters:addBoolean("Cloud", "Show Cloud", "" , true); 
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);	 	 
	 indicator.parameters:addColor("colorA", "Up In Up Trend Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("colorB", "Down In Up Trend Color", "", core.rgb(0, 200, 0)); 
	 indicator.parameters:addColor("colorC", "Up In Down Trend Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("colorD", "Down In Down Trend Color", "", core.rgb(200, 0, 0)); 	



end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2,Method,Period; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2; 
	Method=instance.parameters.Method;
	Period=instance.parameters.Period;
	Cloud=instance.parameters.Cloud;
	Transparency=instance.parameters.Transparency;
    Transparency= 100-Transparency;
   
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2  .. "," ..   Method  .. "," ..  Period.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	open= core.indicators:create(Method, source.open,Period1 );	
	high= core.indicators:create(Method, source.high,Period1 );	
	low= core.indicators:create(Method, source.low,Period1 );	
	close= core.indicators:create(Method, source.close,Period1 );
	
	HA_open = instance:addInternalStream(0, 0);
	HA_high = instance:addInternalStream(0, 0);
	HA_low = instance:addInternalStream(0, 0);
	HA_close = instance:addInternalStream(0, 0);	
	
	if instance.parameters.HA then
    instance:createCandleGroup(name, "HA", HA_open, HA_high, HA_low, HA_close);	
	end
	
	osc_bias = instance:addInternalStream(0, 0);	
	osc_smooth= core.indicators:create(Method, osc_bias,Period );	
	
	Open= core.indicators:create(Method, HA_open,Period2 );	
	High= core.indicators:create(Method, HA_high,Period2 );	
	Low= core.indicators:create(Method, HA_low,Period2 );	
	Close= core.indicators:create(Method, HA_close,Period2 );	
	
	first=open.DATA:first()+1; 
	
	 
	
	
    Bias = instance:addStream("Bias", core.Line, name, "Bias", instance.parameters.color, first +Period2);
    Bias:setPrecision(math.max(2, instance.source:getPrecision()));
    Bias:setWidth(instance.parameters.width);
    Bias:setStyle(instance.parameters.style);
    Bias:addLevel(0);	
	
    BiasHigh = instance:addStream("BiasHigh", core.Line, name, "BiasHigh", instance.parameters.color, first +Period2+Period);
    BiasHigh:setPrecision(math.max(2, instance.source:getPrecision()));
    BiasHigh:setWidth(instance.parameters.width);
    BiasHigh:setStyle(instance.parameters.style);
    BiasHigh:addLevel(0);	


    BiasLow = instance:addStream("BiasLow", core.Line, name, "BiasLow", instance.parameters.color, first +Period2+Period);
    BiasLow:setPrecision(math.max(2, instance.source:getPrecision()));
    BiasLow:setWidth(instance.parameters.width);
    BiasLow:setStyle(instance.parameters.style);
    BiasLow:addLevel(0);		
	
	if Cloud then
    instance:createChannelGroup("Group","Group" , BiasHigh, BiasLow, instance.parameters.colorA, Transparency);
	end	
 
end


function Update(period, mode)

	open:update(mode); 
	high:update(mode); 
	low:update(mode); 
	close:update(mode); 
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	HA_close[period] = (open.DATA[period] + high.DATA[period] + low.DATA[period] + close.DATA[period]) / 4
	HA_open[period] = (open.DATA[period-1] +close.DATA[period-1]) / 2
	HA_high[period] = math.max(high.DATA[period], math.max(HA_open[period], HA_close[period]))
	HA_low [period]= math.min(low.DATA[period], math.min(HA_open[period], HA_close[period]))	
 
	Open:update(mode); 
	High:update(mode); 
	Low:update(mode); 
	Close:update(mode); 	

	if period <= first+Period2
	or  not source:hasData(period) 
	then
	return;
	end
	
	osc_bias[period] = 100 *(Close.DATA[period] - Open.DATA[period] )
	osc_smooth:update(mode); 
	
	if period <= first+Period2+Period
	or  not source:hasData(period) 
	then
	return;
	end
	
 

	  	
	Bias[period]= (High.DATA[period]+Low.DATA[period])/2;
	BiasHigh[period]=High.DATA[period];
	BiasLow[period]=Low.DATA[period];	
	
    if(osc_bias[period] > 0) and (osc_bias[period] >= osc_smooth.DATA[period]) then BiasHigh:setColor(period, instance.parameters.colorA);end 
    if (osc_bias[period] > 0) and (osc_bias[period] < osc_smooth.DATA[period]) then BiasHigh:setColor(period, instance.parameters.colorB);end 
    if(osc_bias[period] < 0) and (osc_bias[period] <= osc_smooth.DATA[period]) then BiasHigh:setColor(period, instance.parameters.colorD);end 
    if (osc_bias[period] < 0) and (osc_bias[period] > osc_smooth.DATA[period]) then BiasHigh:setColor(period, instance.parameters.colorC);end 
	

end

 
--[[

show_ha = input.bool(true, "Show HA Plot/ Market Bias", group="HA Market Bias")
ha_len = input(100, 'Period', group="HA Market Bias")
ha_len2 = input(100, 'Smoothing', group="HA Market Bias")

// Calculations {
o = ta.ema(open, ha_len)
c = ta.ema(close, ha_len)
h = ta.ema(high, ha_len)
l = ta.ema(low, ha_len)

haclose = tf(ha_htf, (o + h + l + c) / 4, 0)
xhaopen = tf(ha_htf, (o + c) / 2, 0)
haopen = na(xhaopen[1]) ? (o + c) / 2 : (xhaopen[1] + haclose[1]) / 2
hahigh = math.max(h, math.max(haopen, haclose))
halow = math.min(l, math.min(haopen, haclose))


o2 = tf(ha_htf, ta.ema(haopen, ha_len2), 0)
c2 = tf(ha_htf, ta.ema(haclose, ha_len2), 0)
h2 = tf(ha_htf, ta.ema(hahigh, ha_len2), 0)
l2 = tf(ha_htf, ta.ema(halow, ha_len2), 0)

ha_avg = (h2 + l2) / 2
// }
    
// Oscillator {
osc_len = input.int(7, "Oscillator Period", group="HA Market Bias")

osc_bias = 100 *(c2 - o2)
osc_smooth = ta.ema(osc_bias, osc_len)

sigcolor = 
  (osc_bias > 0) and (osc_bias >= osc_smooth) ? color.new(color.lime, 35) : 
  (osc_bias > 0) and (osc_bias < osc_smooth) ? color.new(color.lime, 75) : 
  (osc_bias < 0) and (osc_bias <= osc_smooth) ? color.new(color.red, 35) : 
  (osc_bias < 0) and (osc_bias > osc_smooth) ? color.new(color.red, 75) :
  na
// }
 


fill(p_l, p_h, show_ha ? sigcolor : na)
col = o2 > c2 ? color.red : color.lime
plotcandle(show_ha ? o2 : na, h2, l2, c2, title='heikin smoothed', color=col)
]]

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+


--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+