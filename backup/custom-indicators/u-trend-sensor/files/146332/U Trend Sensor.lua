-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72370

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
    indicator:name("U Trend Sensor");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
 

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("periodf", "Fast Period", "", 50, 1, 2000);
    indicator.parameters:addInteger("periods", "Slow Period", "", 200, 1, 2000);

    indicator.parameters:addDouble("fpercent", "Fast percent", "", 1, 0, 2000);
    indicator.parameters:addDouble("spercent", "Slow percent", "", 0.5, 0, 2000);
	
    indicator.parameters:addInteger("p", "Period", "", 10, 1, 2000);
    indicator.parameters:addInteger("psignal", "Signal Period", "", 20, 1, 2000);	
	
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
local periodf, periods; 
local fpercent, spercent; 
local p, psignal; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	periodf=instance.parameters.periodf;
	periods=instance.parameters.periods;
	fpercent=instance.parameters.fpercent;
	spercent=instance.parameters.spercent;	
	p=instance.parameters.p;
	psignal=instance.parameters.psignal;		
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  periodf.. "," ..  periods .. "," ..  fpercent.. "," ..  psignal .. "," ..  p.. "," ..  spercent.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator1= core.indicators:create("TMA", source, periodf);
	Indicator2= core.indicators:create("TMA", source, periods);	
	first=math.max(Indicator1.DATA:first(),Indicator1.DATA:first()) ; 
	
	
	U = instance:addInternalStream(0, 0);
	fss= instance:addInternalStream(0, 0);
 	sss= instance:addInternalStream(0, 0);
	
	Indicator3= core.indicators:create("EMA", U, p);	
	Indicator4= core.indicators:create("EMA", Indicator3.DATA, psignal);		
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, Indicator3.DATA:first() );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
 
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, Indicator4.DATA:first() );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);	 
end


function Update(period, mode)

	Indicator1:update(mode); 
	Indicator2:update(mode);
	
	 if period <= first then 
	 return;
	 end
	 

    fss[period] = source[period]
    sss[period] = source[period]
 
	

	local fMA = Indicator1.DATA[period]
	local sMA = Indicator2.DATA[period]

	if(fMA > fss[period] + (fMA/100)*fpercent) then
	  fss[period] = fMA
	elseif (fMA < fss[period] - (fMA/100)*fpercent) then
	  fss[period] = fMA    
	end

	if(sMA > sss[period] + (sMA/100)*spercent) then
	  sss[period] = sMA
	elseif (sMA < sss[period] - (sMA/100)*spercent) then
	  sss[period] = sMA   
	end

   U[period] = fss[period] - sss[period];
   
  	Indicator3:update(mode); 
  	Indicator4:update(mode); 
	
	 if period <= Indicator3.DATA:first() or period <= Indicator4.DATA:first()  then
	 return;
	 end
	 
   Line1[period] = Indicator3.DATA[period];
   Line2[period] = Indicator4.DATA[period];
 

 
end

--[[
once fss = close
once sss = close

fMA = TriangularAverage[periodf](close)
sMA = TriangularAverage[periods](close)

if(fMA > fss + (fMA/100)*fpercent) THEN
  fss = fMA
ELSIF (fMA < fss - (fMA/100)*fpercent) THEN
  fss = fMA
ELSE
  fss = fss
ENDIF

if(sMA > sss + (sMA/100)*spercent) THEN
  sss = sMA
ELSIF (sMA < sss - (sMA/100)*spercent) THEN
  sss = sMA
ELSE
  sss = sss
ENDIF

U = fss - sss
UMM = exponentialaverage[p](U)

if(plotsignal) THEN
  signal = average[psignal](UMM)
ENDIF

RETURN UMM as "U Trend Sensor", signal as "signal", 0 as "zero level"
]]
 