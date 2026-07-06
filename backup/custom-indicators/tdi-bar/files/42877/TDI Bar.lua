-- Id: 7768
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=24940

--+------------------------------------------------------------------+
--|                               Copyright � 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Traders Dynamic Index Indicator");
    indicator:description("This hybrid indicator is developed to assist traders in their ability to decipher and monitor market conditions related to trend direction, market strength, and market volatility.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addString("Method", " Method", "Method" , "TDI/SIGNAL");
    indicator.parameters:addStringAlternative("Method", "TDI/SIGNAL", "TDI/SIGNAL" , "TDI/SIGNAL");
    indicator.parameters:addStringAlternative("Method","TDI/BASE" , "TDI/BASE", "TDI/BASE");
    indicator.parameters:addStringAlternative("Method", "TDI/BAND", "TDI/BAND" , "TDI/BAND");
	indicator.parameters:addStringAlternative("Method", "TDI/SIGNAL/BASE", "TDI/SIGNAL/BASE" , "TDI/SIGNAL/BASE");
	indicator.parameters:addStringAlternative("Method", "OVERBOUGHT LEVEL / OVER SOLD LEVEL", "OVERBOUGHT LEVEL / OVER SOLD LEVEL" , "OVERBOUGHT LEVEL / OVER SOLD LEVEL");

    indicator.parameters:addGroup("Calculation");

    indicator.parameters:addInteger("RSI_N", "RSI Periods", "Recommended values are in 8-25 range", 13, 2, 1000);
    indicator.parameters:addInteger("VB_N", "Volatility Band", "Number of periods to find volatility band. Recommended value is 20-40", 34, 2, 1000);
    indicator.parameters:addDouble("VB_W", "Volatility Band Width", "", 1.6185, 0, 100);

    indicator.parameters:addInteger("RSI_P_N", "RSI Price Line Periods", "", 2, 1, 1000);
    indicator.parameters:addString("RSI_P_M", "RSI Price Line Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("RSI_P_M", "MVA(SMA)", "", "MVA");
    indicator.parameters:addStringAlternative("RSI_P_M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "LSMA(Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("RSI_P_M", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "WMA(Wilders)", "", "WMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "KAMA(Kaufman)", "", "KAMA");

    indicator.parameters:addInteger("TS_N", "Trade Signal Line Periods", "", 7, 1, 1000);
    indicator.parameters:addString("TS_M", "Trade Signal Line Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("TS_M", "MVA(SMA)", "", "MVA");
    indicator.parameters:addStringAlternative("TS_M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("TS_M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("TS_M", "LSMA(Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("TS_M", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("TS_M", "WMA(Wilders)", "", "WMA");
    indicator.parameters:addStringAlternative("TS_M", "KAMA(Kaufman)", "", "KAMA");
	
	
	indicator.parameters:addGroup("Levels");
	indicator.parameters:addDouble("OB", "OB Level", "",70);
	indicator.parameters:addDouble("OS", "OS Level", "",30);
	indicator.parameters:addDouble("Buy", "Buy Entry Level", "",50);
	indicator.parameters:addDouble("Sell", "Sell Entry Level", "",50);
		
	 indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("UpUp", "Up in Up Trend Color", "",core.rgb(0,255,0));
	 indicator.parameters:addColor("UpDn", "Down in Up Trend Color", "",core.rgb(0,227,0));
	 indicator.parameters:addColor("DnUp", "Up in Down Trend Color", "", core.rgb(255,0,0));
	  indicator.parameters:addColor("DnDn", "Down in Down Trend Color", "", core.rgb(227,0,0));
	 indicator.parameters:addColor("NeUp", "Up in Neutral Trend", "", core.rgb(128, 128, 128));
     indicator.parameters:addColor("NeDn", "Down in Neutral Trend", "", core.rgb(100, 100, 100));
end

local iRSI, iPMA, iTSMA;
local P, VBU, VBD, TS, MB;
local first;
local VB_N, VB_W ;
local fP, fVB, fTS;
local Up,Down,Neutral;
local HZU = nil;
local HZL = nil;

local open=nil;
local close=nil;
local Method;
local OB,OS,Buy,Sell;

function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
    
	Method=instance.parameters.Method;
 
	OB=instance.parameters.OB;
	OS=instance.parameters.OS;
	Buy=instance.parameters.Buy;
	Sell=instance.parameters.Sell;
	
	UpUp=instance.parameters.UpUp;
	DnUp=instance.parameters.DnUp;
	NeUp=instance.parameters.NeUp;
	
	UpDn=instance.parameters.UpDn;
	DnDn=instance.parameters.DnDn;
	NeDn=instance.parameters.NeDn;

    VB_N = instance.parameters.VB_N;
    VB_W = instance.parameters.VB_W;
 

    iRSI = core.indicators:create("RSI", instance.source, instance.parameters.RSI_N);
    assert(core.indicators:findIndicator(instance.parameters.RSI_P_M) ~= nil, instance.parameters.RSI_P_M .. " indicator must be installed");
    iPMA = core.indicators:create(instance.parameters.RSI_P_M, iRSI.DATA, instance.parameters.RSI_P_N);
    fP = iPMA.DATA:first();
    assert(core.indicators:findIndicator(instance.parameters.TS_M) ~= nil, instance.parameters.TS_M .. " indicator must be installed");
    iTSMA = core.indicators:create(instance.parameters.TS_M, iRSI.DATA, instance.parameters.TS_N);
    fTS = iTSMA.DATA:first();

    fVB = iRSI.DATA:first() + instance.parameters.VB_N - 1;

    

    P = instance:addInternalStream(fP, 0);
	VBU = instance:addInternalStream(fVB, 0);
	VBD = instance:addInternalStream(fVB, 0);
	MB = instance:addInternalStream(fVB, 0);
    TS = instance:addInternalStream(fTS, 0)	;
	
	first= math.max(fP,fVB,fTS );
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first);    
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first);
    close:setPrecision(math.max(2, instance.source:getPrecision()));
 
	instance:createChannelGroup ("ZONE", "ZONE", open, close, core.rgb(0, 0, 0), 100)
end

function Update(period, mode)
    iRSI:update(mode);
    iPMA:update(mode);
    iTSMA:update(mode);

     
	close[period] = 0;
	open[period]  = 1;
	
	 
	open:setColor(period, Neutral);
   
	
	if period >= fP then
        P[period] = iPMA.DATA[period];
    end

    if period >= fTS then
        TS[period] = iTSMA.DATA[period];
    end

    if period >= fVB then
        local stdev, ma;
        stdev = core.stdev(iRSI.DATA, period - VB_N + 1, period);
        ma = core.avg(iRSI.DATA, period - VB_N + 1, period);
        VBU[period] = ma + VB_W * stdev;
        VBD[period] = ma - VB_W * stdev;
        MB[period] = ma;
    end
	
	if period< first then
	return;
	end
	
	Color(period);
	
end


function Color (period)


	if Method == "TDI/SIGNAL" then 
	 
	    if P[period] > TS[period] then
			if P[period] >P[period-1] then  
			open:setColor(period, UpUp)
			else
			open:setColor(period, UpDn)
			end
		elseif P[period] < TS[period] then		
		    if P[period] >P[period-1] then  
			open:setColor(period, DnUp)
			else
			open:setColor(period, DnDn)
			end
		else
		    if P[period] >P[period-1] then  
			open:setColor(period, NeUp)
			else
			open:setColor(period, NeDn)
			end
		end
	   
	elseif  Method == "TDI/BASE" then
	
	    if P[period] > MB[period] then
		    if P[period] >P[period-1] then  
			open:setColor(period, UpUp)
			else
			open:setColor(period, UpDn)
			end
		elseif P[period] < MB[period] then
		    if P[period] >P[period-1] then  
			open:setColor(period, DnUp)
			else
			open:setColor(period, DnDn)
			end
		else
		     if P[period] >P[period-1] then  
			open:setColor(period, NeUp)
			else
			open:setColor(period, NeDn)
			end
		end
	
	elseif  Method == "TDI/BAND" then
	
	    if P[period] > VBU[period] then
		    if P[period] >P[period-1] then  
			open:setColor(period, UpUp)
			else
			open:setColor(period, UpDn)
			end
		elseif P[period] < VBD[period] then
		     if P[period] >P[period-1] then  
			open:setColor(period, DnUp)
			else
			open:setColor(period, DnDn)
			end
		else
		     if P[period] >P[period-1] then  
			open:setColor(period, NeUp)
			else
			open:setColor(period, NeDn)
			end
		end
		
	elseif  Method == "TDI/SIGNAL/BASE" then	
		
		if P[period] > TS[period] and TS[period] > MB[period] then
		     if P[period] >P[period-1] then  
			open:setColor(period, UpUp)
			else
			open:setColor(period, UpDn)
			end
		elseif P[period] < TS[period] and TS[period] < MB[period] then
				  if P[period] >P[period-1] then  
				open:setColor(period, DnUp)
				else
				open:setColor(period, DnDn)
				end
		else    
		
		           if P[period] >P[period-1] then  
					open:setColor(period, NeUp)
					else
					open:setColor(period, NeDn)
					end
		 
		end
		
	--[[1.PRICE LINE> SIGNAL LINE AND SIGNAL LINE >BASE LINE 
		2.AND BASE LINE> BUY ENTRY LEVEL 
		3. AND PRICE LINE < UPPER BAND
		4. AND PRICE LINE < BUY EXIT LEVEL


		RED:

		1.PRICE LINE< SIGNAL LINE AND SIGNAL LINE <BASE LINE 
		2.AND BASE LINE< SELL ENTRY LEVEL 
		3. AND PRICE LINE > LOWER BAND
		4. AND PRICE LINE > SELL EXIT LEVEL]]
		
	elseif  Method == "OVERBOUGHT LEVEL / OVER SOLD LEVEL"	then
	
					if P[period] > TS[period] and TS[period] > MB[period] 
					and  MB[period] > Buy
					and P[period]< VBU[period] 
					and P[period]< OB 
					then
					 if P[period] >P[period-1] then  
					open:setColor(period, UpUp)
					else
					open:setColor(period, UpDn)
					end
				elseif P[period] < TS[period] and TS[period] < MB[period]
				and  MB[period] < Sell
				and P[period]> VBD[period] 
				and P[period]> OS
				then
						  if P[period] >P[period-1] then  
						open:setColor(period, DnUp)
						else
						open:setColor(period, DnDn)
						end
				else    
				
						   if P[period] >P[period-1] then  
							open:setColor(period, NeUp)
							else
							open:setColor(period, NeDn)
							end
				 
				end
				
		
		
	end

end

