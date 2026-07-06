-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72198

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
    indicator:name(" Hilbert MA");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("inpPeriod", "Base period", "", 20, 1, 2000);
 
	indicator.parameters:addString("inpPrice", "Price", "", "median");
	indicator.parameters:addStringAlternative("inpPrice","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("inpPrice", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("inpPrice", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("inpPrice", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("inpPrice", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("inpPrice", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("inpPrice", "WEIGHTED", "", "weighted");
 
    indicator.parameters:addInteger("inpLevels", "Levels period", "", 10, 1, 2000);	


    indicator.parameters:addDouble("inpCyclesPeriod", "Levels period", "", 2, 0, 2000);	
    indicator.parameters:addDouble("inpCyclesFilter", "Cycles filter ( =1 for no filtering)", "", 1, 1, 2000);	
    indicator.parameters:addDouble("inpDelta", "Delta", "", 0.5, 0, 2000);	
    indicator.parameters:addDouble("inpFraction", "Fraction", "", 0.5, 0, 2000);	
	
 
 
	indicator.parameters:addGroup("Style");  
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local inpPeriod,inpPrice,inpLevels,inpCyclesPeriod,inpCyclesFilter,inpDelta,inpFraction; 
local first;
local source = nil;
local g_cycleFilter,  g_alphal, g_dPeriod;
local Oscillator;  
 

-- Routine
 function Prepare(nameOnly)   
 
    inpPeriod= instance.parameters.inpPeriod;
    inpPrice= instance.parameters.inpPrice;
    inpLevels = instance.parameters.inpLevels;
	inpCyclesPeriod = instance.parameters.inpCyclesPeriod;
	inpCyclesFilter= instance.parameters.inpCyclesFilter;
	inpDelta= instance.parameters.inpDelta;	
	inpFraction= instance.parameters.inpFraction; 
	
 
 
    g_cycleFilter = 2.0/(1.0+inpCyclesFilter);
    g_alphal      = 2.0/(1.0+inpLevels);
    g_dPeriod     = 2*inpPeriod;	

	
	local Parameters= inpPeriod ..  ", " .. inpPrice ..  ", " .. inpLevels..  ", " ..inpCyclesPeriod ..  ", " .. inpCyclesFilter ..  ", " .. inpDelta  ..  ", " ..   inpFraction;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
     
    
    first=source:first()+6;
	
	apeak = instance:addInternalStream(0, 0); 
    avaley = instance:addInternalStream(0, 0); 
	sumbp= instance:addInternalStream(0, 0); 
	deltaPhase= instance:addInternalStream(0, 0);
	smooth= instance:addInternalStream(0, 0);
	Q1= instance:addInternalStream(0, 0);
	I1= instance:addInternalStream(0, 0);
	Period= instance:addInternalStream(0, 0);
	detrender= instance:addInternalStream(0, 0);
	phase= instance:addInternalStream(0, 0);
 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color, first);
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:setPrecision(math.max(2, source:getPrecision()));
 
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    --Indicator[1]:update(mode);
 
	Period[period]     = 1;  
    deltaPhase[period] = 7;  
    smooth[period] = source[inpPrice][period];  
	Q1[period]  = source[inpPrice][period];  
	I1[period] = source[inpPrice][period]; 
     
	
    if period <= first then
	return;
	end
	
	
	
	
	 iHilbertPhase (  period);
	 
    if (period <=Period[period])  then
    return ;	
    end
 	Line[period]=mathex.avg(source[inpPrice], period - Period[period] +1 , period);	  
end


function iHilbertPhase(  period)
 

 
    if (period <6)  then
    return 0;	
    end
    local cyclesToReach = inpCyclesPeriod* 360.0;



	
	smooth[period]     = (4.0*source[inpPrice][period] +3.0*source[inpPrice][period-1] +2.0*source[inpPrice][period-2] +source[inpPrice][period-3] )/10.0; 
	detrender[period] = ((0.0962* smooth[period] + 0.5769*smooth[period-2] - 0.5769*smooth[period-4]- 0.0962*smooth[period-6]) * (0.075*Period[period-1] + 0.54)) 
    Q1[period]         = 0.15*((0.0962* detrender[period] + 0.5769*detrender[period-2] - 0.5769*detrender[period-4]- 0.0962*detrender[period-6]) * (0.075*Period[period-1] + 0.54))   +0.85*Q1[period-1] ;
    I1[period]         = 0.15*detrender[period-3] +0.85*I1[period-1] ;
	
	
	
	
	if  (I1[period]==0) then
	phase[period]=phase[period-1];
	else
	phase[period] =   180.0/math.pi*math.atan(math.abs(Q1[period] /I1[period] ));
	end
	
 
	 
	      
            if (I1[period] <0 and Q1[period] >0) then phase[period]  = 180.0-phase[period] ; end
            if (I1[period] <0 and Q1[period] <0) then phase[period]  = 180.0+phase[period] ; end
            if (I1[period] >0 and Q1[period] <0) then phase[period]  = 360.0-phase[period] ; end
			
			
		  deltaPhase[period] = phase[period-1] -phase[period] ;
		  
		
		 if (phase[period-1] <90.0 and phase[period] >270.0) then deltaPhase[period]  = 360.0+phase[period-1] -phase[period] ; end
         if (deltaPhase[period] >60.0) then deltaPhase[period]  = 60.0; end
         if (deltaPhase[period] < 7.0) then deltaPhase[period]  =  7.0; end



		 
		 local phaseSum = 0; 
		  local k=0;
		  while true do
		  
		  if phaseSum >  cyclesToReach or period- k <= first then
		  break
		  end
		  
		  phaseSum = phaseSum + deltaPhase[period-k]
		
		  k= k+1;
		  end

 

 
		  
          Period[period]= Period[period-1] +g_cycleFilter*(k-Period[period-1] );
  
		  
	 
end

 