-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72632

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
--|                                                                       https://mario-jemic.com/ |
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
    indicator:name("Laguerre candles");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");
	
	indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addDouble("gamma", "Gamma", "", 0, 0, 1);
	
 

	 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.COLOR_UPCANDLE );
	indicator.parameters:addColor("Down", "Down color", "", core.COLOR_DOWNCANDLE );
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.COLOR_LABEL );
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, Neutral;
local first;
local source = nil; 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local gamma;
 

 function Prepare(nameOnly)  


    gamma= instance.parameters.gamma; 
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " .. gamma .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral; 
 

	source = instance.source;
	
	ol0 = instance:addInternalStream(0, 0);
	ol1 = instance:addInternalStream(0, 0);
	ol2 = instance:addInternalStream(0, 0);
	ol3 = instance:addInternalStream(0, 0);
	
	cl0 = instance:addInternalStream(0, 0);
	cl1 = instance:addInternalStream(0, 0);
	cl2 = instance:addInternalStream(0, 0);
	cl3 = instance:addInternalStream(0, 0);
	
	--MACD=core.indicators:create("MACD",  source[Price], SN, LN, IN);
	first=source:first()+1;

    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	

	
			if period < first then
			
			ol0[period] = source.open[period];
			ol1[period] = source.open[period];
			ol2[period] = source.open[period];
			ol3[period] = source.open[period];	

			cl0[period] = source.close[period];
			cl1[period] = source.close[period];
			cl2[period] = source.close[period];
			cl3[period] = source.close[period];
			
			open:setColor(period, Neutral);	
			return;
			end
			
		if period== first then
        OL=source.open[period];		
        CL=source.close[period];
		else
		ol0[period] = (1 - gamma) * source.open[period] + gamma * ol0[period-1]
		ol1[period] = -gamma * ol0[period] + ol0[period-1] + gamma * ol1[period-1]
		ol2[period] = -gamma * ol1[period] + ol1[period-1] + gamma * ol2[period-1]
		ol3[period] = -gamma * ol2[period] + ol2[period-1] + gamma * ol3[period-1]
		OL = (ol0[period] + 2 * ol1[period] + 2 * ol2[period] + ol3[period]) / 6
		 
		cl0[period] = (1 - gamma) * source.close[period] + gamma * cl0[period-1]
		cl1[period] = -gamma * cl0[period] + cl0[period-1] + gamma * cl1[period-1]
		cl2[period] = -gamma * cl1[period] + cl1[period-1] + gamma * cl2[period-1]
		cl3[period] = -gamma * cl2[period] + cl2[period-1] + gamma * cl3[period-1]
		CL = (cl0[period] + 2 * cl1[period] + 2 * cl2[period] + cl3[period]) / 6		
        end

		open[period] = OL;
		close[period] = CL;
		high[period] = source.high[period];
		low[period] = source.low[period];		
 		
		if close[period]> open[period] then
		open:setColor(period,  Up);
		elseif close[period]< open[period] then 
		open:setColor(period,  Down);
        else
		open:setColor(period, Neutral);	 
		end
 end

 