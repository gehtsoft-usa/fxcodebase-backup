-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72711

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
    indicator:name("My script");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
 
  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period1", "Fast MA", "", 5, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow MA", "", 35, 1, 2000);
	
    indicator.parameters:addDouble("CandleSpread", "CandleSpread", "", 40);
    indicator.parameters:addDouble("candleMovement", "candleMovement", "", 0.00003);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
	 
	indicator.parameters:addGroup("Line Style");	
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
local Period1, Period2; 
local CandleSpread, candleMovement;
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	CandleSpread=instance.parameters.CandleSpread;
	candleMovement	=instance.parameters.candleMovement;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..  CandleSpread.. "," ..  candleMovement .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator1= core.indicators:create("EMA", source.close, Period1 );
	Indicator2= core.indicators:create("EMA", source.close, Period2);	
	first=math.max(Indicator1.DATA:first(),Indicator2.DATA:first()) ; 
	
	
	BUY = instance:addInternalStream(0, 0);
	SELL = instance:addInternalStream(0, 0); 
 	
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
 
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);	
	
	win = instance:createTextOutput ("Win", "Win", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    lose = instance:createTextOutput ("Lose", "Lose", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);		
end


function Update(period, mode)

	  Indicator1:update(mode); 
	  Indicator2:update(mode);
	 if period <= first then
	 return;
	 end
	 
	local candle0color = false
	local candle1color = false
	local candle2color = false
	local TRADABLE=true; 
	
	Line1[period]= Indicator1.DATA[period];
	Line2[period]= Indicator2.DATA[period];	
	
	
	
	
	if BUY[period-1] == 1 or SELL[period-1] == 1 then
	TRADABLE=false;
	end
	if BUY[period-2] == 1 or SELL[period-2] == 1 then
	TRADABLE=false;
	end
	

		if TRADABLE then
			candle2open = source.open[period-2]
			candle2close = source.close[period-2]
			candle2top = source.high[period-2]
			candle2bottom = source.low[period-2]
			candle2maxmovement = candle2top - candle2bottom
			candle2quality = 0.0
			candle2body=0.0
			candle2tail=0.0
			if (candle2open ~= candle2close) then
				if (candle2open < candle2close) then
				candle2color= true
				else 
				TRADABLE= false
				end
		   end	
		end
		
		if (TRADABLE) then
			if (candle2color ) then
			candle2body = candle2close - candle2open
			else
			candle2body = candle2open - candle2close
			candle2tail = (candle2top - candle2bottom) - candle2body
			candle2quality = candle2body / (candle2maxmovement/100)
				if candle2quality < CandleSpread or candle2body < candleMovement then
				TRADABLE= false
				end
			end		
		end
		
		if TRADABLE then
		candle1open = source.open[period-1]
		candle1close = source.close[period-1]
		candle1top = source.high[period-1]
		candle1bottom = source.low[period-1]
		candle1maxmovement = candle1top - candle1bottom
		candle1quality = 1.1
		candle1body=1.1
		candle1tail=1.1
			if (candle1open ~= candle1close) then
				    if (candle1open < candle1close) then
					candle1color  = true
					else
					TRADABLE= true
					end
				
			end
		end




	if (TRADABLE) then
		if (candle1color) then
		candle1body  = candle1close - candle1open
		else
		candle1body  = candle1open - candle1close
		candle1tail  = (candle1top - candle1bottom) - candle1body
		candle1quality  = candle1body / (candle1maxmovement/111)
	 
			if candle1quality < CandleSpread or candle1body < candleMovement then
			TRADABLE = false
			end
	   end
	    
	end

		if candle2color ~= candle1color then
		TRADABLE = false     	
		end	

	
	


		if TRADABLE then
		candle0open =source.open[period]
		candle0close = source.close[period]
		candle0top = source.high[period]
		candle0bottom = source.low[period]
		candle0maxmovement = candle0top - candle0bottom
		candle0quality = 0.0
		candle0body=0.0
		candle0tail=0.0
			if (candle0open ~= candle0close) then
				if (candle0open < candle0close) then
				candle0color  = true
				else
				TRADABLE = false;
				end
			end
		end	
		
		
	if (TRADABLE) then
		if (candle0color) then
		candle0body  = candle0close - candle0open
		else
		candle0body = candle0open - candle0close
		candle0tail = (candle0top - candle0bottom) - candle0body
		candle0quality = candle0body / (candle0maxmovement/100)
		 
		if candle0quality < CandleSpread or candle0body < candleMovement then
		TRADABLE = false
		end
		end
	end

		

	if TRADABLE then
		if candle0color ~= candle1color then
		TRADABLE= false
		else
			if candle1color then
			BUY[period] =1
			else
			SELL[period]=1
			end
		end
	end	 
	
	
    up:setNoData(period);
    down:setNoData(period);
   
    if BUY[period]==1 then
    up:set(period, source.low[period], "\217", source.low[period]);
    end	
    if SELL[period]==1 then	
    down:set(period, source.high[period], "\218", source.high[period]);	
	end
	
	local WIN=false;
	local LOSE=false;
	
    if BUY[period-2] == 1 or SELL[period-2] == 1 then
	 if(BUY[period-2]==1 and source.close[period-2]<source.close[period]) or (SELL[period-2]==1 and source.close[period-2]>source.close[period]) then
	 WIN=true;	 
	 end
	 if (BUY[period-2]==1 and source.close[period-2]>=source.close[period]) or (SELL[period-2]==1 and source.close[period-2]<=source.close[period]) then
	 LOSE=true;
	 end
	 
    win:setNoData(period);
    lose:setNoData(period);	 
	 
	if LOSE then 
    lose:set(period, source.high[period], "\108", source.high[period]);	
	end
	if WIN then 
    win:set(period, source.low[period], "\108", source.low[period]);
	end
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
 
