-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72049

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Position Profit and Loss");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);


	indicator.parameters:addGroup("Selector"); 
 
	indicator.parameters:addString("Method", "Method", "Method" , "Instrument");
    indicator.parameters:addStringAlternative("Method", "Instrument", "Instrument" , "Instrument");
    indicator.parameters:addStringAlternative("Method", "Account", "Account" , "Account");
	
	indicator.parameters:addBoolean("S1", "Show profit in pips", "", true);
	indicator.parameters:addBoolean("S2", "Show profit", "", true);
	
	indicator.parameters:addGroup("Placement");
 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.COLOR_LABEL ); 
   indicator.parameters:addInteger("Size", "Font Size", "", 10); 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil; 
local font;
local Label;
local Size;
local ShiftY;
local S1, S2;
local Method;
-- Routine
function Prepare(nameOnly) 
	Method=instance.parameters.Method;
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;   
	S1= instance.parameters.S1;
	S2= instance.parameters.S2;

		
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
local Num; 
function Draw(stage, context)


    if stage ~= 2 then
	return;
	end

    if not(checkReady("trades"))  then
        return ;
    end
   
	
	 Enum = core.host:findTable("trades"):enumerator();
     Row = Enum:next();
   
 
 
 
	 local PL=0;
	 local GrossPL=0;
	 
	while (Row ~= nil) do
	
                    if (Row.Instrument == source:instrument() and Method=="Instrument" )  or (Method~="Instrument") then    
					PL=PL+ Row.PL;
 		            GrossPL=GrossPL+ Row.GrossPL;
                    end
	Row = Enum:next();				
    end 
	
   
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
	

	
     
	Num=0;
 
	
	if S1 then
	Text1 =  "PL : "
	Text2 = PL;
    DrawLabel(context, Text1,Text2)	
    end
	
	if S2 then
	Text1 = "GrossPL : "
    Text2= win32.formatNumber(GrossPL, false, 2) ; 
    DrawLabel(context, Text1,Text2)		
    end 

end		
 
 

function DrawLabel(context, Text1,Text2)
   	Num=Num+1;
	width0, height0 = context:measureText (1, "XXXXXXXXXX", 0);
	width, height = context:measureText (1, Text1, 0);
    context:drawText (1,  Text1, Label, -1,  context:right ()- width0  - width  ,  context:top ()+height*(ShiftY+Num) , context:right ()- width0 , context:top () + height*(ShiftY+Num+1), 0 );	

 
 
	width, height = context:measureText (1, Text2, 0);
    context:drawText (1,  Text2, Label, -1,  context:right ()- width0  ,  context:top ()+height*(ShiftY+Num) , context:right ()- width0  + width  , context:top () + height*(ShiftY+Num+1), 0 );	
 
end

function checkReady(table)
    return core.host:execute("isTableFilled", table);
end

 
