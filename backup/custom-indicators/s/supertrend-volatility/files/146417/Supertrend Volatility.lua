-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72400

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
    indicator:name("Supertrend Volatility");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("windowlen", "Window Length", "", 28, 1, 2000);
    indicator.parameters:addInteger("vlen", "vlen", "", 14, 1, 2000);	
 	
    indicator.parameters:addDouble("stmult", "Trend Multiplier", "", 2, 0, 100);
    indicator.parameters:addInteger("stperiod", "Trend Period", "", 10, 1, 2000);
    indicator.parameters:addDouble("factor", "Volatility Factor", "", 0.5, 0.1, 5);	
	
 
 
	
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
local windowlen,vlen, stmult; 
local stperiod, factor; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	windowlen=instance.parameters.windowlen;
	vlen=instance.parameters.vlen;
	stmult=instance.parameters.stmult;
	stperiod=instance.parameters.stperiod;
	factor=instance.parameters.factor;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  windowlen.. "," ..  vlen.. "," ..  stmult .. "," ..  stperiod.. "," ..  factor .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	ATR= core.indicators:create("ATR", source, stperiod);
	first=source:first() + windowlen; 
	
	
	trend = instance:addInternalStream(0, 0);
 	myobv = instance:addInternalStream(0, 0);
	range = instance:addInternalStream(0, 0);
	vx= instance:addInternalStream(0, 0);
	vxsmooth= instance:addInternalStream(0, 0);
	atr_ratio= instance:addInternalStream(0, 0);
	spreadvol= instance:addInternalStream(0, 0);
	spreadvolsum= instance:addInternalStream(0, 0);
	
	lb= instance:addInternalStream(0, 0);
	hb= instance:addInternalStream(0, 0);
	l1= instance:addInternalStream(0, 0);
	hl= instance:addInternalStream(0, 0);
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

	ATR:update(mode);  
	range[period]=(source.high[period] - source.low[period]);	
	
	 if period <= first then
	 return;
	 end
	 
   

	local hilow = math.max(source:pipSize(),range[period]*100);
	local openclose = ((source.close[period] - source.open[period])*100);
	
	
	--[[
					if volume<>volume[1] then 
							if close>close[1] then 
							myobv=myobv+volume
							elsif close<close[1] then
							myobv=myobv-volume
							endif 
				endif

	]]
	
    if source.close[period]>source.close[period-1] then 
	myobv[period]=myobv[period-1]+source.volume[period];
	elseif source.close[period]<source.close[period-1] then
	myobv[period]=myobv[period-1]-source.volume[period];
	end 
	
	
	--[[
	
	vol = (myobv / hilow)
	spreadvol = (openclose * vol) 
 
	]]

    local vol = (myobv[period] / hilow)

	spreadvol[period] = (openclose * vol);
	spreadvolsum[period]=spreadvolsum[period-1]+spreadvol[period];

    local pricespread = mathex.stdev(range, period- windowlen+1, period);	
   
	
	
	--[[
		vx =  spreadvol + cumsum(spreadvol)
	smooth = average[vlen,1](vx)
	vspread = std[windowlen](vx - smooth)
	shadow = (vx - smooth) / vspread * pricespread
	]]
	
	
	vx[period] =  spreadvol[period] + spreadvolsum[period];

	 if period <= first+vlen then
	 return;
	 end
	 
	local smooth = mathex.avg(vx, period-vlen-1, period);
	vxsmooth[period]=vx[period] - smooth;
	
	
	 if period <= first+windowlen then
	 return;
	 end
	 
	 
	 --[[
	 vspread = std[windowlen](vx - smooth)
shadow = (vx - smooth) / vspread * pricespread
	 ]]
	 
	local vspread = mathex.stdev(vxsmooth, period-windowlen+1, period);	
	local shadow = (vx[period] - smooth) / vspread * pricespread;

--[[
pricespread = std[windowlen](range)
 

 
if shadow > 0 then
out = high + shadow
else
out = low + shadow
endif
]]
    local out;
	if shadow > 0 then
	out = source.high[period] + shadow;
	else
	out = source.low[period] + shadow;
	end 	
	
