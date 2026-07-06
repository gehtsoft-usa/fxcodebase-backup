-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72960

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



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Short-Term Continuation And Reversal Signals");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("DMIMult", "Fast MA", "", 1, 0, 2000);
    indicator.parameters:addInteger("diLength", "DMI Length", "", 10, 1, 2000);
    indicator.parameters:addInteger("maLength", "MA Length", "", 18, 1, 2000);
    indicator.parameters:addInteger("cciLength", "CCI Length", "", 13, 1, 2000);		

	
	 indicator.parameters:addGroup("Line Style");	
	 
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 50);
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 	 
	 
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("colorA", "DMI Up Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("colorB", "DMI Down Color", "", core.rgb(255, 0, 0)); 	 
	 indicator.parameters:addColor("color", "CCI Line Color", "", core.rgb(128, 128, 128)); 
	 indicator.parameters:addColor("OB", "OB Color", "", core.rgb(128, 0, 255));	 
	 indicator.parameters:addColor("OS", "OS Color", "", core.rgb(255, 128, 0));

   indicator.parameters:addColor("clrUP", "Up Text", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Text", "" , core.COLOR_DOWNCANDLE);	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	
	DMIMult=instance.parameters.DMIMult;
	diLength=instance.parameters.diLength;
	maLength=instance.parameters.maLength;
	cciLength=instance.parameters.cciLength;
	Transparency=instance.parameters.Transparency;
	Size=instance.parameters.Size;
	
 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name()    .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	CCI= core.indicators:create("CCI", source, cciLength);
	MVA= core.indicators:create("MVA", source.close, maLength);
	DMI= core.indicators:create("DMI", source, diLength);	
	first=math.max(CCI.DATA:first(), MVA.DATA:first(), DMI.DATA:first()) ; 
	
	
	L1 = instance:addInternalStream(0, 0);
 	L2 = instance:addInternalStream(0, 0);
	
	L3 = instance:addInternalStream(0, 0);
 	L4 = instance:addInternalStream(0, 0); 
 
 
	
    dmi = instance:addStream("DMI", core.Bar, name, "DMI", instance.parameters.colorA, first );
    dmi:setPrecision(math.max(2, instance.source:getPrecision())); 
    dmi:addLevel(0);	
    dmi:addLevel(100);
    dmi:addLevel(-100);		
	
	
    cci = instance:addStream("CCI", core.Line, name, "CCI", instance.parameters.color, first );
    cci:setPrecision(math.max(2, instance.source:getPrecision()));
    cci:setWidth(instance.parameters.width);
    cci:setStyle(instance.parameters.style);	
	
	
    instance:createChannelGroup("OB", "OB", L1, L2, instance.parameters.OB, 100 - Transparency);
    instance:createChannelGroup("OS", "OS", L3, L4, instance.parameters.OS, 100 - Transparency);	
	
	up = instance:createTextOutput ("Down", "Down", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.clrDN, 0);
    down = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
	
	Top = instance:createTextOutput ("Top", "Top", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.clrDN, 0);
    Bottom = instance:createTextOutput ("Bottom", "Bottom", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);	
end


function Update(period, mode)

	  DMI:update(mode); 
	  MVA:update(mode);
	  CCI:update(mode);	 


     L3[period]=0;	 
	  
	 if period <= first then
	 return;
	 end	


     dmi[period] = DMIMult * (DMI.DIP[period] - DMI.DIM[period])
     cci[period] = CCI.DATA[period] 
	 
      if source.close[period] > MVA.DATA[period] then
	  pGTma=true;
	  else
	  pGTma=false;
      end	  
	  
      if source.close[period] < MVA.DATA[period] then
	  pLTma=true;
	  else
	  pLTma=false;
      end	  
	  
 
 
 
      if  dmi[period]  >0 then
	  dmiGT0=true;
	  else
	  dmiGT0=false;
      end	  
	  
      if dmi[period] <  0  then
	  dmiLT0=true;
	  else
	  dmiLT0=false;
      end
	  
 
    if source.low[period] > source.low[period-1]   and source.low[period-1] > source.low[period-2] then
	risingL = true;
	else
	risingL = false;	
	end
    if source.high[period] < source.high[period-1] and source.high[period-1] < source.high[period-2] then
	falingH = true;
	else
	falingH = false;	
	end
	
    if pGTma and dmiGT0 and risingL then
	conUpTrend = true;
	else
	conUpTrend = false;
	end
	
	
	
	
    if pLTma and dmiLT0 and falingH then
	conDoTrend = true;
	else
	conDoTrend = false;	
	end
 
	 
	 
	 if CCI.DATA[period] > 100 then
     L2[period]=CCI.DATA[period];
     L1[period]=100;	 
	 else
     L2[period]=nil;		 
     L1[period]=nil;	 
	 end
	 
	 if CCI.DATA[period] < -100 then
     L4[period]=CCI.DATA[period];
     L3[period]=-100;	 	 
	 else
     L3[period]=nil;	 
     L4[period]=nil;	 
	 end	 

 

	 
	if dmi[period] > 0 then
	dmi:setColor(period,  instance.parameters.colorA);	
    else	
	dmi:setColor(period,  instance.parameters.colorB)	  
	end
	


	
	if  conUpTrend then 
    down:set(period, -100, "\233");	
	else
    down:setNoData(period);	
	end
	
    if conDoTrend then  
    up:set(period, 100, "\234");		
	else	
    up:setNoData(period);		
    end
	
	if CCI.DATA[period]<100 and CCI.DATA[period-1]>100  and CCI.DATA[period-2]>100 then  
    Top:set(period,  100, "\222");		
    else	
    Top:setNoData(period);	 	
    end
	
	if CCI.DATA[period]> -100 and CCI.DATA[period-1]<-100  and CCI.DATA[period-2]<-100 then 
    Bottom:set(period,  -100, "\221");		
    else	
    Bottom:setNoData(period);	 	
    end
	
end
 

 --[[
 // Oscillator signals:
plotshape(conUpTrend, it0, shapeCon, LBOT, colConUpTrend, 
 size=SZ, display=showLVL)
plotshape(conDoTrend, it0, shapeCon, LTOP, colConDoTrend,
 size=SZ, display=showLVL)
plotshape(cciTop, it1, shapeCCI, LTOP, colCCITop,
 size=SZ, display=showLVL)
plotshape(cciBot, it1, shapeCCI, LBOT, colCCIBot, 
 size=SZ, display=showLVL)
// Overlaid signals:
plotshape(conUpTrend, it0, shapeCon, LBBAR, colConUpTrend, 
 size=SZ, display=showOverlay)
plotshape(conDoTrend, it0, shapeCon, LABAR, colConDoTrend,
 size=SZ, display=showOverlay)
plotshape(cciTop, it1, shapeCCI, LABAR, colCCITop,
 size=SZ, display=showOverlay)
plotshape(cciBot, it1, shapeCCI, LBBAR, colCCIBot, 
 size=SZ, display=showOverlay)
 ]]


 

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