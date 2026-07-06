-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73723

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
    indicator:name("Trendlines with Breaks");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("length", "Length", "", 14, 1, 2000);
    indicator.parameters:addInteger("break_length", "Break Length", "", 100, 1, 2000);	
    indicator.parameters:addDouble("K", "K", "", 1, 0, 2000);
	indicator.parameters:addBoolean("Continuation", "Trend Continuation", "", false);
	
	indicator.parameters:addString("Method", "Slope Calculation Method", "Method" , "Atr");
    indicator.parameters:addStringAlternative("Method", "Stdev", "Stdev" , "Stdev");
    indicator.parameters:addStringAlternative("Method", "Atr", "Atr" , "Atr")
    indicator.parameters:addStringAlternative("Method", "Linreg", "Linreg" , "Linreg")	
	
	 
	
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
local length,K ,Method, break_length;  
	
-- Routine
 function Prepare(nameOnly)   
 
    
	length=instance.parameters.length;
	K=instance.parameters.K;  
	Method=instance.parameters.Method;
	break_length=instance.parameters.break_length;
	Continuation=instance.parameters.Continuation;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  length.. "," ..  K  .. "," ..   Method .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	ATR= core.indicators:create("ATR", source, length);
	first=ATR.DATA:first()+length*2; 
	
	
	slope_ph = instance:addInternalStream(0, 0);
	slope_pl = instance:addInternalStream(0, 0); 
	count_ph = instance:addInternalStream(0, 0);
	count_pl = instance:addInternalStream(0, 0); 	
	
    upper = instance:addStream("upper", core.Line, name, "upper", instance.parameters.color, first );
    upper:setPrecision(math.max(2, instance.source:getPrecision()));
    upper:setWidth(instance.parameters.width);
    upper:setStyle(instance.parameters.style); 


    lower = instance:addStream("lower", core.Line, name, "lower", instance.parameters.color, first );
    lower:setPrecision(math.max(2, instance.source:getPrecision()));
    lower:setWidth(instance.parameters.width);
    lower:setStyle(instance.parameters.style); 
end


function Update(period, mode)

	ATR:update(mode); 
	
	period=period-length;

	if period <= first 
	or  not source:hasData(period) 
	then
	return;
	end
	
	
	local ph=Up(period);
	local pl=Down(period); 
	  
    if 	Method == "Atr" then
	slope = ATR.DATA[period]/length*K;	
    elseif 	Method == "Stdev" then
	slope = mathex.stdev(source.close, period -length+1, period)/length*K;	
	elseif 	Method == "Linreg" then
	slope = math.abs(mathex.lregSlope(source.close, period -length+1, period))/length*K;	 
	end

    if (ph==1 and not Continuation) or (ph==1  and not upper:hasData(period-1) and Continuation) then
	slope_ph[period]=slope 
	count_ph[period]=1; 
    elseif ph==1  and Continuation  and upper:hasData(period-1) then
	slope_ph[period]=slope_ph[period-1] 
	count_ph[period]=1;	
    else	
	slope_ph[period]=slope_ph[period-1] 
	count_ph[period]=count_ph[period-1]+1;
	end
	

   
    if (pl==1  and not Continuation) or (pl==1  and not lower:hasData(period-1) and Continuation) then 
	slope_pl[period]=slope 
	count_pl[period]=1;	
    elseif pl==1  and Continuation  and lower:hasData(period-1)  then 
	slope_pl[period]=slope_pl[period-1] 
	count_pl[period]=1;	
	else
	slope_pl[period]=slope_pl[period-1]
	count_pl[period]=count_pl[period-1]+1;	
    end
	
	

	
		if  count_ph[period] < break_length then
		upper[period]=upper[period-1] - slope_ph[period]
		end
		
		
		if  count_pl[period] < break_length then	
		lower[period]=lower[period-1] + slope_pl[period]
		end
		
	 
		if (ph ==1 and not Continuation ) or (ph ==1 and not upper:hasData(period-1)and Continuation)     then
		upper[period]=source.high[period];  
		end
		
		if (pl ==1 and not Continuation) or (pl ==1 and not lower:hasData(period-1) and Continuation)   then 
		lower[period]=source.low[period]; 
		end		
		
		

		
		if source.close[period]< lower[period] then  
		count_pl[period] = break_length
 	    end
		

		if source.close[period]>upper[period] then  
		count_ph[period] = break_length
 	    end		
		
	if upper[period]> upper[period-1]  or ph == 1 then  
	upper:setBreak(period, true)
    end
	
	if lower[period]< lower[period-1] or pl == 1 then 	
	lower:setBreak(period, true) 
	end
	
    
	
 
end

 


function Up(x) 
  local curr = source.high[x];
	local Return =1  
		
         for i= 1, length, 1 do
		
		     if  curr < source.high[x + i] or curr < source.high[x  - i]  then
			 Return=0;
			 break;
			 end 
		 end	
	return Return;
end	
		 
function Down(x) 
  local curr = source.low[x];
	local Return =1  
		
         for i= 1, length, 1 do
		
		     if  curr > source.low[x + i] or curr > source.low[x  - i]  then
			 Return=0;
			 break;
			 end 
		 end	
	return Return;
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