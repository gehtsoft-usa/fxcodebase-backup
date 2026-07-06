-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=71831

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Arrows & Curves");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("SSP", "SSP", "", 6, 1, 2000);
    indicator.parameters:addInteger("SkyCh", "SkyCh", "", 13, 1, 2000);
	indicator.parameters:addBoolean("Signal", "Signal Mode", "Signal Mode", false);
	
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0)); 
	 
	 
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
local SSP, SkyCh; 
local Indicator;
local Signal;	
-- Routine
 function Prepare(nameOnly)   
 
    
	SSP=instance.parameters.SSP;
	SkyCh=instance.parameters.SkyCh;
	Signal=instance.parameters.Signal;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  SSP.. "," ..  SkyCh  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    Trend = instance:addInternalStream(0, 0);
	first=source:first()+SSP ; 
	
 	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
	
	
	if Signal then
	
	Top= instance:addInternalStream(0, 0);
	Bottom= instance:addInternalStream(0, 0);
	
    SignalBar = instance:addStream("SignalBar", core.Bar, name, "SignalBar", instance.parameters.color1, first );
    SignalBar:setPrecision(math.max(2, instance.source:getPrecision())); 
    SignalBar:addLevel(0);		
	
	else
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
 
 
 
    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, first );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style); 
	
	SignalBar= instance:addInternalStream(0, 0);	
	end
end


function Update(period, mode)

    if Signal then 
    SignalBar[period]=0;	
    else
	up:setNoData(period);
    down:setNoData(period);	
    end
	
	 if period < first then
	 return;
	 end
	 
	 
	local low,high=mathex.minmax(source, period-SSP+1, period); 
	  
 
    local   smax = high - (high - low)*SkyCh / 100 
    local   smin = low + (high - low)*SkyCh / 100;

   

    if(source.close[period]<smin  ) then         
         Trend[period]=-1;
    elseif(source.close[period]>smax )  then
         Trend[period]=1;
	else
         Trend[period]=Trend[period-1];	  
    end
	
	  
	  
    Top[period]=high - (high - low)*SkyCh / 100;
    Bottom[period]=low +  (high - low)*SkyCh / 100; 
   
 
	
    if Trend[period]== 1 and Trend[period-1]~= 1 then	
	    if Signal then 
		SignalBar[period]=1;
		else
		up:set(period, source.high[period], "\217", source.high[period]);	
		end
    elseif Trend[period]== -1 and Trend[period-1]~= -1 then	 
	    if Signal then 
		SignalBar[period]=-1;
		else	
        down:set(period, source.low[period], "\218", source.low[period]);	
		end
    end
	
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

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