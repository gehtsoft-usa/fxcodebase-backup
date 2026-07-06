-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71688

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

--Support that the service we provide to the community be continued onward.
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

function Init()
    indicator:name("THREE CANDLESTICK INDICATOR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	

	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Long", "Long Color", "", core.rgb(0, 255, 0)); 
    indicator.parameters:addColor("Short", "Short Color", "", core.rgb(255, 0, 0)); 	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Short, Long; 
local first;
local source = nil;
 
local Oscillator;  
local TRADE, EXIT; 
-- Routine
 function Prepare(nameOnly)   
 
 
    Long= instance.parameters.Long;
    Short= instance.parameters.Short;
	
	
	local Parameters= "";
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first() +2;
	
    Level = instance:addInternalStream(0, 0); 
   
 
	TRADE = instance:addStream("Trade" , core.Bar, " Trade"," Trade",instance.parameters.Long, first ); 
    TRADE:setPrecision(math.max(2, source:getPrecision()));
	
	EXIT = instance:addStream("EXIT" , core.Bar, " EXIT"," EXIT",instance.parameters.Long, first ); 
    EXIT:setPrecision(math.max(2, source:getPrecision()));	
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end
	
	if source.close[period-2]< source.open[period-2]	
	and source.close[period-1]< source.open[period-1]	 
	and source.close[period]> source.open[period]		
	and source.close[period]> source.high[period-2]	
	then
	TRADE[period]=1;
	TRADE:setColor(period, Long);
	Level[period]=source.low[period];	
	elseif source.close[period-2]> source.open[period-2]	
	and source.close[period-1]> source.open[period-1]	 
	and source.close[period]< source.open[period]		
	and source.close[period]< source.low[period-2]	
	then	
	TRADE[period]=-1;
	TRADE:setColor(period, Short);	
	Level[period]=source.high[period];
	else
	Level[period]=Level[period-1];
	TRADE[period]=0;	
    end	
	
	local Direction, Level= Last(period);
	
	if Direction== 0 then 
	return;
	end
		
	
	if Direction ==1 and  source.close[period]< Level then
	EXIT[period]=2;
	EXIT:setColor(period, Short); 
	end
	
    if Direction ==-1 and  source.close[period]>Level then
	EXIT[period]=-2;
	EXIT:setColor(period, Long); 	
	end				  
				  
end


function Last(period) 
   
   local Return1=0;
   local Return2=0;
   
   for i= period, first, -1 do
   
		if EXIT[i]~= 0 then
		break;
		else
		
 
			   if TRADE[i]==1 then
			   Return1=1;
			   Return2=source.low[i]
			   break;
			   end
			   if TRADE[i]==-1 then
			   Return1=-1;
			   Return2=source.high[i]
			   break;			   
			   end			   
		   
	 
		   
		end
   
    
   end
   
   
   return Return1, Return2
end

