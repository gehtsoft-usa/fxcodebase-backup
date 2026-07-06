-- More information about this indicator can be found at:
-- http://fxcodebase.com 

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
function Init()
      indicator:name("VPOC");
    indicator:description("VPOC");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
      indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("BoxSize", "Size of price box in pips", "", 5);  
	
	  indicator.parameters:addGroup("Style");
 
    indicator.parameters:addColor("POC", "POC Color", "", core.rgb(127, 127, 127));
	 indicator.parameters:addInteger("Size", "Font Size", "", 8);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Size;
local BoxSize;
local source;
local first;  
local s;
local e;  
local BOX; 
local PocMark;
local BarSize;
local Signal;
-- Routine
 function Prepare(nameOnly)
 
 
   
    BoxSize = instance.parameters.BoxSize; 
	Size = instance.parameters.Size;	 
    source = instance.source;
    first = source:first();
	   
	BOX = BoxSize* source:pipSize ();
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. BoxSize .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	PocMark= instance:createTextOutput ("POC", "POC", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.POC, 0);
    Signal = instance:addStream("Signal" , core.Line, " Signal"," Signal",instance.parameters.POC, first );
    Signal:setStyle(core.LINE_NONE );
    local s1, e2;
	 s1, e2 = core.getcandle(source:barSize(), core.now(), 0, 0);
     BarSize= e2-s1;	 
	 
	 
end

local date; 
local Filter;
local FLAG;
-- Indicator calculation routine
function Update(period)

  

  local Last,LastTable;

  local Table;
  
  date = source:date(period);
  Table= core.dateToTable(date); 
  
  Last = source:date(source:size()-1);
  LastTable= core.dateToTable(Last); 

 
  MP (period,Table.month*31+Table.day);
  
  
end

function MP (p,n)

 
 local i, j;
 local min, max;
	 
	  
 s, e = core.getcandle("D1", date, 0, 0);	
 local x= core.findDate(source, s, false);
 local y= core.findDate(source, e, false);
 
  if   (x <= 0  or y < 0) then
  return;
  end
	    
 if p < y   
 then
 return;
 end   
	   
  if not (date >= s  and date <= e) then
  return;
  end

  if   (x <= first  or y > source:size()-1) then
  return;
  end
	min, max= mathex.minmax(source, x, y);
  
							   
	local POC;	
	local Profile={};
 
 

	
	for j= x , y, 1 do	

                   
						   
						   local Count = 0;
						   for i = min, max , BOX  do
							  
							  Count = Count+1;
							  if Profile[Count] == nil then 
							  Profile[Count]=0;
							  end
							  
							 
							  
							 
							  if i >= source.low[j] and i  + BOX  <=  source.high[j]  or  i <= source.low[j] and i  + BOX  >=  source.low[j]   or  i <= source.high[j] and i  + BOX  >=  source.high[j] then					  
								Profile[Count]= Profile[Count]+1;		
                                 
							  end 
							 
							   
							  if i== min then					  
							  POC=Count;
							  elseif Profile[POC] <  Profile[Count] then  
							  POC=Count;					 
							  end
							  
							   
								 
								  
			                        PocMark:set(j, min+ POC*BOX, "\108");
									Signal[j]=min+ POC*BOX
									
							 
						   end				   
						   
					end		
					
				 
					 
					          
			
end
