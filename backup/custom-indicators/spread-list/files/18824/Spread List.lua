-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=8525

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
    indicator:name("Spread List");
    indicator:description("Spread List");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

     indicator.parameters:addGroup("Presentation"); 
    indicator.parameters:addString("Type", "Single/Multiple", "", "Single");
    indicator.parameters:addStringAlternative("Type", "Single", "", "Single");
    indicator.parameters:addStringAlternative("Type", "Multiple", "", "Multiple");
    indicator.parameters:addBoolean("Second", "Show Second Column", "", true);  
	
	 indicator.parameters:addString("SECOND", "Second Column Output", "Pip Cost / Spread Value", "Spread Value");
	 indicator.parameters:addStringAlternative("SECOND", "Spread Value", "", "Spread Value");
    indicator.parameters:addStringAlternative("SECOND", "Pip Cost", "", "Pip Cost");
    
	indicator.parameters:addDouble("Commissions", "Commissions per Lot (Account currency)", "", 0);
	 
	
	 indicator.parameters:addGroup("Style"); 
    indicator.parameters:addInteger("Size", "Font Size", "", 10);  
    indicator.parameters:addColor("color", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("widening", "Widening Spread Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("narrowing", "Narrowing Spread Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("no", "No Change Spread Color", "", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Type;
local SECOND;
local first;
local source = nil;
local Name;
local enum;
local Instruments;
local PointSize;
local Bid;
local Ask;
local Count;
local color, Size;
local widening, narrowing;
local no;
local Previous={};
local PipCost;
local Second;
local Commissions;
local iSize;
local hShift;
-- Routine
 function Prepare(nameOnly)   
    Second = instance.parameters.Second;
	SECOND = instance.parameters.SECOND;
	
    no = instance.parameters.no;
    narrowing = instance.parameters.narrowing;
	widening = instance.parameters.widening;
    Type = instance.parameters.Type;
	color=instance.parameters.color;
    Size=instance.parameters.Size;
    source = instance.source;
    first = source:first();
	
	Commissions = instance.parameters.Commissions;
   
   
    Name = source:instrument ();
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Type) .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
		
	Instruments, Count = getInstrumentList();	
	PointSize =getPointSize();
	PipCost= getPipCost();
	
	if Second then	
	hShift=1;
	else
	hShift=0;
	end
	
	 instance:ownerDrawn(true);
	 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

		
end

local init = false;
 
function Draw(stage, context)
    if stage~= 2 then
	return;
	end
	
	
	
        if not init then
            context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), context.ITALIC);
			iSize=context:pointsToPixels (Size);
            init = true;
        end
 

	Bid, Ask = getBidAskList();
	 
    local i, j;
		
        
		local  Label=  "Spread";
        width, height =  context:measureText (1, Label, 0)		
		x1=context:right ()-iSize*(1+hShift)*12 
		x2=context:right ()-iSize*(1+hShift)*12 +width
		y1=context:top ()+iSize*(2) 
		y2=context:top ()+iSize*(2) +height
        context:drawText (1, Label, color, -1, x1, y1, x2, y2 , 0 );
		
		 if Second then 
       
		        if SECOND == "Pip Cost" then		
				 Label=  "Pip Cost";	
				else
				 Label= "S. Value";
				end		
				
				
				 width, height =  context:measureText (1, Label, 0)		
				 x1=context:right ()-iSize*(0+hShift)*12 
				 x2=context:right ()-iSize*(0+hShift)*12 +width
				 y1=context:top ()+iSize*(2) 
				 y2=context:top ()+iSize*(2) +height
				 context:drawText (1, Label, color, -1, x1, y1, x2, y2 , 0 );
		end 
		
		
		
	
	for i = 1 , Count , 1 do
	
	        if Type == "Single" and Instruments[i] ==  Name   then			
			Add(context,1, i);			
			elseif  Type ~= "Single" then
			Add(context, i,i);			
			end
			 
	end		


end

function Add(context, j,i) 

    local  Label;	
	local Calucation;
	local COLOR;  
    local iCommissions;
	
	
        iCommissions=Commissions/PipCost[i];	
	    COLOR= no;
	  
	    Calucation = ((Ask[i]- Bid[i])  / PointSize [i]) + iCommissions;
		
		if Previous[i]~= nil and Previous[i] >  Calucation then
		COLOR= widening;
		elseif  Previous[i]~= nil and  Previous[i] <  Calucation then
		COLOR= narrowing;			
		end
	
	   	Previous[i] = Calucation;
		
		Label= Instruments[i];		
		
		
		 width, height =  context:measureText (1, Label, 0)		
				 x1=context:right ()-iSize*(2+hShift)*12 
				 x2=context:right ()-iSize*(2+hShift)*12 +width
				 y1=context:top ()+iSize*(j+2) 
				 y2=context:top ()+iSize*(j+2) +height
				 context:drawText (1, Label, color, -1, x1, y1, x2, y2 , 0 );
			 
			 
			 
			 
			 Label= string.format("%." .. 1 .. "f", Calucation );
			 width, height =  context:measureText (1, Label, 0)	
             x1=context:right ()-iSize*(1+hShift)*12 
			 x2=context:right ()-iSize*(1+hShift)*12 +width			 
			 
			  context:drawText (1, Label, color, -1, x1, y1, x2, y2 , 0 ); 
			
			     if Second then
					 if SECOND == "Pip Cost" then
					 Label= string.format("%." .. 4 .. "f", PipCost[i] );
					 else
					 Label=string.format("%." .. 4 .. "f", PipCost[i] * Calucation  );
					 end
					 
					 width, height =  context:measureText (1, Label, 0)	
                    x1=context:right ()-iSize*(0+hShift)*12 
			        x2=context:right ()-iSize*(0+hShift)*12 +width	
			         context:drawText (1, Label, color, -1, x1, y1, x2, y2 , 0 ); 
				 end
			

end
function getPipCost()
    local Cost = {};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
		
        Cost[count] = row.PipCost;		
		
        row = enum:next();
    end

    return  Cost;
end



function getPointSize()
    local SIZE = {};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
		
        SIZE[count] = row.PointSize;		
		
        row = enum:next();
    end

    return  SIZE;
end



function getBidAskList()
    local BID = {};
	local ASK  = {};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
		
        BID[count] = row.Bid;
		ASK[count] = row.Ask;
		
        row = enum:next();
    end

    return BID, ASK;
end



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

