
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60856

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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Ticker Tape");
    indicator:description("Ticker Tape");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("Speed", "Speed", "", 1);
	indicator.parameters:addInteger("Direction", "Direction", "", 2);
    indicator.parameters:addIntegerAlternative("Direction", "Left to Right", "", 1);
    indicator.parameters:addIntegerAlternative("Direction", "Right to Left", "", 2);
	
	indicator.parameters:addInteger("Placement", "Placement", "", 1);
    indicator.parameters:addIntegerAlternative("Placement", "Top", "", 1);
    indicator.parameters:addIntegerAlternative("Placement", "Bottom", "", 2);
	
	indicator.parameters:addGroup("Style");
     indicator.parameters:addInteger("Size", "Font Size", "Font Size",10);
	 indicator.parameters:addInteger("Shift", "Shift", "Shift",50);
    indicator.parameters:addColor("Color", "Label Color", "Label Color", core.COLOR_LABEL);
	indicator.parameters:addColor("Up", "Up Color", "Up Color",  core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "Down Color",  core.rgb(255,0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "Neutral Color",  core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Direction;
local first;
local source = nil;
local Position=0;
local Size;
local Color;
local Shift;
local Speed;
local Start;
local Placement; 
local context;
local Elements={};
local List, Count;
local Up, Down,Neutral;
function getInstrumentList()
    local list={};
   
    local count = 0;   
    local row, enum;   
   
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
        row = enum:next();
    end

    return list, count;
end


function Prepare(nameOnly)  
    source = instance.source;
    first = source:first();
	Size=instance.parameters.Size;
	Color=instance.parameters.Color;
	Shift=instance.parameters.Shift;
	Direction=instance.parameters.Direction;
	Placement=instance.parameters.Placement;
	Speed=instance.parameters.Speed;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	
	
	local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
	
	List, Count= getInstrumentList();
	for i = 1, Count, 1 do                  
	Add(i,  List[i], 0,0 ); 
	end
 
    Start=0;
   

     instance:ownerDrawn(true);
	 
	   
	 core.host:execute ("setTimer", 1, 1);
	 
end

function Add (id,  Ticker, Price, Change )

    local Element={}; 
	Element.Ticker=Ticker;
	Element.Price=Price;
	Element.Change=Change;
    
    Elements[id]=Element;
end
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period) 


   if period < source:size()-1 then
   return;
   end
   

   
	for i = 1, Count, 1 do
	Element= Elements[i];	 
	
	Element.Price= core.host:findTable("offers"):find("Instrument", List[i]).Ask; 
	Element.Change= core.host:findTable("offers"):find("Instrument", List[i]).AskChangeDirection; 
	

    Elements[i]= Element;
	end
	
end


 function AsyncOperationFinished(cookie, success, message)
 
 
    if cookie~= 1 then
	return;
	end

    if Start== 0 
	or (math.abs(Position) >= context:left ()+300*Count  )	
	then
	Start=win32.tickCount();
	end
 
   
	    
	local Now=win32.tickCount();
	  
   	Position= ((Now-Start)/20)*Speed;
	if Direction == 2 then
	Position=-Position;	
	end
	 
	
end
 
function Draw(stage, Context)

    context=Context;


	if stage~= 2 then
	return;
	end
	
	--core.host:execute("setStatus", "Position :" .. Position ); 
	
	
    context:createFont (1, "Arial", Size, Size, 0)
	
    for i= 1, #Elements-1, 1 do
 
	Element= Elements[i];
	Ticker=Element.Ticker;
	Price=Element.Price;
	Change=Element.Change;
  
    if Placement == 1 then
     y1=Context:top ()+Shift;
      y2=y1+Size*2;	
	else
	  y2=Context:bottom ()-Shift;
      y1=y2-Size*2;	
    end
	
	width, height = Context:measureText (1,  Ticker , 0)
	
	iPosition= Position+(i-1)* 300+0;
	  x1=Context:left ()+iPosition;	
      x2=x1+width;
	  
	  
	Context:drawText (1,  Ticker , Price, -1, x1, y1, x2, y2, Context.LEFT);
	
	
	 width, height = Context:measureText (1,  Price , 0)
	
	
	  
	iPosition= Position+(i-1)* 300+120;
	  x1=Context:left ()+iPosition;	
      x2=x1+width;
	  
	if Change== 1 then
	iColor=Up;
	elseif Change== -1 then
	iColor=Down;
	else
	iColor=Neutral;
	end
	  
	Context:drawText (1,  Price , iColor, -1, x1, y1, x2, y2, Context.LEFT);
	
 
	end
	
	
end