-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72984

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
function Init()
    indicator:name("Stepping Ladder");
    indicator:description("Stepping Ladder Trader"); 
    indicator:requiredSource(core.Bar);
 
    indicator:type(core.Indicator);
 

    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("avgtype", "Ladder Line Type", "Method" , "CoRa_Wave");
    indicator.parameters:addStringAlternative("avgtype", "CoRa_Wave", "CoRa_Wave" , "CoRa_Wave");
    indicator.parameters:addStringAlternative("avgtype", "Donchian Midline", "Donchian Midline" , "Donchian Midline");
	
	

    indicator.parameters:addInteger("length", "Length", "Length", 10, 1, 100000);
    indicator.parameters:addInteger("smooth", "Smoothing", "Smoothing", 3, 1, 100000);	
	
	indicator.parameters:addInteger("g_length", "Signal Length", "Length", 5, 1, 100000);
    indicator.parameters:addInteger("g_smooth", "Signal Smooth", "Smooth", 3, 1, 100000);

    indicator.parameters:addBoolean("RoundUp", "Round Up", "", true);
    indicator.parameters:addBoolean("Step", "Step", "", true);
	
    indicator.parameters:addInteger("ATR_Period", "ATR Period", "ATR Period", 20, 0, 100000);
	   indicator.parameters:addDouble("tr_multi", "ATR Multiplier", "ATR Multiplier", 1.25, 0, 100000);	
    indicator.parameters:addDouble("e_pct", "Pct Envelope", "Pct Envelope", 2, 0, 100000);	
 
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "Down", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Line Color", "Down", core.rgb(128, 128, 128));	
	
	
	
    indicator.parameters:addInteger("wdth", "wdth", "wdth", 1, 1, 5);
    indicator.parameters:addInteger("styl", "styl", "styl", core.LINE_SOLID);
    indicator.parameters:setFlag("styl", core.FLAG_LINE_STYLE);
end


 

-- Routine
function Prepare()

    Down= instance.parameters.Down
    Up= instance.parameters.Up
	Neutral= instance.parameters.Neutral;
	
	avgtype= instance.parameters.avgtype;
	length= instance.parameters.length;	
	smooth= instance.parameters.smooth;
	RoundUp= instance.parameters.RoundUp; 
	Step= instance.parameters.Step;
    ATR_Period= instance.parameters.ATR_Period	
	tr_multi= instance.parameters.tr_multi;	
	e_pct= instance.parameters.e_pct; 
	g_length= instance.parameters.g_length;
	g_smooth= instance.parameters.g_smooth;

 
	
	
    source = instance.source;
 

    local name = profile:id() .. "(" .. source:name() .. ", " .. ATR_Period..")"
    instance:name(name);
	
	
	ATR= core.indicators:create("ATR", source, ATR_Period);
	first=math.max(length, ATR.DATA:first()) ; 	
	
	
	
    Top_ATR= instance:addStream("Top_ATR", core.Line, name, "Top_ATR", Neutral, first)
    Bottom_ATR= instance:addStream("Bottom_ATR", core.Line, name, "Bottom_ATR", Neutral, first)
    Ladder_Signal= instance:addStream("Ladder_Signal", core.Line,  name,"Ladder_Signal", Neutral, first)
    Ladder= instance:addStream("Ladder", core.Line,  name,"Ladder", Neutral, first)	
    Top_PCT= instance:addStream("Top_PCT", core.Line, name, "Top_PCT", Neutral, first)
    Bottom_PCT= instance:addStream("Bottom_PCT", core.Line, name,  "Bottom_PCT", Neutral, first)	
    Signal= instance:addStream("Signal", core.Line, name,  "Signal", Neutral, first)		
    Top_ATR:setWidth(instance.parameters.wdth);
    Top_ATR:setStyle(instance.parameters.styl);
    Bottom_ATR:setWidth(instance.parameters.wdth);
    Bottom_ATR:setStyle(instance.parameters.styl);	
    Ladder:setWidth(instance.parameters.wdth);
    Ladder:setStyle(instance.parameters.styl);	
    Ladder_Signal:setWidth(instance.parameters.wdth);
    Ladder_Signal:setStyle(instance.parameters.styl);
    Top_PCT:setWidth(instance.parameters.wdth);
    Top_PCT:setStyle(instance.parameters.styl);
    Bottom_PCT:setWidth(instance.parameters.wdth);
    Bottom_PCT:setStyle(instance.parameters.styl);	
    Signal:setWidth(instance.parameters.wdth);
    Signal:setStyle(instance.parameters.styl);		
	
	
    Top_ATR:setPrecision(math.max(2, instance.source:getPrecision()));
	Bottom_ATR:setPrecision(math.max(2, instance.source:getPrecision()));
    Top_PCT:setPrecision(math.max(2, instance.source:getPrecision()));
	Bottom_PCT:setPrecision(math.max(2, instance.source:getPrecision()));	
	Ladder_Signal:setPrecision(math.max(2, instance.source:getPrecision()));	
	Ladder:setPrecision(math.max(2, instance.source:getPrecision()));		
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	
    assert(core.indicators:findIndicator("COMPUND RATIO MOVING AVERAGE") ~= nil, "Please, download and install COMPUND RATIO MOVING AVERAGE.LUA indicator");

	CR1= core.indicators:create("COMPUND RATIO MOVING AVERAGE", source.typical, length, g_smooth); 
    CR2= core.indicators:create("COMPUND RATIO MOVING AVERAGE", source.typical, length, g_smooth); 
	
	
	s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle("D1", 0, 0, 0);
    s3, e3 = core.getcandle("H1", 0, 0, 0);
