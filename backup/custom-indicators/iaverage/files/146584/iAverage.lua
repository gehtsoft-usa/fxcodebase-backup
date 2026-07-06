-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72450

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
    indicator:name("iAverage");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("OmaLength", "Oma Length", "", 25, 1, 2000);
    indicator.parameters:addDouble("OmaSpeed", "Oma Speed", "", 8, -1.5, 2000); 
    indicator.parameters:addBoolean("OmaAdaptive", "Adaptive Oma", "", false); 
 
 
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;  


local E1=1
local E2=2
local E3=3
local E4=4
local E5=5
local E6=6
local res=7
local stored={};	
-- Routine
 function Prepare(nameOnly)   
 
    
	OmaLength=instance.parameters.OmaLength;
	OmaSpeed=instance.parameters.OmaSpeed; 
	OmaAdaptive=instance.parameters.OmaAdaptive; 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	first=source:first()+1 ; 
	
 
	 
	 for i=1, 7, 1 do
	 stored[i]= instance:addInternalStream(0, 0);  
	 end
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)
 

	 if period <= first  then
	 return;
	 end
	 
 
 
	 Line[period]= iAverage(  period );  
  
 
	if  Line[period] > Line[period-1] then
	Line:setColor(period,  instance.parameters.color1);		
	else
	Line:setColor(period,  instance.parameters.color2);	
	end
	
end


function iAverage(r)

 
 
   if (OmaLength <=1) then return(source[r]); end
   
 
   
   local  e1=stored[E1][r-1]   local e2=stored[E2][r-1];
   local e3=stored[E3][r-1];  local e4=stored[E4][r-1];
   local e5=stored[E5][r-1];  local e6=stored[E6][r-1];

 

      if OmaAdaptive    then
      
         local minPeriod = OmaLength/2.0;
         local maxPeriod = minPeriod*5.0;
         local    endPeriod = math.ceil(maxPeriod);
         
		 
		 if r <  endPeriod then
		 return(source[r]);
		 end
		 
		 
		   
				 
				 local tsignal   = math.abs((source[r]-stored[res][r-endPeriod+1 ]));
				 local noise     = 0.00000000001;
				 
				 
				 

					for   k=1,  endPeriod-1, 1  do noise=noise+math.abs(source[r]-stored[res][r-k+1 ]) ; end

					OmaLength = ((tsignal/noise)*(maxPeriod-minPeriod))+minPeriod;
		 
      end
      
  
      
      local  alpha = (2.0+OmaSpeed)/(1.0+OmaSpeed+OmaLength);

      e1 = e1 + alpha*(source[r]-e1); e2 = e2 + alpha*(e1-e2); local v1 = 1.5 * e1 - 0.5 * e2;
      e3 = e3 + alpha*(v1   -e3); e4 = e4 + alpha*(e3-e4); local v2 = 1.5 * e3 - 0.5 * e4;
      e5 = e5 + alpha*(v2   -e5); e6 = e6 + alpha*(e5-e6); local v3 = 1.5 * e5 - 0.5 * e6;
 

   stored[E1][r]   = e1;  stored[E2][r]  = e2;
   stored[E3][r]   = e3;  stored[E4][r]  = e4;
   stored[E5][r]   = e5;  stored[E6][r]  = e6;
   stored[res][r]  = source[r];
   return(v3);
end 