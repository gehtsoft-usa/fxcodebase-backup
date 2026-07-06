-- Id: 12374
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59981

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Historical Volatility Ratio oscillator");
    indicator:description("Historical Volatility Ratio oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Period 1", "", 6);
    indicator.parameters:addInteger("Period2", "Period 2", "", 100);
     indicator.parameters:addDouble("Threshold", "Crossover Threshold", "", 1);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addBoolean("Show", "Show Crosses","", true);
    indicator.parameters:addColor("clrUP", "Up Cross Color","", core.rgb(0,255,0));
	indicator.parameters:addColor("clrDN", "Down Cross Color","", core.rgb(255,0,0));
	indicator.parameters:addInteger("Size", "Arrow Size","", 10)
end

local first;
local source = nil;
local Period1;
local Period2;
local St;
local HVR=nil;
local MaxPeriod;
local up,down;
local Show;
local Size;
local Threshold;
function Prepare(nameOnly)
    source = instance.source;
    Period1=instance.parameters.Period1;
    Period2=instance.parameters.Period2;
	MaxPeriod=math.max(Period1, Period2);
	Size=instance.parameters.Size;
	Show=instance.parameters.Show;
	Threshold=instance.parameters.Threshold;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Period2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    St = instance:addInternalStream(first, 0);
    HVR = instance:addStream("HVR", core.Line, name .. ".HVR", "HVR", instance.parameters.clr, first+MaxPeriod);
    HVR:setPrecision(math.max(2, instance.source:getPrecision()));
    HVR:setWidth(instance.parameters.widthLinReg);
    HVR:setStyle(instance.parameters.styleLinReg);
  
	
	if Show then
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
	
	core.host:execute ("attachTextToChart", "Up");
	core.host:execute ("attachTextToChart", "Dn");
	end
end

function Update(period )

   

   if period<first+MaxPeriod then
   return;
   end
   
    St[period]=math.log(source.close[period]/source.close[period-1]);
    local StdDev1=mathex.stdev(St, period-Period1+1, period);
    local StdDev2=mathex.stdev(St, period-Period2+1, period);
    if StdDev2~=0 then
     HVR[period]=StdDev1/StdDev2;   
    end 
	
	if not Show
	or period<first+MaxPeriod+1
	then
	return;
	end	
	 up:setNoData(period);
	 down:setNoData(period);
	 
	 
     if core.crossesUnder (HVR,Threshold,period) then
	 up:set(period, source.high[period ], "\217", source.high[period ]);
	 end
	 
	 if core.crossesOver (HVR,Threshold,period) then
	 down:set(period , source.low[period], "\218", source.low[period ]);
	 end
	 
end

