-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72140

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
    indicator:name("Smoothed Bar Correlation");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 


 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("SmthPeriod", "Smooth Period", "", 7, 1, 2000);
    indicator.parameters:addInteger("CorrPeriod", "Corelation Period", "", 7, 1, 2000);
	
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
local SmthPeriod, CorrPeriod;  

-- Routine
 function Prepare(nameOnly)   
 
    
	SmthPeriod=instance.parameters.SmthPeriod;
	CorrPeriod=instance.parameters.CorrPeriod;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  SmthPeriod.. "," ..  CorrPeriod  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	first=source:first()+1 ; 
	
	
	A1 = instance:addInternalStream(0, 0);
 	A2 = instance:addInternalStream(0, 0);
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first+CorrPeriod );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

 

	 if period <= first  then
	 return;
	 end 
  
       A1[period] = source.close[period]-source.open[period ];
       A2[period] = source.close[period-1]-source.open[period-1];
	   
 
	 if period <= first + CorrPeriod  then
	 return;
	 end
	
     local ExtDBuffer  = DataCorr(period );
     Line[period]=((SmthPeriod-1)*Line[period-1]+ ExtDBuffer)/SmthPeriod;
	 
 
	
end 
 
function DataCorr( period )
 
 
    local  SCorr;
	local AMean, BMean, AVar, BVar, ABCov=0,0,0,0,0;
    local  jj;
    localSCorr = 0.;
    localAMean = 0.;
    localBMean = 0.;
    localAVar =  0.;
    localBVar =  0.;
    localABCov = 0.;
    localSCorr = 0.;
	
 
  
    for jj= 0,CorrPeriod-1 , 1   do
 
      AMean  =AMean+ A1[period-jj];
      BMean  =BMean+ A2[period-jj];    
    end
	
     AMean = AMean/CorrPeriod;
     BMean = BMean/CorrPeriod;
 
    for jj= 0,CorrPeriod-1 , 1   do
     
       AVar  = AVar + (A1[period-jj]-AMean)*(A1[period-jj]-AMean);
       BVar  = BVar+ (A2[period-jj]-BMean)*(A2[period-jj]-BMean);
     end 
	 
      AVar = AVar/(CorrPeriod-1); 
      BVar = BVar/(CorrPeriod-1); 
 
    for jj= 0,CorrPeriod-1 , 1   do
     
     ABCov = ABCov + (A1[period-jj]-AMean)*(A2[period-jj]-BMean); 
    end
      ABCov = ABCov/(CorrPeriod-1);  
 
     if( AVar>0. and  BVar>0.)  then SCorr = ABCov/(math.sqrt(AVar*BVar)) end;
	 
    return (SCorr);
end
