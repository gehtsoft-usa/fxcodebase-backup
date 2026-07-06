-- Id: 18807
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
    indicator:name("ZigZag Cumulative Volume");
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
local Period;
local FIRST=true;
-- Streams block
local Volume, ZigZag;
local Signal;
local Color=0;
local Last;
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
    Signal = instance:addInternalStream(0, 0);
    Volume = instance:addStream("Volume", core.Bar, name, "Cumulative Volune", instance.parameters.Up, first);
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));
  
	
	  core.host:execute ("setTimer", 1, 5);
      FIRST=true;
end

 function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
 
	
	if cookie == 1 then
	ZigZag:update(core.UpdateAll);
    instance:updateFrom(0);	
    end
	

end


function Update(period, mode)


  if period < first then
  Last= first;
  end
  
 if period < source:size()-1 then
 FIRST=true;
 return; 
 end
 
  if FIRST then
  ZigZag:update(mode);
  FIRST=false;
  
     Last= first;
	 
     for p= first+1, source:size()-2, 1 do	
	 Find ( p); 
	 end
	 
	  for p= first, source:size()-1, 1 do	
	   Calculate (p);
	  end 
	  
	  
	  
  end
  
     for p= Last, source:size()-2, 1 do	
	 Find ( p); 
	 end
	 
	  for p= Last, source:size()-1, 1 do	
	   Calculate (p);
	  end 
 
	
   
end

function Find ( p)

     

                if not ZigZag.DATA:hasData(p)
				or not ZigZag.DATA:hasData(p+1)
				or not ZigZag.DATA:hasData(p-1)
				then
				return;
				end
				

				if (   ZigZag.DATA[p-1] < ZigZag.DATA[p] and ZigZag.DATA[p+1] < ZigZag.DATA[p] and  ZigZag.DATA[p+1]~= nil )
			    then
				Signal[p]=1;
				Last=math.max(Last,p);
				elseif  ( ZigZag.DATA[p-1] > ZigZag.DATA[p] and ZigZag.DATA[p+1] > ZigZag.DATA[p] and  ZigZag.DATA[p+1]~= nil )
				then
				Signal[p]=-1;
				Last=math.max(Last,p);
				else
				Signal[p]=0;
				end
				
				
	

end

function  Calculate (p)



       if Signal[p]==1 then
	   Color=1;
	   elseif  Signal[p]==- 1 then
	   Color=-1;
	   end
	   
	   
	   if Signal[p]==1  or Signal[p]== -1   then
	   Volume[p]= source.volume[p];
	   else
	   Volume[p]=Volume[p-1]+ source.volume[p];
	   end
	   
	   if Color==1 then
	   Volume:setColor(p, instance.parameters.Up);
       elseif Color==-1 then
	   Volume:setColor(p, instance.parameters.Down);
       end
  

end
 