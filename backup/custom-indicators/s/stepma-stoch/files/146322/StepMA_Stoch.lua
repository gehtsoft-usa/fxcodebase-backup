-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72364

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
    indicator:name("StepMA Stoch");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("PeriodWATR", "PeriodWATR", "", 10, 1, 2000);
    indicator.parameters:addDouble("Kwatr", "Kwatr", "", 1, 0, 2000);
    indicator.parameters:addBoolean("HighLow", "HighLow", "", false);   	
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local PeriodWATR, Kwatr,HighLow; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	PeriodWATR=instance.parameters.PeriodWATR;
	Kwatr=instance.parameters.Kwatr;
	HighLow=instance.parameters.HighLow;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  PeriodWATR.. "," ..  Kwatr  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=Indicator.DATA:first() ; 
	
	
	Stream = instance:addInternalStream(0, 0);
 
	WATRmax= instance:addInternalStream(0, 0);
	WATRmin= instance:addInternalStream(0, 0);
	SminMin= instance:addInternalStream(0, 0);
	SmaxMin= instance:addInternalStream(0, 0);
	SminMax= instance:addInternalStream(0, 0);
	SmaxMax= instance:addInternalStream(0, 0);
	SminMid= instance:addInternalStream(0, 0);
	SmaxMid = instance:addInternalStream(0, 0);
	TrendMin= instance:addInternalStream(0, 0);
	TrendMax= instance:addInternalStream(0, 0);
	TrendMid= instance:addInternalStream(0, 0);
	
	WATR= instance:addInternalStream(0, 0);
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
 
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);	 
end


