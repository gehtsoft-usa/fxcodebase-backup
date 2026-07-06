-- Id: 13478
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61741

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
    indicator:name("CMO RLW Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("CMO Calculation");	
	indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	
	  
	indicator.parameters:addInteger("Period1", "CMO Period ", "", 9, 1, 2000);
   indicator.parameters:addDouble("OB1", "OB Level", "",  80); 	
	indicator.parameters:addDouble("OS1", "OS Level", "",  -80); 
	
	indicator.parameters:addGroup("1. RLW Calculation");
 
	indicator.parameters:addInteger("Period2", "2. MA Period", "", 14, 1, 2000); 	
	indicator.parameters:addDouble("OB2", "OB Level", "",  -20); 	
	indicator.parameters:addDouble("OS2", "OS Level", "",  -80); 
	
	indicator.parameters:addGroup("2. RLW Calculation"); 
	indicator.parameters:addInteger("Period3", "3. MA Period", "", 42, 1, 2000); 
	indicator.parameters:addDouble("OB3", "OB Level", "",  -20); 	
	indicator.parameters:addDouble("OS3", "OS Level", "",  -80); 
	
 
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Color of Up in Uptrend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDn", "Color of Down in Up Trend", "", core.rgb(0, 200, 0))
	indicator.parameters:addColor("DnUp", "Color of Up in Down Trend", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Dn", "Color of  Down in Down Trend", "", core.rgb(200, 0, 0));
	indicator.parameters:addColor("NoUp", "Color of Up in Neutral Trend", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("NoDown", "Color of Down in Neutral Trend", "", core.rgb(0, 0, 200));
	

   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil; 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local OB={};
local OS={};

local Indicator={};
local Period= {} ;
local Price={};
function Prepare(nameOnly)
  
	Show = instance.parameters.Show;
	 
	
	One= instance.parameters.One;
	Two= instance.parameters.Two;
	 
	source = instance.source;
	
	local name = profile:id() .. "(" .. source:name() 	..  ")";
	instance:name(name); 
	if nameOnly then
		return;
	end
 
	first=   source:first() ;
	for i= 1, 3 , 1 do 
	
	Period[i]= instance.parameters:getInteger("Period" .. i);
	OB[i]= instance.parameters:getDouble("OB" .. i);
	OS[i]= instance.parameters:getDouble("OS" .. i);
	
		if i== 1 then
		Price[i]= instance.parameters:getString("Price" .. i);
		Indicator[i]=core.indicators:create("CMO",  source[Price[i]] , Period[i]);
		else
		Indicator[i]=core.indicators:create("RLW",  source  , Period[i]);
		end
	 
	first=math.max(first,Indicator[i].DATA:first());  
	end
	 
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	Number=0;
	
	for i= 1, 3, 1 do
	Indicator[i]:update(mode);
	end
	
	
   if period < first then
   open:setColor(period, instance.parameters.No);
   return;
   end
	
   
		              if Indicator[1].DATA[period]< OS[1] 
					  and  Indicator[2].DATA[period]< OS[2] 
					  and  Indicator[3].DATA[period]< OS[3] 
					  then 
							 if source.close[period]>source.open[period] then
							  open:setColor(period, instance.parameters.Up);	
							 else
							 open:setColor(period, instance.parameters.UpDn);	
							 end
 				 
					  elseif Indicator[1].DATA[period] > OB[1]
                      and Indicator[2].DATA[period] > OB[2] 		
                      and Indicator[3].DATA[period] > OB[3] 					  
					  then
							 if source.close[period]>source.open[period] then
							 open:setColor(period, instance.parameters.DnUp);	
							 else
							 open:setColor(period, instance.parameters.Dn);	
							 end
					  else
		                    if source.close[period]>source.open[period] then
							 open:setColor(period, instance.parameters.NoUp);	
							 else
							 open:setColor(period, instance.parameters.NoDown);	
							 end
					  end
					  
		
		 
		
 end


