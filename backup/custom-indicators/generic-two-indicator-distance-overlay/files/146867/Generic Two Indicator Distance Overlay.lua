-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72554

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

function Init()
    indicator:name("Generic Two Indicator Distance Overlay")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator) 
	
     indicator.parameters:addGroup("Calculation")
     indicator.parameters:addBoolean("ShowSource", "Show Source Lines", "Show Source Lines", false); 
     indicator.parameters:addBoolean("ShowDelta", "Show Delta Source Lines", "Show Delta Source Lines", false); 	 
     indicator.parameters:addBoolean("ChangeCandleColor", "Change Candle Color", "Change Candle Color", true); 	 
     indicator.parameters:addBoolean("Inverse", "Inverse", "Inverse", true);
	 
	indicator.parameters:addInteger("Level", "Candle Color Level", "", 0);
	indicator.parameters:addDouble("Threshold", "Threshold (in Pips)", "", 0);	
	 
  
    indicator.parameters:addGroup("1. Indicator Calculation")
	
    indicator.parameters:addString("Price1", "Indicator Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addInteger("Index1", "Stream Index", "", 1, 1, 100);
	
	indicator.parameters:addString("INDICATOR1", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR1",core.FLAG_INDICATOR);
	
	indicator.parameters:addGroup("2. Indicator Calculation")

    indicator.parameters:addString("Price2", "Indicator Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addInteger("Index2", "Stream Index", "", 1, 1, 100);
	
	indicator.parameters:addString("INDICATOR2", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR2",core.FLAG_INDICATOR);

 
	


    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("color1", "1. Line Line Color", "Line Color", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "2. Line Line Color", "Line Color", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color3", "Delta Bar Color", "Bar Color", core.rgb(0, 0,255))
	
	
    indicator.parameters:addGroup("Candle Style")
    indicator.parameters:addColor("Up", "Up Color", "Candle Color", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Down", "Down Color", "Candle Color", core.rgb(255, 0, 0))
    indicator.parameters:addColor("Neutral", "Neutral Color", "Candle Color", core.rgb(0, 0, 255))
end

local Inverse, First, Second;
local Index1, Index2; 
local Delta, Line1, Line2, first, source; 

local Indicator1, Indicator2;
function Prepare(nameOnly)
     
    source = instance.source
	Price1=instance.parameters.Price1;
	Price2=instance.parameters.Price2;
   
	
	Index1=instance.parameters.Index1-1;
	Index2=instance.parameters.Index2-1;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	Level=instance.parameters.Level;
	Threshold=instance.parameters.Threshold*source:pipSize();

    local name =
    profile:id() ..  "(" .. source:name()  .. ")"
    instance:name(name)

    if nameOnly then
        return
    end
	
	local iprofile1 = core.indicators:findIndicator(instance.parameters:getString("INDICATOR1"));
	local iparams1 = instance.parameters:getCustomParameters("INDICATOR1");
	
	
	local iprofile2 = core.indicators:findIndicator(instance.parameters:getString("INDICATOR2"));
	local iparams2 = instance.parameters:getCustomParameters("INDICATOR2");
	
	if  iprofile1:requiredSource() == core.Tick then			
			Indicator1 = iprofile1:createInstance( source[Price1], iparams1);
	else
			Indicator1 = iprofile1:createInstance(source, iparams1);
	end
		
    
	if  iprofile2:requiredSource() == core.Tick then			
			Indicator2 = iprofile1:createInstance( source[Price2], iparams2);
	else
			Indicator2 = iprofile1:createInstance(source, iparams2);
	end
	
	if (Indicator1:getStreamCount ()-1) <  Index1  then
	assert(false, "1. Indicator only has" .. (Indicator1:getStreamCount ()-1) .. "streams.");
	end
	
	if (Indicator2:getStreamCount ()-1) <  Index2  then
	assert(false, "1. Indicator only has" .. (Indicator2:getStreamCount ()-1) .. "streams.");
	end
	
	First= Indicator1:getStream(Index1);
	Second= Indicator2:getStream(Index2);
	
	first = math.max(Indicator1:getStream(Index1):first(), Indicator2:getStream(Index2):first());
  
   
   
    if instance.parameters.ShowDelta then
    Delta = instance:addStream("Delta" , core.Bar, " Delta"," Delta",instance.parameters.color3, first );
	else
	Delta = instance:addInternalStream(0, 0);
	end
	
	
	if instance.parameters.ShowSource then
	Line1 = instance:addStream("Line1" , core.Line, "1. Line","1. Line",instance.parameters.color1, first  );
	Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);
    Line1:setPrecision(math.max(2, source:getPrecision()));    
	
	Line2 = instance:addStream("Line2" , core.Line, "2. Line","2. Line",instance.parameters.color2, first  );
	Line2:setWidth(instance.parameters.width2);
    Line2:setStyle(instance.parameters.style2);
    Line2:setPrecision(math.max(2, source:getPrecision())); 
    else
	Line1 = instance:addInternalStream(0, 0);
	Line2 = instance:addInternalStream(0, 0)
    end	
	

	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	if instance.parameters.ChangeCandleColor then
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);	
	else
	open= instance:addInternalStream(0, 0)
    high= instance:addInternalStream(0, 0)
    low= instance:addInternalStream(0, 0)
    close= instance:addInternalStream(0, 0) 
	end
end


function Update(period, mode)

    Indicator1:update(mode);
	Indicator2:update(mode);
	
	
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];
	
	
    if period <= first 
	or not source:hasData(period)
	then
        return
    end
	
	
	
	Line1[period]=First[period];
	Line2[period]=Second[period];
	
	
	if Inverse then
	Delta[period]=First[period]-Second[period];
	else
	Delta[period]=Second[period]-First[period];
	end
	

	if   math.abs(Delta[period]) < Threshold then
	open:setColor(period, Neutral);	
	elseif Delta[period] > Level then
	open:setColor(period, Up);
	else
	open:setColor(period, Down);
	end
 end