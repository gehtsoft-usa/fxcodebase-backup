-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12521


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams


function AddParam(id, frame , Flag)

    indicator.parameters:addGroup(id.. ". Time Frame");
	 
	
	indicator.parameters:addBoolean("USE".. id, "Use this Slot", "", Flag);	
	
    indicator.parameters:addString("TF" .. id,  "Time frame", "", frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Pair" .. id, "Pair", "", "EUR/USD");
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	
	indicator.parameters:addInteger("MA_N"..id, "Moving Average Period", "", 1);
    indicator.parameters:addString("MA_M"..id, "Moving Average Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    indicator.parameters:addStringAlternative("MA_M"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_M"..id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_M"..id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_M"..id, "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_M"..id, "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA_M"..id, "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA_M"..id, "Wilders*", "", "WMA");
    indicator.parameters:addInteger("ATR_N"..id, "ATR period", "", 10);
    indicator.parameters:addDouble("VF"..id, "Volatility's Factor or Multiplier", "", 4);
    indicator.parameters:addInteger("OF"..id, "Offset factor", "", 0);
    indicator.parameters:addString("P"..id, "Price", "The price to the indicator apply to", "C");
    indicator.parameters:addStringAlternative("P"..id, "Open", "", "O");
    indicator.parameters:addStringAlternative("P"..id, "High", "", "H");
    indicator.parameters:addStringAlternative("P"..id, "Low", "", "L");
    indicator.parameters:addStringAlternative("P"..id, "Close", "", "C");
    indicator.parameters:addStringAlternative("P"..id, "Median", "", "M");
    indicator.parameters:addStringAlternative("P"..id, "Typical", "", "T");
    indicator.parameters:addStringAlternative("P"..id, "Weighted", "", "W");
    indicator.parameters:addBoolean("HiLoE"..id, "Use High/Low envelope", "", false);
    indicator.parameters:addBoolean("HiLoB"..id, "Hi/Lo Break", "", true);

end


function Init()
    indicator:name("MTF_MCP_Volty Channel Stop");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addBoolean("Chart" , "Use Chart Price Source", "", true); 
	
    AddParam(1, "m1", false);	
    AddParam(2, "m5", false);	
    AddParam(3, "m15", false);	
    AddParam(4, "m30", false);
    AddParam(5, "H1", true);
	AddParam(6, "H2", false);	
    AddParam(7, "H3", false);	
    AddParam(8, "H4", false);	
    AddParam(9, "H6", false);
    AddParam(10, "H8", true);
	AddParam(11, "D1", true);	
    AddParam(12, "W1", true);
    AddParam(13, "M1", true);
	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color for Up Trend", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN", "Color for Down Trend", "", core.rgb(255, 0, 0));	
	indicator.parameters:addColor("NO", "Color for Unclear Trend", "", core.rgb(255, 128, 0));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addDouble("Size", "As % of Cell", "", 90);
	indicator.parameters:addDouble("HSize", "Horizontal indicator size as % of screen", "", 50, 50, 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
    local UP, DN, NO;
	local source = nil;
	local TF={};
	local Pair={};
	local L={};	
	local host;
	local offset;
	local weekoffset;
	local SourceData={};
	local loading={};  
	local Size;
	local HSize;
	local USE={};
	local Count=13;
    local Number;
	local Chart ;
	local Label;
 
	
local Indicator={};
local MA_N={};
local MA_M={};
local ATR_N={};
local VF={};
local OF={};
local P={};
local HiLoE={};
local HiLoB={};

-- Routine
function Prepare(nameOnly)
    	
	Chart=instance.parameters.Chart;
    source = instance.source;
    UP=instance.parameters.UP;
	DN=instance.parameters.DN;
	NO=instance.parameters.NO;
	
	Label=instance.parameters.Label;
    Shift=instance.parameters.Shift;
    Size=instance.parameters.Size;
	HSize=instance.parameters.HSize;
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	
	local name = profile:id() .. "(" .. source:name() ;
	
	 name = name .. ")";
	 instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    assert(core.indicators:findIndicator("VOLTY CHANNEL STOP INDICATOR") ~= nil, "Please, download and install VOLTY CHANNEL STOP INDICATOR.LUA indicator");
	
    local i;
    
	
	Number=0;
	
    for i = 1, Count, 1 do
	
	  
	
	    USE[i]=instance.parameters:getBoolean("USE" .. i);
		
		
	   
	     if USE[i]  then
		 Number=Number+1;
		 
		  
		             MA_N[Number]=instance.parameters:getInteger ("MA_N"..i);
					 MA_M[Number]=instance.parameters:getString ("MA_M"..i);	 
					 ATR_N[Number]=instance.parameters:getInteger ("ATR_N"..i);
					 VF[Number]=instance.parameters:getDouble ("VF"..i);
					 
					 OF[Number]=instance.parameters:getInteger ("OF"..i);
					 P[Number]=instance.parameters:getString ("P"..i);
					 
					 HiLoE[Number]=instance.parameters:getBoolean ("HiLoE"..i);
					 HiLoB[Number]=instance.parameters:getBoolean ("HiLoB"..i);		 
		 		    
		    if  Chart   then		
		    Pair[Number]=source:name();	  
            else
            Pair[Number]= instance.parameters:getString("Pair" .. i);
		    end
	     
		
			
			  TF[Number]= instance.parameters:getString("TF" .. i);	
			  
		
			 
		   
		   L[Number] = TF[Number] .. ", ".. Pair[Number];
		 
		 
		 end   
		   
	  
    end
   
   
   	 
    for i = 1, Number, 1 do	 
	
	    	local Test = core.indicators:create("VOLTY CHANNEL STOP INDICATOR", source , MA_N[i], MA_M[i], ATR_N[i], VF[i],  OF[i], P[i], HiLoE[i], HiLoB[i]);   
	        first= Test.DATA:first()*2 ; 		  
	  	
	  
	    SourceData[i] = core.host:execute("getSyncHistory", Pair[i], TF[i], source:isBid(),  math.min(300,first) , 200+i, 100+i);	   
		Indicator[i] = core.indicators:create("VOLTY CHANNEL STOP INDICATOR", SourceData[i], MA_N[i], MA_M[i], ATR_N[i], VF[i],  OF[i], P[i], HiLoE[i], HiLoB[i], UP, DN);
		loading[i]= true;		
		
		 
    end
    core.host:execute ("setTimer", 1, 1);
	instance:ownerDrawn(true);

end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 


function   Initialization(id,period)

    local Candle;
    Candle = core.getcandle(TF[id], source:date(period), offset, weekoffset);

  
    if loading[id] or SourceData[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
	    
end

 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	local Flag = false;	

	
	
	
    for j = 1, Number, 1 do			
		if loading[j] then	
		Flag=true;
		
		end	 
 
	end    
	
	local Symbol="\149";
	
     	if Flag then
		return;
		end
      
	    local xCell =( (context:right () -context:left ())/100 )* (HSize/Number);		
        local yCell = (context:bottom () -context:top ())/15;		    
		
		for i = 1, Number, 1 do 

            if Indicator[i].DATA:hasData(Indicator[i].DATA:size()-1) then		
			local Color;
						 
			if Indicator[i].DATA:colorI(Indicator[i].DATA:size()-1) == UP 
			and Indicator[i].DATA:hasData(Indicator[i].DATA:size()-1) 
			then
			Color=UP;
			Symbol="\217";
			elseif Indicator[i].DATA:colorI(Indicator[i].DATA:size()-1) == DN 
			and Indicator[i].DATA:hasData(Indicator[i].DATA:size()-1) 
			then
			Color=DN;
			Symbol="\218";
			else
			Symbol="\149";
			Color=NO;
			end		
					    
			        		
			context:createFont (11, "Wingdings", (xCell/10)*(Size/100)*2, yCell*(Size/100), 0);	
           
			 width, height = context:measureText (11, tostring(Symbol), 0)			
			 context:drawText (11,  tostring(Symbol), Color, -1, context:right ()-(i)*xCell    , context:top ()+yCell*2, context:right ()-(i-1)*xCell + width, context:top ()+yCell*2 + height, 0);
			 
			 
			 context:createFont (2, "Arial", (xCell/10)*(Size/100), yCell*(Size/100), 0);	
			  width, height = context:measureText (2, tostring(TF[i]), 0)				
		    context:drawText (2, tostring(TF[i]), Label, -1, context:right ()-(i)*xCell    , context:top ()+yCell, context:right ()-(i-1)*xCell + width, context:top ()+yCell + height, 0);
			
			
			 local Value= string.format("%." .. 2 .. "f", Indicator[i].DATA[Indicator[i].DATA:size()-1] );
			
             width, height = context:measureText (2, Value, 0)			
			 context:drawText (2,  Value, Label, -1, context:right ()-(i)*xCell    , context:top ()+yCell*3, context:right ()-(i-1)*xCell + width, context:top ()+yCell*3 + height, 0);
			
		 end
	 
         	end	 
 
		
end

-- the function is called when the async operation is finished

function AsyncOperationFinished(cookie)

     local j;	 
	local Flag = false;	
	local Count=0;	
	local ID=0;
	
	
    for j = 1, Number, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;  			 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;		
		end	 
 
	end    
	
	
	if not Flag and cookie== 1 then
	
	  for j = 1, Number, 1 do			
	 
		Indicator[j]:update(core.UpdateLast);
		 
 
	  end    
	
	end
	
     	if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded ".. (Number-Count) .."/" .. Number);
		instance:updateFrom(0);		 
		end
   
        
		return core.ASYNC_REDRAW ;
   
end

