-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2451

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
    indicator:name("MA Price Cross indicator");
    indicator:description("MA Price Cross indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("MA Parameters");
	indicator.parameters:addInteger("IN" , "Data Source", "", 4);
    indicator.parameters:addIntegerAlternative("IN" , "Open", "", 1);
    indicator.parameters:addIntegerAlternative("IN", "High", "", 2);
    indicator.parameters:addIntegerAlternative("IN" , "Low", "", 3);
	indicator.parameters:addIntegerAlternative("IN" , "Close", "", 4);
	indicator.parameters:addIntegerAlternative("IN", "Median", "", 5);
    indicator.parameters:addIntegerAlternative("IN" , "Typical", "", 6);
	indicator.parameters:addIntegerAlternative("IN" , "Weighted ", "", 7);		    			
	indicator.parameters:addString("M" , "Method for avegage", "", "EMA");
    indicator.parameters:addStringAlternative("M" , "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("M" , "LWMA", "", "LWMA");
				
    indicator.parameters:addInteger("Frame", "MA Frame", "", 50, 2, 1000);  

 
    indicator.parameters:addGroup("Cross Type"); 
    indicator.parameters:addString("Type" , "Method of Cross", "", "Cross");
    indicator.parameters:addStringAlternative("Type" , "Cross", "", "Cross");
    indicator.parameters:addStringAlternative("Type", "Touch", "", "Touch");
	
	
	indicator.parameters:addGroup("Price Type"); 
	
	indicator.parameters:addInteger("PIN" , "Data Source", "", 4);
    indicator.parameters:addIntegerAlternative("PIN" , "Open", "", 1);
    indicator.parameters:addIntegerAlternative("PIN", "High", "", 2);
    indicator.parameters:addIntegerAlternative("PIN" , "Low", "", 3);
	indicator.parameters:addIntegerAlternative("PIN" , "Close", "", 4);
	indicator.parameters:addIntegerAlternative("PIN", "Median", "", 5);
    indicator.parameters:addIntegerAlternative("PIN" , "Typical", "", 6);
	indicator.parameters:addIntegerAlternative("PIN" , "Weighted ", "", 7);	
 
	indicator.parameters:addGroup("Confirmation"); 
	indicator.parameters:addBoolean("CONF", "Use previous candle for confirmation" ,"" , true);
	indicator.parameters:addString("TF", "Timeframe for previous candle", "", "m30");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("CrossUP", "Up Cross Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("CrossDN", "Down Cross Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("TouchUp", "Up Touch Color", "", core.rgb(0, 128, 255));
	indicator.parameters:addColor("TouchDown", "Down Touch Color", "", core.rgb(128, 0, 255));
	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 15);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local TFDATA;
local TF;
local CONF;
local IN,PIN, Type, M, Frame;
local periodTF;

local first;
local source = nil;

-- Streams block
local PRICE, DATA, indicator = nil, NOTE1, NOTE2;

local Crossdown, Crossup, Touchup, Touchdown;
local Size;
-- Routine
function Prepare(nameOnly)

    IN = instance.parameters.IN;
    PIN = instance.parameters.PIN;
    Type = instance.parameters.Type;
    M = instance.parameters.M;
    Frame = instance.parameters.Frame;
	Size= instance.parameters.Size;
	TF = instance.parameters.TF;
	CONF = instance.parameters.CONF;
	
    source = instance.source;
   
	
	
     	if PIN == 1 then
		PRICE = source.open;	
        NOTE1="Open"  		
		elseif PIN==2 then
		PRICE = source.high;	
		NOTE1="High"
		elseif PIN==3 then
		PRICE = source.low;
        NOTE1="Low"		
		elseif PIN==4 then
		PRICE = source.close;	
		NOTE1="Close"
		elseif PIN==5 then
		PRICE = source.median;	
		NOTE1="Median"
		elseif PIN==6 then
		PRICE = source.typical;	
		NOTE1="Typical"
		elseif PIN==7 then
		PRICE = source.weighted;	
		NOTE1="Weighted"
		end
		
		
		
		if IN == 1 then
		DATA = source.open;	
        NOTE2="Open"		
		elseif IN==2 then
		DATA = source.high;	
		 NOTE2="High"	
		elseif IN==3 then
		DATA = source.low;	
		 NOTE2="Low"	
		elseif IN==4 then
		DATA = source.close;	
		 NOTE2="Close"	
		elseif IN==5 then
		DATA = source.median;	
		 NOTE2="Median"	
		elseif IN==6 then
		DATA = source.typical;	
		 NOTE2="Typical"	
		elseif IN==7 then
		DATA = source.weighted;	
		 NOTE2="Weighted"	
		end
	

    local name = profile:id() .. "(" .. source:name() ..", Price Type ".. NOTE1  .. ", MA Type " .. NOTE2.. ", ".. M..", ".. Frame..", ".. Type..")";
	instance:name(name);
	if nameOnly then
		return;
	end
			   
    assert(core.indicators:findIndicator(M) ~= nil, M .. " indicator must be installed");
	    indicator= core.indicators:create(M, DATA, Frame);		
	
	 first = indicator.DATA:first();
	
	TFDATA = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
	
	LINEUP_0 = instance:addInternalStream(source:first());
	LINEUP_1 = instance:addInternalStream(source:first());
	LINELO_0 = instance:addInternalStream(source:first());
	LINELO_1 = instance:addInternalStream(source:first());
	
	Touchup = instance:createTextOutput ("TU", "Touch UP", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.TouchUp, 0);
	Touchdown = instance:createTextOutput ("TD", "Touchup Down", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.TouchDown, 0);
    Crossdown = instance:createTextOutput ("CD", "Cross Down", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.CrossDN, 0);
    Crossup = instance:createTextOutput ("CU", "Cross Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.CrossUP, 0);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

   	indicator:update(mode);  
	  
	LINEUP_0[period] = TFDATA.high[FindPrevCandleTF(period,0)]
	LINEUP_1[period] = TFDATA.high[FindPrevCandleTF(period,-1)]
	LINELO_0[period] = TFDATA.low[FindPrevCandleTF(period,0)]  	
	LINELO_1[period] = TFDATA.low[FindPrevCandleTF(period,-1)]  	
	if indicator.DATA:hasData(period) and indicator.DATA:hasData(period-1) and period > 1 and LINEUP_0:hasData(period) and LINELO_0:hasData(period)then	
	    if Type == "Cross" then 
			if CONF then
				if  core.crossesOver(PRICE, indicator.DATA,   period)  and LINEUP_0[period] > LINEUP_1[period] then			
					Crossup:set(period, source.low[period], "\225");	
				elseif  core.crossesUnder(PRICE, indicator.DATA,   period)  and LINELO_0[period] < LINELO_1[period] then 				
					Crossdown:set(period, source.high[period], "\226");
				end
			else
				if  core.crossesOver(PRICE, indicator.DATA,   period) then			
					Crossup:set(period, source.low[period], "\225");	
				elseif  core.crossesUnder(PRICE, indicator.DATA,   period) then 				
					Crossdown:set(period, source.high[period], "\226");
				end
			end
		else
			if CONF and source.low[period] <  indicator.DATA[period]  and source.high[period] >  indicator.DATA[period] then 			
				if source.close[period]> indicator.DATA[period] and LINEUP_0[period] > LINEUP_1[period] then
					Touchup:set(period, source.low[period], "\108"); 	
				elseif source.close[period]< indicator.DATA[period] and	LINELO_0[period] < LINELO_1[period] then			
					Touchdown:set(period, source.high[period], "\108"); 
				end
			end
			if CONF == false and source.low[period] <  indicator.DATA[period]  and source.high[period] >  indicator.DATA[period] then 			
				if source.close[period]> indicator.DATA[period] then
					Touchup:set(period, source.low[period], "\108"); 	
				elseif source.close[period]< indicator.DATA[period] then			
					Touchdown:set(period, source.high[period], "\108"); 
				end
			end
		end							
	end		
end

function   FindPrevCandleTF(period, periodTF)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"));

  
    if loading or TFDATA:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(TFDATA, Candle, false)+periodTF;

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end

