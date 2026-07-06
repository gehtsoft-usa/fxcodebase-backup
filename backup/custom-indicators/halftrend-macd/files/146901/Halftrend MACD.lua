-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72563

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
    indicator:name("Halftrend MACD");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Amplitude1", "1. Amplitude", "", 2, 1, 2000);
    indicator.parameters:addInteger("Amplitude2", "2. Amplitude", "", 6, 1, 2000);
    indicator.parameters:addInteger("Amplitude3", "3. Amplitude", "", 30, 1, 2000);	
    indicator.parameters:addInteger("Signal", "Signal", "", 6, 1, 2000);		 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Amplitude1,Amplitude2,Amplitude3; 
local first;
local source = nil;
 

-- Routine
 function Prepare(nameOnly)   
 
    Amplitude1= instance.parameters.Amplitude1;
    Amplitude2= instance.parameters.Amplitude2;
    Amplitude3= instance.parameters.Amplitude3;
	Signal= instance.parameters.Signal;
	
	local Parameters= Amplitude1 ..  ", " .. Amplitude2 ..  ", " .. Amplitude3 ..  ", " .. Signal;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    first=source:first()+math.max(Amplitude1,Amplitude2,Amplitude3);   
  
    low1 = core.indicators:create("MVA", source.low, Amplitude1);
    high1 = core.indicators:create("MVA", source.high, Amplitude1);   

    low2 = core.indicators:create("MVA", source.low, Amplitude2);
    high2 = core.indicators:create("MVA", source.high, Amplitude2);   

    low3 = core.indicators:create("MVA", source.low, Amplitude3);
    high3 = core.indicators:create("MVA", source.high, Amplitude3);   
   
 
    trend1= instance:addInternalStream(0, 0);
    trend2= instance:addInternalStream(0, 0); 	
    trend3= instance:addInternalStream(0, 0);	 

    nexttrend1= instance:addInternalStream(0, 0);
    nexttrend2= instance:addInternalStream(0, 0); 	
    nexttrend3= instance:addInternalStream(0, 0);
	
	up1= instance:addInternalStream(0, 0);
	down1= instance:addInternalStream(0, 0); 
	up2= instance:addInternalStream(0, 0);
	down2= instance:addInternalStream(0, 0); 
	up3= instance:addInternalStream(0, 0);
	down3= instance:addInternalStream(0, 0); 	

	minhighprice1= instance:addInternalStream(0, 0);
	maxlowprice1= instance:addInternalStream(0, 0);

	minhighprice2= instance:addInternalStream(0, 0);
	maxlowprice2= instance:addInternalStream(0, 0);
	
	minhighprice3= instance:addInternalStream(0, 0);
	maxlowprice3= instance:addInternalStream(0, 0);
 
	Line1 = instance:addStream("Line1" , core.Line, "1. Line","1. Line",instance.parameters.color1, first);
	Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:setPrecision(math.max(2, source:getPrecision()));
	
	Line2 = instance:addStream("Line2" , core.Line, "2. Line","2. Line",instance.parameters.color2, first);
	Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:setPrecision(math.max(2, source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    low1:update(mode);
    high1:update(mode);	

    low2:update(mode);
    high2:update(mode);

    low3:update(mode);
    high3:update(mode);
	
    if period <= first then
	return;
	end
	
	
 
	local lowpricei1,highpricei1 = mathex.minmax(source, period-Amplitude1+1 ,period);
	local lowpricei2,highpricei2 = mathex.minmax(source, period-Amplitude2+1 ,period);
	local lowpricei3,highpricei3 = mathex.minmax(source, period-Amplitude3+1 ,period); 
		
	nexttrend1[period]=nexttrend1[period-1];
	nexttrend2[period]=nexttrend2[period-1];
	nexttrend3[period]=nexttrend3[period-1];
	
	trend1[period]=trend1[period-1];
	trend2[period]=trend2[period-1];
	trend3[period]=trend3[period-1];
  
	
	minhighprice1[period]=minhighprice1[period-1];
	maxlowprice1[period]=maxlowprice1[period-1];	

	minhighprice2[period]=minhighprice2[period-1];
	maxlowprice2[period]=maxlowprice2[period-1];
	
	minhighprice3[period]=minhighprice3[period-1];
	maxlowprice3[period]=maxlowprice3[period-1];
	
	
--[[

if(nexttrend1=1) then
 
maxlowprice1=Max(lowpricei1,maxlowprice1)
 
if(highma1<maxlowprice1 and Close<Low[1]) then
trend1=1.0
nexttrend1=0
minhighprice1=highpricei1
endif
 
endif
 
if(nexttrend1=0) then
 
minhighprice1=Min(highpricei1,minhighprice1)
 
if(lowma1>minhighprice1 and Close>High[1]) then
trend1=0.0
nexttrend1=1
maxlowprice1=lowpricei1
endif
 
endif
 
if(trend1=0.0) then
 
if(trend1[1]<>0.0) then
up1=down1[1]
else
up1=Max(maxlowprice1,up1[1])
endif
down1=0.0
 
else
 
if(trend1[1]<>1.0) then
down1=up1[1]
else
down1=Min(minhighprice1,down1[1])
endif
up1=0.0
endif
 
endif

]]
		if(nexttrend1[period]==1) then
		 
		maxlowprice1[period]=math.max(lowpricei1,maxlowprice1[period])
		 
				if(high1.DATA[period]<maxlowprice1[period] and source.close[period]<source.low[period-1]) then
				trend1[period]=1.0
				nexttrend1[period]=0
				minhighprice1[period]=highpricei1
				end 
		 
		end 
 
		if(nexttrend1[period]==0) then
		 
		minhighprice1[period]=math.min(highpricei1,minhighprice1[period])
		 
				if(low1.DATA[period]>minhighprice1[period] and source.close[period]>source.high[period-1]) then
				trend1[period]=0.0
				nexttrend1[period]=1
				maxlowprice1[period]=lowpricei1
				end 
		 
		end 
 
	if(trend1[period]==0.0) then
	 
			if(trend1[period-1] ~= 0.0) then
			up1[period]=down1[period-1]
			else
			up1[period]=math.max(maxlowprice1[period],up1[period-1])
			end 
			down1[period]=0.0
			 
	else
	 
			if(trend1[period-1] ~= 1.0) then
			down1[period]=up1[period-1]
			else
			down1[period]=math.min(minhighprice1[period],down1[period-1])
			end 
			up1[period]=0.0
		 
			 
	end 
	

--[[
f barindex>Amplitude2 then
 
if(nexttrend2=1) then
 
maxlowprice2=Max(lowpricei2,maxlowprice2)
 
if(highma2<maxlowprice2 and Close<Low[1]) then
trend2=1.0
nexttrend2=0
minhighprice2=highpricei2
endif
 
endif
 
if(nexttrend2=0) then
 
minhighprice2=Min(highpricei2,minhighprice2)
 
if(lowma2>minhighprice2 and Close>High[1]) then
trend2=0.0
nexttrend2=1
maxlowprice2=lowpricei2
endif
 
endif
 
if(trend2=0.0) then
 
if(trend2[1]<>0.0) then
up2=down2[1]
else
up2=Max(maxlowprice2,up2[1])
endif
down2=0.0
 
else
 
if(trend2[1]<>1.0) then
down2=up2[1]
else
down2=Min(minhighprice2,down2[1])
endif
up2=0.0
endif
 
endif
 
if up2>0 then
halftrend2 = up2
 
else
halftrend2 = down2
 
endif
]]	
		if(nexttrend2[period]==1) then
		 
		maxlowprice2[period]=math.max(lowpricei2,maxlowprice2[period])
		 
			if(high2.DATA[period]<maxlowprice2[period] and source.close[period]<source.low[period-1]) then
			trend2[period]=1.0
			nexttrend2[period]=0
			minhighprice2[period]=highpricei2
			end 
		 
		end 
 
		if(nexttrend2[period]==0) then
		 
		minhighprice2[period]=math.min(highpricei2,minhighprice2[period])
		 
			if(low2.DATA[period]>minhighprice2[period] and source.close[period]>source.high[period-1]) then
			trend2[period]=0.0
			nexttrend2[period]=1
			maxlowprice2[period]=lowpricei2
			end 
		 
		end 
 
		if(trend2[period]==0.0) then
		 
			if(trend2[period-1]~=0.0) then
			up2[period]=down2[period-1]
			else
			up2[period]=math.max(maxlowprice2[period],up2[period-1])
			end 
		down2[period]=0.0
		 
		else
		 
			if(trend2[period-1]~=1.0) then
			down2[period]=up2[period-1]
			else
			down2[period]=math.min(minhighprice2[period],down2[period-1])
			end 
		up2[period]=0.0
		end 
	 
 
 
	if up2[period]>0 then
	halftrend2  = up2[period]	 
	else
	halftrend2  = down2[period]	 
	end 
	
	
--[[
 

 
if(nexttrend3=1) then
 
	maxlowprice3=Max(lowpricei3,maxlowprice3)
		 
		if(highma3<maxlowprice3 and Close<Low[1]) then
		trend3=1.0
		nexttrend3=0
		minhighprice3=highpricei3
		endif
	 
	endif
 
	if(nexttrend3=0) then
	 
	minhighprice3=Min(highpricei3,minhighprice3)
	 
		if(lowma3>minhighprice3 and Close>High[1]) then
		trend3=0.0
		nexttrend3=1
		maxlowprice3=lowpricei3
		endif
	 
	endif
 
	if(trend3=0.0) then
	 
		if(trend3[1]<>0.0) then
		up3=down3[1]
		else
		up3=Max(maxlowprice3,up3[1])
		endif
	down3=0.0
	 
	else
	 
		if(trend3[1]<>1.0) then
		down3=up3[1]
		else
		down3=Min(minhighprice3,down3[1])
		endif
		up3=0.0
		endif
	 
	endif
 
	if up3>0 then
	halftrend3 = up3
	else
	halftrend3 = down3
 
 
 ]]
	
	if(nexttrend3[period]==1) then
	 
	maxlowprice3[period]=math.max(lowpricei3,maxlowprice3[period])
	 
	if(high3.DATA[period]<maxlowprice3[period] and source.close[period]<source.low[period-1]) then
	trend3[period]=1.0
	nexttrend3[period]=0
	minhighprice3[period]=highpricei3
	end 
	 
	end 
 
	if(nexttrend3[period]==0) then
	 
	minhighprice3[period]=math.min(highpricei3,minhighprice3[period])
	 
		if(low3.DATA[period]>minhighprice3[period]  and source.close[period]>source.high[period-1]) then
		trend3[period]=0.0
		nexttrend3[period]=1
		maxlowprice3[period]=lowpricei3
		end 
	 
	end 
	 
		if(trend3[period]==0.0) then
		 
			if(trend3[period-1]~=0.0) then
			up3[period]=down3[period-1]
			else
			up3[period]=math.max(maxlowprice3[period],up3[period-1])
			end 
		down3[period]=0.0
		 
		else
		 
			if(trend3[period-1]~=1.0) then
			down3[period]=up3[period-1]
			else
			down3[period]=math.min(minhighprice3[period],down3[period-1])
			end 
		up3[period]=0.0
		end 
		 
 
		 
		if up3[period]>0 then
		halftrend3 = up3[period]
		else
		halftrend3 = down3[period]
		 
		end 
 
 
     Line1[period]=halftrend2 - halftrend3;
	 
	 if period <= first+ Signal then
	 return;
	 end
	 
	 
     Line2[period]=mathex.avg(Line1, period-Signal+1, period);				  
end

 