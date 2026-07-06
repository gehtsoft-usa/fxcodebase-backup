-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72860

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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
    indicator:name("Trend Corrected EMA");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Length", "", 20, 2, 2000);
    indicator.parameters:addBoolean("add_t1", "Use Trend", "", true);
    indicator.parameters:addBoolean("add_t2", "Use Trend of Trend", "", true);
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Length, add_t1, add_t2; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Length=instance.parameters.Length;
	add_t1=instance.parameters.add_t1;
	add_t2=instance.parameters.add_t2; 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Length   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	
	s = instance:addInternalStream(0, 0);
    EMA= core.indicators:create("EMA", s, Length );
    EMAP= core.indicators:create("EMA", s, Length+1 );
    EMAM= core.indicators:create("EMA", s, Length-1 );	
	
	first=EMAP.DATA:first() ; 	
 	
	t0 = instance:addInternalStream(0, 0);
	t1 = instance:addInternalStream(0, 0);
	t2 = instance:addInternalStream(0, 0);	
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)


    s[period] = math.log(source[period])


	 if period <= first then
	 return;
	 end
	  
	EMA:update(mode); 
	EMAP:update(mode); 
	EMAM:update(mode); 

    local t0=EMA.DATA[period];
	local t1= (EMAM.DATA[period] - EMAP.DATA[period]) / (2*1)
	local t2 = (EMAM.DATA[period] - 2 * t0 + EMAP.DATA[period]) / math.pow(1,2)
	
	
	if add_t2 then 
	T2=t2/2 
	else
	T2=0
	end
	
	if add_t1 then	
	T1=(t1 + T2 * Length) * Length 
	else
	T1=0
	end
	
	Line[period]= math.exp(t0 + T1)
	
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
