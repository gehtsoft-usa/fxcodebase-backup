-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71996

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
    indicator:name("BOW indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("RSI Calculation");	
    indicator.parameters:addInteger("RSI_Period", "RSI Period", "", 14); 	
	
    indicator.parameters:addGroup("BB Calculation");	
    indicator.parameters:addInteger("BB_Period", "BB Period", "", 14); 	
    indicator.parameters:addDouble("BB_Deviation", "BB Deviation", "", 2); 		
	indicator.parameters:addGroup("CCI Calculation");	
    indicator.parameters:addInteger("CCI_Period", "CCI Period", "", 5); 


	indicator.parameters:addGroup("CCI Calculation");	
    indicator.parameters:addInteger("Stochastic1", "1.Stochastic Period ", "", 5); 
    indicator.parameters:addInteger("Stochastic2", "2.Stochastic Period", "", 5); 
	
	indicator.parameters:addGroup("Line Style");	
	indicator.parameters:addInteger("Size1", "Signal Arrow Size", "", 20); 
	indicator.parameters:addInteger("Size2", "Strong Signal Arrow Size", "", 40); 	
   indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	
	indicator.parameters:addColor("color", "Bar Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
 
local first;
local source = nil;  
local up, down;
-- Routine
 function Prepare(nameOnly)   
  
	source = instance.source
	
	Signal=instance.parameters.Signal;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	CCI= core.indicators:create("CCI", source, instance.parameters.CCI_Period);
	Stochastic= core.indicators:create("STOCHASTIC", source, instance.parameters.Stochastic1,instance.parameters.Stochastic2);
	BB= core.indicators:create("BB", source.close, instance.parameters.BB_Period,instance.parameters.BB_Deviation);
	RSI= core.indicators:create("RSI", source.close, instance.parameters.RSI_Period);	
 
 
	first=math.max(CCI.DATA:first(),Stochastic.DATA:first(),BB.DATA:first(),RSI.DATA:first());  
	
	 
	up1 = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size1, core.H_Center, core.V_Top, instance.parameters.clrDN, 0);
    down1 = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size1, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
 
	up2 = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size2, core.H_Center, core.V_Top, instance.parameters.clrDN, 0);
    down2 = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size2, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0); 
end


function Update(period, mode)

	CCI:update(mode);  
	Stochastic:update(mode);  
	RSI:update(mode);  
	BB:update(mode);  	
	
	 if period <= first then
	 return;
	 end
	  
	  
    up1:setNoData(period);
    down1:setNoData(period);	
	
    up2:setNoData(period);
    down2:setNoData(period);	
	

	
	
    if source.close[period] > BB.TL[period]
	and Stochastic.DATA[period]>80
	and CCI.DATA[period]> 150
	and RSI.DATA[period]> 70	
	then 
    up2:set(period, source.high[period], "\218", source.high[period]);	
    elseif source.close[period] > BB.TL[period]
	and Stochastic.DATA[period]>80
	and CCI.DATA[period]> 100
	then 
    up1:set(period, source.high[period], "\218", source.high[period]);	
	end
	

	 
	   if source.close[period] < BB.BL[period]
	and Stochastic.DATA[period]<20
	and CCI.DATA[period]< -150
	and RSI.DATA[period]<30		
	then 	
 
    down2:set(period, source.low[period], "\217", source.low[period]);	
    elseif source.close[period] < BB.BL[period]
	and Stochastic.DATA[period]<20
	and CCI.DATA[period]< -100
	then 	
 
    down1:set(period, source.low[period], "\217", source.low[period]);	
     end
	
end

