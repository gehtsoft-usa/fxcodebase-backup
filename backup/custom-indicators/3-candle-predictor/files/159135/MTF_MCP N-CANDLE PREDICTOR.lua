-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75859

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 

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
	
 
    indicator.parameters:addInteger("Period"..id, "MVA period", "", 10);
 

end


function Init()
    indicator:name("MTF_MCP N-CANDLE PREDICTOR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addBoolean("Chart" , "Use Chart Price Source", "", true); 
	
    AddParam(1, "m1", false);	
    AddParam(2, "m5", false);	
    AddParam(3, "m15", true);	
    AddParam(4, "m30", false);
    AddParam(5, "H1", true);
	AddParam(6, "H2", false);	
    AddParam(7, "H3", false);	
    AddParam(8, "H4", false);	
    AddParam(9, "H6", false);
    AddParam(10, "H8", false);
	AddParam(11, "D1", true);	
    AddParam(12, "W1", false);
    AddParam(13, "M1", false);
	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color for Up Trend", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN", "Color for Down Trend", "", core.rgb(255, 0, 0));	
	indicator.parameters:addColor("NO", "Color for Unclear Trend", "", core.rgb(255, 128, 0));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addDouble("Size", "As % of Cell", "", 90);
	indicator.parameters:addDouble("HSize", "Horizontal indicator size as % of screen", "", 50, 50, 100);
	
	indicator.parameters:addInteger("VShift", "Vertical Shift", "", 0);
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
	local SourceData={};
	local loading={};  
	local Size;
	local HSize;
	local VShift;
	local USE={};
	local Count=13;
    local Number;
	local Chart ;
	local Label;
 
	
local Indicator={};
local Period={};

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
    	
	Chart=instance.parameters.Chart;
    source = instance.source;
    UP=instance.parameters.UP;
	DN=instance.parameters.DN;
	NO=instance.parameters.NO;
	
	Label=instance.parameters.Label;
    Shift=instance.parameters.Shift;
    Size=instance.parameters.Size;
	HSize=instance.parameters.HSize;
	VShift=instance.parameters.VShift;
	


	
    assert(core.indicators:findIndicator("N-CANDLE PREDICTOR OSCILLATOR") ~= nil, "Please, download and install N-CANDLE PREDICTOR OSCILLATOR.LUA indicator");
	
    local i;
    
	
	Number=0;
	
    for i = 1, Count, 1 do
	
	  
	
	    USE[i]=instance.parameters:getBoolean("USE" .. i);
		
		
	   
	     if USE[i]  then
		 Number=Number+1;
		 
		  
		             Period[Number]=instance.parameters:getInteger ("Period"..i); 
		 		    
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
	
	    	local Test = core.indicators:create("MVA", source.close ,Period[i]);   
	        first= Test.DATA:first()*2 ; 		  
	  	
	  
	    SourceData[i] = core.host:execute("getSyncHistory", Pair[i], TF[i], source:isBid(),  math.min(300,first) , 200+i, 100+i);	   
		Indicator[i] = core.indicators:create("N-CANDLE PREDICTOR OSCILLATOR", SourceData[i] , Period[i]);
		loading[i]= true;		
		
		 
    end
    
	instance:ownerDrawn(true);
	core.host:execute ("setTimer", 1, 1);

end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
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
	
	
	
     	if Flag then
		return;
		end
		
		
		for i = 1, Number, 1 do 	
		Add(context, i );
		end
		       		 
 
		
end

function Add(context, i )

        if not  Indicator[i].DATA:hasData(Indicator[i].DATA:size()-1)
        or  not Indicator[i].DATA:hasData(Indicator[i].DATA:size()-2)
		then
		return;
		end
		
		
		local Symbol="Neutral";
      
	    local xCell =( (context:right () -context:left ())/100 )* (HSize/Number);		
        local yCell = (context:bottom () -context:top ())/15;	

		 context:createFont (1, "Arial", (xCell/10)*(Size/100), yCell*(Size/100), 0);	
       -- context:createFont (1, "Wingdings", (xCell/10)*(Size/100)*2, yCell*(Size/100), 0);	
	  
		

			local Color;
						 
			if Indicator[i].upCount[Indicator[i].upCount:size()-1]  > Indicator[i].downCount[Indicator[i].downCount:size()-1]		 
			then
			Color=UP;
			Symbol="Up";
			elseif Indicator[i].upCount[Indicator[i].upCount:size()-1]  <  Indicator[i].downCount[Indicator[i].downCount:size()-1]		 
			then
			Color=DN;
			Symbol="Down";
			else
			Symbol="Neutral";
			Color=NO;
			end		
					    
			        		
			
           
			 width, height = context:measureText (1,  Symbol , 0)			
			 context:drawText (1,   Symbol , Color, -1, context:right ()-(i)*xCell    , context:top ()+VShift+yCell*2, context:right ()-(i-1)*xCell + width, context:top ()+VShift+yCell*2 + height, 0);
			 
			 
		
			  width, height = context:measureText (1, tostring(TF[i]), 0)				
		    context:drawText (1, tostring(TF[i]), Label, -1, context:right ()-(i)*xCell    , context:top ()+VShift+yCell, context:right ()-(i-1)*xCell + width, context:top ()+VShift+yCell + height, 0);
			
			
		 
			
			
			if not Chart then						
             width, height = context:measureText (1, Pair[i], 0)			
			 context:drawText (1,  Pair[i], Label, -1, context:right ()-(i)*xCell    , context:top ()+VShift+yCell*4, context:right ()-(i-1)*xCell + width, context:top ()+VShift+yCell*4 + height, 0);			 
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
	
		if not Flag and cookie == 1 then	
		 
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

-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75859

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 