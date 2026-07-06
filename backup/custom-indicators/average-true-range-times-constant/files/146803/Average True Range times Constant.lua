-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72530

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

function Init()
    indicator:name("Average True Range times Constant");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 7, 1, 2000);
     indicator.parameters:addDouble("Coeff", "Coeff", "", 3, 0, 2000);
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period, Coeff; 
local first;
local source = nil;
 
local Line;

-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Period= instance.parameters.Period;
    Coeff = instance.parameters.Coeff;
	
	
	local Parameters= Period ..  ", " .. Coeff;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    ATR = core.indicators:create("ATR", source , Period);
    first=ATR.DATA:first()+1;
	
	ref= instance:addInternalStream(0, 0);
	inv= instance:addInternalStream(0, 0);
   
 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color1, first);
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    ATR:update(mode); 

    if period<1 then
	return;
	end	
	
    inv[period]=inv[period-1]+1;
	Line[period]=Line[period-1];
	ref[period]=ref[period-1];
	
    if period <= first  then


    local arc=Coeff*ATR.DATA[period-1];	
	
			 if source.close[period]>=source.close[period-1] then
			  ref[period]=source.close[period]
			  Line[period]=source.close[period]-arc
			 elseif source.close[period]<source.close[period-1] then
			  ref[period]=source.close[period]
			  Line[period]=source.close[period]+arc
			 end 
			 inv[period]=period;
		 
	return;
	end
	
	
    local arc=Coeff*ATR.DATA[period-1];	
 
 
 
 
	 if source.close[period] < Line[period]
	 and source.close[period-1] >= Line[period-1]
	 then
	  Line[period]=source.close[period]+arc
	  inv[period]=1;
	 end
	 if source.close[period]> Line[period]
	 and source.close[period-1] <= Line[period-1]	 
	 then
	  Line[period]=source.close[period]-arc
	  inv[period]=1;
      end


 
	
	if  inv[period] > period
	then
	return;
	end
	
	
	local min,max=mathex.minmax(source.close, period -inv[period],period-1   );	
	 if source.close[period]>=Line[period]  then
	  ref[period]=max
	  Line[period]=ref[period]-arc
	 end 
	 if source.close[period]<Line[period]     then
	  ref[period]=min
	  Line[period]=ref[period]+arc
	 end 
	 
	 
	if source.close[period]  > Line[period] then
	Line:setColor(period,  instance.parameters.color1);	
	else
	Line:setColor(period,  instance.parameters.color2);	
    end	
end
 
 
 

 --[[
 
 //period=7
//coeff=3
 
mioATR=AverageTrueRange[period](close)
arc=coeff*mioATR[1]
 
once ref=open
if barindex=8 then
 if close>=close[1] then
  ref=close
  mioSAR=close-arc
 elsif close<close[1] then
  ref=close
  mioSAR=close+arc
 endif
 inv=barindex[1]
endif
 
if barindex>8 then
 if close crosses under mioSAR then
  mioSAR=close+arc
  inv=barindex
 endif
 if close crosses over mioSAR then
  mioSAR=close-arc
  inv=barindex
 endif
 
 
 if close>=mioSAR and (barindex-inv)>0 then
  ref=highest[barindex-inv](close[1])
  mioSAR=ref-arc
 endif
 if close<mioSAR and (barindex-inv)>0 then
  ref=lowest[barindex-inv](close[1])
  mioSAR=ref+arc
 endif
 
 
 endif
 
if close>mioSAR then
 red=210
 blu=0
else
 red=0
 blu=250
endif
 
 
return mioSAR coloured (red,0,blu) as "Wilder's ARC stop"
 ]]
 
 

 
 