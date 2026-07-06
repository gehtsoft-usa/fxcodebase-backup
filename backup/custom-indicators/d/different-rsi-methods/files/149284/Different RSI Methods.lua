-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73269

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
    indicator:name("Different RSI Methods");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 	indicator.parameters:addString("Method", "RSI Method", "Method" , "Regular");
    indicator.parameters:addStringAlternative("Method", "Regular", "" , "Regular");
    indicator.parameters:addStringAlternative("Method", "Slow", "" , "Slow"); 
    indicator.parameters:addStringAlternative("Method", "Harris", "" , "Harris");
    indicator.parameters:addStringAlternative("Method", "RSX", "" , "RSX");
    indicator.parameters:addStringAlternative("Method", "Cuttlers", "" , "Cuttlers");
 
 
    indicator.parameters:addInteger("Period1", "1. Period", "", 6, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. Period", "", 14, 1, 2000); 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 255)); 
	 
    indicator.parameters:addGroup("Levels");

    indicator.parameters:addDouble("Level1", "1. Level","", 30);
	indicator.parameters:addDouble("Level2", "2. Level","", 50);
	indicator.parameters:addDouble("Level3", "3. Level","", 70); 
	
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID)	 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1,Period2, Method; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;	
	Method=instance.parameters.Method; 
 
				
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2.. "," ..  Method  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	rsi= core.indicators:create("RSI", source, Period1);
	ema= core.indicators:create("EMA", source, Period1);
	first=source:first() +Period1; 
	
	
	Up = instance:addInternalStream(0, 0);
	Down = instance:addInternalStream(0, 0);
	MA_Up = instance:addInternalStream(0, 0);
	MA_Down = instance:addInternalStream(0, 0);	


	f18 = 3.0 / (Period1 + 2.0)	
	f20 = 1.0 - f18	
	
	f90 = instance:addInternalStream(0, 0);
    f88= instance:addInternalStream(0, 0);
	f0= instance:addInternalStream(0, 0);
	v14= instance:addInternalStream(0, 0); 
	v20= instance:addInternalStream(0, 0);
	f8= instance:addInternalStream(0, 0);
	f28= instance:addInternalStream(0, 0);
	f30= instance:addInternalStream(0, 0);
	f38= instance:addInternalStream(0, 0);
	f40= instance:addInternalStream(0, 0);	
	f48= instance:addInternalStream(0, 0);
	f50= instance:addInternalStream(0, 0);	
	f58= instance:addInternalStream(0, 0);
	f60= instance:addInternalStream(0, 0);	
	f68= instance:addInternalStream(0, 0);
	f70= instance:addInternalStream(0, 0);	
	f78= instance:addInternalStream(0, 0);
    f80= instance:addInternalStream(0, 0);
	
    RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.color, first );
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
    RSI:setWidth(instance.parameters.width);
    RSI:setStyle(instance.parameters.style);
	
	
 
	RSI:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	RSI:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	RSI:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
 



 
end


