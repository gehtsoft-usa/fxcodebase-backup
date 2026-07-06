-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73545

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
    indicator:name("Dynamic resistance support");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addDouble("Accurency", "Accurency", "", 75, 10, 100); 
    indicator.parameters:addInteger("LookBack", "LookBack", "", 100, 5, 1000); 

 
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	 indicator.parameters:addColor("color1", "Support Line Color", "", core.rgb(0, 255, 0)); 	
	 indicator.parameters:addColor("color2", "Resistance Line Color", "", core.rgb(255, 0, 0)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Accurency,LookBack; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Accurency=instance.parameters.Accurency;
	LookBack=instance.parameters.LookBack;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Accurency.. "," ..  LookBack  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	 
	first=source:first()+1; 
	
	
	Range = instance:addInternalStream(0, 0);
	Sum = instance:addInternalStream(0, 0); 
	
    Support = instance:addStream("Support", core.Line, name, "Support", instance.parameters.color1, first+LookBack );
    Support:setPrecision(math.max(2, instance.source:getPrecision()));
    Support:setWidth(instance.parameters.width);
    Support:setStyle(instance.parameters.style);
 
	
    Resistance = instance:addStream("Resistance", core.Line, name, "Resistance", instance.parameters.color2, first+LookBack );
    Resistance:setPrecision(math.max(2, instance.source:getPrecision()));
    Resistance:setWidth(instance.parameters.width);
    Resistance:setStyle(instance.parameters.style);
   
 
end


function Update(period, mode) 

    Range[period]=source.high[period]-source.low[period];
	Sum[period]=Range[period];
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
    Sum[period]=Sum[period-1]+Range[period];
    local AvgCandleHeight=Sum[period]/period;
	
	if(Range[period]>AvgCandleHeight*2.0) then
    isNormalCandle=false;
	else
	isNormalCandle=true;
 	end
	



	if period <= first+LookBack
	or  not source:hasData(period) 
	then
	return;
	end


	
	local  matches=0;
    local matchSumUpper=0.0;
    local matchSumLower=0.0; 
	  
	Support[period]=Support[period-1];
	Resistance[period]=Resistance[period-1];
	
	if isNormalCandle then
	
	
		local Upper=source.high[period]+AvgCandleHeight;
        local Lower=source.low[period]-AvgCandleHeight;
	
			for i= period, period-LookBack+1 , -1 do
			  
				 if(source.high[i]<=Upper and source.low[i]>=Lower) then
				 
					matches=matches+1;
					matchSumUpper=matchSumUpper+source.high[i];
					matchSumLower=matchSumLower+source.low[i];
				 end
			end
			
			
		if(matches/LookBack*100>=Accurency) then
				
					 local matchAvgUpper=matchSumUpper/matches;
					 local matchAvgLower=matchSumLower/matches;
					 
					 if(matchAvgUpper>Resistance[period] or matchAvgLower<Support[period]) then
					  
						Resistance[period]=matchAvgUpper+AvgCandleHeight;
						Support[period]=matchAvgLower-AvgCandleHeight;
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