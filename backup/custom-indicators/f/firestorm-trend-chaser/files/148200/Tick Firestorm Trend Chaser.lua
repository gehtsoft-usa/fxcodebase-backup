-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72910

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
    indicator:name("Tick Firestorm Trend Chaser");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("Show", "Show MAs", "Show", false);	
    indicator.parameters:addInteger("annual_avg", " Moving Avg Length", "", 100, 1, 2000);
    indicator.parameters:addInteger("month_step_down", "Step Down", "", 20, 1, 2000);
	
 	indicator.parameters:addGroup("Signal Calculation");	
	
    indicator.parameters:addInteger("Periods", "ATR Period", "", 10, 1, 2000);
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 3, 0, 2000);	
 
	
	
	indicator.parameters:addString("avg_type", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("avg_type", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("avg_type", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("avg_type", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("avg_type", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("avg_type", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("avg_type", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("avg_type", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("avg_type", "WMA", "WMA" , "WMA");
	
 
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0)); 
	 
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
    indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.rgb(0, 0, 255));
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" ,core.rgb(0, 0, 255));		 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local annual_avg, month_step_down, Periods, Multiplier; 
local Indicator={};
local Line={};
local Count=0;	
local Up,Down;
local Size;
local Show;
-- Routine
 function Prepare(nameOnly)   
 
    Show=instance.parameters.Show;
	annual_avg=instance.parameters.annual_avg;
	month_step_down=instance.parameters.month_step_down;
	avg_type=instance.parameters.avg_type;
	Periods=instance.parameters.Periods;
	Multiplier=instance.parameters.Multiplier;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Size=instance.parameters.Size;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  annual_avg.. "," ..  month_step_down  .. "," ..   avg_type .. "," ..   Periods .. "," ..   Multiplier.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Count=0;
		
	for i= 1, 12, 1 do
		if annual_avg-(i-1)*month_step_down  <=1 then
		break;
		end
	
	Count=Count+1;
	Indicator[i]= core.indicators:create(avg_type, source, annual_avg-(i-1)*month_step_down);
	end
	
    assert(core.indicators:findIndicator("TATR") ~= nil, "Please, download and install TATR.LUA indicator");
	ATR= core.indicators:create("TATR", source, Periods);
	
	first=math.max(source:first() +annual_avg, ATR.DATA:first()) ; 
	
	
	up = instance:addInternalStream(0, 0);
 	dn = instance:addInternalStream(0, 0);
	trend = instance:addInternalStream(0, 0);

	if Show then	
		for i = 1 , Count, 1 do	
		Line[i] = instance:addStream(i .. "Line", core.Line, name,i..". Line", instance.parameters.Up, first );
		Line[i]:setPrecision(math.max(2, instance.source:getPrecision()));
		Line[i]:setWidth(instance.parameters.width);
		Line[i]:setStyle(instance.parameters.style);
		end
	end
 
	up_arrow = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down_arrow = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
	 
end


function Update(period, mode)


	ATR:update(mode);
	
			 if period <= first then
			 trend[period]=1;	 
			 return;
			 end
			 
	
	if Show then
			for i = 1 , Count, 1 do
			Indicator[i]:update(mode);   
			end


			  
			for i = 1 , Count, 1 do	  	
				Line[i][period]= Indicator[i].DATA[period];
				
				if Line[i][period] > Line[1][period] then
				Line[i]:setColor(period,  Up);	
				else
				Line[i]:setColor(period,  Down);		
				end
			
	        end
	
	end
	
	
	
	up[period] = source[period] - Multiplier * ATR.DATA[period]; 
	if  source[period-1] > up[period-1] then
	up[period]=math.max(up[period], up[period-1])
	end
	
	dn[period] = source[period] + Multiplier * ATR.DATA[period]; 
	 
	if  source[period-1] < dn[period-1] then
	dn[period]=math.min(dn[period], dn[period-1])  
	end
	
 
	

	
	trend[period]= trend[period-1];
	
	if trend[period] == -1 and source[period] > dn[period-1]  then
	trend[period]=1;
	elseif trend[period] == 1 and source[period] < up[period-1]  then
	trend[period]=-1;
	end
	
    up_arrow:setNoData(period);
    down_arrow:setNoData(period);	
	
    if trend[period]==1 and trend[period-1]~=1 then
    up_arrow:set(period, up[period], "\217" , up[period]  );		
    end

    if trend[period]==-1 and trend[period-1]~=-1 then
    down_arrow:set(period, dn[period], "\218" , dn[period]);	
    end   
	 
	
end


 --[[
 atr2 = ta.sma(ta.tr, Periods)
atr = changeATR ? ta.atr(Periods) : atr2
up = src - Multiplier * atr
up1 = nz(up[1], up)
up := close[1] > up1 ? math.max(up, up1) : up
dn = src + Multiplier * atr
dn1 = nz(dn[1], dn)
dn := close[1] < dn1 ? math.min(dn, dn1) : dn
trend = 1
trend := nz(trend[1], trend)
trend := trend == -1 and close > dn1 ? 1 : trend == 1 and close < up1 ? -1 : trend
upPlot = plot(trend == 1 ? up : na, title='Up Trend', style=plot.style_linebr, linewidth=2, color=color.new(color.green, 0))
buySignal = trend == 1 and trend[1] == -1
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
