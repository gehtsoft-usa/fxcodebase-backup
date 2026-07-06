-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71862

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
    indicator:name("Trender");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Length", "", 14, 1, 2000);
    indicator.parameters:addInteger("Factor", "Factor", "", 2, 1, 2000);
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(128, 128, 128)); 
	indicator.parameters:addColor("color3", "3. Line Color", "", core.rgb(0, 0, 255)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Length, Factor; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Length=instance.parameters.Length;
	Factor=instance.parameters.Factor;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Length.. "," ..  Factor  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	
	first=source:first()  ; 
	
	mp = core.indicators:create("EMA", source.median, Length);
	ATR = core.indicators:create("ATR", source, Length); 

    ad = instance:addInternalStream(0, 0);	 

   trndDn = instance:addInternalStream(0, 0);	 
   trndUp = instance:addInternalStream(0, 0);	 
	
	ADM = core.indicators:create("EMA", ad, Length); 	
    trndr = instance:addStream("trndr", core.Line, name, "trndr", instance.parameters.Up, first +Length*3  );
    trndr:setPrecision(math.max(2, instance.source:getPrecision()));
    trndr:setWidth(instance.parameters.width);
    trndr:setStyle(instance.parameters.style);
    trndr:addLevel(0);	
 
    mpEma = instance:addStream("mpEma", core.Line, name, "mpEma", instance.parameters.color2,  first +Length );
    mpEma:setPrecision(math.max(2, instance.source:getPrecision()));
    mpEma:setWidth(instance.parameters.width);
    mpEma:setStyle(instance.parameters.style);
    mpEma:addLevel(0);	

    adm = instance:addStream("adm", core.Line, name, "adm", instance.parameters.color3, first +Length*3  );
    adm:setPrecision(math.max(2, instance.source:getPrecision()));
    adm:setWidth(instance.parameters.width);
    adm:setStyle(instance.parameters.style);
    adm:addLevel(0);		
end


function Update(period, mode)

 
	 if period < first +Length then
	 return;
	 end	 
 
  	mp:update(mode);   
  	
	mpEma[period]=mp.DATA[period];
	
	ATR:update(mode); 
	
	 if period < first +Length*2 then
	 return;
	 end	 	
	
	local stdDev=mathex.stdev(ATR.DATA, period-Length+1, period);
	
	
	if source.median[period] > source.median[period-1] then
	ad[period] =mp.DATA[period] + (ATR.DATA[period]  / 2)
	elseif source.median[period] <source.median[period-1] then
	ad[period]= mp.DATA[period] - (ATR.DATA[period]  / 2);	 
	else
	ad[period]= mp.DATA[period];
	end

  	ADM:update(mode); 	
	
	 if period < first +Length*3 then
	 return;
	 end	

    adm[period]=ADM.DATA[period];
	
	
	if  adm[period]< mpEma[period] and adm[period-1]>= mpEma[period-1] then
	trndDn[period]= source.high[period-2] 
	elseif source.median[period]  < source.median[period-1] then 
	trndDn[period]=source.median[period] + (stdDev * Factor); 
	else
	trndDn[period] =trndDn[period-1];
	end


	if  adm[period]> mpEma[period] and adm[period-1]<= mpEma[period-1] then
	trndUp[period]= source.high[period-2] 
	elseif source.median[period]  > source.median[period-1] then 
	trndUp[period]=source.median[period] - (stdDev * Factor);
	else
	trndUp[period] =trndUp[period-1];
	end


 
    if adm[period] < mpEma[period] then
    trndr[period]= trndDn[period] 
	elseif adm[period] > mpEma[period] then
	trndr[period]= trndUp[period] 
	else
	trndr[period]= trndr[period-1]; 
    end
	
	
	if source.median[period] > trndr[period] then
    trndr:setColor(period, instance.parameters.Up);	
	else
    trndr:setColor(period, instance.parameters.Down);	
	end
	
 
end


--[[
//@version=4
// Copyright (c) 2019-present, Franklin Moormann (cheatcountry)
// Trender [CC] script may be freely distributed under the MIT license.
study("Trender [CC]", overlay=true)

f_security(_symbol, _res, _src, _repaint) => 
    security(_symbol, _res, _src[_repaint ? 0 : barstate.isrealtime ? 1 : 0])[_repaint ? 0 : barstate.isrealtime ? 0 : 1]
    
res = input(title="Resolution", type=input.resolution, defval="")
rep = input(title="Allow Repainting?", type=input.bool, defval=false)
bar = input(title="Allow Bar Color Change?", type=input.bool, defval=true)
length = input(title="Length", type=input.integer, defval=14, minval=1)
factor = input(title="Factor", type=input.integer, defval=2, minval=1)
p = f_security(syminfo.tickerid, res, hl2, rep)
h = f_security(syminfo.tickerid, res, high, rep)
l = f_security(syminfo.tickerid, res, low, rep)
t = f_security(syminfo.tickerid, res, tr, rep)

mpEma = ema(p, length)
trEma = ema(t, length)
stdDev = stdev(trEma, length)

ad = p > nz(p[1]) ? mpEma + (trEma / 2) : p < nz(p[1]) ? mpEma - (trEma / 2) : mpEma
adm = ema(ad, length)

trndDn = 0.0
trndDn := crossunder(adm, mpEma) ? h[2] : p < nz(p[1]) ? p + (stdDev * factor) : nz(trndDn[1], h[2])
trndUp = 0.0
trndUp := crossover(adm, mpEma) ? l[2] : p > nz(p[1]) ? p - (stdDev * factor) : nz(trndUp[1], l[2])
trndr = 0.0
trndr := adm < mpEma ? trndDn : adm > mpEma ? trndUp : nz(trndr[1], 0)

sig = p > trndr ? 1 : p < trndr ? -1 : 0
alertcondition(crossover(sig, 0), "Buy Signal", "Bullish Change Detected")
alertcondition(crossunder(sig, 0), "Sell Signal", "Bearish Change Detected")
trndrColor = sig > 0 ? color.green : sig < 0 ? color.red : color.black
barcolor(bar ? trndrColor : na)
plot(trndr, color=trndrColor, linewidth=2)
plot(mpEma, color=color.blue, linewidth=2)

]]
 