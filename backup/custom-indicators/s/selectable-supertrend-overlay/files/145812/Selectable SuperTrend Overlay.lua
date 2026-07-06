-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72120

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
function Init()
    indicator:name("Selectable SuperTrend Overlay");
    indicator:description("The indicator displays the buying and selling with the colors. The indicator is initially developed by Jason Robinson for MT4");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Selector");
	
	indicator.parameters:addString("Price", "Price Source", "", "RegularBar");
    indicator.parameters:addStringAlternative("Price", "RegularBar", "", "RegularBar");
    indicator.parameters:addStringAlternative("Price", "HA", "", "HA");
 
	indicator.parameters:addString("Output", "Output", "", "RegularBar");
    indicator.parameters:addStringAlternative("Output", "RegularBar", "", "RegularBar");
    indicator.parameters:addStringAlternative("Output", "HA", "", "HA");
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 10);
    indicator.parameters:addDouble("M", "Multiplier", "", 1.5);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up", " ", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Color of Down", " ", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Color of Neutral", " ", core.rgb(128,128, 128));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local M;

local first;
local source = nil;
local ATR = nil;

-- Streams block

local UP = nil;
local DN = nil;
local TR = nil;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local Up,Down,Neutral;

local Price,Output;
-- Routine
 function Prepare(nameOnly)   
    N = instance.parameters.N;
    M = instance.parameters.M;
    source = instance.source;
  
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. M .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral;
	
	Price = instance.parameters.Price;
	Output = instance.parameters.Output;
	
	

	
    HA = core.indicators:create("HA", source);			
	if 	Price== "HA" then
	ATR = core.indicators:create("ATR", HA:getCandleOutput (0), N);	
	else	
	ATR = core.indicators:create("ATR", source, N);
	end
	

    first = ATR.DATA:first();
	
    UP = instance:addInternalStream(first, 0);
    DN = instance:addInternalStream(first, 0);
    TR = instance:addInternalStream(first, 0);
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
  
end

-- Indicator calculation routine
function Update(period, mode)


   ATR:update(mode);
   HA:update(mode);	

  if period< first then
  return;
  end
   
   if not ATR.DATA:hasData(period) then
   return;
   end
   

    if Output== "HA" then
    open[period] = HA.open[period];
	close[period] = HA.close[period];
	high[period] = HA.high[period];
	low[period] = HA.low[period];	
	else	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	end
	
	
	

    TR[period] = 1;
	
    if period < first then
	open:setColor(period, Neutral);	
	return;
	end
	
        local median, atr, change;
        atr = ATR.DATA[period];
		
		if 	Price== "HA" then
        median = (HA.high[period] + HA.low[period]) / 2;		
		else
        median = (source.high[period] + source.low[period]) / 2;
		end
		
        UP[period] = median + atr * M;
        DN[period] = median - atr * M;

        if period >= first + 1 then
            change = false;
			
			if 	Price== "HA" then
					if HA.close[period] > UP[period - 1] then
						TR[period] = 1;
						if TR[period - 1] == -1 then
							change = true;
						end
					elseif HA.close[period] < DN[period - 1] then
						TR[period] = -1;
						if TR[period - 1] == 1 then
							change = true;
						end
					else
						TR[period] = TR[period - 1];
					end
					
			else
			
					if source.close[period] > UP[period - 1] then
						TR[period] = 1;
						if TR[period - 1] == -1 then
							change = true;
						end
					elseif source.close[period] < DN[period - 1] then
						TR[period] = -1;
						if TR[period - 1] == 1 then
							change = true;
						end
					else
						TR[period] = TR[period - 1];
					end
			
			end

            local flag, flagh;

            if TR[period] < 0 and TR[period - 1] > 0 then
               flag = 1;
            else
               flag = 0;
            end

            if TR[period] > 0 and TR[period - 1] < 0 then
               flagh = 1;
            else
               flagh = 0;
            end

            if TR[period] > 0 and DN[period] < DN[period - 1] then
                DN[period] = DN[period - 1];
            end

            if TR[period] < 0 and UP[period] > UP[period - 1] then
                UP[period] = UP[period - 1];
            end

            if flag == 1 then
                UP[period] = median + atr * M;
            end

            if flagh == 1 then
                DN[period] = median - atr * M;
            end

            
        end
		
		
		if TR[period] > 0 then		
		open:setColor(period,  Up);
        elseif TR[period] < 0 then
		open:setColor(period,  Down);
		else
		open:setColor(period, Neutral);			
		end
   
end
 