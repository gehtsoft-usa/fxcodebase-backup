-- Id: 2018
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2451

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

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

local IN,PIN, Type, M, Frame;

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
	 
	Touchup = instance:createTextOutput ("TU", "Touch UP", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.TouchUp, 0);
	Touchdown = instance:createTextOutput ("TD", "Touchup Down", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.TouchDown, 0);
    Crossdown = instance:createTextOutput ("CD", "Cross Down", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.CrossDN, 0);
    Crossup = instance:createTextOutput ("CU", "Cross Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.CrossUP, 0);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

   	 indicator:update(mode);  
	  
	  
	if indicator.DATA:hasData(period) and indicator.DATA:hasData(period-1) and period > 1 then	
	
	    if Type == "Cross" then 		
		        if  core.crossesOver(PRICE, indicator.DATA,   period)  then
				Crossup:set(period, source.low[period], "\225");	
                elseif  core.crossesUnder(PRICE, indicator.DATA,   period)  then 				
				Crossdown:set(period, source.high[period], "\226");
		        end  
		else
				if source.low[period] <  indicator.DATA[period]  and source.high[period] >  indicator.DATA[period]then 
				
						if source.close[period]> indicator.DATA[period] then
						Touchup:set(period, source.low[period], "\108"); 	
						else				
						Touchdown:set(period, source.high[period], "\108"); 
						end
				end
		end	
							
	end		
end

