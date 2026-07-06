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
    indicator:name("Step One more average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("OmaLength", "Oma Length", "", 25, 1, 2000);
    indicator.parameters:addDouble("OmaSpeed", "Oma Speed", "", 8, -1.5, 2000);
    indicator.parameters:addDouble("Sensitivity", "Sensitivity", "", 5, 0, 2000);
    indicator.parameters:addDouble("StepSize", "Constant Step Size", "", 10, 0, 2000);	 
    indicator.parameters:addBoolean("OmaAdaptive", "Adaptive Oma", "", false);
    indicator.parameters:addBoolean("HighLow", " High/Low Mode Switch (more sensitive)", "", false);
 
 
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
local Point; 

local workStep={};
 
local _smin=1
local _smax=2
local _trend=3

local size;	
-- Routine
 function Prepare(nameOnly)   
 
    
	OmaLength=instance.parameters.OmaLength;
	OmaSpeed=instance.parameters.OmaSpeed;
	Sensitivity=instance.parameters.Sensitivity;
	StepSize=instance.parameters.StepSize;
	OmaAdaptive=instance.parameters.OmaAdaptive;
	HighLow=instance.parameters.HighLow;
	source = instance.source
	Point=source:pipSize();
	
 
    if (Sensitivity == 0) then Sensitivity = 0.0001; end
    if (StepSize    == 0) then StepSize    = 0.0001; end

	size = Sensitivity*StepSize;	
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    assert(core.indicators:findIndicator("IAVERAGE") ~= nil, "Please, download and install IAVERAGE.LUA indicator");
	
    if HighLow then	
	Indicator1= core.indicators:create("IAVERAGE", source.high, OmaLength, OmaSpeed, OmaAdaptive);
	Indicator2= core.indicators:create("IAVERAGE", source.low, OmaLength, OmaSpeed, OmaAdaptive);	
    else
	Indicator1= core.indicators:create("IAVERAGE", source.close, OmaLength, OmaSpeed, OmaAdaptive);
	Indicator2= core.indicators:create("IAVERAGE", source.close, OmaLength, OmaSpeed, OmaAdaptive);		
    end	
	first=Indicator1.DATA:first() ; 
	
	
	for i= 1, 3, 1 do
    workStep[i]= instance:addInternalStream(0, 0);
    end	
	 
	 LineBuffer= instance:addInternalStream(0, 0);
	 DnBuffera= instance:addInternalStream(0, 0);
	 DnBufferb= instance:addInternalStream(0, 0);
	 smin= instance:addInternalStream(0, 0);
	 smax= instance:addInternalStream(0, 0);  
 
	 High= instance:addInternalStream(0, 0);
	 Low= instance:addInternalStream(0, 0);	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

	  Indicator1:update(mode); 
	  Indicator2:update(mode);
	  
	 if period <  first then
	 return;
	 end
 
	
	 High[period]= Indicator1.DATA[period]
	 Low[period]= Indicator2.DATA[period]	
	 
	 
    Line[period]=  iStepMa(  period);
 
 
	if source.close[period]> Line[period] then
	Line:setColor(period,  instance.parameters.color1);		
	else
	Line:setColor(period,  instance.parameters.color2);	
	end
	
end
 


function iStepMa(r)
 

      local  result;  
      
      if (r==first) then
       
         workStep[_smax][r]  = High[r]+2.0*size*Point;
         workStep[_smin][r]  = Low[r] -2.0*size*Point;
         workStep[_trend][r] = 0;
         return(source.close[r]);
     end

 
      workStep[_smax][r]  = High[r]+2.0*size*Point;
      workStep[_smin][r]  = Low[r] -2.0*size*Point;
      workStep[_trend][r] = workStep [_trend][r-1];
	  
	  
            if (source.close[r]>workStep[_smax][r-1]) then workStep[_trend][r] =  1; end
            if (source.close[r]<workStep [_smin][r-1]) then workStep [_trend][r] = -1; end
			
            if (workStep[_trend][r] ==  1) then  if (workStep[_smin][r] < workStep[_smin][r-1]) then workStep[_smin][r]=workStep [_smin][r-1]; result = workStep[_smin][r]+size*Point; else  result =Line[r-1] end end
            if (workStep[_trend][r] == -1) then  if (workStep[_smax][r] > workStep [_smax][r-1]) then workStep [_smax][r]=workStep [_smax][r-1]; result = workStep[_smax][r]-size*Point; else  result =Line[r-1] end end
     

   return(result); 
end

 