-- Id: 12407
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61103

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
    indicator:name("Number Of Moving Average Intersections");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
	
	
	indicator.parameters:addString("Type", "Calculation Method", "Method" , "Cross");
    indicator.parameters:addStringAlternative("Type", "Cross", "Cross" , "Cross");
    indicator.parameters:addStringAlternative("Type", "Touch", "Touch" , "Touch");
	
    indicator.parameters:addInteger("Period", "Max MA Period", "",300, 1, 1000);
	
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
    indicator.parameters:addColor("color", "Bar Color", "", core.rgb(0, 0, 0));
    indicator.parameters:addInteger("transparency", "Transparency (%)", "", 70, 0, 100); 
 
end

local   color, transparency ;
local source, first;
local MAX,MIN;
local Period;
local MA={};
local Method;
local Count={};
local Type;
-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
	Period= instance.parameters.Period;
	Type= instance.parameters.Type;
	Method= instance.parameters.Method;
	color = instance.parameters.color;   
    first = source:first();
    local name = profile:id() .. "(" .. source:name()  .. "," .. Type.. "," .. Period.. "," .. Method  .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end
	
	for i= 1, Period, 1 do
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA[i]= core.indicators:create(Method, source.close, i);
	Count[i]= instance:addInternalStream(0, 0);
	first = math.max(first,MA[i].DATA:first());
	end
	
    MAX = instance:addStream("MAX", core.Line, "", "",  core.rgb(0, 0, 0), first);	
    MAX:setPrecision(math.max(2, instance.source:getPrecision()));
    MAX:setStyle (core.LINE_NONE);	
	
	MIN = instance:addStream("MIN", core.Line, "", "",  core.rgb(0, 0, 0), first);	
    MIN:setPrecision(math.max(2, instance.source:getPrecision()));
    MIN:setStyle (core.LINE_NONE);
    source = instance.source; 
	   
    instance:ownerDrawn(true);
end

function Update(period, mode)

	MAX[period]= Period;
	MIN[period]= 1;

	
	if period < first then
	return;
	end
	
 
	
    for i= 1, Period, 1 do
	MA[i]:update(mode);
	 
	 
	   
		    if Type == "Cross" then
					if core.crosses (MA[i].DATA, source.close, period) then
					Count[i][period]= 1;
					else
					Count[i][period]= 0;
					end
			else
			       if  source.low[period] <= MA[i].DATA[period]
				   and  source.high[period] >= MA[i].DATA[period]
				   then
					Count[i][period]= 1;
					else
					Count[i][period]= 0;
					end
            end			
		 
	end
end

local drawInit = false;

function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	
        if not drawInit then
            context:createPen(1, context.SOLID, 1, color);
            context:createSolidBrush(2, color);
            transparency = context:convertTransparency(instance.parameters.transparency);
            drawInit = true;
        end
   
        local bars = {}; 
        local MaxValue=0;
    
		 for index = 1, Period, 1 do	
			bars[index]= Calculate(index);
			MaxValue= math.max(MaxValue,bars[index]);
       end
	   

      local visible, min = context:pointOfPrice(1);
	  local visible, max = context:pointOfPrice(Period);
 
        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());


        top = context:top();
        bottom = context:bottom();
        right = context:right();
		left = context:left();
		
		  local barWidth = (max-min) / Period;
          local barHeight = (right - left) /100;

        for i = 1, Period, 1 do
           
              --y1 =  bottom - i * barWidth ;
			  --y2= y1 +barWidth;
			  visible, y1 = context:pointOfPrice(i);
              y2 = y1 +barWidth;
			
			x1= context:right()  - barHeight *(bars[i]/ (MaxValue /100));
			x2= context:right(); 
            context:drawRectangle(1, 2, x1, y1, x2, y2, transparency);
        end 
        
        context:resetClipRectangle();
    
end

function Calculate(ID)
  
  index= mathex.sum(Count[ID], first, source:size()-1);
   
return index;
end
