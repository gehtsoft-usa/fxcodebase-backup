-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72824

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
    indicator:name("Haos Visual");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("WPR1 Calculation");	
    indicator.parameters:addInteger("t3period1", "1. Period", "", 8, 1, 2000);
    indicator.parameters:addDouble("b1", "Coefficient", "", 0.7, 0, 1);
    indicator.parameters:addInteger("per1", "2. Period", "", 14, 1, 2000);

 	indicator.parameters:addGroup("WPR2 Calculation");		
    indicator.parameters:addInteger("t3period2", "1. Period", "", 8, 1, 2000);
    indicator.parameters:addDouble("b2", "Coefficient", "", 0.7, 0, 1);
    indicator.parameters:addInteger("per2", "2. Period", "", 96, 1, 2000);	
 
 
	
	indicator.parameters:addGroup("Fast Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color", "Fast Line Color", "", core.rgb(255,200, 0)); 
	 
	indicator.parameters:addGroup("Slow Bar Style"); 	
	indicator.parameters:addColor("color1", "Slow Line Color", "", core.rgb(0,125, 255)); 
	indicator.parameters:addColor("color2", "Slow Line OB Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color3", "Slow Line OS Color", "", core.rgb(255, 0, 0)); 

    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 30);
	indicator.parameters:addDouble("Level2", "2. Level","", 40);
    indicator.parameters:addDouble("Level3", "3. Level","", -30);
	indicator.parameters:addDouble("Level4", "4. Level","", -40);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local t3period1, b1, per1; 
local t3period2, b2, per2; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	t3period1=instance.parameters.t3period1;
	b1=instance.parameters.b1;
	per1=instance.parameters.per1;
	
	t3period2=instance.parameters.t3period2;
	b2=instance.parameters.b2;
	per2=instance.parameters.per2;	
	
	source = instance.source
 
	b2=b1*b1
	b3=b2*b1
	c1=-b3
    c2=(3*(b2+b3))
    c3=-3*(2*b2+b1+b3)
    c4=(1+3*b1+b3+3*b2)
    n=t3period1
    qb2=b2*b2
    qb3=qb2*b2
    qc1=-qb3
    qc2=(3*(qb2+qb3))
    qc3=-3*(2*qb2+b2+qb3)
    qc4=(1+3*b2+qb3+3*qb2)
    qn=t3period2
	
 
    n=1+0.5*(n-1)
    w1=2/(n+1)
    w2=1-w1 
    qn=1+0.5*(qn-1)
    qw1=2/(qn+1)
    qw2=1-qw1	
	
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  t3period1.. "," ..  b1.. "," ..  per1 .. "," ..  t3period2.. "," ..  b2.. "," ..  per2 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	first=source:first()+math.max(per1, per2) ; 
	
	
	e1 = instance:addInternalStream(0, 0);
 	e2 = instance:addInternalStream(0, 0);
	e3 = instance:addInternalStream(0, 0);
	e4 = instance:addInternalStream(0, 0);
	e5 = instance:addInternalStream(0, 0);
	e6 = instance:addInternalStream(0, 0);	

	q1 = instance:addInternalStream(0, 0);
 	q2 = instance:addInternalStream(0, 0);
	q3 = instance:addInternalStream(0, 0);
	q4 = instance:addInternalStream(0, 0);
	q5 = instance:addInternalStream(0, 0);
	q6 = instance:addInternalStream(0, 0);	
	
    Fast = instance:addStream("Fast", core.Line, name, "Fast", instance.parameters.color, first );
    Fast:setPrecision(math.max(2, instance.source:getPrecision()));
    Fast:setWidth(instance.parameters.width);
    Fast:setStyle(instance.parameters.style);
    Fast:addLevel(0);		
	Fast:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Fast:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Fast:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Fast:addLevel(instance.parameters.Level4, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		
	
    Slow = instance:addStream("Slow", core.Bar, name, "Slow", instance.parameters.color1, first );
    Slow:setPrecision(math.max(2, instance.source:getPrecision())); 
    Slow:addLevel(0);	
 
end


function Update(period, mode)

 

	 if period <= first then
	 return;
	 end
	 
	local min1, max1=mathex.minmax(source, period- per1+1, period); 
	local min2, max2=mathex.minmax(source, period- per2+1, period); 	
	
	local Williams1 = ((max1-source[period]) /(max1-min1))* (-100) ;
	local Williams2 = ((max2-source[period]) /(max2-min2))* (-100) ;	
 
	  
	  	
	 e1[period]=w1*Williams1+w2*e1[period-1];
	 e2[period]=w1*e1[period]+w2*e2[period-1];
	 e3[period]=w1*e2[period]+w2*e3[period-1];
	 e4[period]=w1*e3[period]+w2*e4[period-1];
	 e5[period]=w1*e4[period]+w2*e5[period-1];
	 e6[period]=w1*e5[period]+w2*e6[period-1];
	 
	 Fast[period]=c1*e6[period]+c2*e5[period]+c3*e4[period]+c4*e3[period]+50
	 
	 
	 q1[period]=qw1*Williams2+qw2*q1[period-1];
	 q2[period]=qw1*q1[period]+qw2*q2[period-1];
	 q3[period]=qw1*q2[period]+qw2*q3[period-1];
	 q4[period]=qw1*q3[period]+qw2*q4[period-1];
	 q5[period]=qw1*q4[period]+qw2*q5[period-1];
	 q6[period]=qw1*q5[period]+qw2*q6[period-1];
	 
	 Slow[period]=qc1*q6[period]+qc2*q5[period]+qc3*q4[period]+qc4*q3[period]+50
	 
	 
	 if Slow[period] > instance.parameters.Level2 then
	 Slow:setColor(period,  instance.parameters.color2);
	 elseif Slow[period] < instance.parameters.Level4 then	 
	 Slow:setColor(period,  instance.parameters.color3);	
	 else
     Slow:setColor(period,  instance.parameters.color1);
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
