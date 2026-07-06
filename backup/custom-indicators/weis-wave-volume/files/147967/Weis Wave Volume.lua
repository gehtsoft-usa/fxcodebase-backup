-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72851

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
    indicator:name("Weis Wave Volume");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("methodvalue", "Period", "", 14, 1, 2000);
 
	
	indicator.parameters:addString("Method", "Renko Assignment Method", "Renko Assignment Method" , "MethodATR");
    indicator.parameters:addStringAlternative("Method", "ATR", "ATR" , "MethodATR");
    indicator.parameters:addStringAlternative("Method", "Traditional", "Traditional" , "MethodTraditional");
    indicator.parameters:addStringAlternative("Method", "Part of Price", "Part of Price" , "MethodPart");
 
	
	indicator.parameters:addString("pricesource", "Price Source", "Price Source" , "PriceClose");
    indicator.parameters:addStringAlternative("pricesource", "Close", "Close" , "PriceClose");
    indicator.parameters:addStringAlternative("pricesource", "Open / Close", "Open / Close" , "PriceOpenClose");
    indicator.parameters:addStringAlternative("pricesource", "High / Low", "High / Low" , "PriceHighLow"); 
 

    indicator.parameters:addBoolean("useTrueRange", "Use True Range instead of Volume", "", true);
    indicator.parameters:addBoolean("normalize", "Normalize", "", false);
    indicator.parameters:addBoolean("isOscillating", "Is Oscillating", "", false);
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local normalize,Period, Method,useOpenClose,useClose,isOscillating,useTrueRange ; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    methodvalue=instance.parameters.methodvalue;
	Method=instance.parameters.Method;
	normalize=instance.parameters.normalize;
	pricesource=instance.parameters.pricesource;
	isOscillating=instance.parameters.isOscillating;
	useTrueRange=instance.parameters.useTrueRange;
	source = instance.source
	
    -- bool useClose = pricesource == PriceClose;
    -- bool useOpenClose = pricesource == PriceOpenClose || useClose;
	--useClose = pricesource == "Close"
	--useOpenClose = pricesource == "Open / Close" or useClose	  
	
	if pricesource == "PriceClose" then
	useClose=true;
	else
	useClose=false;	
	end
	
 
 
	if pricesource == "PriceOpenClose" or useClose then
	useOpenClose=true;
	else
	useOpenClose=false;	
	end  
 
    local name = profile:id() .. "(" ..  instance.source:name()..    ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--TR = core.indicators:create("ATR", source, 1);
	ATR = core.indicators:create("ATR", source, math.floor(methodvalue));	
	first=ATR.DATA:first() ; 
	
	
	currclose = instance:addInternalStream(0, 0);
    direction = instance:addInternalStream(0, 0);
	barcount= instance:addInternalStream(0, 0);
	vol= instance:addInternalStream(0, 0);	
	
    WWV = instance:addStream("WWV", core.Bar, name, "WWV", instance.parameters.color1, first );
    WWV:setPrecision(math.max(2, instance.source:getPrecision())); 
 
end

function  TrueRange(period)
 
   local  hl = math.abs(source.high[period] - source.low[period]);
   local hc = math.abs(source.high[period] - source.close[period - 1]);
   local lc = math.abs(source.low[period] - source.close[period - 1]);

   local tr = hl;
   if (tr < hc) then
      tr = hc;
   end	  
   if (tr < lc) then
      tr = lc;
   end	  
   return tr;
end

