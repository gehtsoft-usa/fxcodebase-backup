-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73254

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
    indicator:name("Fair Value Gaps");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Length", "Box Length", "", 3, 1, 2000);
	
	 indicator.parameters:addGroup("Style");	
	 indicator.parameters:addColor("Up", "Up Box Color", "", core.rgb(128, 128, 128)); 
	 indicator.parameters:addColor("Down", "Down Box Color", "", core.rgb(128, 128, 128)); 
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Length;  
local bullishFvg;
local bearishFvg;
local Transparency;	
-- Routine
 function Prepare(nameOnly)     
	Length=instance.parameters.Length; 
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Length  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	 
	first=source:first()+Length;  
 
	bullishFvg = instance:addInternalStream(0, 0);
	bearishFvg = instance:addInternalStream(0, 0);	
	
	instance:ownerDrawn(true); 
	
end

  
function Update(period, mode) 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	bullishFvg[period]=0;
	bearishFvg[period]=0;
	
	if(source.low[period] > source.high[period-2]) then
	bullishFvg[period]=1;
    end
	if (source.high[period] < source.low[period-2]) then
	bearishFvg[period]=1;	
    end	 
	
end


local init=false;
function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
 
   
    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then 
			context:createSolidBrush(1, instance.parameters.Up);      
			context:createSolidBrush(2, instance.parameters.Down);
            Transparency= context:convertTransparency (instance.parameters.Transparency)
			init = true;			
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
 
	
       
	for i= first, last, 1 do	 
	
		if bullishFvg[i]==1 then 
			visible, y1 = context:pointOfPrice (source.low[i])
			visible, y2 = context:pointOfPrice (source.high[i-2])
			x1, x, x = context:positionOfBar (i);
			x2, x, x = context:positionOfBar (i-Length);	
			context:drawRectangle (-1, 1, x1, y1, x2 , y2, Transparency);
		end
		if bearishFvg[i]==1 then	 
			visible, y1 = context:pointOfPrice (source.low[i-2])
			visible, y2 = context:pointOfPrice (source.high[i])		
			x1, x, x = context:positionOfBar (i);
			x2, x, x = context:positionOfBar (i-Length);			
			context:drawRectangle (-1, 2, x1, y1, x2 , y2, Transparency);			
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