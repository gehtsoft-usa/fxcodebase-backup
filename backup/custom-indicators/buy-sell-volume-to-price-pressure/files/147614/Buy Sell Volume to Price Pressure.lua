-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72764

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
    indicator:name("Buy & Sell Volume to Price Pressure");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("signal", "Signal Period", "", 3, 1, 2000);
    indicator.parameters:addInteger("long", "Long Period", "", 21, 1, 2000);
	
	indicator.parameters:addBoolean("vmacd", "Buy to Sell Convergence/Div OSC", "", true);
	indicator.parameters:addBoolean("vinv", "Buy to Sell Conv/Div as cummulative", "", false);
	indicator.parameters:addBoolean("norm", "Normalised (Filtered) Version", "", false);	
  
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0)); 
    indicator.parameters:addInteger("Transparency", "Transparency", "", 95,0,100);	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local vmacd, vinv,norm ; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	signal=instance.parameters.signal;
	long=instance.parameters.long;
	vinv =instance.parameters.vinv;
	norm =instance.parameters.norm;	
	
	Transparency= instance.parameters.Transparency;
    Transparency= 100-Transparency;

	if instance.parameters.vmacd then
	vmacd =1;
	else
	vmacd =0;	
	end
	

	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  signal.. "," ..  long  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first() +1; 
	
	
	BP = instance:addInternalStream(0, 0);
	SP = instance:addInternalStream(0, 0); 
	
	BPV = instance:addInternalStream(0, 0);
	SPV = instance:addInternalStream(0, 0);
	TPV = instance:addInternalStream(0, 0);
	
	BPN = instance:addInternalStream(0, 0);
	SPN = instance:addInternalStream(0, 0);
	TPN = instance:addInternalStream(0, 0);
	
  

	BPVavg0= core.indicators:create("EMA", BPV, signal);
	SPVavg0= core.indicators:create("EMA", SPV, signal);
	TPVavg0= core.indicators:create("WMA", TPV, signal);		
	
	BPVavg= core.indicators:create("EMA", BPVavg0.DATA, signal);
	SPVavg= core.indicators:create("EMA", SPVavg0.DATA, signal);
	TPVavg= core.indicators:create("EMA", TPVavg0.DATA, signal);	
	

	volume= core.indicators:create("EMA", source.volume, long);
	LongBP= core.indicators:create("EMA", BP, long);
	LongSP= core.indicators:create("EMA", SP, long);
	
	BPVwavg= core.indicators:create("WMA", BPV, signal);
	SPVwavg= core.indicators:create("WMA", SPV, signal);
	TPVwavg= core.indicators:create("WMA", TPV, signal);
	
	nbf= core.indicators:create("EMA", BPVwavg.DATA, signal);
	nsf= core.indicators:create("EMA", SPVwavg.DATA, signal);
	tpf= core.indicators:create("EMA", TPVwavg.DATA, signal);


    vph = instance:addInternalStream(0, 0);	
	vpo1 = instance:addInternalStream(0, 0);	
	vpo2 = instance:addInternalStream(0, 0);	
 

    Buying = instance:addStream("Buying", core.Line, name, "Buying", instance.parameters.Up, first + math.max(signal*2 , long) +long );
    Buying:setPrecision(math.max(2, instance.source:getPrecision())); 
    Buying:addLevel(0);	
	
    Selling = instance:addStream("Selling", core.Line, name, "Selling", instance.parameters.Down, first + math.max(signal*2 , long) +long );
    Selling:setPrecision(math.max(2, instance.source:getPrecision())) 
    Selling:addLevel(0);	
	
    SPAvg = instance:addStream("SPAvg", core.Line, name, "SPAvg", instance.parameters.Up, first + math.max(signal*2 , long) +long );
    SPAvg:setPrecision(math.max(2, instance.source:getPrecision())); 
    SPAvg:addLevel(0);	
	
    BPAvg = instance:addStream("BPAvg", core.Line, name, "BPAvg", instance.parameters.Down, first + math.max(signal*2 , long) +long );
    BPAvg:setPrecision(math.max(2, instance.source:getPrecision())) 
    BPAvg:addLevel(0); 
  
    VPO1 = instance:addStream("VPO1", core.Line, name, "VPO1", instance.parameters.Up, first + math.max(signal*2 , long) +long );
    VPO1:setPrecision(math.max(2, instance.source:getPrecision()));
    VPO1:setWidth(instance.parameters.width);
    VPO1:setStyle(instance.parameters.style);
    VPO1:addLevel(0);	
	
    VPO2 = instance:addStream("VPO2", core.Line, name, "VPO2", instance.parameters.Up, first + math.max(signal*2 , long) +long );
    VPO2:setPrecision(math.max(2, instance.source:getPrecision()));
    VPO2:setWidth(instance.parameters.width);
    VPO2:setStyle(instance.parameters.style);
    VPO2:addLevel(0);	
	
	
    VPH = instance:addStream("VPH", core.Bar, name, "VPH", instance.parameters.Up, first + math.max(signal*2 , long) +long );
    VPH:setPrecision(math.max(2, instance.source:getPrecision())); 
    VPH:addLevel(0); 
	
	Top= instance:addInternalStream(0, 0);	
	Bottom= instance:addInternalStream(0, 0);	
 	instance:createChannelGroup("Group","Group" , Top, Bottom, instance.parameters.Up, Transparency); 
