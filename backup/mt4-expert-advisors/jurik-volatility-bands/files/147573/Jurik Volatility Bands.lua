-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=38&t=72751

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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
    indicator:name("Jurik Volatility Bands");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Length", "", 14, 1, 2000);
    indicator.parameters:addInteger("Shift", "Shift", "", 0, 1, 2000);
    indicator.parameters:addInteger("avgLen", "Average Length", "", 65, 1, 2000);	
    indicator.parameters:addBoolean("ZeroBind", "ZeroBind", "", true);	
    indicator.parameters:addBoolean("Normalize", "Normalize", "", false);		
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("color3", "Cental Line Color", "", core.rgb(128, 128, 128));
	 indicator.parameters:addColor("color4", "Price Line Color", "", core.rgb(0, 0, 255));	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Length, Shift,ZeroBind,Normalize,avgLen; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Length=instance.parameters.Length;
	Shift=instance.parameters.Shift;
	ZeroBind=instance.parameters.ZeroBind;
	Normalize=instance.parameters.Normalize;
	avgLen=instance.parameters.avgLen;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Length.. "," ..  Shift .. "," ..    avgLen .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first()+Length+Shift	; 
	
	
	bsmax = instance:addInternalStream(0, 0);
	bsmin = instance:addInternalStream(0, 0); 
	volty = instance:addInternalStream(0, 0); 
	vsum = instance:addInternalStream(0, 0); 
	
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first+avgLen );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
 	

    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, first+avgLen );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
	
    Central = instance:addStream("Central", core.Line, name, "Central", instance.parameters.color3, first+avgLen );
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
    Central:setWidth(instance.parameters.width);
    Central:setStyle(instance.parameters.style);
	
    Price = instance:addStream("Price", core.Line, name, "Price", instance.parameters.color4, first+avgLen );
    Price:setPrecision(math.max(2, instance.source:getPrecision()));
    Price:setWidth(instance.parameters.width);
    Price:setStyle(instance.parameters.style);	
end


function Update(period, mode)

	--  Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	 
 
	local lprice, hprice = mathex.minmax(source, period-Shift-Length+1, period-Shift); 
 
	local len1 = math.max(math.log(math.sqrt(0.5*(Length-1)))/math.log(2.0)+2.0,0) 
	local pow1 = math.max(len1-2.0,0.5)
	local del1 = hprice - bsmax[period-1]
	local del2 = lprice - bsmin[period-1]
	
	
 
	 volty[period] = 0
	 if(math.abs(del1) > math.abs(del2)) then
	  volty[period] = math.abs(del1)
	 end 
	 if(math.abs(del1) < math.abs(del2)) then
	  volty[period] = math.abs(del2)
	 end 	
 
    vsum[period] = vsum[period-1] + 0.1*(volty[period]-volty[period-10])
	
 
	 avg = vsum[period]
	 
	 if period <= first+avgLen then
	 return;
	 end
	 

	 for k=1 , avgLen-1, 1 do
	  avg = avg+vsum[period-k]
	 end
	 avg = avg/avgLen
	 
	 avolty = avg
	 if avolty > 0 then
	  dVolty = volty[period]/avolty
	 else
	  dVolty = 0
	 end 
	 
	 if dVolty>math.exp((1/pow1)*math.log(len1)) then
	  dVolty=math.exp((1/pow1)*math.log(len1))
	 end 
	 if (dVolty < 1) then
	  dVolty = 1.0
	 end 	 
 
	 pow2 = math.exp(pow1*math.log(dVolty))
	 len2 = math.sqrt(0.5*(Length-1))*len1
	 Kv = math.exp(math.sqrt(pow2)*math.log(len2/(len2+1)))
	 
	 
	 if (del1 > 0) then
	  bsmax[period] = hprice
	 else
	  bsmax[period] = hprice - Kv*del1
	 end 
	 if (del2 < 0) then
	  bsmin[period] = lprice
	 else
	  bsmin[period] = lprice - Kv*del2
	 end 	 
	 
	 dnValue = bsmin[period]
	 upValue = bsmax[period]
	 miValue = (upValue+dnValue)/2.0	 
 
	if (ZeroBind) then
			  if (Normalize) then
			   Top[period] =  1
			   Bottom[period] = -1
			   diff = (upValue-miValue)
					   if (diff ~= 0) then
						Price[period] = (source[period]-miValue)/diff
					   else
						Price[period] = 0
					   end 
			  else
			   Top[period] = upValue-miValue
			   Bottom[period] = dnValue-miValue
			   Price[period]    = (source[period]-miValue)
			  end 
	 else
	  Top[period] = upValue
	  Bottom[period] = dnValue
	  Price[period]    = source[period]
	 end 
 
  if (ZeroBind) then
   Central[period] = 0
  else
   Central[period] = miValue
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