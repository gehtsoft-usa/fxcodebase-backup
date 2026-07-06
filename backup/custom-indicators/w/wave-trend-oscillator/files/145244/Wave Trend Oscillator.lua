-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71939

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
    indicator:name("Wave Trend Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("channellen", "Channel Length", "", 8, 1, 2000);
    indicator.parameters:addInteger("averagelen", "Average Length", "", 6, 1, 2000);

    indicator.parameters:addInteger("wt1malen", "Moving Average Length", "", 3, 1, 2000);
    indicator.parameters:addInteger("channellen2", "Channel Length", "", 13, 1, 2000);
    indicator.parameters:addInteger("averagelen2", "Average Length", "", 55, 1, 2000);
	
 
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0));
	 
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 90);
	indicator.parameters:addDouble("Level2", "2. Level","", 70); 	
	indicator.parameters:addDouble("Level3", "3. Level","", 0);
	indicator.parameters:addDouble("Level4", "4. Level","", -70); 
    indicator.parameters:addDouble("Level5", "5. Level","", -90); 	
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);	

	indicator.parameters:addGroup("Arrow Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
    indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);		
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local channellen, averagelen,wt1malen,channellen2,averagelen2; 
local MVA;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	channellen=instance.parameters.channellen;
	averagelen=instance.parameters.averagelen;
	wt1malen=instance.parameters.wt1malen;
	channellen2=instance.parameters.channellen2;	
	averagelen2=instance.parameters.averagelen2;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  channellen.. "," ..  averagelen .. "," ..  wt1malen.. "," ..  channellen2.. "," ..  averagelen2 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	MVA1= core.indicators:create("MVA", source , channellen);
	first=MVA1.DATA:first() ; 

    Data = instance:addInternalStream(0, 0);
	
    Data1 = instance:addInternalStream(0, 0);
    Data2 = instance:addInternalStream(0, 0);	
	MVA2= core.indicators:create("MVA", Data1, channellen);	
	MVA3= core.indicators:create("MVA", Data2, averagelen);	
	
    mva1= core.indicators:create("MVA", source , channellen); 
    data1 = instance:addInternalStream(0, 0);
    data2 = instance:addInternalStream(0, 0);	
	mva2= core.indicators:create("MVA", data1, channellen2);	
	mva3= core.indicators:create("MVA", data2, averagelen2);
	
	
    Line1 = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, MVA3.DATA:first() );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	


	
    Line2 = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color2, mva2.DATA:first() );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0); 
	
	Line1:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
	Line1:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
	Line1:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
	Line1:addLevel(instance.parameters.Level4, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
	Line1:addLevel(instance.parameters.Level5, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);		
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
end


function Update(period, mode)

	  MVA1:update(mode); 

	 if period < first then
	 return;
	 end
	 
	Data1[period]= math.abs(source [period]-MVA1.DATA[period])
 
	  MVA2:update(mode); 	
	  
	 if period < first+channellen then
	 return;
	 end	  
	 
	 
	Data2[period] = (source [period] - MVA1.DATA[period]) / (0.015 * MVA2.DATA[period]);

	  MVA3:update(mode); 	
	  
	 if period < MVA3.DATA:first() then
	 return;
	 end	 
	 
	Line1[period]= MVA3.DATA[period];
	
	
	if period < MVA3.DATA:first()+wt1malen then
	return;
	end	
	
    Data[period] = mathex.avg(Line1, period- wt1malen +1, period);
	

    up:setNoData(period);
    down:setNoData(period);	

    if Line1[period] > Data[period] and Line1[period-1] <= Data[period-1] then
    up:set(period, Line1[period], "\217" ); 
    elseif Line1[period] < Data[period] and Line1[period-1] >= Data[period-1] then	
    down:set(period, Line1[period], "\218" );
	end
	  mva1:update(mode);	
	data1[period]= math.abs(source[period]-mva1.DATA[period])
 
	  mva2:update(mode); 	
	  
	 if period < mva2.DATA[period] then
	 return;
	 end	  
	 
	 
	data2[period] = (source[period] - mva1.DATA[period]) / (0.015 * mva2.DATA[period]);

	  mva3:update(mode); 	
	  
	 if period < mva3.DATA:first() then
	 return;
	 end	 
	 
	Line2[period]= mva3.DATA[period];
end

 