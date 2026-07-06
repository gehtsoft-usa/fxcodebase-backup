-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73559

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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
    indicator:name("Kase Permission Stochastic Smoothed");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("pstLength", "Fast MA", "", 9, 1, 2000);
    indicator.parameters:addInteger("pstX", "Slow MA", "", 5, 1, 2000);
    indicator.parameters:addInteger("pstSmooth", "Fast MA", "", 3, 1, 2000);
    indicator.parameters:addInteger("smoothPeriod", "Slow MA", "", 10, 1, 2000);
    indicator.parameters:addBoolean("Signal", "Signal Mode", "", false); 	
 
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 	 
	 
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 25);
	indicator.parameters:addDouble("Level2", "2. Level","", 50);
	indicator.parameters:addDouble("Level3", "3. Level","", 75); 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
	
	
	indicator.parameters:addGroup("Line Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
   indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	
	indicator.parameters:addColor("color", "Bar Color", "", core.rgb(0, 0, 255)); 
		 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local pstLength, pstX,pstSmooth; 
local alpha,lookBackPeriod ;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	pstLength=instance.parameters.pstLength;
	pstX=instance.parameters.pstX;
	pstSmooth=instance.parameters.pstSmooth;
	smoothPeriod=instance.parameters.smoothPeriod;	
    Signal=instance.parameters.Signal;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  pstLength.. "," ..  pstX .. "," ..  pstSmooth.. "," ..  smoothPeriod .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	---Indicator= core.indicators:create("AO", source, Period1, Period2);
 
	
	alpha = 2.0/(1.0+pstSmooth);
    lookBackPeriod = pstLength*pstX;
	
	first=source:first()+lookBackPeriod;	
	
	TripleK= instance:addInternalStream(0, 0);
	TripleDF= instance:addInternalStream(0, 0);
	TripleDS= instance:addInternalStream(0, 0); 
	TripleDFs= instance:addInternalStream(0, 0);
	TripleDSs= instance:addInternalStream(0, 0);


    assert(core.indicators:findIndicator("SMOOTH") ~= nil, "Please, download and install SMOOTH.LUA indicator");

	
	Indicator1 = core.indicators:create("SMOOTH", TripleDFs,  smoothPeriod);
	Indicator2 = core.indicators:create("SMOOTH", TripleDSs,  smoothPeriod);	
	

	Trend= instance:addInternalStream(0, 0);
	
	Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
	Line1:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line1:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line1:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);

 
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);	
	
	if Signal then
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.color, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	
	else
    Bar = instance:addInternalStream(0, 0);	
	end
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);
 	
	core.host:execute ("attachTextToChart", "Up")
	core.host:execute ("attachTextToChart", "Dn")  
end


function Update(period, mode)

 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	local min, max=mathex.minmax(source, period-lookBackPeriod+1, period)
	local max=max-min;

   
    if (max>0) then 
    TripleK[period] = 100.0*(source.close[period]-min)/max;
    else 
	TripleK[period] =   0.0;
	end

    if period <= first+pstX then
    TripleDF[period] = TripleK[period]
    TripleDS[period] = TripleK[period]
	return;
	end
	
 
    TripleDF[period] =  TripleDF[period-pstX]+alpha*(TripleK[period]-TripleDF[period-pstX]);
    TripleDS[period] = (TripleDS[period-pstX]*2.0+TripleDF[period])/3.0;
	
    TripleDFs[period] = mathex.avg(TripleDF, period-3+1, period);   
    TripleDSs[period] = mathex.avg(TripleDS, period-3+1, period);	
	

	Indicator1:update(mode);
	Indicator2:update(mode);	
	
    if period < Indicator1.DATA[period]
    or period < Indicator2.DATA[period]
	then
	return;
	end	
  	
	Line1[period]= Indicator1.DATA[period];
	Line2[period]= Indicator2.DATA[period];	

    up:setNoData(period);
    down:setNoData(period);	
	
 
      if (Line2[period] > Line1[period]) then
	  Trend[period] =  1; 	  
      elseif (Line2[period] < Line1[period]) then
	  Trend[period] =  -1;
	  else
	  Trend[period]= Trend[period-1];
	  end
	  

	
	
	
	
	
	if Trend[period] ==1 and Trend[period-1]~= 1 then
	Bar[period]= 1;
    up:set(period, source.low[period], "\217");		
    elseif Trend[period] ==-1 	and Trend[period-1] ~=  -1 then
    down:set(period, source.high[period], "\218");	
	Bar[period]= -1;		
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