-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73019

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



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Volatility & Amplitude");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period1", "Fast MA", "", 14, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow MA", "", 27, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);


	 indicator.parameters:addColor("color2", "Volatilite Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color1", "Amplitude Line Color", "", core.rgb(0, 255, 0)); 	


end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	 
	
	ABS = instance:addInternalStream(0, 0);
	Indicator1= core.indicators:create("MVA", ABS, Period1);
	Fxscale = instance:addInternalStream(0, 0);
	Indicator2= core.indicators:create("MVA", Fxscale, Period2);	


   FxRRange	 = instance:addInternalStream(0, 0);
   LxRRange	 = instance:addInternalStream(0, 0);
   
   
   TLr	 = instance:addInternalStream(0, 0);
   TrDL	 = instance:addInternalStream(0, 0);
   UAmp	 = instance:addInternalStream(0, 0);
   DAmp	 = instance:addInternalStream(0, 0);
   Amp	 = instance:addInternalStream(0, 0);
   OAmp	 = instance:addInternalStream(0, 0);
   VRange= instance:addInternalStream(0, 0);
   
   
    Volatilite = instance:addStream("Volatilite", core.Line, name, "Volatilite", instance.parameters.color2, source:first()+1 );
    Volatilite:setPrecision(math.max(2, instance.source:getPrecision()));
    Volatilite:setWidth(instance.parameters.width);
    Volatilite:setStyle(instance.parameters.style);
    Volatilite:addLevel(0);	 
	
	
    Amplitude = instance:addStream("Amplitude", core.Line, name, "Amplitude", instance.parameters.color1, source:first()+1 );
    Amplitude:setPrecision(math.max(2, instance.source:getPrecision()));
    Amplitude:setWidth(instance.parameters.width);
    Amplitude:setStyle(instance.parameters.style);
    Amplitude:addLevel(0);	



end


function Update(period, mode)



	 if period <= source:first()+1 then
	 FxRRange[period]=source.close[period];
	 LxRRange[period]=source.close[period];
	 return;
	 end
	 
	 
    ABS[period]= math.abs(source.close[period]-source.close[period-1])

	 Indicator1:update(mode);  
	 
	 if period <= source:first()+1 +Period1 then
	 return;
	 end
	  
	 
	Fxscale[period] = 2.338*Indicator1.DATA[period]
	
	 if period <= source:first()+1 +Period1 +Period2 then
	 return;
	 end
	 
	 Indicator2:update(mode);	 
 
	
  
 
	if source[period] > FxRRange[period-1] then
		if (source[period]-Indicator2.DATA[period]) < FxRRange[period-1] then
		FxRRange[period] = FxRRange[period-1]
		else
		FxRRange[period] = (source[period]-Indicator2.DATA[period])
		end 
	elseif (source[period]+Indicator2.DATA[period]) > FxRRange[period-1] then
	FxRRange[period] = FxRRange[period-1]
	else
	FxRRange[period] = (source[period]+Indicator2.DATA[period])
	end 
	 
	FxTrend = FxRRange[period]
	FxURange = FxRRange[period] + Indicator2.DATA[period]
	FxDRange = FxRRange[period] - Indicator2.DATA[period]
	
	
 
 
	 
	if source.high[period] > LxRRange[period-1] then
		if (source.high[period]-Fxscale[period]) < LxRRange[period-1] then
		LxRRange[period] = LxRRange[period-1]
		else
		LxRRange[period] = (source.high[period]-Fxscale[period])
		end 
	elseif (source.low[period]+Fxscale[period]) > LxRRange[period-1] then
	LxRRange[period] = LxRRange[period-1]
	else
	LxRRange[period] = (source.low[period]+Fxscale[period])
	end 
	 
	LxTrend = LxRRange[period]
	LxURange = LxRRange[period] + Fxscale[period]
	LxDRange = LxRRange[period] - Fxscale[period]
	
	
 
	TLr[period] = (FxTrend+LxTrend)/2
	AvTrD1 = (TLr[period]+TLr[period-1])/2
	AvTrD2 = (AvTrD1-TLr[period])/15
	TrDL[period] = AvTrD1-AvTrD2
	 
	 
	XURange = (FxURange+LxURange)/2 
	XDRange = ((FxDRange+LxDRange)/2)
	
	
 
	UAmp[period] = 0
	if source.close[period] > TrDL[period] then
	UAmp[period] = UAmp[period-1]+1
	end 
	 
	 
	DAmp[period] = 0
	if source.close[period] < TrDL[period] then
	DAmp[period] = DAmp[period-1]+1
	end 
	 
	 
	Amp[period] = UAmp[period]+DAmp[period]
	if Amp[period] < Amp[period-1]-1 then
	Amp[period] = Amp[period-Amp[period]]-Amp[period]
	end 




	VRange[period] = 0
	if TrDL[period] ==TrDL[period-1] then
	VRange[period] = VRange[period-1]+1
	end 
	 
 
	OAmp[period] = (Amp[period]-VRange[period])-VRange[period]
	if OAmp[period] < 0 then
	OAmp[period] = 0
	end 
	 
	if OAmp[period] < OAmp[period-1]-1 then
	OAmp[period] = OAmp[period-1]-1
	end 
	 
	if OAmp[period] > OAmp[period-1]+1 then
	OAmp[period] = OAmp[period-1]+1
	end 
	 
	 
	if VRange[period] > OAmp[period] then
	OAmp[period] = VRange[period]
	end 
	
	
	local P = math.floor(OAmp[period]); 
    Volatilite[period] = (((XURange*0.5)-(XDRange*0.5)))
	
	if period < P then
	return;
	end
	
	local Min, Max=mathex.minmax(source, period-P+1, period);
	
	if source.close[period] > TrDL[period] then
	Amplitude[period] = (source.close[period]-Min) 
	elseif source.close[period] < TrDL[period] then
	Amplitude[period] = (Max-source.close[period]) 
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