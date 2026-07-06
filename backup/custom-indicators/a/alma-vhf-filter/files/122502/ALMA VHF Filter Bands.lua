-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67048

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
    indicator:name("ALMA VHF Filter Bands");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 
	
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Window", "Window", "", 7);
	indicator.parameters:addInteger("Sigma", "Sigma", "", 3);
	indicator.parameters:addInteger("Length", "Length", "", 21);
  
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Neutral Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Window,Sigma,Length;
local first;
local source = nil;
local s; 
local Line;
local high, low,trend;
-- Routine
 function Prepare(nameOnly)    
 
    Window= instance.parameters.Window;
	Sigma= instance.parameters.Sigma;
	Length= instance.parameters.Length; 
	
	local Parameters= Window ..  ", " .. Sigma ..  ", " .. Length;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. "," ..   Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	
	high = instance:addInternalStream(0, 0);
	low = instance:addInternalStream(0, 0);
	trend = instance:addInternalStream(0, 0);
	
    s = Window/Sigma;
			
    source = instance.source; 
    first=source:first()+Length;
	 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color, first);
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style); 
	
end

-- Indicator calculation routine
function Update(period, mode)
 
	
    if period < first then
	return;
	end

 

    high[period]=Calculate(source.high, period);
	low[period]=Calculate(source.low, period);
	

 
	
if high[period]<high[period-1] and source.low[period]<low[period] then
trend[period]=-1;
elseif low[period]>low[period-1] and source.high[period]>high[period] then
trend[period]=1;
else
trend[period]=trend[period-1];
end
 
 
 local r=0;
 local g=0;
 local b=0;
 
 
if trend[period]==1 then
 Line[period]=low[period];
 r=0
 g=255
 b=0
else
 Line[period]=high[period];
 r=255
 g=0
 b=0
end
	
	
	Line:setColor(period, core.rgb(r, g, b));
end


function Calculate(Source, period)


local CloseDiff = 0;
local SumDiff = 0; 
 
for  Counter = 0 ,  Length - 1, 1  do
 CloseDiff = math.abs(Source[period-Counter] - Source[Counter - 1]);
 SumDiff = SumDiff + CloseDiff;
end
 
if SumDiff == 0 then
 SumDiff = 1;
end

local min,max=mathex.minmax(Source, period-Length+1, period);--

local VHF = (max-min) / SumDiff;
 
 
local Offset = math.max(0.01,1- VHF)
local  m = (Offset * (Window - 1))

 
local WtdSum = 0
local CumWt  = 0
 
for k = 0 ,  Window - 1, 1  do
 Wtd = math.exp(-((k-m)*(k-m))/(2*s*s))
 WtdSum = WtdSum + Wtd * Source[period-Window + 1 + k]
 CumWt = CumWt + Wtd
end
 
		
     return WtdSum / CumWt;
				  
end

