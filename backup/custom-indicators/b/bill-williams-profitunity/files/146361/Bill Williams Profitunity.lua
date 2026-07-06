-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72379

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
    indicator:name("Bill Williams Profitunity");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("ATR_Period", "ATR Period", "", 10, 1, 2000);
    indicator.parameters:addDouble("ATR_Multiplier", "ATR Multiplier", "", 0.5, 0, 2000);
	
    indicator.parameters:addInteger("Period1", "1. Period", "", 50, 1, 2000);
    indicator.parameters:addInteger("Period2", "2.  Period", "", 500, 1, 2000);	
 
	
	indicator.parameters:addGroup("Line Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
	indicator.parameters:addInteger("FontSize", "Font Size", "", 10); 	
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
local ATR_Period, ATR_Multiplier,Period1, Period2; 
local ATR;


local max=4;
local min=0.0001;
local low,high, open, close;	
-- Routine
 function Prepare(nameOnly)   
 
    
	ATR_Period=instance.parameters.ATR_Period;
	ATR_Multiplier=instance.parameters.ATR_Multiplier;
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;	
	source = instance.source;
	low=source.low;
	high=source.high;
	open=source.open;
	close=source.close;
	volume=source.volume;
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  ATR_Period.. "," ..  Period2 .. "," ..  Period1.. "," ..  Period2 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	ATR= core.indicators:create("ATR", source, ATR_Period);
	first=math.max(Period1, Period2, ATR.DATA:first()) ; 
	
	
	sma = instance:addInternalStream(0, 0);
	bv = instance:addInternalStream(0, 0);
	av = instance:addInternalStream(0, 0);	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom , instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrDN, 0);
 

	Bottom = instance:createTextOutput ("Bottom", "Bottom", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Bottom , instance.parameters.clrUP, 0);
    Top = instance:createTextOutput ("Top", "Top", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.clrDN, 0); 
end


function Update(period, mode)

	ATR:update(mode); 

   if period <= first then
   return;
   end
   
    up:setNoData(period);
    down:setNoData(period);	   

   local atr = ATR.DATA[period]*ATR_Multiplier;
   local stdvol = mathex.stdev (source.volume, period-Period2+1, period);
   sma[period] = mathex.avg (source.volume, period-Period1+1, period);
   local smavol = mathex.avg (source.volume, period-Period2+1, period);	
  
   
    if stdvol > max then
    av[period]=(smavol +max*stdvol)
	else
	av[period]=0
	end 
 
	if stdvol> min then
	bv[period]=(smavol +min*stdvol)
	else
	bv[period]=0
	end 
	
	
	local MFI0 = (high[period] - low[period]) / volume[period];
    local MFI1 = (high[period-1] - low[period-1]) / volume[period-1]
   
   
     
 
     if MFI0 > MFI1 then
	 MFIplus = true;
	 MFIminus=false;
	 else
	 MFIplus = false;	
	 MFIminus=true;	 
	 end
	 
	 
	if (high[period] + low[period]) /2 > high[period-1] then
	meanplus = true;
	meanminus= false;
	else
	meanminus= true;
	meanplus = false;
	end
	
	
     if volume[period] > volume[period-1] then
	 volplus = true;
	 volminus = false;
	 else
	 volplus = false;
	 volminus = true;
	 end
	 
  if open[period] < (high[period] + low[period]) /2 and close[period] > (high[period] + low[period]) /2 and close[period] > open[period] then
  b13 = true;
  else
  b13  = false;
  end
  
  if open[period] > (high[period] + low[period]) /2 and close[period] < (high[period] + low[period]) /2 and close[period] < open[period] then
  b31 = true;
  else
  b31 = false;
  end
  
  
   if open[period] > (high[period] + low[period]) /2 and close[period] > (high[period] + low[period]) /2 and close[period] > open[period] then
   a0 = true;
   else
   a0 = false;
   end
   
	if a0 then
	up:set(period, source.low[period], "\217", source.low[period]);	 
	end 
	
	
	
if open[period] < (high[period] + low[period]) /2 and close[period] < (high[period] + low[period]) /2 and close[period] > open[period] then
b0= true;
else
b0= false;
end

if b0 then
down:set(period, source.high[period], "\218", source.high[period]);		
end
 
if open[period] < (high[period] + low[period]) /2 and close[period] < (high[period] + low[period]) /2 and close[period] < open[period]  then
c0 =  true;
else
c0 =  false;
end

if c0 then
down:set(period, source.high[period], "\218", source.high[period]);		
end
 
if open[period] > (high[period] + low[period]) /2 and close[period] > (high[period] + low[period]) /2 and close[period] < open[period]  then
d0 =  true; 
else
d0 = false; 
end

