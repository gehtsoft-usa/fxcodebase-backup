-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72594

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
    indicator:name("CM_Laguerre PPO PctRank Tops-Bottoms");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("Short", "Short", "", 0.4, 0, 2000);
    indicator.parameters:addDouble("Long", "Long", "", 0.8, 0, 2000);

    indicator.parameters:addInteger("lkb", "Look back period", "", 200, 1, 2000);
    indicator.parameters:addInteger("pctile", "Extreme threshold lines", "", 90, 1, 2000);
    indicator.parameters:addInteger("midpctile", "Warning threshold lines", "", 70, 1, 2000);	 
	
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 90);
	indicator.parameters:addDouble("Level2", "2. Level","", 70);  
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
local Short, Long,lkb,pctile,midpctile; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Short=instance.parameters.Short;
	Long=instance.parameters.Long;
	lkb=instance.parameters.lkb; 
	pctile=instance.parameters.pctile;
	midpctile=instance.parameters.midpctile;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Short.. "," ..  Long .. "," ..   lkb .. "," ..   pctile .. "," ..  midpctile .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first()+lkb ; 
	
 
 
	Ls0 = instance:addInternalStream(0, 0);
	Ls1 = instance:addInternalStream(0, 0);
	Ls2 = instance:addInternalStream(0, 0);
	Ls3 = instance:addInternalStream(0, 0); 

	 
	Ll0 = instance:addInternalStream(0, 0);
	Ll1 = instance:addInternalStream(0, 0);
	Ll2 = instance:addInternalStream(0, 0);
	Ll3 = instance:addInternalStream(0, 0);
	
	ppoT = instance:addInternalStream(0, 0);
	ppoB = instance:addInternalStream(0, 0);
	
    pctRankT = instance:addStream("Top", core.Bar, name, "Top", core.COLOR_LABEL , first );
    pctRankT:setPrecision(math.max(2, instance.source:getPrecision())); 
    pctRankT:addLevel(0);	
	pctRankT:addLevel(instance.parameters.Level1/100, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	pctRankT:addLevel(instance.parameters.Level2/100, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
 
    pctRankB = instance:addStream("Bottom", core.Bar, name, "Bottom", core.COLOR_LABEL, first );
    pctRankB:setPrecision(math.max(2, instance.source:getPrecision())); 
    pctRankB:addLevel(0);
	pctRankB:addLevel(-instance.parameters.Level1/100, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	pctRankB:addLevel(-instance.parameters.Level2/100, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
end


function Update(period, mode)

	  --Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	 
 
	Ls0[period] = (1 - Short)*source[period]+Short*(Ls0[period-1])
	Ls1[period] = -Short*Ls0[period]+(Ls0[period-1])+Short*(Ls1[period-1])
	Ls2[period] = -Short*Ls1[period]+(Ls1[period-1])+Short*(Ls2[period-1])
	Ls3[period] = -Short*Ls2[period]+(Ls2[period-1])+Short*(Ls3[period-1])
	lmas = (Ls0[period] + 2*Ls1[period] + 2*Ls2[period] + Ls3[period])/6

	 
	Ll0[period] = (1 - Long)*source[period]+Long*(Ll0[period-1])
	Ll1[period] = -Long*Ll0[period]+(Ll0[period-1])+Long*(Ll1[period-1])
	Ll2[period] = -Long*Ll1[period]+(Ll1[period-1])+Long*(Ll2[period-1])
	Ll3[period] = -Long*Ll2[period]+(Ll2[period-1])+Long*(Ll3[period-1])
	lmal = (Ll0[period] + 2*Ll1[period] + 2*Ll2[period] + Ll3[period])/6
	
	
	pctileB = pctile * -1
	midpctileB = midpctile * -1
  
	ppoT[period] = (lmas-lmal)/lmal*100
	ppoB[period] = (lmal-lmas)/lmal*100	
	
	
	topvalueMinus = 0
	topvaluePlus = 0
	bottomvalueMinus = 0
	bottomvaluePlus = 0

	for i = 0 ,lkb, 1  do
			if ppoT[period-i]<ppoT[period] then
			topvalueMinus = topvalueMinus+1
			else
			topvaluePlus = topvaluePlus+1
			end
			if ppoB[period-i]<ppoB[period] then
			bottomvalueMinus = bottomvalueMinus+1
			else
			bottomvaluePlus = bottomvaluePlus+1
			end
	end
	
	
	pctRankT[period] = topvalueMinus / (topvalueMinus+topvaluePlus)
	pctRankB[period] = (bottomvalueMinus / (bottomvalueMinus+bottomvaluePlus)) *-1	
	
 
	if pctRankT[period]>=pctile/100 then
	TopColor = 1
	else
	TopColor = -1
	end 

	 
	if pctRankT[period]>=midpctile/100 and pctRankT[period] < pctile/100 then
	TopColor = 2
	end 
	
	
	if TopColor==1 then
	r=255
	g=0
	b=0
	elseif TopColor<0 then
	r=128
	g=128
	b=128
	end

	if TopColor==2 then
	r=255
	g=140
	b=0
	elseif TopColor<0 then
	r=128
	g=128
	b=128
	end	
	
	
	
 
if pctRankB[period] <= pctileB/100 then
BottomColor = 1
else
BottomColor = -1
end 

 
if pctRankB[period] <= midpctileB/100 and pctRankB[period] > pctileB/100 then
BottomColor = 3
end 

	if BottomColor == 1 then
	rr=255
	gg=0
	bb=255
	elseif BottomColor < 0 then
	rr=211
	gg=211
	bb=211
	end 

	if BottomColor==3 then
	rr=0
	gg=128
	bb=0
	elseif BottomColor>0 then
	rr=0
	gg=255
	bb=0
	end  
	
	pctRankT:setColor(period,  core.rgb(r, g, b));	
	pctRankB:setColor(period,  core.rgb(rr, gg, bb));		
	 
end 