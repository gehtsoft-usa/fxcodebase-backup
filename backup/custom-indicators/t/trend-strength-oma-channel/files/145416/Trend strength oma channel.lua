-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71995

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
    indicator:name("Trend strength oma channel");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("OmaLength", "OmaLength", "", 21, 1, 2000);
    indicator.parameters:addInteger("HighLowPeriod", "HighLowPeriod", "", 30, 1, 2000);
    indicator.parameters:addDouble("OmaSpeed", "OmaSpeed", "", 8, 1, 2000);
    indicator.parameters:addBoolean("Adaptive", "Adaptive", "", false);	
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 

	 indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0));  
	
end



 
 
 


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local OmaLength, HighLowPeriod,OmaSpeed; 
 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	OmaLength=instance.parameters.OmaLength;
	HighLowPeriod=instance.parameters.HighLowPeriod;
	Adaptive=instance.parameters.Adaptive;
	OmaSpeed=instance.parameters.OmaSpeed;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  OmaLength.. "," ..  HighLowPeriod .. "," ..  OmaSpeed .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
	  Average= instance:addInternalStream(0, 0);
      e1 =  instance:addInternalStream(0, 0);
      e2=  instance:addInternalStream(0, 0);
	  v1=  instance:addInternalStream(0, 0);
      e3 =  instance:addInternalStream(0, 0);
	  e4  =  instance:addInternalStream(0, 0);
	  v2  =  instance:addInternalStream(0, 0);
	  e5  =  instance:addInternalStream(0, 0);
	  e6  =  instance:addInternalStream(0, 0);
	  v3 =  instance:addInternalStream(0, 0);	
	
	Indicator1= core.indicators:create("MVA", source, 5);
	Indicator2= core.indicators:create("MVA", source, 10);
	Indicator3= core.indicators:create("MVA", source, 20);
	Indicator4= core.indicators:create("MVA", source, 30);
	Indicator5= core.indicators:create("MVA", source, 40);
	Indicator6= core.indicators:create("MVA", source, 50);
	Indicator7= core.indicators:create("MVA", source, 60);
	Indicator8= core.indicators:create("MVA", source, 70);
	Indicator9= core.indicators:create("MVA", source, 80);
	Indicator10= core.indicators:create("MVA", source, 90);	
	first=Indicator10.DATA:first() ; 
	
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style); 

    Top = instance:addStream("Top",  core.Line, name, "Top", instance.parameters.color1, first+HighLowPeriod );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style); 

    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, first+HighLowPeriod );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style); 
end


function Update(period, mode)

	Indicator1:update(mode); 
	Indicator2:update(mode); 
	Indicator3:update(mode); 
	Indicator4:update(mode); 
	Indicator5:update(mode); 
	Indicator6:update(mode); 
	Indicator7:update(mode); 
	Indicator8:update(mode); 
	Indicator9:update(mode); 
	Indicator10:update(mode); 
	 if period <= first then
	 return;
	 end
         
    Average[period]= ( 9*Indicator1.DATA[period] - Indicator2.DATA[period]- Indicator3.DATA[period]- Indicator4.DATA[period]- Indicator5.DATA[period]- Indicator6.DATA[period]- Indicator7.DATA[period]- Indicator8.DATA[period]- Indicator9.DATA[period])/9;
	
    Line[period] =  AverageFunction(period); 
	
	 if period <= first+HighLowPeriod then
	 return;
	 end
	  
	 local min,max=mathex.minmax(Line, period-HighLowPeriod+1, period); 
	 
	 Top[period]=max;
	 Bottom[period]=min;	 

end


function AverageFunction(period) 

	      if Adaptive then
       
				 local  minPeriod =instance.parameters.OmaLength/2.0;
				 local  maxPeriod = minPeriod*5.0;
				 local    endPeriod = math.ceil(maxPeriod);
				 local  signal = math.abs(Average[period]-Average[period-endPeriod]);
				 local noise  = 0.00000000001;

					for k=1, endPeriod-1, 1  do noise=noise+math.abs(Average[period]-Average[period-k+1]); end

					OmaLength = ((signal/noise)*(maxPeriod-minPeriod))+minPeriod;
           end  
 
      
      local  alpha = (2.0+OmaSpeed)/(1.0+OmaSpeed+OmaLength);

      e1[period] = e1[period-1] + alpha*(Average[period]-e1[period-1]);
      e2[period] = e2[period-1] + alpha*(e1[period]-e2[period-1]); 
	  v1[period] = 1.5 * e1[period] - 0.5 * e2[period];
      e3[period] = e3[period-1] + alpha*(v1[period]   -e3[period-1]); 
	  e4[period] = e4[period-1] + alpha*(e3[period]-e4[period-1]);
	  v2[period] = 1.5 * e3[period] - 0.5 * e4[period];
	  e5[period] = e5[period-1] + alpha*(v2[period]   -e5[period-1]);
	  e6[period] = e6[period-1] + alpha*(e5[period]-e6[period-1]); 
	  


    return  1.5 * e5[period] - 0.5 * e6[period];
	  
	  
	  

end

 