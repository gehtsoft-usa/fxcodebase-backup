-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72585

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
    indicator:name("MACZVWAP");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("fastLength", "Fast MA", "", 12, 1, 2000);
    indicator.parameters:addInteger("slowLength", "Slow MA", "", 25, 1, 2000);
    indicator.parameters:addInteger("signalLength", "Signal MA", "", 9, 1, 2000);
	
    indicator.parameters:addInteger("lengthz", "Z-VWAP Length", "", 20, 1, 2000);	
    indicator.parameters:addInteger("lengthStdev", "Stdev Length", "", 25, 1, 2000);		
    indicator.parameters:addDouble("A", "MACZ constant A", "", 1, 0, 2000);	 
    indicator.parameters:addDouble("B", "MACZ constant B", "", 1, 0, 2000);	
    indicator.parameters:addDouble("gamma", "Laguerre Gamma", "", 0.02, 0, 2000);	
	
    indicator.parameters:addBoolean("useLag", "Apply Laguerre Smoothing", "", true);	 
 
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Signal Color", "", core.rgb(255, 0, 0)); 	 
	 indicator.parameters:addColor("color3", "Bar Color", "", core.rgb(0, 0, 255)); 
	 
 		 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local fastLength, slowLength,signalLength; 
local lengthz, lengthStdev, A, B, gamma,useLag;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	fastLength=instance.parameters.fastLength;
	slowLength=instance.parameters.slowLength;
	signalLength=instance.parameters.signalLength;
	slowLength=instance.parameters.slowLength;	
	
	lengthz=instance.parameters.lengthz;
	lengthStdev=instance.parameters.lengthStdev;
	A=instance.parameters.A;
	B=instance.parameters.B;
	gamma=instance.parameters.gamma;
	useLag=instance.parameters.useLag;
	
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  fastLength.. "," ..  slowLength .. "," ..  signalLength.. "," ..  slowLength.. "," .. 
    lengthz.. "," ..  lengthStdev.. "," ..  A .. "," ..  B.. "," ..  gamma 	.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Fast= core.indicators:create("MVA", source.close, fastLength );
	Slow= core.indicators:create("MVA", source.close, slowLength);	
	first=math.max(Fast.DATA:first(), Slow.DATA:first(),lengthz,lengthStdev) ; 
	
	
    volumeclose	 = instance:addInternalStream(0, 0);
    closemean	 = instance:addInternalStream(0, 0);	
	
	close_mean_average= core.indicators:create("MVA", closemean, lengthz);	
	
	l0 = instance:addInternalStream(0, 0);	
	l1 = instance:addInternalStream(0, 0);
 	l2 = instance:addInternalStream(0, 0);
	l3 = instance:addInternalStream(0, 0);	
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first +lengthz  );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	 


    Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color2, first +lengthz +signalLength  );
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.width);
    Signal:setStyle(instance.parameters.style);
	
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.color3, first +lengthz +signalLength  );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);		
 
end


function Update(period, mode)

	Fast:update(mode); 
	Slow:update(mode); 
	
	
     volumeclose[period]=source.close[period]*source.volume[period];	
	
 	if period <= first then
	return;
	end
	
	
	local std= mathex.stdev(source.close, period-lengthStdev+1, period) 
    local mean = mathex.sum(volumeclose, period-lengthz+1, period) / mathex.sum(source.volume, period-lengthz+1, period);
	closemean[period]= math.pow(source.close[period] - mean, 2);
	
	
	close_mean_average:update(mode); 	
  	if period <= first +lengthz then
	return;
	end	 
 
	 
    local vwapsd = math.sqrt(close_mean_average.DATA[period]);
    local zscore = (source.close[period]-mean)/vwapsd;
	
	local imacd = Fast.DATA[period] - Slow.DATA[period];
	local maczt=zscore*A+ imacd/std*B
	
		if useLag and maczt>0 then 
		s = maczt
		g = gamma 
		
		l0[period] = (1 - g)*s+g*(l0[period-1])
		l1[period] = -g*l0[period]+(l0[period-1])+g*(l1[period-1])
		l2[period] = -g*l1[period]+(l1[period-1])+g*(l2[period-1])
		l3[period] = -g*l2[period]+(l2[period-1])+g*(l3[period-1])
		Line[period]=(l0[period] + 2*l1[period] + 2*l2[period] + l3[period])/6
		else
		Line[period]=maczt
		end  
		
  	if period <= first +lengthz +signalLength then
	return;
	end	 		
	Signal[period] = mathex.avg(Line, period-signalLength+1, period) ; 
	Bar[period]=Line[period]-Signal[period]

 
	
end

 




