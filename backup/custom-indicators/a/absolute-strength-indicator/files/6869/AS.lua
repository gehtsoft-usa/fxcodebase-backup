-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2987
-- Id: 6493

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Absolute Strength Indicator");
    indicator:description("Absolute Strength Indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
	 indicator.parameters:addString("Method", "Method", "", "RSI");
    indicator.parameters:addStringAlternative("Method", "RSI", "", "RSI");
    indicator.parameters:addStringAlternative("Method", "Stoch", "", "Stoch");
    indicator.parameters:addStringAlternative("Method", "ADX", "", "ADX");
	
	indicator.parameters:addString("Method1", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");   
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");

	
	 indicator.parameters:addInteger("Length", "Period for Evaluation", "", 10);
	 indicator.parameters:addInteger("Signal", "Period for Signal", "", 5);
	 indicator.parameters:addInteger("Smoothing", "Period for Smoothing", "", 5);
	 
	  indicator.parameters:addDouble("OverBought", "OverBought", "", 0);
	   indicator.parameters:addDouble("OverSold", "OverSold", "", 0);

	 indicator.parameters:addGroup("Selector");   
	 indicator.parameters:addBoolean("ShowBulls", "Show Bulls", "" , true);
	 indicator.parameters:addBoolean("ShowBears", "Show Bears", "" , true);
	
	 indicator.parameters:addGroup("Bulls Style");   
    indicator.parameters:addColor("Bulls_color", "Color of Bulls", "Color of Bulls", core.rgb(0, 255, 0));
		indicator.parameters:addInteger("Bullswidth", "Line Width", "", 1, 1, 5);
     indicator.parameters:addInteger("Bullsstyle", "Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("Bullsstyle", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("Bears Style");
    indicator.parameters:addColor("Bears_color", "Color of Bears", "Color of Bears", core.rgb(255, 0, 0));
		indicator.parameters:addInteger("Bearswidth", "Line Width", "", 1, 1, 5);
     indicator.parameters:addInteger("Bearsstyle", "Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("Bearsstyle", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("Bulls Signal Style");
    indicator.parameters:addColor("SignalBulls_color", "Color of SignalBulls", "Color of SignalBulls", core.rgb(0, 255, 128));
		indicator.parameters:addInteger("SignalBullswidth", "Line Width", "", 1, 1, 5);
     indicator.parameters:addInteger("SignalBullsstyle", "Line Style", "", core.LINE_DASH);
	indicator.parameters:setFlag("SignalBullsstyle", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("Bears Signal Style");
    indicator.parameters:addColor("SignalBears_color", "Color of SignalBears", "Color of SignalBears", core.rgb(255, 0, 128));	
	indicator.parameters:addInteger("SignalBearswidth", "Line Width", "", 1, 1, 5);
     indicator.parameters:addInteger("SignalBearsstyle", "Line Style", "", core.LINE_DASH);
	indicator.parameters:setFlag("SignalBearsstyle", core.FLAG_LINE_STYLE);	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method;
local Method1;

local first;
local source = nil;

 local BullsAVGofAVG;
 local BearsAVGofAVG; 
-- Streams block
local Bulls = nil;
local Bears = nil;
local SignalBulls = nil;
local SignalBears = nil;
local Length;
local BullsTemp, BearsTemp;
local MA;
local BullsAVG, BearsAVG;
local OverBought, OverSold;
local Smoothing, Signal;
local Type1,P1;

local AVGBull;
local AVGBear;
local ShowBulls, ShowBears;

-- Routine
function Prepare(nameOnly)
     ShowBulls= instance.parameters.ShowBulls;
	 ShowBears= instance.parameters.ShowBears;
    Smoothing = instance.parameters.Smoothing;
	Signal = instance.parameters.Signal;  
   
    OverBought = instance.parameters.OverBought;
	OverSold = instance.parameters.OverSold;
    Length = instance.parameters.Length;
    Method = instance.parameters.Method;
	Method1= instance.parameters.Method1;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. Method .. ", ".. Method1.. "," .. Length.. ",".. Smoothing .."," .. Signal.. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	MA= core.indicators:create("MVA", source, 2);
	first = MA.DATA:first();
	
	BullsTemp = instance:addInternalStream(0, 0);
	BearsTemp = instance:addInternalStream(0, 0); 
	
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	BullsAVG= core.indicators:create(Method1,BullsTemp, Length);
	BearsAVG= core.indicators:create(Method1, BearsTemp, Length);
	
	AVGBull= core.indicators:create(Method1,BullsAVG.DATA, Smoothing);
	AVGBear= core.indicators:create(Method1, BearsAVG.DATA, Smoothing);
	
	 BullsAVGofAVG= core.indicators:create(Method1,AVGBull.DATA, Signal); 
  BearsAVGofAVG = core.indicators:create(Method1,AVGBear.DATA, Signal); 
	
	if ShowBulls then
    Bulls = instance:addStream("Bulls", core.Line, name .. ".Bulls", "Bulls", instance.parameters.Bulls_color,  AVGBull.DATA:first());
	Bulls:setWidth(instance.parameters.Bullswidth);
	Bulls:setStyle(instance.parameters.Bullsstyle);
	SignalBulls = instance:addStream("SignalBulls", core.Line, name .. ".SignalBulls", "SignalBulls", instance.parameters.SignalBulls_color, BullsAVGofAVG.DATA:first());
	SignalBulls:setWidth(instance.parameters.SignalBullswidth);
	SignalBulls:setStyle(instance.parameters.SignalBullsstyle);
	else
	Bulls= instance:addInternalStream(0, 0);
	SignalBulls= instance:addInternalStream(0, 0);
	end
	
	if ShowBears then 
    Bears = instance:addStream("Bears", core.Line, name .. ".Bears", "Bears", instance.parameters.Bears_color,  AVGBear.DATA:first());
	Bears:setWidth(instance.parameters.Bearswidth);
	Bears:setStyle(instance.parameters.Bearsstyle);   
    SignalBears = instance:addStream("SignalBears", core.Line, name .. ".SignalBears", "SignalBears", instance.parameters.SignalBears_color,BearsAVGofAVG.DATA:first());
	SignalBears:setWidth(instance.parameters.SignalBearswidth);
	SignalBears:setStyle(instance.parameters.SignalBearsstyle);
	else
	Bears= instance:addInternalStream(0, 0);
	SignalBears= instance:addInternalStream(0, 0);
	end
	
	Bulls:setPrecision(math.max(2, instance.source:getPrecision()));
	SignalBulls:setPrecision(math.max(2, instance.source:getPrecision()));
	Bears:setPrecision(math.max(2, instance.source:getPrecision()));
	SignalBears:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
     if period < first or  not source:hasData(period) then
    return;
    end	
	
			MA:update(mode); 
			
			 	
			if Method == "RSI" then
	
				BullsTemp[period] = 0.5*(math.abs(MA.DATA[period]-MA.DATA[period-1])+(MA.DATA[period]-MA.DATA[period-1]));
				BearsTemp[period] = 0.5*(math.abs(MA.DATA[period]-MA.DATA[period-1])-(MA.DATA[period]-MA.DATA[period-1]));
			
			elseif  Method == "Stoch" then	
				local min,max;
				min, max = core.minmax(source, core.range(period -Length , period));
				BullsTemp[period] = MA.DATA[period]-min;
				BearsTemp[period] = max-MA.DATA[period];
				
				
			elseif  Method == "ADX" then			
			   BullsTemp[period] = 0.5*(math.abs(source.high[period]-source.high[period-1])+(source.high[period]-source.high[period-1]));
			   BearsTemp[period] = 0.5*(math.abs(source.low[period-1]-source.low[period])+(source.low[period-1]-source.low[period]));       
			   
			end
			   
			   
			  BullsAVG:update(mode); 
             BearsAVG:update(mode); 			 
			   
			 
			   
			   AVGBull:update(mode); 
               AVGBear:update(mode); 			 
			   
			  if period < AVGBull.DATA:first()  then
			   return;
			   end
			   
			    Bulls[period] =AVGBull.DATA[period];
			   Bears[period] =AVGBear.DATA[period]; 
			   
			   
				 if OverBought > 0 and OverSold > 0  then
				
				SignalBulls[period]=OverBought/100*( Bulls[period]+Bears[period]);
				SignalBears[period] =OverSold/100*( Bulls[period]+Bears[period]);
				
				else			
				
				  BullsAVGofAVG:update(mode); 
                  BearsAVGofAVG:update(mode); 
				  
				  
				  if  period < BearsAVGofAVG.DATA:first()  then
				  return;
				  end
				  
				SignalBulls[period]=BullsAVGofAVG.DATA[period];
				SignalBears[period]=BearsAVGofAVG.DATA[period];
			    end
			
end