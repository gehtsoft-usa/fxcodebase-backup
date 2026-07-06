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
    indicator:name("ALMA VHF Filter");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator); 
	
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Window", "Window", "", 7);
	indicator.parameters:addInteger("Sigma", "Sigma", "", 3);
	indicator.parameters:addInteger("Length", "Length", "", 21);
  
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
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

 

local CloseDiff = 0;
local SumDiff = 0; 
 
for  Counter = 0 ,  Length - 1, 1  do
 CloseDiff = math.abs(source[period-Counter] - source[Counter - 1]);
 SumDiff = SumDiff + CloseDiff;
end
 
if SumDiff == 0 then
 SumDiff = 1;
end

local min,max=mathex.minmax(source, period-Length+1, period);--

local VHF = (max-min) / SumDiff;
 
 
local Offset = math.max(0.01,1- VHF)
local  m = (Offset * (Window - 1))

 
local WtdSum = 0
local CumWt  = 0
 
for k = 0 ,  Window - 1, 1  do
 Wtd = math.exp(-((k-m)*(k-m))/(2*s*s))
 WtdSum = WtdSum + Wtd * source[period-Window + 1 + k]
 CumWt = CumWt + Wtd
end
 
		
     Line[period]=WtdSum / CumWt;
				  
end