if d0 then
down:set(period, source.high[period], "\218", source.high[period]);		
end


 
if open[period] > (high[period] + low[period]) /2 and close[period] > (high[period] + low[period]) /2 and close[period] > open[period] and volume[period] > av[period-1] then
a0 = true;
else
a0 = false; 
end

if a0 then
up:set(period, source.low[period] , "\217", "Green");	
Bottom:set(period, source.low[period]-atr  , "Green", "Green");	
end 
 
if open[period] < (high[period] + low[period]) /2 and close[period] < (high[period] + low[period]) /2 and close[period] > open[period] and volume[period] < bv[period-1] then
b0= true; 
else
b0= false; 
end

if b0 then
down:set(period, source.high[period], "\218", "Fade" );
Top:set(period, source.high[period]+atr  , "Fade", "Fade");
end 
 
if open[period] < (high[period] + low[period]) /2 and close[period] < (high[period] + low[period]) /2 and close[period] < open[period] and volume[period] > sma[period-1] then
c0 = true; 
else
c0 = false; 
end

if c0 then
down:set(period, source.high[period], "\218", "Green" );
Top:set(period, source.high[period]+atr  , "Green", "Green");
end 
 
if open[period] > (high[period] + low[period]) /2 and close[period] > (high[period] + low[period]) /2 and close[period] < open[period] and volume[period] > sma[period-1] then
d0 = true; 
else
d0 = false;
end

if d0 then
down:set(period, source.high[period] , "\218", "Squat" );
Top:set(period, source.high[period]+atr  , "Squat", "Squat");
end 
 

 
if meanplus and b13 and volplus and MFIplus then
up:set(period, source.low[period], "\217", "Green" );
Bottom:set(period, source.low[period]-atr  , "Green", "Green");		
--Green", -atr/4 
end 
 
 
if  meanplus and b13 and volminus and MFIminus then
up:set(period, source.low[period], "\217", "Fade");	 
Bottom:set(period, source.low[period]-atr  , "Fade", "Fade");	
end 
 
 
if meanplus and b13 and volminus and MFIplus then
up:set(period, source.low[period], "\217", "Fake");	
Bottom:set(period, source.low[period]-atr , "Fake", "Fake");	 
end 
 
 
if  meanplus and b13 and volplus and MFIminus then
up:set(period, source.low[period], "\217", "Squat");	
Bottom:set(period, source.low[period]-atr  , "Squat", "Squat");	 
end 
 
 
if meanminus and b13 and volplus and MFIplus then
down:set(period, source.high[period], "\218", "Fade");	
Top:set(period, source.high[period]+atr  , "Fade", "Fade");
end 
 
 
if meanminus and b13 and volminus and MFIminus then
down:set(period, source.high[period], "\218", "Fade");	
Top:set(period, source.high[period]+atr  , "Fade", "Fade");
end 
 
 
if meanminus and b13 and volminus and MFIplus then
down:set(period, source.high[period], "\218", "Fake");	
Top:set(period, source.high[period]+atr  , "Fake", "Fake");
end 
 
 
if meanminus and b13 and volplus and MFIminus then
down:set(period, source.high[period], "\218", "Squat");	
Top:set(period, source.high[period]+atr  , "Squat", "Squat");
end 
 
 
if meanplus and b31 and volplus and MFIplus then
up:set(period, source.low[period], "\217", "Green");	
Bottom:set(period, source.low[period]-atr  , "Green", "Green");	
end 
 
 
if meanplus and b31 and volminus and MFIminus then
up:set(period, source.low[period], "\217", "Fade");	
Bottom:set(period, source.low[period]-atr  , "Fade", "Fade");	
end 
 
 
if meanplus and b31 and volminus and MFIplus then
up:set(period, source.low[period], "\217","Fake");	
Bottom:set(period, source.low[period]-atr  , "Fake", "Fake");	
end 
 
 
if meanplus and b31 and volplus and MFIminus then
up:set(period, source.low[period], "\217", "Squat");	
Bottom:set(period, source.low[period]-atr  , "Squat", "Squat");	
end 
 
 
if meanminus and b31 and volplus and MFIplus then
down:set(period, source.high[period], "\218", "Green");	
Top:set(period, source.high[period]+atr  , "Green", "Green");
end 
 
 
if  meanminus and b31 and volminus and MFIminus then
down:set(period, source.high[period], "\218", "Fade");	
Top:set(period, source.high[period]+atr  , "Fade", "Fade");
end 
 
 
if meanminus and b31 and volminus and MFIplus then
down:set(period, source.high[period], "\218", "Fake");	
Top:set(period, source.high[period]+atr  , "Fake", "Fake");
end 
 
 
if meanminus and b31 and volplus and MFIminus then
down:set(period, source.high[period], "\218", "Squat");	
Top:set(period, source.high[period]+atr  , "Squat", "Squat");
end 

 		
end


 