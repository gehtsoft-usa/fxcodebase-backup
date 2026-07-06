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
    indicator:name("Pipq StopLevel");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addDouble("Pips", "Pips", "", 65, 1, 2000); 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Pips;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Pips=instance.parameters.Pips;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Pips.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first()+1 ; 
	
	
	 
 
	
	
    StopLevel = instance:addStream("StopLevel", core.Line, name, "StopLevel", instance.parameters.color, first );
    StopLevel:setPrecision(math.max(2, instance.source:getPrecision()));
    StopLevel:setWidth(instance.parameters.width);
    StopLevel:setStyle(instance.parameters.style);
    StopLevel:addLevel(0);	
 
end


function Update(period, mode)

	--Indicator:update(mode); 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	
   if( (source.close[period] == StopLevel[period-1]) ) then  
 
      StopLevel[period]=StopLevel[period-1];
      
   else 
      
      if( (source.close[period-1])<=StopLevel[period-1] and (source.close[period]<StopLevel[period-1])  ) then
  
         StopLevel[period]=math.min(StopLevel[period-1],source.close[period]+Pips*source:pipSize());
         
    elseif( ((source.close[period-1])>=StopLevel[period-1]) and (source.close[period]>StopLevel[period-1]) ) then 
				
				StopLevel[period]=math.max(StopLevel[period-1],source.close[period]-Pips*source:pipSize());
			   
	else 
				
					if( (source.close[period]>StopLevel[period-1]) )  then
									   
					   StopLevel[period]=source.close[period]-Pips*source:pipSize();
					  

					else 
					StopLevel[period]=source.close[period]+Pips*source:pipSize();
					end
			 end
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