function Update(period, mode)

	--TR:update(mode); 
	ATR:update(mode); 
	
	
	--[[
	   double mv;
      switch (method)
      {
         case MethodATR:
            mv = iATR(_Symbol, _Period, methodvalue, pos);
            break;
         case MethodTraditional:
            mv = methodvalue;
            break;
         case MethodPart:
            mv = close[pos] / methodvalue;
            break;
      }

	if method == "ATR"
    methodvalue := atr(round(methodvalue))
if method == "Part of Price"
    methodvalue := close / methodvalue
	]]
	
	 if period <= first then
	 return;
	 end
	  
    local mv;
         if Method== "MethodATR" then
            mv = ATR.DATA[period];
         elseif Method== "MethodTraditional" then 
            mv = methodvalue; 
         elseif Method==  "MethodPart" then 
            mv = source.close[period] / methodvalue;
         end
     


    --      double volVal = useTrueRange ? TrueRange(pos, high, low, close) : tick_volume[pos];	 
	--vol = useTrueRange == "Always" or useTrueRange == "Auto" and na(volume) ? tr : volume
	local volVal;
	if useTrueRange or source.volume== nil then
	volVal=TrueRange(period);
	else
    volVal= source.volume[period];  
	end
	
    --      double op = useClose ? close[pos] : open[pos];	
	--      op = useClose ? close : open
	 local op;
	 if  useClose then
	 op=source.close[period];
     else	 
	 op=source.open[period];
     end

    -- double hi = useOpenClose ? close[pos] >= op ? close[pos] : op : high[pos];
    -- double lo = useOpenClose ? close[pos] <= op ? close[pos] : op : low[pos];

	--hi = useOpenClose ? close >= op ? close : op : high
	--lo = useOpenClose ? close <= op ? close : op : low	
      local hi;
	  if useOpenClose  then 
		  if source.close[period] >= op then
		  hi=source.close[period]
		  else
		  hi=op 
		  end
	  else
	  hi=source.high[period];
	  end
      local  lo;
	  if  useOpenClose  then
	      if source.close[period] <= op then 
		  lo=source.close[period] 
		  else
		  lo=op 
		  end
	  else
	  lo=source.low[period];
      end	  
	  
	 
      --double prevclose = currclose[pos + 1];
      --double prevhigh = prevclose + mv;
      --double prevlow = prevclose - mv;	

	--prevclose = nz(currclose[1])
	--prevhigh = prevclose + methodvalue
	--prevlow = prevclose - methodvalue
	  
      local  prevclose = currclose[period - 1];
      local prevhigh = prevclose + mv;
      local prevlow = prevclose - mv;	  
	  
     --currclose[pos] = hi > prevhigh ? hi : lo < prevlow ? lo : prevclose;  
     --currclose := hi > prevhigh ? hi : lo < prevlow ? lo : prevclose	 
      if hi > prevhigh then
	  currclose[period] = hi 
	  elseif lo < prevlow then
	  currclose[period] = lo 
	  else 
	  currclose[period] = prevclose;	
      end		  


     -- direction[pos] = currclose[pos] > prevclose ? 1 : currclose[pos] < prevclose ? -1 : direction[pos + 1];	  
     --direction := currclose > prevclose ? 1 : currclose < prevclose ? -1 : nz(direction[1])

     if currclose[period] > prevclose then
	 direction[period]= 1 
	 elseif currclose[period] < prevclose then
	 direction[period]=-1 
	 else 
	 direction[period]=direction[period-1];	  
	 end
	 
	 
    --   bool directionHasChanged = direction[pos] != direction[pos + 1];
     --directionHasChanged = change(direction) != 0
	 	
	 if  direction[period] ~= direction[period - 1] then
	 directionHasChanged = true;
	 else
	 directionHasChanged = false;
     end	 
	 
    --     barcount[pos] = !directionHasChanged && normalize ? barcount[pos + 1] + 1 : barcount[pos + 1];	
    --barcount = 1	
	--barcount := not directionHasChanged and normalize ? barcount[1] + barcount : barcount
	if not directionHasChanged and normalize then
	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	barcount[period] = 	barcount[period-1]+1
	else
	barcount[period] = 1
	end
    --   vol[pos] = !directionHasChanged ? vol[pos + 1] + volVal : volVal;	
	--vol := not directionHasChanged ? vol[1] + vol : vol
	if not directionHasChanged then   
    vol[period] = vol[period - 1] + volVal;	
	else
	vol[period] = volVal;
	end
	
    --  double res = barcount[pos] > 1 ? vol[pos] / barcount[pos] : vol[pos]; 
	--res = barcount > 1 ? vol / barcount : vol
	if barcount[period] > 1 then
	WWV[period]= vol[period] / barcount[period]
	else
	WWV[period]= vol[period]--volVal
	end
	
    if isOscillating and direction[period] < 0 then
	WWV[period]=-WWV[period]
	end
	 
	 
	if direction[period] > 0 then 
    WWV:setColor(period,  instance.parameters.color1);	
	else
    WWV:setColor(period,  instance.parameters.color2);		
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