function Update(period, mode)


	 if period <= first + 1 then
	 WATRmin[period] = math.huge 
	 return;
	 end
	 
	 
	WATRmax[period]= WATRmax[period-1];
	WATRmin[period]= WATRmin[period-1];
	SminMin[period]= SminMin[period-1];
	SmaxMin[period]= SmaxMin[period-1];
	SminMax[period]= SminMax[period-1];
	SmaxMax[period]= SmaxMax[period-1];
	SminMid[period]= SminMid[period-1];
	SmaxMid[period] = SmaxMid[period-1];
	TrendMin[period]= TrendMin[period-1];
	TrendMax[period]= TrendMax[period-1];
	TrendMid[period]= TrendMid[period-1];

	WATR[period]= WATR[period-1];
 
	 if period <= first + 1+PeriodWATR then
	 return;
	 end
	 
   SumRange = 0.0;
 
	  for  iii = 0, PeriodWATR - 1,   1   do
	 
         dK = 1.0 + 1.0 * (PeriodWATR - iii) / PeriodWATR; 
         SumRange  = SumRange+ dK * math.abs(source.high[period  -  iii] - source.low[period - iii]); 
      end
  
	  WATR[period] = SumRange / PeriodWATR;  
	  WATRmax[period] = math.max(WATR[period], WATRmax[period]); 
	  WATRmin[period] = math.min(WATR[period], WATRmin[period]); 
	  
 
 
	  pKwatr = Kwatr / source:pipSize();
	  
	  StepSizeMin = math.floor(pKwatr * WATRmin[period]); 
	  StepSizeMax = math.floor(pKwatr * WATRmax[period]); 
     StepSizeMid = math.floor(pKwatr * 0.5 * (WATRmax[period] + WATRmin[period])); 
    
     SizeMin = StepSizeMin * source:pipSize();
     SizeMax = StepSizeMax * source:pipSize();
     SizeMid = StepSizeMid * source:pipSize();
 
     SizeMin2 = 2 * SizeMin;
     SizeMax2 = 2 * SizeMax;
     SizeMid2 = 2 * SizeMid;
 
 
 
	  if  (HighLow) then
	 
	    SmaxMin[period] = source.low[period] + SizeMin2; 
	    SminMin[period] = source.high[period] - SizeMin2; 
 
	    SmaxMax[period] = source.low[period] + SizeMax2; 
	    SminMax[period] = source.high[period] - SizeMax2; 
	 
	    SmaxMid[period] = source.low[period] + SizeMid2; 
	    SminMid[period] = source.high[period] - SizeMid2; 
	    
	    if(source.close[period] > SmaxMin[period-1])then TrendMin[period] = 1;  end
	    if(source.close[period] < SminMin[period-1]) then TrendMin[period] = -1;   end
	   
	    if(source.close[period] > SmaxMax[period-1]) then TrendMax[period] = 1;   end 
	    if(source.close[period] < SminMax[period-1])then TrendMax[period] = -1;   end
	    
	    if(source.close[period] > SmaxMid[period-1])then TrendMid[period] = 1;   end 
	    if(source.close[period] < SminMid[period-1])then TrendMid[period] = -1;   end
	  end

	  
	   if  not (HighLow) then
 
	    SmaxMin[period] = source.close[period] + SizeMin2; 
	    SminMin[period] = source.close[period] - SizeMin2; 
	   
	    SmaxMax[period] = source.close[period] + SizeMax2; 
	    SminMax[period] = source.close[period] - SizeMax2; 
	    
	    SmaxMid[period] = source.close[period] + SizeMid2; 
	    SminMid[period] = source.close[period] - SizeMid2; 
	    
	    if(source.close[period] > SmaxMin[period-1]) then
	                    TrendMin[period] = 1; end 
	    if(source.close[period] < SminMin[period-1]) then
	                    TrendMin[period] = -1;end 
	    
	    if(source.close[period] > SmaxMax[period-1]) then 
	                    TrendMax[period] = 1;end  
	    if(source.close[period] < SminMax[period-1]) then 
	                    TrendMax[period] = -1; end
	    
	    if(source.close[period] > SmaxMid[period-1]) then 
	                    TrendMid[period] = 1; end 
	    if(source.close[period] < SminMid[period-1]) then 
	                    TrendMid[period] = -1; end
	  end
	  
	  
	  if(TrendMin[period] > 0 and SminMin[period] < SminMin[period-1]) then
	                               SminMin[period] = SminMin[period-1]; end
	  if(TrendMin[period] < 0  and SmaxMin[period] > SmaxMin[period-1])  then
	                               SmaxMin[period] = SmaxMin[period-1];  end
		
	  if(TrendMax[period] > 0  and SminMax[period] < SminMax[period-1])  then
	                               SminMax[period] = SminMax[period-1];  end
	  if(TrendMax[period] < 0  and SmaxMax[period] > SmaxMax[period-1])  then
	                               SmaxMax[period] = SmaxMax[period-1];  end
	  
	  if(TrendMid[period] > 0  and SminMid[period] < SminMid[period-1])  then
	                               SminMid[period] = SminMid[period-1];  end
	  if(TrendMid[period] < 0  and SmaxMid[period] > SmaxMid[period-1])  then
	                               SmaxMid[period] = SmaxMid[period-1]; end
                           
	  if (TrendMin[period] > 0) then
	            linemin = SminMin[period] + SizeMin; end
	  if (TrendMin[period] < 0) then 
	            linemin = SmaxMin[period] - SizeMin; end
	  
	  if (TrendMax[period] > 0)  then
	            linemax = SminMax[period] + SizeMax; end
	  if (TrendMax[period] < 0)  then
	            linemax = SmaxMax[period] - SizeMax; end
	  
	  if (TrendMid[period] > 0) then 
	            linemid = SminMid[period] + SizeMid; end
	  if (TrendMid[period] < 0) then
	            linemid = SmaxMid[period] - SizeMid; end
	 
	  bsmin = linemax - SizeMax; 
	  bsmax = linemax + SizeMax; 
	 
	  Line1[period] = (linemin - bsmin) / (bsmax - bsmin); 
	  Line2[period] = (linemid - bsmin) / (bsmax - bsmin); 
 
	 
	 
	
end