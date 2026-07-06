-- More information about this indicator can be found at:
-- http://fxcodebase.com

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
    indicator:name("Every Little Bit Helps");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period", "Fast MA", "", 14, 1, 2000);
 
    indicator.parameters:addString("Price1", "1. Line Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");		
	
    indicator.parameters:addString("Price2", "2. Line Price Source", "", "median");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");		
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
	 
	indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	Price1=instance.parameters.Price1;
	Price2=instance.parameters.Price2;
    Transparency= instance.parameters.Transparency;
    Transparency= 100-Transparency;	
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period .. "," ..  Price1.. "," ..  Price2 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator1= core.indicators:create("RSI", source[Price1], Period);
	Indicator2= core.indicators:create("RSI", source[Price2], Period);	
	first=Indicator1.DATA:first() ; 
	
	
	--Stream = instance:addInternalStream(0, 0);
 
	
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
	
 
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
	
	
	instance:createChannelGroup("Group","Group" , Line1, Line2, instance.parameters.color1, Transparency);	

end


function Update(period, mode)

	Indicator1:update(mode); 
	Indicator2:update(mode); 
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	  	
	Line1[period]= Indicator1.DATA[period];
	Line2[period]= Indicator2.DATA[period];	
	
 	if period <= first + Period
	or  not source:hasData(period) 
	then
	return;
	end   
	
	
    	
	local color=Coloring ((Line1[period]+Line2[period])/2, false)
	Line1:setColor(period, color);		
end

function Coloring (value, revers)

	if value <= 50 then
	   r = 255
	   g = 255*value/50
	   b = 0
	else 
	   r = 255*(100-value)/50
	   g = 255
	   b = 0
	end
	
	if revers then
	 r, g = g, r
	end
	
return  core.rgb(r, g, 0); 
end
  
function Coloring1 (value, mid)

local color =  core.rgb(255-(255/100)*value, (255/100)*value, 0)
 
return  color; 
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