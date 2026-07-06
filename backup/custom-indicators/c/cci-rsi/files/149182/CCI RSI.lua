-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73245

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
    indicator:name("CCI + RSI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);


  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "CCI Period", "", 10, 1, 2000);
    indicator.parameters:addInteger("Period2", "RSI Period", "", 7, 1, 2000);
    indicator.parameters:addInteger("Period3", "MA Period", "", 10, 1, 2000); 	
	
 	indicator.parameters:addGroup("Selector");	 
	indicator.parameters:addString("Method", "OB/OS Method", "Method" , "Both");
    indicator.parameters:addStringAlternative("Method", "Both", "Both" , "Both");
    indicator.parameters:addStringAlternative("Method", "Any", "Any" , "Any");	
	
	indicator.parameters:addString("Type", "Indicator/MA Type", "Type" , "Indicator");
    indicator.parameters:addStringAlternative("Type", "Indicator", "Indicator" , "Indicator");
    indicator.parameters:addStringAlternative("Type", "Moving Average", "Moving Average" , "Average");		
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 255)); 
	indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 255)); 
	indicator.parameters:addColor("color3", "Neutral Line Color", "", core.rgb(128, 128, 128)); 	
 
	
	indicator.parameters:addGroup("Channel Style");	
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));

	indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);	
	
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 30);
	indicator.parameters:addDouble("Level2", "2. Level","", 50);
	indicator.parameters:addDouble("Level3", "3. Level","", 70); 
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
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
    Transparency= instance.parameters.Transparency;
    Transparency= 100-Transparency;	
    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
	Method= instance.parameters.Method;
    Type= instance.parameters.Type;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2.. "," ..  Period3  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	cci= core.indicators:create("CCI", source, Period1 );
	rsi= core.indicators:create("RSI", source.close, Period2 );	
	first=math.max(cci.DATA:first(),rsi.DATA:first()) ; 
	
	cci_ma= core.indicators:create("MVA", cci.DATA, Period3 );
	rsi_ma= core.indicators:create("MVA", rsi.DATA, Period3 );	
	
	
    Top= instance:addInternalStream(0, 0);
    Bottom= instance:addInternalStream(0, 0);
	
	instance:createChannelGroup("ZoneGroup","ZoneGroup" , Top, Bottom, Neutral, Transparency);
	
	
	
    CCI = instance:addStream("CCI", core.Line, name, "CCI", instance.parameters.color1, first  +Period3 );
    CCI:setPrecision(math.max(2, instance.source:getPrecision()));
    CCI:setWidth(instance.parameters.width);
    CCI:setStyle(instance.parameters.style); 
	
	CCI:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	CCI:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	CCI:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);

	
 
    RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.color1, first   +Period3 );
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
    RSI:setWidth(instance.parameters.width);
    RSI:setStyle(instance.parameters.style); 
	
	instance:createChannelGroup("LineGroup","LineGroup" , CCI, RSI, Neutral, Transparency);	
	
	
end


function Update(period, mode)

	cci:update(mode); 
	rsi:update(mode); 

    Top[period]=100;
    Bottom[period]=0;
	
	cci_ma:update(mode); 
	rsi_ma:update(mode);	
   	
	if period <= first +Period3 
	or  not source:hasData(period) 
	then
	return;
	end
  
    if Type =="Indicator" then
		local min, max=mathex.minmax(cci.DATA, first, period);
			
		CCI[period]= (cci.DATA[period]-min)/(max-min)*100;
		RSI[period]= rsi.DATA[period];	
	else  
		local min, max=mathex.minmax(cci_ma.DATA, first+Period3, period);
				
		CCI[period]= (cci_ma.DATA[period]-min)/(max-min)*100;
		RSI[period]= rsi_ma.DATA[period];		
	end
	

	
	if ((CCI[period]> instance.parameters.Level3 or RSI[period]> instance.parameters.Level3) and Method~= "Both")
	or ((CCI[period]> instance.parameters.Level3 and RSI[period]> instance.parameters.Level3) and Method== "Both")
	then 
	Top:setColor(period, Up);
	elseif ((CCI[period]< instance.parameters.Level1 or RSI[period]< instance.parameters.Level1) and Method~= "Both")
	or ((CCI[period]< instance.parameters.Level1 and RSI[period]< instance.parameters.Level1) and Method== "Both")
	then  
	Top:setColor(period, Down);	
	else
	Top:setColor(period, Neutral);	
	end
	
	if ((cci.DATA[period]> cci_ma.DATA[period] or rsi.DATA[period]> rsi_ma.DATA[period]) and Method~= "Both")
	or ((cci.DATA[period]> cci_ma.DATA[period] and rsi.DATA[period]> rsi_ma.DATA[period]) and Method== "Both")
	then 
	CCI:setColor(period, instance.parameters.color1);
	elseif ((cci.DATA[period]< cci_ma.DATA[period] or rsi.DATA[period]< rsi_ma.DATA[period]) and Method~= "Both")
	or ((cci.DATA[period]< cci_ma.DATA[period] and rsi.DATA[period]< rsi_ma.DATA[period]) and Method== "Both")
	then  
	CCI:setColor(period, instance.parameters.color2);	
	else
	CCI:setColor(period, instance.parameters.color3);	
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