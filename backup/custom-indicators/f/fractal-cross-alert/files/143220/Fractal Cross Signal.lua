-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71419

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

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams


 


function Init()
    indicator:name("Fractal Cross Signal");
    indicator:description("");
   indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
    
  indicator.parameters:addGroup("Calculation");		
    indicator.parameters:addDouble("Tolerance", "Tolerance in Pips", "", 0 ); 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("up_color", "Up Color", "", core.rgb(0, 255, 0)); 
    indicator.parameters:addColor("down_color", "Down Color", "", core.rgb(255, 0, 0));  
	 
end
 

local first;
local source = nil;

local Tolerance;
local up, down;

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 

     
	source = instance.source; 

 
	 -- Create short and long EMAs for the source 
	
	first=source:first();
    Tolerance= instance.parameters.Tolerance*source:pipSize();
	
    up = instance:addInternalStream(0, 0);
	down= instance:addInternalStream(0, 0);	
	
	Up = instance:addStream("up" , core.Bar, " up"," up",instance.parameters.up_color, first ); 
    Up:setPrecision(math.max(2, source:getPrecision()));

	Down = instance:addStream("down" , core.Bar, " down"," down",instance.parameters.down_color, first ); 
    Down:setPrecision(math.max(2, source:getPrecision())); 
end 
 
	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 


      if (period < 6) then
	  return;
	  end
	  
        local curr = source.high[period - 2];
        if (curr > source.high[period - 4] and curr > source.high[period - 3] and
            curr > source.high[period - 1] and curr > source.high[period]) then
            up[period - 2]=1;
            
        else
             up[period - 2]=0;
        end
        curr = source.low[period - 2];
        if (curr < source.low[period - 4] and curr < source.low[period - 3] and
            curr < source.low[period - 1] and curr < source.low[period]) then 
            down[period - 2]=1;
        else
            down[period - 2]=0;
        end
    

    Signal_Logic ( period)
end


function FindLast(period)

local Return1, Return2=0,0;


		for i= period, first, -1 do


			if Return1==0 and up[i]== 1 then
			Return1=i;
			end
			
			if Return2==0 and down[i]== 1 then
			Return2=i;
			end
		   
			if Return1~= 0 and  Return2 ~= 0 then
			break;
			end

		end

return Return1, Return2;

end
 


function Signal_Logic ( period)


       
       Top, Bottom= FindLast(period);
	
	  
			if  source.close[period] > (source.high[Top]-Tolerance)
			and  source.close[period-1] <= (source.high[Top]-Tolerance)
			then
			           
						    
         
                Up[period]= 1;	
 	   
					
						   							  
			elseif  source.close[period] < (source.low[Bottom]+Tolerance)
			and  source.close[period-1] >= (source.low[Bottom]+Tolerance)
            then			
		 
						   
		  
		     Up[period]= 0;
			                
	         end
			
	   
		
 
		 
			if  source.close[period] < (source.low[Bottom]+Tolerance)
			and  source.close[period-1] >= (source.low[Bottom]+Tolerance)
			then
			           
						    
         
                Down[period]= 1;	
 	 	   
			
						   
							  							  
			elseif  source.close[period] > (source.high[Top]-Tolerance)
			and  source.close[period-1] <= (source.high[Top]-Tolerance)
            then			
  
		 
		     Down[period]= 0;
			end               
	 
			
	 

end
 



 


  