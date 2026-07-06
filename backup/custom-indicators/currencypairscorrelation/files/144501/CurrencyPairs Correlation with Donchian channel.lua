-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71712

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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
 
function Init()
    indicator:name("CurrencyPairs Correlation with Donchian channel");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
   indicator.parameters:addGroup("Calculation"); 
   indicator.parameters:addDouble("ActiveLevel", "ActiveLevel", "" , 3.618);
   indicator.parameters:addDouble("PassiveLevel", "PassiveLevel", "" , 1.618);   



   indicator.parameters:addGroup("1.Line Calculation"); 
   indicator.parameters:addString("instrument1"  , "Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("instrument1" ,  core.FLAG_INSTRUMENTS);
   indicator.parameters:addInteger("Period1", "MA Period", "Period" , 14);
    indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
    
	
	indicator.parameters:addGroup("2.Line Calculation"); 
	indicator.parameters:addString("instrument2"  , "Instrument", "", "AUD/USD");
    indicator.parameters:setFlag("instrument2" ,  core.FLAG_INSTRUMENTS);
   indicator.parameters:addInteger("Period2", "MA Period", "Period" , 14);
    indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");

   indicator.parameters:addGroup("3.Line Calculation");  
   indicator.parameters:addInteger("Period3", "MA Period", "Period" , 5);
    indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
    
	
	indicator.parameters:addGroup("4.Line Calculation");  
   indicator.parameters:addInteger("Period4", "MA Period", "Period" , 5);
    indicator.parameters:addString("Method4", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method4", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method4", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method4", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method4", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method4", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method4", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Donchian channel Calculation")
	indicator.parameters:addInteger("N", "Number of periods", "", 20, 2, 10000)
	indicator.parameters:addString("AC", "Analyze the current period", "", "no")
	indicator.parameters:addStringAlternative("AC", "no", "", "no")
	indicator.parameters:addStringAlternative("AC", "yes", "", "yes")

	indicator.parameters:addString("SM", "Show middle line", "", "yes")
	indicator.parameters:addStringAlternative("SM", "no", "", "no")
	indicator.parameters:addStringAlternative("SM", "yes", "", "yes")
	
		
    
	indicator.parameters:addGroup("1.Line Style");  
	indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    
	indicator.parameters:addGroup("2.Line Style");
	indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("Style");  
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);	
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));	
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));	


	indicator.parameters:addGroup("Line Style")
	indicator.parameters:addColor("clrDU", "Color of the Up line", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE)
	indicator.parameters:addColor("clrDN", "Color of the Down line", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE)
	indicator.parameters:addColor("clrDM", "Color of the middle line", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE)
	
end
 
 
local source;

local Indicator1= nil; 
local Indicator2= nil;
 

 
local first; 
 
local dayoffset, weekoffset; 
local Source1, Source2;
 local loading1, loading2; 
local First_Line,Second_Line;

local Point1, Point2;
local lastBar, firstBar;


