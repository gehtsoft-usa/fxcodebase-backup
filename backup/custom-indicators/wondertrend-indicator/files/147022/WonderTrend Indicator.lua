-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72602

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
    indicator:name("WonderTrend Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("MA Calculation");	
    indicator.parameters:addInteger("Length", "Length", "", 20, 1, 2000);
	
 	indicator.parameters:addGroup("SAR Calculation");		
	indicator.parameters:addDouble("Step", "Step","", 0.02, 0.001, 1);
    indicator.parameters:addDouble("Max", "Max","", 0.2, 0.001, 10);	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "Neutral Line Color", "", core.rgb(0, 0, 255)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Length; 
 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Length=instance.parameters.Length;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Length  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	sar= core.indicators:create("SAR", source, instance.parameters.Step, instance.parameters.Max);
	first=math.max(sar.UP:first(), sar.DN:first(), Length); 
	
	
    kc = instance:addInternalStream(0, 0);
 	psar = instance:addInternalStream(0, 0);
	save = instance:addInternalStream(0, 0);
	trend = instance:addInternalStream(0, 0);

	
    kc = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first );
    kc:setPrecision(math.max(2, instance.source:getPrecision()));
    kc:setWidth(instance.parameters.width);
    kc:setStyle(instance.parameters.style);
    kc:addLevel(0);	
 
end


function Update(period, mode)

	sar:update(mode); 
	
 
	 if period <= first then
	 return;
	 end 
	 
 
    kc[period] = mathex.avg(source.close, period-Length+1, period);
 
	
	if sar.DN:hasData(period) then
	psar[period]=1;
	else
	psar[period]=-1;	
	end
	
	
	save[period]=save[period-1];
	if psar[period]~= psar[period-1] then
		if psar[period-1]==1 then
		save[period]=sar.DN[period-1];
		else
		save[period]=sar.UP[period-1];
		end
	end
	
	
local  wavelen=0;
 
if psar[period] == 1 and source.low[period] > math.max(kc[period],source.low[period-2]) and source.low[period-1] > save[period] and source.low[period-2] > math.max(kc[period],save[period]) 
or psar[period] == -1 and source.high[period] < math.min(kc[period],source.high[period-2]) and source.high[period-1] < save[period] and source.high[period-2] < math.min(kc[period],save[period]) 
then
wavelen = 3 
end	
	
 
    trend[period]=trend[period-1];
    if trend[period] <= 0 and wavelen >= 3 and psar[period] == 1  then	
	trend[period]=1 
	elseif trend[period] >= 0 and wavelen >= 3 and psar[period] == -1 then	
	trend[period]=-1 
	end
	
   if trend[period] == -1 and save[period] > save[period-1] 
   or trend[period] == 1 and save[period] < save[period-1] 
   then
   trend[period]= 0 
   end
   
   
	  
	
    if    trend[period] == -1 and (trend[period-1] == -1 or kc[period]<=kc[period-1]) or trend[period-1]==-1 and kc[period]<kc[period-1] then
	wave_color= instance.parameters.color2;	
	elseif trend[period] == 1 and (trend[period-1] == 1 or kc[period]>=kc[period-1]) or trend[period-1]==1 and kc[period]>kc[period-1] then
	wave_color= instance.parameters.color1;	
    else
	wave_color= instance.parameters.color3;	
	end
	
	kc[period]=kc[period];
	kc:setColor(period,  wave_color);
 	
end
 