end

-- Indicator calculation routine
function Update(period)


   ATR:update(mode);
   CR1:update(mode);  
   CR2:update(mode); 
   
   if period < first then
   return;
   end
   
   
 
   local min, max= mathex.minmax(source, period-length+1, period);
   
   
   
--Ladder Line calculation
    if avgtype == 'CoRa_Wave' then   
    Ladder[period]=CR1.DATA[period]
	else
	Ladder[period]= (max+min)/2;
	end
	
	Signal[period]= CR2.DATA[period]
	
	
    local step= f_step(source.typical[period])  ; 
	
    if Step then	
  	Ladder_Signal[period]=  Rounding(period,   step )  
	else
	Ladder_Signal[period]=  Ladder[period];
	end
	
	
	Top_PCT[period]     = Ladder_Signal[period] * (1 + e_pct / 100)
	Bottom_PCT[period]    = Ladder_Signal[period] * (1 - e_pct / 100)
	
 
	local Change= Ladder_Signal[period]-Ladder_Signal[period-1];
	
	if Change~=0 then
	ATR_us       =  ATR.DATA[period]*tr_multi;  
	ATR_ls       =  ATR.DATA[period]*tr_multi;
	else
	ATR_us       =  ATR.DATA[period-1]*tr_multi;  
	ATR_ls       =  ATR.DATA[period-1]*tr_multi;	
	end
	
 
	Top_ATR[period]   = Ladder_Signal[period] + ATR_us
	Bottom_ATR[period]    = Ladder_Signal[period] - ATR_ls	
	
	if Signal[period]> Ladder_Signal[period] then
	Ladder_Signal:setColor(period, Up);	
	else
 	Ladder_Signal:setColor(period,  Down);	  
	end
end

function Rounding(period,   _step )   
   if RoundUp then
   return  math.floor((Ladder[period] / _step)+0.5) * _step;
   else
   return math.floor (Ladder[period] / _step) * _step;
   end
end
  

 
function f_step(x)  
 
      if x < 2     then 
	  initstep= 0.01  
	  elseif x < 5     then
	  initstep= 0.02  
      elseif x < 10    then
	  initstep= 0.10  
	  elseif x < 30    then
	  initstep= 0.20   
      elseif x < 100   then
	  initstep= 1.00  
	  elseif x < 300   then
	  initstep= 2.00   
      elseif x < 500   then
	  initstep= 5.00  
	  elseif x < 1000  then
	  initstep= 10.0  
      elseif x < 2000  then
	  initstep= 20.0  
	  elseif x < 5000  then
	  initstep= 50.0  
      elseif x < 10000 then
	  initstep= 100.0 
	  elseif x < 20000 then
	  initstep= 200.0  
      elseif x < 50000 then
	  initstep= 500  
	  else
	  initstep=  1000.0
	  end



      if source:barSize()== "W1"  then
	  adjstep = initstep * 2 
      end
	  
      if source:barSize()== "M1"  then
	  adjstep = initstep * 5  
	  end 
     if  (e1 -s1) < (e2 -s2) then   
	 
	   if  (e1 -s1) <= (e3 -s3) then  
       adjstep =  initstep / 5  
	   else
	   adjstep = initstep / 2   
	   end
	   
	 end
	 
    return adjstep;
	
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

