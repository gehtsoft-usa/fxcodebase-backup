-- Id: 11222
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60316

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
    indicator:name("MA Cross Dot");
    indicator:description("MVA/EMA Cross Dot");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Method One");
	indicator.parameters:addInteger("SF", "First Averege Period", "First Averege  Period", 20);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method1", "VAMA", "VAMA" , "VAMA");	
	indicator.parameters:addStringAlternative("Method1", "NONLAGMA", "NONLAGMA", "NONLAGMA"); 
	
	indicator.parameters:addString("Type1", "Price Type", "", "close");
    indicator.parameters:addStringAlternative("Type1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Type1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Type1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Type1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Type1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Type1", "WEIGHTED", "", "weighted");
	
	
	indicator.parameters:addGroup("Method Two");
	indicator.parameters:addInteger("LF", "Second Averege Period", "Second Averege Period", 100);
	indicator.parameters:addString("Method2", "MA Method", " " , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method2", "VAMA", "VAMA" , "VAMA");	
	indicator.parameters:addStringAlternative("Method2", "NONLAGMA", "NONLAGMA", "NONLAGMA"); 
	
	
	indicator.parameters:addString("Type2", "Price Type", "", "close");
    indicator.parameters:addStringAlternative("Type2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Type2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Type2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Type2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Type2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Type2", "WEIGHTED", "", "weighted");
     
	
	indicator.parameters:addGroup("Style");	

    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb( 0, 255, 0));
    indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Font Size", "Font Size", 20);
	indicator.parameters:addBoolean("Show", "Show MA Lines", "" , true); 
	
	indicator.parameters:addColor("color1", "Color of Short MA", "Color of Short MA", core.rgb( 0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Color of Long MA", "Color of Long MA", core.rgb( 255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Non Lag MA Parameters One");   
    indicator.parameters:addInteger("Filter1", "Filter", "Filter", 0);
    indicator.parameters:addInteger("ColorBarBack1", "ColorBarBack", "ColorBarBack", 2);
    indicator.parameters:addDouble("Deviation1", "Deviation", "Deviation", 0);
	
	indicator.parameters:addGroup("Non Lag MA Parameters Two");   
    indicator.parameters:addInteger("Filter2", "Filter", "Filter", 0);
    indicator.parameters:addInteger("ColorBarBack2", "ColorBarBack", "ColorBarBack", 2);
    indicator.parameters:addDouble("Deviation2", "Deviation", "Deviation", 0);
	
	indicator.parameters:addGroup("Draw Fib. Levels");	
	indicator.parameters:addBoolean("Fib", "Show Fib Levles", "" , true); 
	indicator.parameters:addInteger("LookBack", "LookBack Period ", "", 0);
	indicator.parameters:addDouble("Trigger", "Trigger Level ", "", 5);
	
	
	local i;
	for i= 1, 5, 1 do
	Add(i);
	end
	
	
	
end

local Width={};
local Style={};
local Color={};

function Add(id) 
local levels={0,  0.382 , 0.50 , 0.618 , 1};
local color={core.rgb( 0, 0, 255),  core.rgb( 255, 0, 0) , core.rgb( 0, 255, 0) ,core.rgb( 255, 0, 0) , core.rgb( 0, 0, 255)};
indicator.parameters:addGroup(id.. ". Level");	
indicator.parameters:addDouble("Level"..id, id.. ". Fibonacci Level", " ", levels[id]);
indicator.parameters:addColor("Color"..id, id..". Line Color", "",color[id]);
indicator.parameters:addInteger("Width"..id, "Line width", "", 1, 1, 5);
indicator.parameters:addInteger("Style"..id, "Line style", "", core.LINE_SOLID);
indicator.parameters:setFlag("Style"..id, core.FLAG_LINE_STYLE);

end
local Levels={};
local ShortFrame=nil;
local LongFrame=nil;
local Method1=nil;
local Method2=nil;
local Filter1;
local ColorBarBack1;
local Deviation1;
local Filter2;
local ColorBarBack2;
local Deviation2;
local LookBack;
local first;
local source = nil;

-- Streams block
local LongDATA = nil;
local ShortDATA = nil;

local Type1;
local Type2;
local font;
local Size;
local Show;
local X, Y,Fib;
local id; 
local Trigger;
-- Routine
function Prepare(nameOnly)
    LookBack=instance.parameters.LookBack;
	Trigger=instance.parameters.Trigger;
	Fib=instance.parameters.Fib;
    Filter1=instance.parameters.Filter1;
    ColorBarBack1=instance.parameters.ColorBarBack1;
    Deviation1=instance.parameters.Deviation1;
	Size=instance.parameters.Size;
	Show=instance.parameters.Show;
	
	for i=1, 5, 1  do
	Levels[i]= instance.parameters:getDouble("Level".. i);
	Color[i]= instance.parameters:getDouble("Color".. i);
	Width[i]= instance.parameters:getInteger("Width".. i);
	Style[i]= instance.parameters:getInteger("Style".. i);
	end
		
    font = core.host:execute("createFont", "Wingdings", Size, false, false);
  	
	Filter2=instance.parameters.Filter2;
    ColorBarBack2=instance.parameters.ColorBarBack2;
    Deviation2=instance.parameters.Deviation2;
	
	Type1=instance.parameters.Type1;
	Type2=instance.parameters.Type2;
   
   
    ShortFrame = instance.parameters.SF;
    LongFrame = instance.parameters.LF;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	
    source = instance.source;
    first = source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. ShortFrame .. ", " .. LongFrame.. ", " .. Method1.. ", ".. Method2  .. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
		
	assert(core.indicators:findIndicator(Method1) ~= nil, "Please, download and install "..Method1..  " indicator");
	assert(core.indicators:findIndicator(Method2) ~= nil, "Please, download and install "..Method2..  " indicator");
	
	
	if Method1 == "VAMA" then
	LongDATA= core.indicators:create(Method1, source, ShortFrame);
	elseif   Method1 == "NONLAGMA" then
	LongDATA= core.indicators:create(Method1, source[Type1], ShortFrame, Filter1, ColorBarBack1,Deviation1,true);
	else
	LongDATA= core.indicators:create(Method1, source[Type1], ShortFrame);
	end
	
	if Method2 == "VAMA" then
	ShortDATA= core.indicators:create(Method2, source, LongFrame);
	elseif   Method2 == "NONLAGMA" then
	ShortDATA= core.indicators:create(Method2, source[Type2], LongFrame, Filter2, ColorBarBack2,Deviation2,true);
	else
	ShortDATA= core.indicators:create(Method2, source[Type2], LongFrame);
	end
	
	first = math.max(ShortDATA.DATA:first(),LongDATA.DATA:first());
	
	if Show then   
   short=instance:addStream("SHORT", core.Line, name, "Short", instance.parameters.color1, first);
   short:setWidth(instance.parameters.width1);
   short:setStyle(instance.parameters.style1);
   long=instance:addStream("LONG", core.Line, name, "Long",  instance.parameters.color2, first);
   long:setWidth(instance.parameters.width2);
   long:setStyle(instance.parameters.style2);
   else
   short=instance:addInternalStream(first, 0);
   long=instance:addInternalStream(first, 0);
   end
   

   Y=instance:addInternalStream(first, 0);
   
   local Flag=false;
   
   if Fib then
   Flag= true;
   end
   
   instance:ownerDrawn(Flag);

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


   
	Y[period]=0;

    LongDATA:update(mode);
	ShortDATA:update(mode);
	core.host:execute ("removeLabel", source:serial(period));
		
    if period < first or not source:hasData(period) then
	return;
	end
	
   short[period]=ShortDATA.DATA[period];
   long[period]=LongDATA.DATA[period];
				
						if ShortDATA.DATA[period]>  LongDATA.DATA[period]   and  ShortDATA.DATA[period-1]<=  LongDATA.DATA[period-1]then	
						local x,y;	 	
						local a1, b1= getline(period-1, ShortDATA.DATA[period-1], period, ShortDATA.DATA[period])
						local a2, b2=  getline(period-1, LongDATA.DATA[period-1], period, LongDATA.DATA[period])
						x,y=intersect(a1, b1, a2, b2);						
						 Y[period]=y;
                        core.host:execute("drawLabel1", source:serial(period), source:date(period),core.CR_CHART, y, core.CR_CHART, core.H_Center, core.V_Center, font,  instance.parameters.Up, "\108");						
						end
						
						if ShortDATA.DATA[period]<  LongDATA.DATA[period]   and  ShortDATA.DATA[period-1]>=  LongDATA.DATA[period-1]then	
                        local x,y;	 	
						local a1, b1= getline(period-1, ShortDATA.DATA[period-1], period, ShortDATA.DATA[period])
						local a2, b2=  getline(period-1, LongDATA.DATA[period-1], period, LongDATA.DATA[period])
						x,y=intersect(a1, b1, a2, b2);							 
						Y[period]=y;
						core.host:execute("drawLabel1", source:serial(period), source:date(period),core.CR_CHART, y, core.CR_CHART, core.H_Center, core.V_Center, font,  instance.parameters.Down, "\108");								
	
	end
 
	
   
end

function Draw(stage, context)

if stage~=  2 then
return;
end

	context:setClipRectangle (  context:left (), context:top(), context:right (), context:bottom());
	
	

id=1;

local One=math.max(context:firstBar (), first);


local x1,y1;
local x2,y2;
local x3,y3;
 
	local i;
	for  i=   context:lastBar ()-1, One, -1 do
		
	   if Y[i]~= 0 then		  
		  x2=i;
		  x1= Find(i, context); 		
		  
				if x1~= nil and ((context:maxPrice ()-context:minPrice ())*(Trigger/100  )) <  math.abs(Y[x2]-Y[x1]) then
				
				x3= xFind(i,  context);				
					local Price=0;				
			
				for j=1, 5 , 1 do
					
					if ShortDATA.DATA[i] >LongDATA.DATA[i] then				 
					Price= Y[x2] - math.abs(Y[x2]-Y[x1]) *Levels[j];
					else					 
					Price= Y[x2] + math.abs(Y[x2]-Y[x1]) *Levels[j];
					end
					
					core.host:execute("drawLine", id, source:date(x2), Price, source:date(x3), Price, Color[j], Style[j], Width[j],string.format("%." .. source:getPrecision () .. "f",  Price));
                   id=id+1;
				 
				end
				
				
				
				end
				
				
	   end			   
	   
	end

end

function xFind(One, context)
 
   local  x =context:lastBar ();     
   
   for i=  One+1 ,  context:lastBar ()   ,1 do
	   if Y[i]~= 0 then	  
	    x=i;
	    break;
	   end
   end
   
   return x;

end

function Find(One, context)
   local x=nil;
 
   local Two;
   if LookBack==0 then
   Two= math.max(first, context:firstBar ());
   else
   Two=  math.max( first, context:firstBar (), One -LookBack); 
   end
   
   for i= (One -1), Two,-1 do
	   if Y[i]~= 0 then	  
	   x=i;
	    break;
	   end
   end
   
   return x;

end

function getline(x1, y1, x2, y2)
    local a, b;

    a = ((y2 - y1) / (x2 - x1));
    b = (y1 - a * x1);
    return a, b;
end

function intersect(a1, b1, a2, b2)
    local x, y;

    -- collinear
    if a1 == a2 then
        return nil, nil;
    end

    x = (b2 - b1) / (a1 - a2);
    y = a1 * x + b1;
    return x, y;
end


function ReleaseInstance()
       core.host:execute("deleteFont", font);

end	   
	   