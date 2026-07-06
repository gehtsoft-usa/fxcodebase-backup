-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72702

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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
    indicator:name("Jurik RSX");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Len", "Period", "", 14, 1, 2000); 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 

    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 30);
	indicator.parameters:addDouble("Level2", "2. Level","", 50);
	indicator.parameters:addDouble("Level3", "3. Level","", 70); 
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
local Len; 
local Indicator;
local f18;	
-- Routine
 function Prepare(nameOnly)   
 
    
	Len=instance.parameters.Len;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Len  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	first=source:first() ; 

	f18 = 3.0 / (Len + 2.0)	
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
	
    rsx = instance:addStream("rsx", core.Line, name, "rsx", instance.parameters.color, first );
    rsx:setPrecision(math.max(2, instance.source:getPrecision()));
    rsx:setWidth(instance.parameters.width);
    rsx:setStyle(instance.parameters.style);
    rsx:addLevel(0);	
	rsx:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	rsx:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	rsx:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	 
end


function Update(period, mode)

 

	 if period <= first then
	 return;
	 end
	

	f88[period]=f88[period-1];
	f90[period]=f90[period-1];
	f0[period]=f0[period-1];
	v14[period]=v14[period-1];	
	v20[period]=v20[period-1];
	f8[period]=f8[period-1];
 
	if (f90[period] == 0.0) then
	f90[period] = 1.0
	f0[period] = 0.0
			if (Len-1 >= 5) then 
			f88[period] = Len-1.0
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
		 
		rsx[period] = (v14[period] / v20[period] + 1.0) * 50.0
				if (rsx[period] > 100.0) then 
				rsx[period] = 100.0
				end 
				if (rsx[period] < 0.0) then 
				rsx[period] = 0.0
				end 
		else 
		rsx[period] = 50.0
		end 
		 
 
	
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+


--[[
if (f90 = 0.0) then
f90 = 1.0
f0 = 0.0
if (Len-1 >= 5) then 
f88 = Len-1.0
 else 
f88 = 5.0
endif
f8 = 100.0*(Close)
f18 = 3.0 / (Len + 2.0)
f20 = 1.0 - f18
else
if (f88 <= f90) then 
f90 = f88 + 1
else
f90 = f90 + 1
endif
f10 = f8
f8 = 100*Close
v8 = f8 - f10
f28 = f20 * f28 + f18 * v8
f30 = f18 * f28 + f20 * f30
vC = f28 * 1.5 - f30 * 0.5
f38 = f20 * f38 + f18 * vC
f40 = f18 * f38 + f20 * f40
v10 = f38 * 1.5 - f40 * 0.5
f48 = f20 * f48 + f18 * v10
f50 = f18 * f48 + f20 * f50
v14 = f48 * 1.5 - f50 * 0.5
f58 = f20 * f58 + f18 * Abs(v8)
f60 = f18 * f58 + f20 * f60
v18 = f58 * 1.5 - f60 * 0.5
f68 = f20 * f68 + f18 * v18
 
f70 = f18 * f68 + f20 * f70
v1C = f68 * 1.5 - f70 * 0.5
f78 = f20 * f78 + f18 * v1C
f80 = f18 * f78 + f20 * f80
v20 = f78 * 1.5 - f80 * 0.5
 
if ((f88 >= f90) and (f8 <> f10)) then 
 f0 = 1.0
endif
if ((f88 = f90) and (f0 = 0.0)) then 
f90 = 0.0
endif
endif
 
 
if ((f88 < f90) and (v20 > 0.0000000001)) then 
 
v4 = (v14 / v20 + 1.0) * 50.0
if (v4 > 100.0) then 
v4 = 100.0
endif
if (v4 < 0.0) then 
v4 = 0.0
endif
 else 
v4 = 50.0
endif
 
rsx=v4

]]
 
