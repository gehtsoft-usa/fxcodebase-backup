-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71969

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
    indicator:name("5D Candles and Line");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
	
	indicator.parameters:addBoolean("Candles", "Show Candles", "", false);
	indicator.parameters:addBoolean("CandleCci", "Show CCI", "", false);
	indicator.parameters:addBoolean("CandleRsi", "Show RSI", "", false);
	indicator.parameters:addBoolean("CandleStochastic", "Show Stochastic", "", false);
	--indicator.parameters:addBoolean("CandleCycle", "Show CYCLE", "", false);
	indicator.parameters:addBoolean("CandleDI", "Show DMI", "", false);
	
    indicator.parameters:addInteger("CciPeriod", "Cci Period", "",20, 1, 2000);
    indicator.parameters:addInteger("RsiPeriod", "Rsi Period", "", 14, 1, 2000);
	
    indicator.parameters:addInteger("K", "K", "", 5, 1, 2000);
    indicator.parameters:addInteger("D", "D", "", 3, 1, 2000);
    indicator.parameters:addInteger("DiPeriod", "Di Period", "", 14, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 
	 
 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local CciPeriod, RsiPeriod, D, K, DiPeriod; 
 

local Candles,CandleCci,CandleRsi,CandleStochastic,CandleCycle,CandleDI;	
-- Routine
 function Prepare(nameOnly)   
 
    Candles=instance.parameters.Candles;
	CandleCci=instance.parameters.CandleCci;
	CandleRsi=instance.parameters.CandleRsi;
	CandleStochastic=instance.parameters.CandleStochastic;
	--CandleCycle=instance.parameters.CandleCycle;
	CandleDI=instance.parameters.CandleDI;
	
	CciPeriod=instance.parameters.CciPeriod;
	RsiPeriod=instance.parameters.RsiPeriod;
	
	D=instance.parameters.D;
	K=instance.parameters.K;
	DiPeriod=instance.parameters.DiPeriod;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  CciPeriod.. "," ..  RsiPeriod .. "," ..  K.. "," ..  D.. "," ..  DiPeriod .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	CCI= core.indicators:create("CCI", source, CciPeriod);
	RSI= core.indicators:create("RSI", source.close, RsiPeriod);	
	DMI= core.indicators:create("DMI", source, DiPeriod);		
	Stochastic= core.indicators:create("STOCHASTIC", source, K, D, 1);		
	first=math.max(CCI.DATA:first(),RSI.DATA:first(),DMI.DATA:first()) ; 
	
 
	if Candles then
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
	
	else
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
	
	end
	
 
end


function Update(period, mode)

	CCI:update(mode); 
	RSI:update(mode); 
	DMI:update(mode); 	
	Stochastic:update(mode); 	
	 if period < first then
	 return;
	 end
	 
 
	local count = 0;
	local R=0;
	local G=0;
	local B=0; 
 
	 if CandleCci then 
	 R = (200-CCI.DATA[period])
	 G = (200+CCI.DATA[period])
	 count = count + 1
	end

 
	if CandleRsi then
	 
	 R =50+(200-(RSI.DATA[period]-50)*12)
	 G = 50+(200+(RSI.DATA[period]-50)*12)
	 count = count + 1
	end
	
	if CandleDI then 
	 R = 50+(200-DMI.DATA[period]*10)
	 G = 50+(200+DMI.DATA[period]*10)
	 count = count + 1
	end 


	if CandleStochastic then
	 
	 R = 50+(200-(Stochastic.DATA[period]-50)*6)
	 G = 50+(200+(Stochastic.DATA[period]-50)*6)
	 count = count + 1
	end
 --[[ 
if candlecycle then
 MyCycle    = Cycle(customclose)
 R4 = (200-MyCycle*10)
 G4 = (200+MyCycle*10)
 count = count + 1
endif
   

]]


	if count == 0 then
	R=128;
	G=128;
	B=128;
	else

	 
	 R = R/count
	 G = G/count
	 B = 255
	end


	if Candles then
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];	
	open:setColor(period,  core.rgb(R, G, B));		
	else
	Line[period]=  G - R;
	Line:setColor(period,  core.rgb(R, G, B));		
	end
	
	

end