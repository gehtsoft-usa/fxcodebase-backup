
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63029

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
    indicator:name("Position Profit and Loss");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);


	indicator.parameters:addGroup("Trade Info");	
	
    indicator.parameters:addString("Trade", "Choose Trade", "", "");
    indicator.parameters:setFlag("Trade", core.FLAG_TRADE);
	
	indicator.parameters:addGroup("Selector")
	indicator.parameters:addBoolean("S1", "Show TradeID", "", true);
	indicator.parameters:addBoolean("S2", "Show Instrument", "", true);
	indicator.parameters:addBoolean("S3", "Show Number of Lots", "", true);
	indicator.parameters:addBoolean("S4", "Show Amount", "", true);
	indicator.parameters:addBoolean("S5", "Show Trade Direction", "", true);
	indicator.parameters:addBoolean("S6", "Show profit in pips", "", true);
	indicator.parameters:addBoolean("S7", "Show profit", "", true);
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Left");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 10);
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local X,Y;
local font;
local Label;
local Size;
local ShiftY;
local Trade;
local S1, S2, S3, S4, S5, S6, S7;
-- Routine
function Prepare(nameOnly)
    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;   
    Trade = instance.parameters.Trade;	
	S1= instance.parameters.S1;
	S2= instance.parameters.S2;
	S3= instance.parameters.S3;
	S4= instance.parameters.S4;
	S5= instance.parameters.S5;
	S6= instance.parameters.S6;
	S7= instance.parameters.S7;
		
    source = instance.source;
    first=source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   	
    instance:ownerDrawn(true);

	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   

  
end
 
local init = false;
 
function Draw(stage, context)


    if stage ~= 2 then
	return;
	end

    if not(checkReady("trades"))  then
        return ;
    end
  
  
    local TradeID=nil;
	
	 Enum = core.host:findTable("trades"):enumerator();
     Row = Enum:next();
	 
	while (Row ~= nil) do
	
                    if Row.TradeID == Trade then
                       TradeID=Row.TradeID;
                        break;
                    end
	Row = Enum:next();				
    end 
	
	if TradeID == nil then
	return;
	end
				
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
	
	 local Instrument = core.host:findTable("trades"):find("TradeID", TradeID).Instrument;
	 local Lot= core.host:findTable("trades"):find("TradeID", TradeID).Lot;
	 local AmountK= core.host:findTable("trades"):find("TradeID", TradeID).AmountK;
     local BS= core.host:findTable("trades"):find("TradeID", TradeID).BS;
	 local PL= core.host:findTable("trades"):find("TradeID", TradeID).PL;
     local GrossPL= core.host:findTable("trades"):find("TradeID", TradeID).GrossPL;
	
  	local Num=0;
	
	if S1 then	
	Text =  " Trade ID : " .. TradeID;
	width, height = context:measureText (1, Text, 0);
    context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,1+ShiftY+Num,1) ,iX(context,width,0,2),iY(context,height,1+ShiftY+Num,2), 0 );	
	Num=Num+1;
    end
	
	if S2 then
	Text = " Instrument : " .. Instrument;
	width, height = context:measureText (1, Text, 0);
     context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,1+ShiftY+Num,1) ,iX(context,width,0,2),iY(context,height,1+ShiftY+Num,2), 0 );	
	Num=Num+1;
    end
	
	if S3 then
	Text = " Lot : " .. Lot;
	width, height = context:measureText (1, Text, 0);
    context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,1+ShiftY+Num,1) ,iX(context,width,0,2),iY(context,height,1+ShiftY+Num,2), 0 );	
	Num=Num+1;
    end
	
	
	if S4 then
	Text =  " Amount (K) : " .. AmountK;
	 width, height = context:measureText (1, Text, 0);
     context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,1+ShiftY+Num,1) ,iX(context,width,0,2),iY(context,height,1+ShiftY+Num,2), 0 );	
	Num=Num+1;
    end
	
	if S5 then
	Text =  " Direction : " .. BS;
	width, height = context:measureText (1, Text, 0);
    context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,1+ShiftY+Num,1) ,iX(context,width,0,2),iY(context,height,1+ShiftY+Num,2), 0 );	
    Num=Num+1;	
    end
	
	if S6 then
	Text =  " PL : " .. PL;
	width, height = context:measureText (1, Text, 0);
    context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,1+ShiftY+Num,1) ,iX(context,width,0,2),iY(context,height,1+ShiftY+Num,2), 0 );	
	Num=Num+1;
    end
	
	if S7 then
	Text = " GrossPL : " .. win32.formatNumber(GrossPL, false, 2) ;
	width, height = context:measureText (1, Text, 0);
    context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,1+ShiftY+Num,1) ,iX(context,width,0,2),iY(context,height,1+ShiftY+Num,2), 0 );	
	Num=Num+1;
    end
	
	 
  
   

end		
 
 

function iX(context, width,Shift,x)

	if X== "Left" then
	return  context:left()+ Shift*width +  width*(x-1) ;
	else
	return context:right() - width*Shift -  width*(1-(x-1));
	end
end

function checkReady(table)
    return core.host:execute("isTableFilled", table);
end

function iY(context, height,Shift,x)

	if Y== "Top" then
		return context:top()+Shift* height + height*(x-1) ;
	else
	return context:bottom()-Shift* height + height*(x-1) ;
	end
end
