-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73996

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Custom Period Separators");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);


	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Start", "Start Time (As Hour)" , "", 17, 0, 24);	
	indicator.parameters:addInteger("Interval", "Interval (As Hour)", "", 24, 0, 10000);		
	 
   
   indicator.parameters:addGroup( "Line Style"); 
    indicator.parameters:addColor("Color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
 
 
end

 
 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
 
local first;
local source = nil;
 

local Color; 
local Width; 
local Style; 

local Start, Interval;
local Hour=1/24;
local Shift;

local First=false;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	

    
	
         Start=instance.parameters.Start;
		 Interval=instance.parameters.Interval;
		 
		 Shift=Hour*Interval;
		
		 Color=instance.parameters:getColor("Color" );
		 Width=instance.parameters:getInteger("Width" );
		 Style=instance.parameters:getInteger("Style");
		
	
	
	 
    source = instance.source;
    first=source:first();
 
    instance:ownerDrawn(true);
	
	First=false
	 
end
 
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values


function Update(period)   

   if period <=first then
   First=false;  
   end
   
   
   
   local datetable=core.dateToTable (source:date(period));
   
   
   if not First and datetable.hour == Start then
   FirstInstance= source:date(period); 
   First=true;
   end
   
   

   
end




local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2 then
	  return;
	  end
	
        if not init then
         
            init = true;
 
				context:createPen (1, context:convertPenStyle (Style), context:pointsToPixels (Width), Color) 
				 
			
        end
		
	local N=0;
	
    while true do	  
	x, x1, x2 = context:positionOfDate (FirstInstance+N*Shift);
	context:drawLine (1, x, context:top (), x, context:bottom ());
	N=N+1;
	
		if  FirstInstance+N*Shift > source:date(source:size()-1) then
		break;	
		end
	end
	 
end		
 
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

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