-- Id: 22292
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66649

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("Vostro");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup(" Calculation"); 
	indicator.parameters:addBoolean("Scalping", "Scalping", "Scalping", true);
    indicator.parameters:addInteger("Period1", "Scalping Period", "", 100, 1, 2000);
	indicator.parameters:addInteger("Period2", "Non Scalping Period", "", 300, 1, 2000);
	
	indicator.parameters:addInteger("MA_Period", "MA Period", "", 5, 1, 2000);
 
	 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", -80);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

  
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Scalping, Period; 
local first;
local source = nil;
local MA_Period,MA1,MA2;
local Range;
local Oscillator;  
local ibuf116, ibuf112;

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Scalping = instance.parameters.Scalping;
	MA_Period = instance.parameters.MA_Period;
	
	if Scalping then
	Period = instance.parameters.Period1;
	else
	Period = instance.parameters.Period2;
	end
    
	
	Range = instance:addInternalStream(0, 0);
	ibuf116 = instance:addInternalStream(0, 0);
	ibuf112 = instance:addInternalStream(0, 0);
			
    source = instance.source;
    
  
    MA1 = core.indicators:create("MVA", source.median, MA_Period);
	MA2 = core.indicators:create("MVA", Range, MA_Period);
    
    first= MA1.DATA:first();
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    
	Oscillator:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Oscillator:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
	Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)

 
    
	Range[period]= source.high[period]-source.low[period];
    MA1:update(mode);
	MA2:update(mode);
	
	
    if period < first then
	return;
	end 
 
 local gd128=MA1.DATA[period];
 local gd136=0.2*MA2.DATA[period]
 
 
 ibuf116[period]=(source.low[period]-gd128)/gd136
 ibuf112[period]=(source.high[period]-gd128)/gd136
 
 
 
   if ibuf112[period]>8.0 and source.high[period]> mathex.avg(source.median, period-2+1, period) then 
  Oscillator[period]=90
  elseif ibuf116[period]<-8.0 and source.low[period]<  mathex.avg(source.median, period-2+1, period) then
   Oscillator[period]=-90
  else
   Oscillator[period]=0
  end
 
 
 if ibuf112[period]>8 and ibuf112[period-1]>8 then
  Oscillator[period]=0
 end
 if ibuf112[period]>8 and ibuf112[period-1]>8 and ibuf112[period-2]>8 then
  Oscillator[period]=0
 end
 if ibuf116[period]<-8 and ibuf116[period-1]<-8 then
  Oscillator[period]=0
 end
 if ibuf116[period]<-8 and ibuf116[period-1]<-8 and ibuf116[period-2]<-8 then
  Oscillator[period]=0
 end
 
	
	 	 	  
end
 