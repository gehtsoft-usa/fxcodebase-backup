-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71726

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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
    indicator:name("Volatility StepChannel");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addDouble("InpScaleFactor", " Scale factor", "", 2.25, 0, 2000);
    indicator.parameters:addInteger("InpMaPeriod", "Smooth Period", "", 3, 1, 2000);	
    indicator.parameters:addInteger("InpVolatilityPeriod", "Volatility Period", "", 70, 1, 2000);
    indicator.parameters:addInteger("InpFastPeriod", " Fast Period", "", 10, 1, 2000);	 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Cental Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
    indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);

    indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local InpScaleFactor,InpMaPeriod,InpVolatilityPeriod,InpFastPeriod,Method; 
local first,FIRST;
local source = nil;
 
local Cental, Top, Bottom;
-- Routine
 function Prepare(nameOnly)   
 
 
    InpScaleFactor= instance.parameters.InpScaleFactor;
    InpMaPeriod= instance.parameters.InpMaPeriod;
	InpVolatilityPeriod= instance.parameters.InpVolatilityPeriod;
	InpFastPeriod= instance.parameters.InpFastPeriod; 
	
	
	local Parameters= InpScaleFactor..", "..InpMaPeriod..", "..InpVolatilityPeriod..", "..InpFastPeriod;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=math.max(source:first() +InpFastPeriod,InpMaPeriod);  
    FIRST=  first+InpVolatilityPeriod ;	
	
	
	Stdev= instance:addInternalStream(0, 0);
	
	UpperBuffer= instance:addInternalStream(0, 0);	
	LowerBuffer= instance:addInternalStream(0, 0);	
	MiddleBuffer= instance:addInternalStream(0, 0);
	
	HighBuffer= instance:addInternalStream(0, 0);
	LowBuffer= instance:addInternalStream(0, 0);
    CloseBuffer= instance:addInternalStream(0, 0);
	
   
 
	Central = instance:addStream("Central" , core.Line, " Central"," Central",instance.parameters.color, FIRST+InpMaPeriod );
	Central:setWidth(instance.parameters.width);
    Central:setStyle(instance.parameters.style);
    Central:setPrecision(math.max(2, source:getPrecision()));

	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.color1, FIRST+InpMaPeriod );
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
    Top:setPrecision(math.max(2, source:getPrecision()));

	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.color2, FIRST+InpMaPeriod);
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
    Bottom:setPrecision(math.max(2, source:getPrecision()));	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < source:first() +InpFastPeriod   
	then
	return;
	end
	 
 
	Stdev[period]= mathex.stdev(source, period-InpFastPeriod+1, period);
	
	
	if period < first 
	then
	return;
	end	
	
	local H= mathex.avg(source.high, period-InpMaPeriod+1, period);
	local L= mathex.avg(source.low, period-InpMaPeriod+1, period);
	local C= mathex.avg(source.close, period-InpMaPeriod+1, period); 	
	
	
	if period < FIRST 
	then
	return;
	end		
  
	local base= mathex.avg(Stdev, period-InpVolatilityPeriod+1, period)*InpScaleFactor;		
 
	 
      if((H-base)>HighBuffer[period-1]) then HighBuffer[period]=H;
      elseif(H+base<HighBuffer[period-1]) then  HighBuffer[period]=H+base;
      else HighBuffer[period]=HighBuffer[period-1]; end
 
      if(L+base<LowBuffer[period-1])then LowBuffer[period]=L;
      elseif((L-base)>LowBuffer[period-1])then LowBuffer[period]=L-base;
      else LowBuffer[period]=LowBuffer[period-1]; end
	  
 
      if((C-base/2)>CloseBuffer[period-1]) then CloseBuffer[period]=C-base/2;
      elseif(C+base/2<CloseBuffer[period-1]) then CloseBuffer[period]=C+base/2;
      else CloseBuffer[period]=CloseBuffer[period-1]; end
 
 
      MiddleBuffer[period]=(HighBuffer[period]+LowBuffer[period]+CloseBuffer[period]*2)/4;
      UpperBuffer[period]=HighBuffer[period] + base/2;
      LowerBuffer[period]=LowBuffer[period]  - base/2;
	  
	  
	if period < FIRST+ InpMaPeriod 
	then
	return;
	end		
 
      Top[period]=mathex.avg(UpperBuffer, period-InpMaPeriod+1, period);
      Bottom[period]=mathex.avg(LowerBuffer, period-InpMaPeriod+1, period);
      Central[period]=mathex.avg(MiddleBuffer, period-InpMaPeriod+1, period);

 
end


 