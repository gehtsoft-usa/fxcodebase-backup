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
    indicator:name("Pipq");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addBoolean("Signal", "Signal Mode", "", false); 	
    indicator.parameters:addDouble("Pips", "Pips", "", 65, 1, 2000); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000); 
    indicator.parameters:addDouble("ATRmultiplier", "ATR Multiplier", "", 0.45, 0, 100);	
	
	
	
	indicator.parameters:addGroup("Line Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
    indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	

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
	Period=instance.parameters.Period;
	ATRmultiplier=instance.parameters.ATRmultiplier;
	Signal=instance.parameters.Signal;
	
	source = instance.source;
    Bid = core.host:execute("getBidPrice");
    Ask = core.host:execute("getAskPrice");	
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Pips  .. ", " ..  Period  .. ", " ..  ATRmultiplier.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	ATR= core.indicators:create("ATR", source, Period);
	first=ATR.DATA:first()  ; 
	
	
	StopLevel = instance:addInternalStream(0, 0);
 
 	if Signal then
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.clrUP, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	
	else
    Bar = instance:addInternalStream(0, 0);	
	end
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);
 
end


function Update(period, mode)

	ATR:update(mode); 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
    up:setNoData(period);
    down:setNoData(period);	



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
 
	
	
    if period <= 4 then
	return;
	end
	
    local min, max=mathex.minmax(source, period-4+1, period);


	
	if( source.close[period] > StopLevel[period] and  (source.close[period-1]<StopLevel[period-1] or (source.close[period-1]<=StopLevel[period-1] and source.close[period-2]<StopLevel[period-2])))  then
		 

	 
				   atrstop = StopLevel[period]-ATR.DATA[period]*ATRmultiplier;
				   
				   if (atrstop > min) then min = atrstop end 
			 
				   if ((Bid[period] > StopLevel[period]) and  (source.close[period-1]<=StopLevel[period-1]) ) then
					up:set(period,min, "\217",min);	
					Bar[period]= 1;	 
                   end
	end 

	if( source.close[period] < StopLevel[period] and  (source.close[period-1]>StopLevel[period-1] or (source.close[period-1]>=StopLevel[period-1] and source.close[period-2]>=StopLevel[period-2])))   then
		 

	 
				   atrstop = StopLevel[period]+ATR.DATA[period]*ATRmultiplier;
				   
				   if (atrstop < max) then max =atrstop; end
				 
				   if ( (Ask[period] < StopLevel[period]) and  (source.close[period-1]>=StopLevel[period-1])) then	
					Bar[period]= -1;
					down:set(period, max, "\218",max);						   
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