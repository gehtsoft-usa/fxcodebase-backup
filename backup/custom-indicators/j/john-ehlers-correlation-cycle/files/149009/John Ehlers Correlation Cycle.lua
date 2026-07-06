-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73165

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
    indicator:name("John Ehlers – Correlation Cycle");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000); 
	
	
	indicator.parameters:addInteger("Method", "MA Method", "Method" , 1);
    indicator.parameters:addIntegerAlternative("Method", "Indicator Mode", "Indicator Mode" , 1);
    indicator.parameters:addIntegerAlternative("Method", "Index Mode", "Index Mode" , 2);
    indicator.parameters:addIntegerAlternative("Method", "Angle Phasor Mode", "Angle Phasor Mode" , 3);
    indicator.parameters:addIntegerAlternative("Method", " Market State Mode", "Market State Mode" , 4);
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
 
	indicator.parameters:addColor("color2", "Real Line Up Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color3", "Real Line Up Color", "", core.rgb(255, 0, 0)); 	
	indicator.parameters:addColor("color4", "Imag Line Up Color", "", core.rgb(128, 128, 128)); 	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period; 
local Method;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	Method=instance.parameters.Method;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first() +Period; 
	
	
	Price = instance:addInternalStream(0, 0);
 
	Real = instance:addInternalStream(0, 0);
	Imag = instance:addInternalStream(0, 0);
	
	if Method == 3 then	
    Angle = instance:addStream("Angle", core.Line, name, "Angle", instance.parameters.color4, first );
    Angle:setPrecision(math.max(2, instance.source:getPrecision()));
    Angle:setWidth(instance.parameters.width);
    Angle:setStyle(instance.parameters.style);	
	else
	Angle = instance:addInternalStream(0, 0);
	end
	
	if Method == 4 then
    State = instance:addStream("State", core.Line, name, "State", instance.parameters.color4, first );
    State:setPrecision(math.max(2, instance.source:getPrecision()));
    State:setWidth(instance.parameters.width);
    State:setStyle(instance.parameters.style);	
	else
	State = instance:addInternalStream(0, 0); 
	end
 
	
	Realshow = instance:addStream("Realshow", core.Line, name, "Realshow", instance.parameters.color2, first );
    Realshow:setPrecision(math.max(2, instance.source:getPrecision()));
    Realshow:setWidth(instance.parameters.width);
    Realshow:setStyle(instance.parameters.style); 
	
	Imagshow = instance:addStream("Imagshow", core.Line, name, "Imagshow", instance.parameters.color4, first );
    Imagshow:setPrecision(math.max(2, instance.source:getPrecision()));
    Imagshow:setWidth(instance.parameters.width);
    Imagshow:setStyle(instance.parameters.style); 
 
end


function Update(period, mode)

	--Indicator:update(mode); 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
 
	local Sx = 0
	local Sy = 0
	local Sxx = 0
	local Sxy = 0
	local Syy = 0
	
	for Count = 1 ,  Period, 1 do
	X = source[period-Count + 1]
	Y = math.cos( 360 * (Count - 1 ) / Period )
	Sx = Sx + X
	Sy = Sy + Y
	Sxx = Sxx + X * X
	Sxy = Sxy + X * Y
	Syy = Syy + Y*Y
	end


	if ( Period*Sxx - Sx*Sx > 0) and ( Period*Syy - Sy*Sy > 0 ) then
	Real[period] = ( Period*Sxy - Sx*Sy ) / math.sqrt( ( Period*Sxx - Sx*Sx ) * ( Period*Syy - Sy*Sy ) )
	end 
	
	
	
	local Sx = 0
	local Sy = 0
	local Sxx = 0
	local Sxy = 0
	local Syy = 0
	for Count = 1 , Period, 1  do
	X = source[period-Count + 1]
	Y = -math.sin( 360 * ( Count - 1 ) / Period )
	Sx = Sx + X
	Sy = Sy + Y
	Sxx = Sxx + X * X
	Sxy = Sxy + X * Y
	Syy = Syy + Y * Y
	end
	 
 if (Period * Sxx - Sx * Sx > 0) and (Period * Syy - Sy * Sy > 0) then
        Imag[period] = (Period * Sxy - Sx * Sy) / math.sqrt((Period * Sxx - Sx * Sx) * (Period * Syy - Sy * Sy));
    end
    if Imag[period] ~= 0 then 
        Angle[period] = 90 + math.atan(Real[period] / Imag[period]);
    end
    if Imag[period] > 0 then 
        Angle[period] = Angle[period] - 180;
    end
	
 
	--if  (Angle[period]  <Angle[period-1] ) then
	--Angle[period] = Angle[period-1]
	--end
	 
 
	State[period] = 0
	if math.abs( Angle[period] - Angle[period-1] ) < 9 and Angle[period] <= 0 then
	State[period] = -1*100
	end
	if math.abs( Angle[period] - Angle[period-1] ) < 9 and Angle[period] >= 0 then
	State[period] = 1*100
	end
	
 
	
	if Method==1 then
	Realshow[period] = (((Real[period]+1)/2)*200)-100
	Imagshow[period] = (((Imag[period]+1)/2)*200)-100
 
		if Realshow[period]>Imagshow[period] then
		Realshow:setColor(period,  instance.parameters.color2);
		else 
		Realshow:setColor(period,  instance.parameters.color3);
		end 
	end
	
	
	
	if Method==2 then
	Realshow[period] = (((Real[period]+1)/2)*100)
	Imagshow[period] = (((Imag[period]+1)/2)*100)
	
		if Realshow[period]>Imagshow[period] then
		Realshow:setColor(period,  instance.parameters.color2);
		else 
		Realshow:setColor(period,  instance.parameters.color3);
		end 
	end




	if Method==3 then 
		if Angle[period]>0 then
		Angle:setColor(period,  instance.parameters.color2);
		else
		Angle:setColor(period,  instance.parameters.color3);
		end 
		 
	end

	if Method==4 then 
		if State[period]>0 then
		State:setColor(period,  instance.parameters.color2);
		else
		State:setColor(period,  instance.parameters.color3);
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