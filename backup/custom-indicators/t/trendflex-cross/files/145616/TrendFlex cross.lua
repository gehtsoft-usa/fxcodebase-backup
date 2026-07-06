-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72064

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

--Your donations will allow the service to continue onward.
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
    indicator:name("TrendFlex cross");
    indicator:description("");
    indicator:requiredSource(core.Tick); 
    indicator:type(core.Oscillator);
	
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("inpFastPeriod", "Fast trend-flex period", "", 20, 1, 2000);
    indicator.parameters:addInteger("inpSlowPeriod", "Slow trend-flex period", "", 50, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Up", "Up Slope Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("Down", "Down Slope Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local inpFastPeriod, inpSlowPeriod; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	inpFastPeriod=instance.parameters.inpFastPeriod;
	inpSlowPeriod=instance.parameters.inpSlowPeriod;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  inpFastPeriod.. "," ..  inpSlowPeriod  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	first=source:first()+math.max(inpFastPeriod,inpSlowPeriod ) ; 
	 

    ms={};	
    ms[1] = instance:addInternalStream(0, 0);
    ms[2] = instance:addInternalStream(0, 0);
	
	sum={};	
    sum[1] = instance:addInternalStream(0, 0);
    sum[2] = instance:addInternalStream(0, 0);
	
	ssm={};	
    ssm[1] = instance:addInternalStream(0, 0);
    ssm[2] = instance:addInternalStream(0, 0);
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.Up, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode) 

	 if period <= first then
	 return;
	 end
	 
 
	

	Line[period]= Calculate (period, inpFastPeriod, 1 )-Calculate (period, inpSlowPeriod,2);
	
	if Line[period]> Line[period-1] then
	Line:setColor(period,  instance.parameters.Up);	
	else
	Line:setColor(period,  instance.parameters.Down);	
	end	
end


function Calculate (period, Period, Index)

	local a1 = math.exp(-1.414*math.pi/Period);
	local b1 = 2.0*a1*math.cos(1.414*math.pi/Period);
	local m_c2 = b1;
	local m_c3 = -a1*a1;
	local m_c1 = 1.0 - m_c2 - m_c3;
	
	
	
       
            if (period>2) then
            ssm[Index][period] = m_c1*(source[period]+source[period-1])/2.0 + m_c2*ssm[Index][period-1] + m_c3*ssm[Index][period-2];
			else 
			ssm[Index][period] = source[period];
			end
               
			   

			
            if (period>Period) then
                 sum[Index][period] = sum[Index][period-1]+ ssm[Index][period] - ssm[Index][period-Period];
            else
                                
								 
                sum[Index][period] = ssm[Index][period]+mathex.sum(ssm[Index], period-Period+1, period);
	 
            end
               local  sum   = Period*ssm[Index][period]- sum[Index][period];
                      sum   =sum/ Period;


 
               if period > 1 then
			   ms[Index][period] =  0.04 * sum*sum+0.96*ms[Index][period-1]  
			   else
			   ms[Index][period]=0;
			   end
			   
			    
			   if ms[Index][period]~= 0 then			   
               return sum/math.sqrt(ms[Index][period])  
	           else
			   return 0;
			   end
			   
	
end	