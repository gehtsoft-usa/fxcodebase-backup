-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71767

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
    indicator:name("Limit channels");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("inpAtrPeriod", "ATR period", "", 50, 1, 2000);
    indicator.parameters:addDouble("inpAtrMultiplier", "ATR multiplier", "", 5, 1, 2000);
	
 
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "1. Top Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
	
    indicator.parameters:addColor("color2", "2. Top Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_DASH);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);

    indicator.parameters:addColor("color3", "3. Top Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID );
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);	
	
   indicator.parameters:addColor("color4", "1. Bottom Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style4", "Line Style", "",core.LINE_DOT);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 1, 1, 5);
	
    indicator.parameters:addColor("color5", "2. Bottom Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style5", "Line Style", "", core.LINE_DASH);
    indicator.parameters:setFlag("style5", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width5", "Line Width", "", 1, 1, 5);

    indicator.parameters:addColor("color6", "3. Bottom Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style6", "Line Style", "",  core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width6", "Line Width", "", 1, 1, 5);	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local inpAtrPeriod,inpAtrMultiplier; 
local first;
local source = nil;

-- Routine
 function Prepare(nameOnly)   
 
 
    inpAtrPeriod= instance.parameters.inpAtrPeriod;
    inpAtrMultiplier= instance.parameters.inpAtrMultiplier;
	
	
	local Parameters= inpAtrPeriod..", "..inpAtrMultiplier;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	source = instance.source; 
    first=source:first()+inpAtrPeriod;
	
	ATR = core.indicators:create("ATR", source, inpAtrPeriod);
	
	up1 = instance:addStream("Top1" , core.Line, " Top1"," Top1",instance.parameters.color1, first );
	up1:setWidth(instance.parameters.width1);
    up1:setStyle(instance.parameters.style1);
    up1:setPrecision(math.max(2, source:getPrecision()));
	
	up2 = instance:addStream("Top2" , core.Line, " Top2"," Top2",instance.parameters.color2, first );
	up2:setWidth(instance.parameters.width2);
    up2:setStyle(instance.parameters.style2);
    up2:setPrecision(math.max(2, source:getPrecision()));

	up3 = instance:addStream("Top3" , core.Line, " Top3"," Top3",instance.parameters.color3, first );
	up3:setWidth(instance.parameters.width3);
    up3:setStyle(instance.parameters.style3);
    up3:setPrecision(math.max(2, source:getPrecision()));	
	
	
	
	down1 = instance:addStream("Bottom1" , core.Line, " Bottom1"," Bottom1",instance.parameters.color4, first );
	down1:setWidth(instance.parameters.width4);
    down1:setStyle(instance.parameters.style4);
    down1:setPrecision(math.max(2, source:getPrecision()));
	
	down2 = instance:addStream("Bottom2" , core.Line, " Bottom2"," Bottom2",instance.parameters.color5, first );
	down2:setWidth(instance.parameters.width5);
    down2:setStyle(instance.parameters.style5);
    down2:setPrecision(math.max(2, source:getPrecision()));

	down3 = instance:addStream("Bottom3" , core.Line, " Bottom3"," Bottom3",instance.parameters.color6, first );
	down3:setWidth(instance.parameters.width6);
    down3:setStyle(instance.parameters.style6);
    down3:setPrecision(math.max(2, source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)

    ATR:update(mode);
	if period < first
	then
	return;
	end
 
	
    local Atr=ATR.DATA[period]*inpAtrMultiplier;
		
                     if (source.high[period] > up3[period-1]) then
					 up3[period]   = source.high[period];
					 elseif (source.high[period] < up3[period-1]) then
					 up3[period]   = math.min(source.high[period] + Atr*1.0, up3[period-1]);
					 else
					 up3[period]   = up3[period-1];
					 end
					
					
					
                    if (source.high[period] > up2[period-1])  then
					up2[period]   = source.high[period]; 
					elseif (source.high[period] < up2[period-1])  then
					up2[period]   = math.min(source.high[period] + Atr*0.5, up2[period-1]); 
					else
					up2[period]   = up2[period-1];
					end
					
                    if (source.high[period] > up1[period-1]) then
					up1[period]   = source.high[period];
					elseif (source.high[period] < up1[period-1]) then
					up1[period]   = math.min(source.high[period] + Atr*0.1, up1[period-1]); 
					else 
					up1[period]   = up1[period-1];
					end
					
					
                    if (source.low[period]  < down1[period-1]) then  
					down1[period] = source.low[period];  
					elseif (source.low[period]  > down1[period-1]) then
					down1[period] = math.max(source.low[period]  - Atr*0.1, down1[period-1]);
					else 
					down1[period] = down1[period-1];
					end
					
					
					
                    if (source.low[period]  < down2[period-1]) then 
					down2[period] = source.low[period]; 
					elseif (source.low[period]  > down2[period-1]) then
					down2[period] = math.max(source.low[period]  - Atr*0.5, down2[period-1]);
					else
					down2[period] = down2[period-1];
					end
					
					
                    if (source.low[period]  < down3[period-1]) then
					down3[period] = source.low[period]; 
					elseif (source.low[period]  > down3[period-1]) then
					down3[period] = math.max(source.low[period]  - Atr*1.0, down3[period-1]);
					else 
					down3[period] = down3[period-1];
					end
				  
end
 
 