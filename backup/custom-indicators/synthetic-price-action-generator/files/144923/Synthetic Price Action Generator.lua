-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71845

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
    indicator:name("Synthetic Price Action Generator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("nptIV", "Initial Value", "", 50 );
    indicator.parameters:addDouble("nptMPA", "Manipulate Price Action", "", 0.45, 0, 0.95);
    indicator.parameters:addDouble("nptPCR", "Perturbate close Randomness", "", 0.004, 0.002, 0.013);
    indicator.parameters:addDouble("nptPHL", "Perturbate high/low Volatility", "", 0.19, 0.07, 0.25);
    indicator.parameters:addDouble("nptOCV", "Variability of open/close", "", 0.07, -0.07, 0.07);	
    indicator.parameters:addDouble("nptPM", "Price Multiplier", "", 1.0 );
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local nptIV, nptMPA, nptPCR, nptPHL, nptOCV, nptPM;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	nptIV=instance.parameters.nptIV;
	nptMPA=instance.parameters.nptMPA;
	nptPCR=instance.parameters.nptPCR;
	nptPHL=instance.parameters.nptPHL;
	nptOCV=instance.parameters.nptOCV;
	nptPM=instance.parameters.nptPM;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  nptIV.. "," ..  nptMPA.. "," ..  nptPCR.. "," ..  nptPHL.. "," ..  nptOCV.. "," ..  nptPM  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	OPEN = instance:addInternalStream(0, 0);
	HIGH = instance:addInternalStream(0, 0);
	LOW = instance:addInternalStream(0, 0);	
    CLOSE = instance:addInternalStream(0, 0);
	
	HighValue = instance:addInternalStream(0, 0);
	LowValue = instance:addInternalStream(0, 0);
	first=source:first() ;  
	
	open = instance:addStream("openup", core.Line, name, "", instance.parameters.Neutral, first);
    high = instance:addStream("highup", core.Line, name, "", instance.parameters.Neutral, first);
    low = instance:addStream("lowup", core.Line, name, "", instance.parameters.Neutral, first);
    close = instance:addStream("closeup", core.Line, name, "", instance.parameters.Neutral, first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
 
end


function Update(period, mode) 

	 if period < first then
	 return;
	 end
	 
   spg(nptIV, nptMPA, nptPCR, nptPHL, nptOCV, nptPM, period)
	
end


function spg(InitialCloseValue,
    ManipulatePriceAction ,
    PertubateCloseRandomness,
    PerturbateHighLowValues ,
    OpenCloseVariability ,
    PriceMultiplier, period  ) 
	
	if PriceMultiplier==0 then
	PRICE_MULT =  0.001; 
	else
	PRICE_MULT=PriceMultiplier;
	end
	
    local SIGN=0;
	if PriceMultiplier> 0 then
	SIGN=1;
	elseif PriceMultiplier< 0 then
	SIGN=-1;	
    end
	
	if SIGN== -1 then
	SIGN_OF_PM=true;
	else
	SIGN_OF_PM=false;
	end
	
		
	local temp = 1.0 - PertubateCloseRandomness;
    CLOSE[period]= PertubateCloseRandomness * math.random(0,100) + temp * CLOSE[period-1];
	
	if period == source:first() then
    CLOSE[period] = InitialCloseValue;
	end
	
    temp = 1 - ManipulatePriceAction;
    local rand4High  = math.random(0,0.25)
	
    if HighValue[period-1] >0 then
	HighValue[period] = ManipulatePriceAction * rand4High + temp *  HighValue[period-1] 
	else
	HighValue[period] = ManipulatePriceAction * rand4High + temp *   rand4High 	
	end
	
    HighValue[period]  = HighValue[period] -HighValue[period-1] - HighValue[period]	
	
	
    HIGH[period] = math.max(CLOSE[period], CLOSE[period] + HighValue[period] * PerturbateHighLowValues)
    local rand4Low  = math.random(0,0.25)
    
	if LowValue[period-1] >0 then
	LowValue[period] = ManipulatePriceAction * rand4Low + temp * LowValue[period-1] 
	else
	LowValue[period] = ManipulatePriceAction * rand4Low + temp * rand4Low 
	end
	
		
    LowValue[period]  =  LowValue[period] - LowValue[period-1] - LowValue[period]
    LOW[period]       = math.min(CLOSE[period], CLOSE[period] - LowValue[period] * PerturbateHighLowValues)
	
	local Mod=period % 2;
	
	if Mod==0 then
    OPEN[period]  = CLOSE[period-1] +  ((rand4High+ rand4Low)/2) * (1) * nptOCV		
	else
    OPEN[period]  = CLOSE[period-1] +  ((rand4High+ rand4Low)/2) * (-1) * nptOCV	
	end
	---------------------------
	
	
    if SIGN_OF_PM then
	open[period]=( OPEN[period] - 50) * PriceMultiplier 
	else
	open[period]=OPEN[period] * PRICE_MULT
    end
	
    if SIGN_OF_PM then
    high[period]=( HIGH[period] - 50) * PriceMultiplier 
	else
    high[period]=HIGH[period] * PRICE_MULT
    end	

    if SIGN_OF_PM then
    low[period]=(  LOW[period] - 50) * PriceMultiplier
	else
    low[period]=LOW[period] * PRICE_MULT
    end	

    if SIGN_OF_PM then
    close[period]=(CLOSE[period] - 50) * PriceMultiplier
	else
    close[period]= CLOSE[period] * PRICE_MULT
    end	

 
	 
	    if close[period]> open[period] then
		open:setColor(period,  instance.parameters.Up);
	    elseif close[period]< open[period] then		
		open:setColor(period,  instance.parameters.Down);
		else
		open:setColor(period, instance.parameters.Neutral);	
	    end
end 