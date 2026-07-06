-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71340

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Account Mathematics Instrument");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Selector");
    local Labels={"Spread", "PipCost", "MMR", "IntrS", "IntrB", "100$ Potential"};		
	for i=1 ,#Labels , 1 do
    indicator.parameters:addBoolean("Show"..i, "Show ".. Labels[i], "", true);
    end
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.COLOR_LABEL ); 
   indicator.parameters:addInteger("Size", "Font Size", "", 20); 
 
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
local Labels={"Spread", "PipCost", "MMR", "IntrS", "IntrB", "100$ Potential"};	
local Data={};
local Number;

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;   
    source = instance.source;
    first=source:first();
 
    instance:ownerDrawn(true);
	
	Number=0;
	if  instance.parameters.Show1 then	
	Number=Number+1;
	Ask = core.host:findTable("offers"):find("Instrument", source:instrument()).Ask;
	Bid = core.host:findTable("offers"):find("Instrument", source:instrument()).Bid;
    Data[Number]  =string.format("%." .. 5 .. "f", Ask  - Bid);	
    end
	if  instance.parameters.Show2 then
	Number=Number+1;
	Data[Number] = core.host:findTable("offers"):find("Instrument", source:instrument()).PipCost;
	end
    if  instance.parameters.Show3    then
	Number=Number+1;
    Data[Number]= core.host:findTable("offers"):find("Instrument", source:instrument()).MMR;
	end
	if  instance.parameters.Show4 then
	Number=Number+1;	
    Data[Number]= core.host:findTable("offers"):find("Instrument", source:instrument()).IntrS;
	end
	if  instance.parameters.Show5 then
	Number=Number+1;	
    Data[Number]= core.host:findTable("offers"):find("Instrument", source:instrument()).IntrB;	
	end
	
	
	if  instance.parameters.Show6 then
	Number=Number+1;	
    Data[Number]= (100 / core.host:findTable("offers"):find("Instrument", source:instrument()).MMR)* core.host:findTable("offers"):find("Instrument", source:instrument()).PipCost;
	Data[Number]=string.format("%." .. 2 .. "f", Data[Number]);	
	end
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
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
   local Text;
   for i= 1, Number, 1 do 
   Text= Labels[i] .. " : " ..  Data[i]
   width, height = context:measureText (1,Text, 0);
   context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   end

end		
 
 

function iX(context, width,Shift,x)

	if X== "Left" then
	return  context:left()+ Shift*width +  width*(x-1) ;
	else
	return context:right() - width*Shift -  width*(1-(x-1));
	end
end



function iY(context, height,Index , Line)

	if Y== "Top" then
		return context:top()+Index*height +ShiftY*height + Line *height;
	else
		if Line== 1 then
		return context:bottom()-(Index+1)*height -ShiftY*height + height;
		else
		return context:bottom()-(Index+1)*height -ShiftY*height;
		end
	end
end
 