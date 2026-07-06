-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71960

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
    indicator:name("VAR Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
 
 
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("periodAMA", "period of AMA", "", 50, 1, 2000);
    indicator.parameters:addInteger("nfast", "First noise filter parameter", "", 15, 1, 2000);
    indicator.parameters:addInteger("nslow", "Second noise filter parameter", "", 10, 1, 2000);
	
    indicator.parameters:addInteger("offsetInPips", "Maximal offset signal dots from current price", "", 30, 1, 2000);	


    indicator.parameters:addDouble("G", "The power of filtered part in the moving average.", "", 1, 0, 2000);	
	indicator.parameters:addDouble("dK", "dK", "", 0.1, 0, 2000);	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 


	indicator.parameters:addGroup("Arrow Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
   indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local periodAMA, nfast,nslow,offsetInPips,G; 
local slowSC,fastSC,dSC,dKPoint;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	periodAMA=instance.parameters.periodAMA;
	nfast=instance.parameters.nfast;
	nslow=instance.parameters.nslow;
	offsetInPips=instance.parameters.offsetInPips;
	G=instance.parameters.G;
	dK=instance.parameters.dK;
	
	source = instance.source
	
	
	slowSC  = 2.0 / ( nslow + 1 );
    fastSC  = 2.0 / ( nfast + 1 );
    dSC     = fastSC - slowSC;
    dKPoint = dK * source:pipSize();
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  periodAMA.. "," ..  nfast .. "," ..     nslow .. "," ..     offsetInPips.. "," ..     G .. "," ..     dK  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first() ; 
	
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Center, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Center, instance.parameters.clrDN, 0);	
 
end


function Update(period, mode)

--	  Indicator:update(mode); 

	 if period < first then
	 return;
	 end 

    local signal    = math.abs( source.close[ period ] - source.close[ period-periodAMA+1 ] );
    local ER        = signal / getNoise( period );
    local ERSC      = ER * dSC;
    local SSC       = ERSC + slowSC;
    local ddK       = math.pow( SSC, G ) * ( source.close[period] - Line[period-1] );
    Line[period]        = Line[period-1] + ddK;
 
    
    local offset  = ( source.high[period] - source.low[period] ) / source:pipSize() * 2;

    if( offset < 5 )  then offset = 5; end
    if( offset > offsetInPips ) then offset = offsetInPips; end
    
 
 

    if( math.abs( ddK ) <= dKPoint ) then	
	return;
	end
    
	up:setNoData(period);
    down:setNoData(period);	
	
    if( ddK > 0 )  then   up:set(period, Line[period], "\108", Line[period]);    end
    if( ddK < 0 )  then   down:set(period, Line[period], "\108",Line[period]);	  end
	 
end


function  getNoise( period ) 
 
   local   noise = 0;
    
  for  i=1,  periodAMA , 1 do
    noise  =  noise + math.abs( source.close[ period -i+1] - source.close[ period -i+1-1 ] );
  end
  
  return noise;
end