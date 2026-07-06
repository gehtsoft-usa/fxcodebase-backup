-- Id: 16734
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63926&p=108378#p108378

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("CCI MA Crossover Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	 indicator.parameters:addGroup("CCI Calculation");
    indicator.parameters:addInteger("CCI_Period", "Period", "", 44);
	 indicator.parameters:addInteger("Min_Max_Period", "Min Max Period", "", 200);
	 indicator.parameters:addInteger("Sum_Period", "Sum Period", "", 13);
	
    indicator.parameters:addGroup("Signal Calculation");
    indicator.parameters:addInteger("Signal_Period", "Period", "", 9);
	
	
	indicator.parameters:addGroup("Raw Line Style"); 
	indicator.parameters:addColor("color1", "Line color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("Signal Line Style"); 
	indicator.parameters:addColor("color2", "Line color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
local Signal_Period, ema,CCI_Period;
-- Streams block
local cci,mva;
local Raw, cci;
local signal;
local Min_Max_Period;
local Sum_Period;
local Data;
-- Routine
function Prepare(nameOnly)
    Signal_Period = instance.parameters.Signal_Period;
	CCI_Period = instance.parameters.CCI_Period;
	Min_Max_Period= instance.parameters.Min_Max_Period;
	Sum_Period= instance.parameters.Sum_Period;
    source = instance.source;
	
	
	local name = profile:id() .. " + " .. source:name() ;
    instance:name(name);

	  if   (nameOnly) then
        return;
    end
	
	 cci= core.indicators:create("CCI", source, CCI_Period);
	 first = cci.DATA:first()+Min_Max_Period;
	 Data= instance:addInternalStream(first, 0);
	
   
	
	
	    Raw= instance:addStream("Raw", core.Line, name, "Raw", instance.parameters.color1, first + Sum_Period);		
		Raw:setWidth(instance.parameters.width1);
        Raw:setStyle(instance.parameters.style1);
	    ema= core.indicators:create("EMA", Raw, Signal_Period);
		
        signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color2, ema.DATA:first());
		signal:setWidth(instance.parameters.width2);
        signal:setStyle(instance.parameters.style2);
		
		Raw:setPrecision(math.max(2, instance.source:getPrecision()));
		signal:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

  
	
	cci:update(mode);
	  
	if period < first or not source:hasData(period) then
	return;
	end
	
	local min,max=mathex.minmax(cci.DATA, period-Min_Max_Period+1, period);
	
	Data[period]=max-min;
	
	if period < first + Sum_Period then
	return;
	end
	
	Raw[period]= mathex.sum(cci.DATA, period-Sum_Period+1, period)/mathex.sum(Data, period-Sum_Period+1, period);
	  
	  ema:update(mode);
 
    if period < ema.DATA:first() then
	return;
	end
	
	signal[period]= ema.DATA[period]
 
 
 	--[[
	Buy: 
	var1:=Sum(CCI(34),13)/Sum(HHV(CCI(34),200)-LLV(CCI(34),200),13);
	Cross(var1,Mov(var1,9,E))

	Sell:
	var1:=Sum(CCI(34),13)/Sum(HHV(CCI(34),200)-LLV(CCI(34),200),13);
	Cross(Mov(var1,9,E),var1)

	]]
 
end

