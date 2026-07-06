-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73105

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
    indicator:name("WSO WRO");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Length", "Length", "", 9, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "WSO Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "WRO Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Length, Center; 
local S={};		  
local R={};
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Length=instance.parameters.Length;  
	Center = (Length-1)/2;
	
	 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Length  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first()+Length ; 
	
	
	for i= 1, 6, 1 do 
	S[i] = instance:addInternalStream(0, 0);
	R[i] = instance:addInternalStream(0, 0); 	
	end
	
    WSO = instance:addStream("WSO", core.Line, name, "WSO", instance.parameters.color1, first );
    WSO:setPrecision(math.max(2, instance.source:getPrecision()));
    WSO:setWidth(instance.parameters.width);
    WSO:setStyle(instance.parameters.style);
    WSO:addLevel(0);	
	
	WRO = instance:addStream("WRO", core.Line, name, "WRO", instance.parameters.color2, first );
    WRO:setPrecision(math.max(2, instance.source:getPrecision()));
    WRO:setWidth(instance.parameters.width);
    WRO:setStyle(instance.parameters.style);
    WRO:addLevel(0);
 
end


function Update(period, mode)

	 -- Indicator:update(mode); 
	 
	 
	for i= 1, 6, 1 do 
    S[i][period]   = source.low[period];
    R[i][period] = source.high[period]; 
	end 

	 if period <= first then
	 return;
	 end
	  
	
    local min, max, minpos, maxpos = mathex.minmax(source, period-Length+1, period);

   --= iLowest(NULL,0,MODE_LOW,Length,i)-i;
    --     int highest = iHighest(NULL,0,MODE_HIGH,Length,i)-i;	 
		 
	  

		for i= 1, 6, 1 do 
		S[i][period]  = S[i][period-1]; 
		R[i][period]  = R[i][period-1]; 
		end 
	 
		 
	 if (minpos==period -Center) then       
            S[1][period] = min;
            S[2][period] = S[1][period-1];
            S[3][period] = S[2][period-1];
            S[4][period] = S[3][period-1];
            S[5][period] = S[4][period-1];
            S[6][period] = S[5][period-1];
      end  
         if (maxpos==period -Center) then
       
            R[1][period] = max;
            R[2][period] = R[1][period-1];
            R[3][period] = R[2][period-1];
            R[4][period] = R[3][period-1];
            R[5][period] = R[4][period-1];
            R[6][period] = R[5][period-1];
      end


	
    WSO[period]=100*(1-(MathInt(S[1][period]/source.close[period])+ MathInt(S[2][period]/source.close[period])+ MathInt(S[3][period]/source.close[period])+MathInt(S[4][period]/source.close[period])+MathInt(S[5][period]/source.close[period])+MathInt(S[6][period]/source.close[period]))/6.0 ); 
    WRO[period]=100*(1-(MathInt(R[1][period]/source.close[period])+ MathInt(R[2][period]/source.close[period])+ MathInt(R[3][period]/source.close[period])+ MathInt(R[4][period]/source.close[period])+ MathInt(R[5][period]/source.close[period])+ MathInt(R[6][period]/source.close[period]))/6.0) ;

 
end

 
 
function MathInt( number)
  
    if(number>=1.0) then
    return(1);
	else  
    return(0);
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