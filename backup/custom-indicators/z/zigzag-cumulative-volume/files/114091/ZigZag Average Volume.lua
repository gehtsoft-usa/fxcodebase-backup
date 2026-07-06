-- Id: 23413
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64976

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
    indicator:name("ZigZag Average Volume");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Depth", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
 
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Up", "Up Volume color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Volume color", "Color", core.rgb(255, 0, 0));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Depth;
local Deviation;
local Backstep;

local first;
local source = nil;
 
 
-- Streams block
local  ZigZag, Average;
local FIRST=false; 
-- Routine
function Prepare(nameOnly)
    Depth = instance.parameters.Depth;
    Deviation = instance.parameters.Deviation;
    Backstep = instance.parameters.Backstep;
	 
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    ZigZag = core.indicators:create("ZIGZAG", source,Depth	,Deviation,Backstep);
    first = source:first();
    
	Average= instance:addStream("Average", core.Bar, name, "Average Volune", instance.parameters.Up, first);
    Average:setPrecision(math.max(2, instance.source:getPrecision()));
 
end 

 

function Update(period )

 
 
  if period < first then
  FIRST=false;
  return;
  end
  
  
  if period < source:size()-1 then
  return;
  end
  
 
  
  
  if not FIRST then    
  FIRST=true;
 
   
    ZigZag:update(core.UpdateAll);
	
	
	
	for i=  source:size()-1,first, - 1 do
  
    local Last1,Last2,Direction1, Direction2= FindLast ( i); 
	
		if Last1~= nil
		and Last2~= nil
		then
		Calculate (Last1,Last2, Direction1, Direction2); 
		end
	 
	 
	   
   
   end
   
   
   return;
  
end  
  

  
	ZigZag:update(core.UpdateAll);
	
	local Last1,Last2,Direction1, Direction2= FindLast ( period); 
	
	    if Last1~= nil
		and Last2~= nil
		then
		Calculate (Last1,Last2,Direction1, Direction2); 
		end
	
   
end

function FindLast ( Current)
 
    local Return={};
	local Direction={};
	local Number=0;
	
    if ZigZag == nil then
	return nil, nil;
	end
	
 
	
                for p=Current, source:first(), -1 do

					if ZigZag.DATA:hasData(p) 
					or not ZigZag.DATA:hasData(p-1)
					then
				 
						

						if (   ZigZag.DATA[p-1] < ZigZag.DATA[p] and ZigZag.DATA[p+1] < ZigZag.DATA[p] and  ZigZag.DATA[p+1]~= nil )
						then
						Number=Number+1;
						Return[Number]=p; 
						Direction[Number]=1;
						elseif  ( ZigZag.DATA[p-1] > ZigZag.DATA[p] and ZigZag.DATA[p+1] > ZigZag.DATA[p] and  ZigZag.DATA[p+1]~= nil )
						then
						Number=Number+1;
						Return[Number]=p; 
						Direction[Number]=-1;
						end
						 
				
				    end
					
					if Number==2 then 
					break;
					end
					
				end
				
	
     return Return[2],Return[1],Direction[2],Direction[1];
end

function  Calculate (p1,p2,Direction1, Direction2)

 
	local S1=mathex.sum(source.volume, p1, p2)
	local S2=(p2-p1);   
 
    local Value=S1/S2;
 
 
    if Direction2== 2 then
	 core.drawLine(Average, core.range(p1, p2), Value, p1, Value, p2, instance.parameters.Up);
	else
    
     core.drawLine(Average, core.range(p1, p2), Value, p1, Value, p2, instance.parameters.Down);
    end
end
 