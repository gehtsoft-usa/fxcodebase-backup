-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67123

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
    indicator:name("Quadratic semaphore");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("length", "length", "", 30, 1, 2000);
    indicator.parameters:addInteger("p", "p", "", 6, 1, 2000);
	
	
	indicator.parameters:addBoolean("SignalMode", "Signal Mode", "", false);
	 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Bottom", "Bottom Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Top", "Top Color", "",  core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "",  core.rgb(128, 128, 128));
    indicator.parameters:addInteger("Size", "Size", "",  15);
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SignalMode,Signal;
local length,p; 
local first;
local source = nil;
local Indicator1,Indicator2;
local High,Low; 
local Period; 
local ATR; 
local font;
local Size;
local Top, Bottom;
-- Routine
 function Prepare(nameOnly)    
 
    length= instance.parameters.length; 
	p= instance.parameters.p;
	SignalMode= instance.parameters.SignalMode;
	
	local Parameters= length  .. "," ..  p ;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. "," ..   Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Size= instance.parameters.Size;
 
	
	
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
	
	Period = round(p/2,0)+1

	
	
	
	assert(core.indicators:findIndicator("QUADRATIC REGRESSION") ~= nil, "Please, download and install QUADRATIC REGRESSION.LUA indicator");
    
			
    source = instance.source;
	
	Indicator1= core.indicators:create("QUADRATIC REGRESSION", source.high, length);
	Indicator2= core.indicators:create("QUADRATIC REGRESSION", source.low, length);	
	ATR= core.indicators:create("ATR", source, length);	
    first=Indicator1.DATA:first();
	
	High = instance:addInternalStream(0, 0);
	Low = instance:addInternalStream(0, 0);
	
	if SignalMode then
	Signal = instance:addStream("Signal" , core.Bar, " Signal"," Signal",instance.parameters.Neutral, first+Period);
	else
	Signal = instance:addInternalStream(0, 0);
	end
   
    if not SignalMode then
	Top = instance:createTextOutput ("Top", "Top", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Top, 0);
    Bottom = instance:createTextOutput ("Bottom", "Bottom", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Bottom, 0);
	end
	
end

-- Indicator calculation routine
function Update(period, mode)
 
    Indicator1:update(mode);
    Indicator2:update(mode);
	ATR:update(mode);
	
	if period < first then
	return;
	end
	
	Signal:setColor(period, instance.parameters.Neutral)
	
	
	if not SignalMode then
	 Top:setNoData(period);
	 Bottom:setNoData(period);
	end 
	
	High[period]=Indicator1.DATA[period];
	Low[period]=Indicator2.DATA[period];	
	
	if period < first+Period then
	return;
	end
      
	
    local countH = 0
    local countL = 0
	
	for i = 1 , Period-1, 1  do
	 if High[period-i]<High[period] then
	  countH=countH+1
	 end 
	 if Low[period-i]>Low[period] then
	  countL=countL+1
	 end 
	end

	for i = Period+1 , p+1,1 do
	 if High[period-i]<High[period] then
	  countH=countH+1
	 end 
	 if Low[period-i]>Low[period] then
	  countL=countL+1
	 end 
	end
	
	
	if countH==p then
	
		if not SignalMode then
		Top:set(period, source.high[period]+ATR.DATA[period], "\108", source.high[period]+ATR.DATA[period]);
		Top:setNoData(period-1);
		else
		Signal[period]=-1;
		Signal[period-1]=0;
		Signal:setColor(period, instance.parameters.Top);
		Signal:setColor(period-1, instance.parameters.Neutral);
		end
	
	
	end
	
 	if countL==p then
		if not SignalMode then
		Bottom:set(period, source.low[period]-ATR.DATA[period], "\108", source.low[period]-ATR.DATA[period]);
		Bottom:setNoData(period-1);
		else
		Signal[period]=1;
		Signal[period-1]=0;
		Signal:setColor(period, instance.parameters.Bottom);
		Signal:setColor(period-1, instance.parameters.Neutral);
		end
	end
end


function round(num, numDecimalPlaces)
  if numDecimalPlaces and numDecimalPlaces>0 then
    local mult = 10^numDecimalPlaces
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

 
 function ReleaseInstance()
       core.host:execute("deleteFont", font);
end