--[[
// CALCULATIONS //
uplev =out - (stmult * averagetruerange[stperiod])
dnlev = out + (stmult * averagetruerange[stperiod])
]] 
    local uplev =out - (stmult * ATR.DATA[period]);
    local dnlev = out + (stmult * ATR.DATA[period]);



--[[
iVolatility = 100 * summation[1](100 * averagetruerange[1] / low) / 100
perc = (iVolatility*0.01) *factor
]]	
	atr_ratio[period]= 100 * ATR.DATA[period-1] / source.low[period];
	
 
 
	local iVolatility = 100 * (atr_ratio[period]+atr_ratio[period-1]) / 100
	local perc = (iVolatility*0.01) *factor
	
	
	local n = dnlev
    local x =uplev


 
 	lb[period] = lb[period-1];
	hb[period] = hb[period-1];
	l1[period] = l1[period-1];
	hl[period] = hl[period-1];
    trend[period] = trend[period-1];	
 
	if period< first+windowlen+1  then

		
		lb[period] = n
		hb[period] = x
		l1[period] = out
		hl[period] = out
	 

		if x >= hb[period-1] then
		hb[period] = x
		hl[period] = out
		trend[period] = 1
		else
		lb[period] = n
		l1[period] = out
		trend[period] = -1
		end 
		
	return;
	end	

		 
		if trend[period-1] > 0 then
						hl[period] = math.max(hl[period-1], out)
						
						
							if x >= hb[period-1] then
							hb[period] = x
							else
						
									if n < (hb[period-1] - hb[period-1] * perc) then
									lb[period] = n
									l1[period] = out
							 
									trend[period] = -1
									 end 
					       end
		else
		               l1[period] = math.min(l1[period-1], out )
		 
						if n <= lb[period-1] then
						    lb[period] = n
						else
						
							if x > (lb[period-1] + lb[period-1] * perc) then
							hb[period] = x
							hl[period] = out
							trend[period] = 1
							end 
						end
		end 

	if trend[period] == 1 then
	Line[period] = hb[period] 
	Line:setColor(period,  instance.parameters.color1);		
	elseif trend[period] == -1 then
	Line[period] = lb[period]  
	Line:setColor(period,  instance.parameters.color2);		
	end 
	
	
end

--[[
if barindex>28 then
hilow = max(pointsize,((high - low)*100))
openclose = ((close - open)*100)
				if volume<>volume[1] then 
				if close>close[1] then 
				myobv=myobv+volume
				elsif close<close[1] then
				myobv=myobv-volume
				endif 
				endif
vol = (myobv / hilow)
spreadvol = (openclose * vol)
VPT = spreadvol + cumsum(spreadvol)
once windowlen = 28
 
once vlen = 14
pricespread = std[windowlen](range)
 

 
if shadow > 0 then
out = high + shadow
else
out = low + shadow
endif
// CALCULATIONS //
uplev =out - (stmult * averagetruerange[stperiod])
dnlev = out + (stmult * averagetruerange[stperiod])
//
iVolatility = 100 * summation[1](100 * averagetruerange[1] / low) / 100
perc = (iVolatility*0.01) *factor
 
c=barindex
 
n = dnlev
x =uplev
 
once lb = n
once hb = x
once l1 = out
once hl = out
 
if c = 0 then
if x >= hb[1] then
hb = x
hl = out
trend = 1
else
lb = n
l1 = out
trend = -1
endif
endif
 
if c > 1 then
 
if trend[1] > 0 then
hl = max(hl[1], out)
if x >= hb[1] then
hb = x
else
            
if n < hb[1] - hb[1] * perc then
lb = n
l1 = out
 
trend = -1
endif
endif
else
l1 = min(l1[1], out )
 
if n <= lb[1] then
lb = n
else
 
          
if x > lb[1] + lb[1] * perc then
hb = x
hl = out
trend = 1
endif
endif
endif
endif
 
 
if trend = 1 then
v = hb
r=0
g=200
elsif trend = -1 then
v = lb
r=255
g=0
endif
endif
 
return v style(line,2) coloured(r,g,0)
endif
]] 