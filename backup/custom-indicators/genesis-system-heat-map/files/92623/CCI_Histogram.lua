-- Id: 11118

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60294

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
    indicator:name("Commodity channel index Histogram ");
    indicator:description("Commodity channel index Histogram");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

 
    indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("CCI_Period", "CCI Period", "", 45);
	
	
	
	indicator.parameters:addString("Type", "Signal Type", "", "CCI Trigger Level");
    indicator.parameters:addStringAlternative("Type", "CCI Trigger Level", "", "CCI Trigger Level");
    indicator.parameters:addStringAlternative("Type", "CCI MA", "", "CCI MA");

    indicator.parameters:addInteger("CCI_Trigger_Level",  "CCI Trigger Level", "", 0);
	
	indicator.parameters:addInteger("Period", "MA Period", "Period" , 14);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");


    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color", "Up Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "Down Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Histogram;

local CCI_Period;
local CCI;
local CCI_Trigger_Level;
local Trend;
local Period, Method, Type;
local MA;
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
    source = instance.source;
	
	CCI_Period = instance.parameters.CCI_Period;
	CCI_Trigger_Level= instance.parameters.CCI_Trigger_Level;
	
	Period= instance.parameters.Period;
	Method= instance.parameters.Method;
	Type=instance.parameters.Type;
   
    source = instance.source;
	CCI = core.indicators:create("CCI", source, CCI_Period);
	
	if Type == "CCI Trigger Level" then
    first = CCI.DATA:first();
	else
	MA = core.indicators:create(Method, CCI.DATA, Period);
	first = MA.DATA:first();
	end
	
	Trend= instance:addInternalStream(0, 0);
	
	 
 

    
        TVI = instance:addInternalStream(0, 0);
   
   
    Histogram = instance:addStream("Histogram", core.Bar, name .. "Histogram", "Histogram", instance.parameters.Up, first);
	Histogram:addLevel(0, core.LINE_NONE , 1, core.rgb(128, 128, 128));    
	Histogram:addLevel(1, core.LINE_NONE , 1, core.rgb(128, 128, 128));  


    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));	 
 

end

function Update(period, mode)

Histogram[period]=1;
CCI:update(mode);

if Type == "CCI MA" then
MA:update(mode);
end


if period < first+1 or not source:hasData(period) then
Trend[period]=0;
return;
end

 
	
	if Type == "CCI Trigger Level" then
	
		if( (CCI.DATA[period] > CCI_Trigger_Level) and (CCI.DATA[period-1] <= CCI_Trigger_Level) ) then
			 Trend[period]=1;
		elseif( (CCI.DATA[period] < CCI_Trigger_Level) and (CCI.DATA[period-1] >= CCI_Trigger_Level) )  then
			 Trend[period]=-1;
		else	
			 Trend[period]=Trend[period-1];
		end
	else
	    if( (CCI.DATA[period] > MA.DATA[period]) and (CCI.DATA[period-1] <= MA.DATA[period-1]) ) then
			 Trend[period]=1;
		elseif( (CCI.DATA[period] < MA.DATA[period]) and (CCI.DATA[period-1] >=  MA.DATA[period-1]) )  then
			 Trend[period]=-1;
		else	
			 Trend[period]=Trend[period-1];
		end
	end
	
	
	if( Trend[period]== 1  ) then
		Histogram:setColor(period, instance.parameters.Up);
	else  
			Histogram:setColor(period, instance.parameters.Down);
	end

	 
end

 