local ActiveLevel,PassiveLevel;	
local Up, Down, Neutral;
local Max, Min;
local du, dn,dm;
local ac, sm;
function Prepare(nameOnly)
 
    source = instance.source;	
	first = source:first();
	
	
	n = instance.parameters.N

	ac = (instance.parameters.AC == "yes")
	sm = (instance.parameters.SM == "yes")
	
	ActiveLevel=instance.parameters.ActiveLevel;
	PassiveLevel=instance.parameters.PassiveLevel;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	Transparency=instance.parameters.Transparency;
	Transparency= 100-Transparency;

    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	instance:name(name );
	if nameOnly then
		return;
	end
	
		 
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
 
	Raw1 = instance:addInternalStream(0, 0);
	Raw2 = instance:addInternalStream(0, 0);  

 	
	
	Point1= core.host:findTable("offers"):find("Instrument", instance.parameters.instrument1).PointSize;		
	Point2= core.host:findTable("offers"):find("Instrument", instance.parameters.instrument2).PointSize;	
	
	Source1 = core.host:execute("getSyncHistory",  instance.parameters.instrument1, source:barSize(), source:isBid(), 300, 100, 101);
	loading1=true;
	
	Source2 = core.host:execute("getSyncHistory", instance.parameters.instrument2, source:barSize(), source:isBid(), 300, 200, 201);
	loading2=true;
	
	
	Indicator1 = core.indicators:create( instance.parameters.Method1, Source1.close,  instance.parameters.Period1);
    Indicator2 = core.indicators:create( instance.parameters.Method2, Source2.close,  instance.parameters.Period2);
	
	
	Indicator3 = core.indicators:create( instance.parameters.Method3, Raw1,  instance.parameters.Period3);
    Indicator4 = core.indicators:create( instance.parameters.Method4, Raw2,  instance.parameters.Period4);
	
 
     First_Line = instance:addStream("First_Line", core.Line, "First_Line", "First_Line", instance.parameters.color1, first);
	 First_Line:setWidth(instance.parameters.width1);
     First_Line:setStyle(instance.parameters.style1);
	 
	 Second_Line = instance:addStream("Second_Line", core.Line, "Second_Line", "Second_Line", instance.parameters.color2, first);
	 
	 Second_Line:setWidth(instance.parameters.width2);
     Second_Line:setStyle(instance.parameters.style2);

 
 
	Min = instance:addInternalStream(0, 0);
	Max = instance:addInternalStream(0, 0); 
	
	
	du = instance:addStream("DU", core.Line, name .. ".DU", "DU", instance.parameters.clrDU, first)
	du:setWidth(instance.parameters.width3)
	du:setStyle(instance.parameters.style3)
	dn = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.clrDN, first)
	dn:setWidth(instance.parameters.width4)
	dn:setStyle(instance.parameters.style4)
	if (sm) then
		dm = instance:addStream("DM", core.Line, name .. ".DM", "DM", instance.parameters.clrDM, first)
		dm:setWidth(instance.parameters.width5)
		dm:setStyle(instance.parameters.style5)
	end
	
	
	
	instance:createChannelGroup("Channel","Channel" , First_Line,Second_Line, Neutral, Transparency);

end


function   Initialization1(period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
    if loading1 or Source1:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source1, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	


function   Initialization2(period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
    if loading2 or Source2:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source2, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	


local Last=nil;
function Update(period, mode)

 
 
	if period == first then
	Last=period;
		return;
	elseif   period < Last then 
	
	
	 	Last=period;
	  instance:updateFrom(0);
	 
	return;
	end 
	

  
   Indicator1:update(mode);
   Indicator2:update(mode);	
   
   p1= Initialization1(period);   
   p2= Initialization2(period);
   
   if p1== false or p2== false then
   return;
   end
   
   
   
   Raw1[period]=(Source1.close[p1]- Indicator1.DATA[p1])/Point1;
   Raw2[period]=(Source2.close[p2]-Indicator2.DATA[p2])/Point2;  
 
   Indicator3:update(mode);
   Indicator4:update(mode);	
   
   
   First_Line[period]=Indicator3.DATA[period];
   Second_Line[period]=Indicator4.DATA[period];   
   
     if(First_Line[period] > Second_Line[period] and First_Line[period] > 0 and Second_Line[period] < 0 and First_Line[period] >= ActiveLevel and Second_Line[period] <= -PassiveLevel) then
 
		First_Line:setColor(period,Up);
		Second_Line:setColor(period,  Up); 
      
      elseif(First_Line[period] < Second_Line[period] and First_Line[period] < 0 and Second_Line[period] > 0 and Second_Line[period] >= ActiveLevel and First_Line[period] <= -PassiveLevel) then
  
		First_Line:setColor(period,Down);
		Second_Line:setColor(period,  Down);  
   
      else
 		First_Line:setColor(period,Neutral);
		Second_Line:setColor(period,  Neutral);
 
      end
	  
    Min[period]=math.min(Indicator3.DATA[period], Indicator4.DATA[period]);
    Max[period]=math.max(Indicator3.DATA[period], Indicator4.DATA[period]);
	  
 
    if period <= n then
	return;
	end
	
		if (ac) then
			dn[period] = mathex.min(Min, period - n + 1, period)
			du[period] = mathex.max(Max, period - n + 1, period)
		else
			dn[period] = mathex.min(Min, period - n + 1 - 1, period - 1)
			du[period] = mathex.max(Max, period - n + 1 - 1, period - 1)
		end
 

	if (sm) then
		dm[period] = (du[period] + dn[period]) / 2
	end
 
  
end
 

  

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading1 = false;
       
    elseif cookie == 101 then
        loading1 = true;
    end
	
	
	 if cookie == 200 then
        loading2 = false;
 
    elseif cookie == 201 then
        loading2 = true;
    end
	
	
	 if not  loading1 and not loading2 then
	 instance:updateFrom(0); 
	 end
	 
	 return core.ASYNC_REDRAW ;
end


 

  