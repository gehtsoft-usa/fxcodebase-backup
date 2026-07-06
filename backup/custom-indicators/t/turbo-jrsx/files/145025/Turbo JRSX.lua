-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71879

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
    indicator:name("Turbo JRSX");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("Len", "Period", "", 14, 1, 2000);
    indicator.parameters:addDouble("UpperLevel", "Upper Level", "", 70, 1, 2000);
    indicator.parameters:addDouble("LowerLevel", "Lower Level", "", 30, 1, 2000);
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	
	 indicator.parameters:addColor("Up", "OB Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("Down", "OS Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("Neutral", "Bat Color", "", core.rgb(0, 0, 255)); 	 
    indicator.parameters:addGroup("Levels");	 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);			 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local UpperLevel, LowerLevel,Len; 
local Indicator;
	
local f90;
local f0;
local f88;
local f8;
local f18;	
local f20;	
-- Routine
 function Prepare(nameOnly)   
 
    
	UpperLevel=instance.parameters.UpperLevel;
	LowerLevel=instance.parameters.LowerLevel;
	Len=instance.parameters.Len;
	source = instance.source
	
    f28 = instance:addInternalStream(0, 0);	  
    f30 = instance:addInternalStream(0, 0);	 
    f38 = instance:addInternalStream(0, 0);	 
    f40 = instance:addInternalStream(0, 0);	 
    f48 = instance:addInternalStream(0, 0);	 
    f50 = instance:addInternalStream(0, 0);	 
    f58 = instance:addInternalStream(0, 0);	 	
    f60 = instance:addInternalStream(0, 0);	 
    f68 = instance:addInternalStream(0, 0);
    f70 = instance:addInternalStream(0, 0);	
    f78 = instance:addInternalStream(0, 0);
    f80 = instance:addInternalStream(0, 0);		 

    f90 = instance:addInternalStream(0, 0);
    f0 = instance:addInternalStream(0, 0);		

	if (Len-1 >= 5) then f88 = Len-1.0; else f88 = 5.0; end	
	
	f18 = 3.0 / (Len + 2.0);
	f20 = 1.0 - f18;
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Len .. "," ..  UpperLevel.. "," ..  LowerLevel  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	first=source:first() ; 
	
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.Neutral, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line:addLevel(0);	
	Line:addLevel(instance.parameters.UpperLevel, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line:addLevel(instance.parameters.LowerLevel, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style); 
end


function Update(period, mode)

	 if period == first then
		f90[period] = 1.0;
		f0[period] = 0.0;
	end
			 if (f88 <= f90[period-1]) then f90[period] = f88 + 1; else f90[period] = f90[period-1] + 1; end
			 f10 = 100 * source[period-1];	 
			 f8 = 100 * source[period];
			 v8 = f8 - f10;
			 f28[period] = f20 * f28[period-1] + f18 * v8;
			 f30[period] = f18 * f28[period] + f20 * f30[period];
			 vC = f28[period] * 1.5 - f30[period] * 0.5;
			 f38[period] = f20 * f38[period-1] + f18 * vC;
			 f40[period] = f18 * f38[period] + f20 * f40[period-1];
			 v10 = f38[period] * 1.5 - f40[period] * 0.5;
			 f48[period] = f20 * f48[period-1] + f18 * v10;
			 f50[period] = f18 * f48[period] + f20 * f50[period-1];
			 v14 = f48[period] * 1.5 - f50[period] * 0.5;
			 f58[period] = f20 * f58[period-1] + f18 * math.abs(v8);
			 f60[period] = f18 * f58[period] + f20 * f60[period-1];
			 v18 = f58[period] * 1.5 - f60[period] * 0.5;
			 f68[period] = f20 * f68[period-1] + f18 * v18;
			 f70[period] = f18 * f68[period] + f20 * f70[period-1];
			 v1C = f68[period] * 1.5 - f70[period] * 0.5;
			 f78[period] = f20 * f78[period-1] + f18 * v1C;
			 f80[period] = f18 * f78[period] + f20 * f80[period-1];
			 v20 = f78[period] * 1.5 - f80[period] * 0.5;

			 if ((f88 >= f90[period]) and (f8 ~= f10)) then f0[period] = 1.0; else f0[period] = f0[period-1]; end
			 if ((f88 == f90[period]) and (f0[period] == 0.0)) then f90[period] = 0.0; end
	 
	
	
      if ((f88 < f90[period]) and (v20 > 0.0000000001))  then

         Line[period] = (v14 / v20 + 1.0) * 50.0;
         if (Line[period] > 100.0) then Line[period] = 100.0; end
         if (Line[period] < 0.0) then Line[period] = 0.0; end

       else  
         Line[period] = 50.0;
       end 
	   
	   
	   if  Line[period] > instance.parameters.UpperLevel then
	   Line:setColor(period, instance.parameters.Up);	
	   elseif  Line[period] < instance.parameters.LowerLevel then
	   Line:setColor(period, instance.parameters.Down);		   
	   else
	   Line:setColor(period, instance.parameters.Neutral);		   
	   end
	   
end
 
 