-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71884

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
    indicator:name("AMA Optimized");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("periodAMA", "AMA Period", "", 10, 1, 2000);
    indicator.parameters:addDouble("nfast", "Fast MA", "", 2, 1, 2000);
    indicator.parameters:addDouble("nslow", "Slow MA", "", 30, 1, 2000);	
 
    indicator.parameters:addDouble("G", "G", "", 2, 1, 2000);
    indicator.parameters:addDouble("dK", "dK", "", 2, 1, 2000);
   
   
    indicator.parameters:addInteger("AMA_Trend_Type", "MA Method", "Method" , 0);
    indicator.parameters:addIntegerAlternative("AMA_Trend_Type", "First", "First" , 0);
    indicator.parameters:addIntegerAlternative("AMA_Trend_Type", "Second", "Second" , 1);
 
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

	 indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0)); 	 
	 indicator.parameters:addColor("Neutral", "Neutral Line Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local periodAMA, nfast, nfast, G, dK,AMA_Trend_Type; 
local Indicator;
local slowSC, fastSC, dFS;	
-- Routine
 function Prepare(nameOnly)   
 
    
	periodAMA=instance.parameters.periodAMA;
	nfast=instance.parameters.nfast;
	nslow=instance.parameters.nslow;
	G=instance.parameters.G;
	dK=instance.parameters.dK;	
	AMA_Trend_Type=instance.parameters.AMA_Trend_Type;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  periodAMA.. "," ..  nfast.. "," ..  nslow.. "," ..  G.. "," ..  dK.. "," ..  G  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	first=source:first()+1 ; 
	
    slowSC=(2.0 /(nslow+1));
    fastSC=(2.0 /(nfast+1));
    dFS=fastSC-slowSC;
	
	AbsBuffer = instance:addInternalStream(0, 0);
	AMA2Buffer = instance:addInternalStream(0, 0);
	SumAMABuffer = instance:addInternalStream(0, 0);
	StdAMA = instance:addInternalStream(0, 0);
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.Neutral, first + periodAMA);
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

 

	 if period < first then
	 return;
	 end
 
	AbsBuffer[period]=math.abs(source[period]-source[period-1]);
	
	 if period < first + periodAMA then
	 return;
	 end 	
	  local Noise=mathex.sum(AbsBuffer, period-periodAMA+1, period);
	  
	  local ER;	  
      if (Noise~=0) then ER=math.abs(source[period]-source[period-periodAMA])/Noise; else ER=0; end
	  
	  
      local SSC=math.pow(ER*dFS+slowSC,G);
      Line[period]=source[period]*SSC+Line[period-1]*(1-SSC);
      AMA2Buffer[period]=Line[period]*Line[period]+AMA2Buffer[period-1]; 
      SumAMABuffer[period]=SumAMABuffer[period-1]+Line[period];
	  
 
      local SredneeAMA=(SumAMABuffer[period]-SumAMABuffer[period-periodAMA])/periodAMA;
      local SumKvadratAMA=AMA2Buffer[period]-AMA2Buffer[period-periodAMA];
      local dipersion=SumKvadratAMA/periodAMA-SredneeAMA*SredneeAMA;
	  
	  Line:setColor(period, instance.parameters.Neutral);	
	  
      if (dipersion<0) then 
      StdAMA[period]=0; 
      else
	  StdAMA[period]=math.sqrt(dipersion);
	  end

      if (AMA_Trend_Type~=0) then 
	  
	   if (math.abs(Line[period]-Line[period-1])>dK*source:pipSize()) then 
	   
	   if (Line[period]-Line[period-1]>0) then
		    Line:setColor(period, instance.parameters.Up);	
            else 
		    Line:setColor(period, instance.parameters.Down);
            end  
        end 
      else
 
         if (math.abs(Line[period]-Line[period-1])>dK*StdAMA[period]) then
      
            if (Line[period]-Line[period-1]>0) then
		    Line:setColor(period, instance.parameters.Up);	
            else
		    Line:setColor(period, instance.parameters.Down);	
            end
         end   
      end
	  
	 
end

  