function Update(period, mode)

	rsi:update(mode); 
	ema:update(mode); 
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	 
	 
	if Method == "Regular" and period >= rsi.DATA[period] then
	RSI[period]= rsi.DATA[period];	
	elseif Method == "Slow" and period >= Period1 then
	
	
	  
			
			if source[period] > ema.DATA[period] then
			Up[period]=source[period] - ema.DATA[period]
			else
			Up[period]=0			
			end
			
			if   source[period] < ema.DATA[period] then
			Down[period]= ema.DATA[period] - source[period]
			else
            Down[period]=0;			
			end  
             
        
              
            MA_Up[period]=(Up[period] +  MA_Up[period-1] * (Period2-1))/Period2    
            MA_Down[period]=(Down[period] +  MA_Down[period-1] * (Period2-1))/Period2   		
			
			RSI[period] = 100 - ( 100 / ( 1 + ( MA_Up[period] / MA_Down[period] ) ) )
       
		 
	elseif Method == "Harris" and period >= Period1 then
	
	
		local up = 0.0
		local down = 0.0
		local avgerageUp = 0.0
		local avgerageDown = 0.0
			for k = 1, Period1, 1 do
				local   difference = source[period-k] - source[period-k+1] 
				if(difference > 0.) then 
					avgerageUp = avgerageUp+difference 
					up =up+ 1
				else   
					avgerageDown =avgerageDown- difference 
					down =down+ 1
				end 
			end 
	    
			if up ~= 0.0 then
			avgerageUp = avgerageUp/up 
			else
			avgerageUp = avgerageUp
			end
			
		    if down ~= 0.0 then 
			avgerageDown = avgerageDown/down 
			else
			avgerageDown = avgerageDown
		    end
		
			if avgerageDown ~= 0. then
			RS=avgerageUp / avgerageDown
			else
			RS=1;
			end 
		
        RSI[period] = 100-100 / (1.0 + RS)
	elseif Method == "Cuttlers" and period >= Period1 then
	
	  local  sump = 0.
	  local  sumn = 0.
            for k = 1 , Period1, 1 do
                 local diff = source[period-k] - source[period-k+1] 
                if (diff > 0.)  then
                    sump = sump+diff
                elseif (diff < 0.) then
                    sumn =sumn- diff
			    end
			end		
			
			if sumn > 0. then		
            RSI[period] =    100. - 100. / (1. + sump / sumn) 
			else
			RSI[period] =50.
			end
			
    elseif Method == "RSX" and period >= Period1 then
				
				f88[period]=f88[period-1];
				f90[period]=f90[period-1];
				f0[period]=f0[period-1];
				v14[period]=v14[period-1];	
				v20[period]=v20[period-1];
				f8[period]=f8[period-1];
			 
				if (f90[period] == 0.0) then
				f90[period] = 1.0
				f0[period] = 0.0
						if (Period1-1 >= 5) then 
						f88[period] = Period1-1.0
						else 
						f88[period] = 5.0
						end
				f8[period] = 100.0*(source[period])


				else
				
						if (f88[period] <= f90[period]) then 
						f90[period] = f88[period] + 1
						else
						f90[period] = f90[period] + 1
						end

				 
						f10 = f8[period]
						f8[period] = 100*source[period];
						v8 = f8[period] - f10
						f28[period] = f20 * f28[period-1] + f18 * v8
						f30[period] = f18 * f28[period] + f20 * f30[period-1]
						vC = f28[period] * 1.5 - f30[period] * 0.5
						f38[period] = f20 * f38[period-1] + f18 * vC
						f40[period] = f18 * f38[period] + f20 * f40[period-1]
						v10 = f38[period] * 1.5 - f40[period] * 0.5
						f48[period] = f20 * f48[period-1] + f18 * v10
						f50[period] = f18 * f48[period] + f20 * f50[period-1]
						v14[period] = f48[period] * 1.5 - f50[period] * 0.5
						f58[period] = f20 * f58[period-1] + f18 * math.abs(v8)
						f60[period] = f18 * f58[period] + f20 * f60[period-1]
						v18 = f58[period] * 1.5 - f60[period] * 0.5
						f68[period] = f20 * f68[period-1] + f18 * v18
						f70[period] = f18 * f68[period] + f20* f70[period-1]			
						v1C = f68[period] * 1.5 - f70[period] * 0.5
						f78[period] = f20 * f78[period-1] + f18 * v1C
						f80[period] = f18 * f78[period] + f20 * f80[period-1]
						v20[period] = f78[period] * 1.5 - f80[period] * 0.5  
						
						if ((f88[period] >= f90[period]) and (f8[period] ~= f10)) then 
						 f0[period] = 1.0
						end 
						if ((f88[period] == f90[period]) and (f0[period] == 0.0)) then 
						f90[period] = 0.0
						end 
     end 
	
		if ((f88[period] < f90[period]) and (v20[period] > 0.0000000001)) then 
		 
		RSI[period] = (v14[period] / v20[period] + 1.0) * 50.0
				if (RSI[period] > 100.0) then 
				RSI[period] = 100.0
				end 
				if (RSI[period] < 0.0) then 
				RSI[period] = 0.0
				end 
		else 
		RSI[period] = 50.0
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