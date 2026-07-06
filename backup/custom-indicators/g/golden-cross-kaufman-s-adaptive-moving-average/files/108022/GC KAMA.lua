
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63849

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Golden Cross Kaufman's Adaptive Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("len1","Period", "", 12);
    indicator.parameters:addInteger("len2","Period", "", 26);	
	indicator.parameters:addInteger("fast","Fastest SC", "", 2);	
	indicator.parameters:addInteger("slow","Slowest SC", "", 30);	
 

	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpUp", "Up in Up Trend", "1. Line", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Down in Up Trend", "1. Line", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DownUp", "Up in Down Trend", "1. Line", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DownDown", "Down in Down Trend", "1. Line", core.rgb(200, 0, 0));
	indicator.parameters:addColor("Neutral", "1. Line Neutral", "1. Line", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width1","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addBoolean("Show", "Show 2. Line", "", false);
	indicator.parameters:addColor("color2", "2. Line", "2. Line", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width2","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries

local first;
local source = nil;
 
local fastestSC,  slowestSC;
local len1, len2;
local diff1,diff2;
local out1, out2;
local UpUp,DownDown, UpDown, DownUp,Neutral;
local Show;
function Prepare(nameOnly) 
    
    source = instance.source;
   
	len1=instance.parameters.len1;
	len2=instance.parameters.len2;
	
	
	UpUp=instance.parameters.UpUp;
	DownDown=instance.parameters.DownDown;
	UpDown=instance.parameters.UpDown;
	DownUp=instance.parameters.DownUp;
	Neutral=instance.parameters.Neutral;
	
	Show=instance.parameters.Show;
	
	
	 local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	 fastestSC=(2/( instance.parameters.fast+1))
     slowestSC=(2/( instance.parameters.slow+1))
   
	
	diff1 = instance:addInternalStream(len1,0);
	diff2 = instance:addInternalStream(len2,0);

   
	
    out1 = instance:addStream("out1", core.Line, name, "out1", Neutral, len1*2);
	out1:setWidth(instance.parameters.width1);
    out1:setStyle(instance.parameters.style1);
	
	if Show then
	out2 = instance:addStream("out2", core.Line, name, "out2", instance.parameters.color2, len2*2);
	out2:setWidth(instance.parameters.width2);
    out2:setStyle(instance.parameters.style2);
	else
	out2 = instance:addInternalStream(len2*2,0);
	end
	
	 first = math.max(len1*2, len2*3);
	
end

function AsyncOperationFinished(cookie, success, message)

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
Add1(period);
Add2(period);

if period < first then
out1:setColor(period, Neutral);
return;
end
if out1[period]>out2[period] then

	 if source[period]>out1[period] then
	 out1:setColor(period, UpUp);
	 else
	 out1:setColor(period, UpDown);
	 end
 
else
 
	if source[period]>out1[period] then
	out1:setColor(period, DownUp);
	else
	out1:setColor(period, DownDown);
	end
end
 

end
 
function Add1(period)

if period < len1 then
return;
end
 
local change1=math.abs(source[period]-source[period-len1]);
diff1[period]=math.abs(source[period]-source[period-1]);


if period < len1*2 then
return;
end

local volatility1=mathex.sum(diff1,period-len1, period);
local ER1=change1/volatility1;
local SC1=math.pow(ER1*(fastestSC-slowestSC)+slowestSC,2);
out1[period]=out1[period-1]+SC1*(source[period]-out1[period-1]);
   
end
 
function Add2(period)

if period < len2 then
return;
end
 
local change2=math.abs(source[period]-source[period-len2]);
diff2[period]=math.abs(source[period]-source[period-1]);


if period < len2*2 then
return;
end

local volatility2=mathex.sum(diff2,period-len2, period);
local ER2=change2/volatility2;
local SC2=math.pow(ER2*(fastestSC-slowestSC)+slowestSC,2);
out2[period]=out2[period-1]+SC2*(source[period]-out2[period-1]);

end 
 