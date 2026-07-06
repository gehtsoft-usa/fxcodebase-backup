-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68856

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("MA infliction point");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
 
 
   
	
	indicator.parameters:addGroup("MA Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000);
	 
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	  indicator.parameters:addGroup("Selector"); 
    indicator.parameters:addBoolean("Show", "Show Historical", "", false);
	indicator.parameters:addBoolean("ShowMA", "Show MA", "", false);
 
 
    indicator.parameters:addGroup("Next Infliction Point approximation"); 
	indicator.parameters:addInteger("Period1", "Curent Candle Period", "", 0, 0, 1);
	indicator.parameters:addInteger("Period2", "Previous Candle Period", "", 1, 1, 1000);
 
	
	
	indicator.parameters:addGroup("Infliction point style"); 	
    indicator.parameters:addColor("Up", "Line Cross Over Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Line Cross Under Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("istyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("istyle", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("iwidth", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("MA Line Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);

	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method, Period,Show;
local Period1, Period2;
local first;
local source = nil;
local MA,ma; 
local Next;
local ShowMA;
-- Routine
 function Prepare(nameOnly)   
 
 
    Show= instance.parameters.Show;
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
    Period= instance.parameters.Period;
    Method= instance.parameters.Method; 
	ShowMA= instance.parameters.ShowMA;
	
	
	local Parameters= Period  ..  ", " .. Method;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
  
    ma = core.indicators:create(Method, source, Period); 
	
	
	first=ma.DATA:first(); 
	 
	if ShowMA then 
	 MA = instance:addStream("MA" , core.Line, " MA"," MA",instance.parameters.color, first );
	MA:setWidth(instance.parameters.width);
    MA:setStyle(instance.parameters.style);
    MA:setPrecision(math.max(2, source:getPrecision()));
	else
	MA = instance:addInternalStream(0, 0);
	end
	
	
	
	Next=0;
	
	 instance:ownerDrawn(true); 
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    ma:update(mode); 
	
	if period < first then
	return;
	end
	
	MA[period]=ma.DATA[period];
	
	local S1, S2, S2;
	
	if period== source:size()-1 then
	
	S1=(source[period-Period1]-source[period-Period1-Period2])/source:pipSize();
	S2=(source[period-Period1-Period2]-source[period-Period1-Period2*2])/source:pipSize();
	
 
       if (S1  >  S2  ) then
		 Delta = S1-S2
		 Next=math.abs(S1/Delta);
	    elseif (S1 <S2  ) then
          
		  Delta = S2-S1
		  Next=math.abs(S2/Delta);
		end

		
			 
			
		 
		
		Next= round(Next, 1);
		else
		Next=0;
		end
	
	 
				  
end


function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end
 
function Draw(stage, context)
    if stage~= 2 then
	 return;
	end
	
	 
	 
	 
	
        if not init then
		
		    context:createPen(1, context:convertPenStyle (instance.parameters.istyle), instance.parameters.iwidth, instance.parameters.Up); 
			context:createPen(2, context:convertPenStyle (instance.parameters.istyle), instance.parameters.iwidth, instance.parameters.Down); 
			
            
						
            init = true;
        end
		
	  
	  
	  
	    local First = math.max(first, context:firstBar ());
        local Last = math.min (context:lastBar (), source:size()-1);
		
    local period;
	
			    for period= First, Last, 1 do	 
			    x, x1, x2 = context:positionOfBar (period);
				
				       if ma.DATA:hasData(period)
					   and  ma.DATA:hasData(period-1)
					   and ma.DATA:hasData(period-2) 
					   then
					   
							 if Show  and
							 (
							 (ma.DATA[period]> ma.DATA[period-1] and ma.DATA[period-1]<= ma.DATA[period-2]) 
							 or
							 (ma.DATA[period]< ma.DATA[period-1] and ma.DATA[period-1]>= ma.DATA[period-2]) 
							 )

							 then
							 
							 if ma.DATA[period]> ma.DATA[period-1] then
							 context:drawLine (1, x , context:top(), x , context:bottom());
							 else						 
							 context:drawLine (2, x , context:top(), x , context:bottom());
							 end
						end
					
				    end
				end
				
				local Delta;
				period= source:size()-1;
				if Next >0 then
				
				 x, x1, x2 = context:positionOfBar (period);
				 Delta=math.abs(x2-x1);
					 if   (ma.DATA[period]< ma.DATA[period-1]) then
					 context:drawLine (1, x +Delta*Next, context:top(), x +Delta*Next , context:bottom());
					 else
					 context:drawLine (2, x  +Delta*Next, context:top(), x +Delta*Next , context:bottom());
					 end
				end
				
  
end	

