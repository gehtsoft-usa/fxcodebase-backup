-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72626

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
    indicator:name("Volatility breakout indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 

 
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("InpBandsPeriod", "Period", "", 18, 1, 2000);
    indicator.parameters:addInteger("Smooth", "Smoothness", "", 2, 1, 2000);
    indicator.parameters:addInteger("cp", "Fractals periods", "", 10, 1, 2000);
    indicator.parameters:addDouble("change", "Percent change to modify the upper/lower channel", "", 0.1, 0, 2000);
	
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
 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	InpBandsPeriod=instance.parameters.InpBandsPeriod;
	Smooth=instance.parameters.Smooth;
	cp=instance.parameters.cp;
	change=instance.parameters.change;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  InpBandsPeriod.. "," ..  Smooth  .. "," ..  cp.. "," .. change  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first()+InpBandsPeriod ; 
	
	
	StdDev = instance:addInternalStream(0, 0);
    VolDer= instance:addInternalStream(0, 0);
	BOTy= instance:addInternalStream(0, 0);
	TOPy= instance:addInternalStream(0, 0);	
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color, first+InpBandsPeriod+1 +Smooth);
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:addLevel(0);	


    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color, first+InpBandsPeriod+1+Smooth );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:addLevel(0);	 
end


function Update(period, mode)

	--  Indicator:update(mode); 


	 if period <= first then
	 return;
	 end
    StdDev[period] = mathex.stdev(source.close, period-InpBandsPeriod, period)
	
	 if period <= first +InpBandsPeriod+1 then
	 return;
	 end
	 
    local lowindex, highindex = mathex.minmax( StdDev, period-1-InpBandsPeriod, period-1)
	
 
	VolDer[period] = (StdDev[period]-highindex)/(highindex-lowindex)
	
	 if period <= first +InpBandsPeriod+1+Smooth then
	 return;
	 end	
	local VolSmooth = mathex.avg(VolDer, period-Smooth, period)
 
	
	 
	 if VolSmooth>0 then
	  VolSmooth = 0
	 elseif VolSmooth<-1.0 then
	  VolSmooth = -1.0
	 end 
	 
	 if period <= first+2*cp+1 then
	 return;
	 end	 
	 
	local lowest, highest=mathex.minmax(source, period-2*cp+1, period)
 
		if source.high[period-cp] >= highest then
		 LH = 1
		else
		 LH = 0
		end 
		 
		if source.low[period-cp] <= lowest  then
		 LL = -1
		else
		 LL = 0
		end 
		 
		 
	BOTy[period]= BOTy[period-1];
	TOPy[period]= TOPy[period-1];	
	Top[period]= Top[period-1];
	Bottom[period]= Bottom[period-1];	
	
		if LH == 1 then
		 TOPy[period] = source.high[period-cp]
		end 
		 
		if LL == -1 then
		 BOTy[period] = source.low[period-cp]
		end 
 
 
if VolSmooth == -1.0 then 
 if math.abs(TOPy[period]-Top[period])/source.close[period]>change/100 then 
  Top[period] = TOPy[period]
 end 
 if math.abs(BOTy[period]-Bottom[period])/source.close[period]>change/100 then 
   Bottom[period] = BOTy[period]
 end 
end 
 
	
 
end
 