end


function Update(period, mode)

 
    Top[period] = 100000;	
	Bottom[period] = -100000;
	
	 if period <= first then
	 return;
	 end
	 
 
	if source.close[period]<source.open[period] then
		if source.close[period-1]<source.open[period] then
		BP[period] = math.max(source.high[period]-source.close[period-1], source.close[period]-source.low[period])
		else
		BP[period] = math.max(source.high[period]-source.open[period], source.close[period]-source.low[period])
		end
	
	elseif source.close[period]>source.open[period] then
		if source.close[period-1]>source.open[period] then
		BP[period] = source.high[period]-source.low[period]
		else
		BP[period] = math.max(source.open[period]-source.close[period-1], source.high[period]-source.low[period])
		end 
	elseif source.high[period]-source.close[period]>source.close[period]-source.low[period] then
		if source.close[period-1]<source.open[period] then
		BP[period] = math.max(source.high[period]-source.close[period-1],source.close[period]-source.low[period])
		else
		BP[period] = source.high[period]-source.open[period]
		end 
	elseif source.high[period]-source.close[period]<source.close[period]-source.low[period] then
		if source.close[period-1]>source.open[period] then
		BP[period] = source.high[period]-source.low[period]
		else
		BP[period] = math.max(source.open[period]-source.close[period-1], source.high[period]-source.low[period])
		end 
	elseif source.close[period-1]>source.open[period] then
	BP[period] = math.max(source.high[period]-source.open[period], source.close[period]-source.low[period])
	elseif source.close[period-1]<source.open[period] then
	BP[period] = math.max(source.open[period]-source.close[period-1], source.high[period]-source.low[period])
	else
	BP[period] =  source.high[period]-source.low[period]
	end 	
	
  
 
 

 
	if source.close[period]<source.open[period] then
		if source.close[period-1]>source.open[period] then
		SP[period] = math.max(source.close[period-1]-source.open[period], source.high[period]-source.low[period])
		else
		SP[period] = source.high[period]-source.low[period]
		end 
	elseif source.close[period]>source.open[period] then
	if source.close[period-1]>source.open[period] then
		SP[period] = math.max(source.close[period-1]-source.low[period], source.high[period]-source.close[period])
		else
		SP[period] = math.max(source.open[period]-source.low[period], source.high[period]-source.close[period])
		end 
	elseif source.high[period]-source.close[period]>source.close[period]-source.low[period] then
		if source.close[period-1]>source.open[period] then
		SP[period] = math.max(source.close[period-1]-source.open[period], source.high[period]-source.low[period])
		else
		SP[period] = source.high[period]-source.low[period]
		end 
	elseif source.high[period]-source.close[period]<source.close[period]-source.low[period] then
		if source.close[period-1]>source.open[period] then
		SP[period] = math.max(source.close[period-1]-source.low[period], source.high[period]-source.close[period])
		else
		SP[period] = source.open[period]-source.low[period]
		end 
	elseif source.close[period-1]>source.open[period] then
	SP[period] = math.max(source.close[period-1]-source.open[period], source.high[period]-source.low[period])
	elseif source.close[period-1]<source.open[period] then
	SP[period] = math.max(source.open[period]-source.low[period], source.high[period]-source.close[period])
	else
	SP[period] = source.high[period]-source.low[period]
	end 
	 
	TP = BP[period]+SP[period]
	 
	 
	BPV[period] = (BP[period]/TP)*source.volume[period]
	SPV[period] = (SP[period]/TP)*source.volume[period]
	TPV[period] = BPV[period]+SPV[period]
	

	
	BPVavg0:update(mode);	
	SPVavg0:update(mode);	
	TPVavg0:update(mode);
	
	BPVavg:update(mode);	
	SPVavg:update(mode);	
	TPVavg:update(mode);
	
	volume:update(mode);	
	LongBP:update(mode);
	LongSP:update(mode);
	
	BPVwavg:update(mode);
	SPVwavg:update(mode);
	TPVwavg:update(mode);
	
	nbf:update(mode);
	nsf:update(mode);
	tpf:update(mode);
	
	 if period <= first + math.max(signal*2 , long) then
	 return;
	 end		
 
	
	local VN = source.volume[period]/volume.DATA[period]; 
	BPN[period] = ((BP[period]/LongBP.DATA[period])*VN)*100
	SPN[period] = ((SP[period]/LongSP.DATA[period])*VN)*100
	TPN[period] = BPN[period]+SPN[period]
	
	
	
	local ndif = nbf.DATA[period]-nsf.DATA[period]
	
	if BPV[period]>SPV[period] then
	BPc1 = BPV[period]
	else
	BPc1 = -math.abs(BPV[period])
	end 
	 
	if BPN[period]>SPN[period] then
	BPc2 = BPN[period]
	else
	BPc2 = -math.abs(BPN[period])
	end 
	 
	if SPV[period]>BPV[period] then
	SPc1 = SPV[period]
	else
	SPc1 = -math.abs(SPV[period])
	end 
	 
	if SPN[period]>BPN[period] then
	SPc2 = SPN[period]
	else
	SPc2 = -math.abs(SPN[period])
	end 
	 
	if norm then
	BPcon = BPc2
	else
	BPcon = BPc1
	end 
	 
	if norm then
	SPcon = SPc2
	else
	SPcon = SPc1
	end 
	 
	if norm then
	BPAcon = nbf.DATA[period]
	else
	BPAcon = BPVavg.DATA[period]
	end 
	 
	if norm then
	SPAcon = nsf.DATA[period]
	else
	SPAcon = SPVavg.DATA[period]
	end 
	 
	if norm then
	TPAcon = tpf.DATA[period]
	else
	TPAcon = TPVavg.DATA[period]
	end 	
	
	
	 if period <= first + math.max(signal*2 , long) +long then
	 return;
	 end		
 
 
	local A= mathex.sum(BPVavg.DATA, period-long+1, period);
	local B= mathex.sum(SPVavg.DATA, period-long+1, period); 
	local C= mathex.sum(TPVavg.DATA, period-long+1, period);  
	
	local D= mathex.sum(nbf.DATA, period-long+1, period); 
	local E= mathex.sum(nsf.DATA, period-long+1, period);  
	local F= mathex.sum(tpf.DATA, period-long+1, period); 
	
	if vinv then
	vpo1[period] = ((A-B)/C)*100
	else
	vpo1[period] = ((BPVavg.DATA[period]-SPVavg.DATA[period])/TPVavg.DATA[period])*100
	end 
	 
	if vinv then
	vpo2[period] = ((D-E)/F)*100
	else
	vpo2[period] = ((nbf.DATA[period]-nsf.DATA[period])/tpf.DATA[period])*100
	end 
	 
	vph[period] = (vpo1[period] - vpo2[period])	
	
	 
	
	
	if (vpo1[period] > vpo1[period-1] and vpo2[period] > vpo2[period-1]) or (BPcon > SPcon and BPAcon > SPAcon)  then
	Top:setColor(period,  instance.parameters.Up);
	end 
	if (vpo1[period] < vpo1[period-1] and vpo2[period] < vpo2[period-1]) or (BPcon < SPcon and BPAcon < SPAcon) then
	Top:setColor(period,  instance.parameters.Down);
	end 	
	
	
	VPO1[period]=(vmacd)*math.floor(vpo1[period]);
	VPO2[period]=(vmacd)*math.floor(vpo2[period]);
	VPH[period]=(vmacd)*math.floor(vph[period]); 
    Selling[period]=(1-vmacd)*math.floor(SPcon);
    Buying[period]=(1-vmacd)*math.floor(BPcon) 	
	SPAvg[period]=(1-vmacd)*math.floor(SPAcon)
    BPAvg[period]=(1-vmacd)*math.floor(BPAcon)
	
	
	 
	if vpo2[period] > 0 then 
	VPO2:setColor(period,  instance.parameters.Up);		
	else 
	VPO2:setColor(period,  instance.parameters.Down);		
	end 
	
	
	if vph[period] > vph[period-1] then 
	VPH:setColor(period,  instance.parameters.Up);	
	else 
	VPH:setColor(period,  instance.parameters.Down);	
	end 
	 
	if vpo1[period] > 0 then 
	VPO1:setColor(period,  instance.parameters.Up);		
	else 
	VPO1:setColor(period,  instance.parameters.Down);			
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