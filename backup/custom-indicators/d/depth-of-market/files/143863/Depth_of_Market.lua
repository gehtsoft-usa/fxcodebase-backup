-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71550

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Depth of Market");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("BoxSize", "Size of price box in pips", "", 5);
 
	indicator.parameters:addString("Type", "Indicator Type", "", "Consolidated");
    indicator.parameters:addStringAlternative("Type", "Consolidated", "", "Consolidated");
    indicator.parameters:addStringAlternative("Type", "Aligned", "", "Aligned");
    indicator.parameters:addStringAlternative("Type", "Numerical", "", "Numerical");	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("NumberOfPoints", "Number of points", "Number of points to display histogram", 200); 
	indicator.parameters:addDouble("transparency", "Transparency", "Transparency", 50); 
	indicator.parameters:addColor("Long", "Long Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Short", "Short Color", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Type;
local BoxSize;
local NumberOfPoints;
local  uTPO = {};
local  dTPO = {};
local source = nil; 
local first;
local Transparency;
local  Long,Short;

local TF;
local bid;                 -- the additional data stream
local loading;               -- flag indicating the other data stream is being loaded
local offset, weekoffset;    -- params for candle calculation
local load_from; 


local umax = 0;
local dmax = 0;
-- Routine
 function Prepare(nameOnly)   

    source = instance.source;
    first = source:first();
	Type= instance.parameters.Type;
	
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	TF = source:barSize();

    offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");

	
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(), offset, weekoffset);
    s2, e2 = core.getcandle(TF, offset, weekoffset);
    assert((e2 - s2) >=(e1 - s1), "The chosen time frame must be longer than the source time frame");
	   

    BoxSize = instance.parameters.BoxSize;
	Long = instance.parameters.Long;
	Short = instance.parameters.Short;
 
  

    source = instance.source;
    
	
   instance:setLabelColor(Long);
   instance:ownerDrawn(true);
   
            uTPO = {};
			dTPO = {};
            umax = 0;
			dmax=0;
   
end


local init = false; 
 
function Draw (stage, context)

    if stage  ~= 2 then
	return;
	end		
	
	 
	NumberOfPoints = instance.parameters.NumberOfPoints; 
	
	if not init then
	init=true;
	context:createPen (1, 1, 1, Long);
	context:createSolidBrush (2, Long);
	
	context:createPen (3, 1, 1, Short);
	context:createSolidBrush (4, Short);
	Transparency= context:convertTransparency (instance.parameters.transparency)
	end
	
	
	local Box= context:priceWidth (0, BoxSize*source:pipSize());
	
	context:createFont (10, "Arial", Box, Box, 0);
	
	    local Start={};
        for k, v in pairs(uTPO) do
				length = (v / umax) * NumberOfPoints; 
				max_length= NumberOfPoints
				visible, y1 = context:pointOfPrice (k * source:pipSize());
				y2 = y1;	

				if Type== "Consolidated" then		
				x1= context:right ()-length;
				x2= x1+length;
			    Start[k]=x1;				
				elseif  Type== "Aligned"  then
				x1= context:right ()-max_length;
				x2= x1+length;
				Start[k]=x1;
				elseif  Type== "Numerical"  then
				x1= context:right ()-max_length;
				end
				
                if  Type~= "Numerical" then
				context:drawRectangle (-1, 2, x1, y1 , x2, y2-Box,Transparency)
				else
                width, height = context:measureText (10, v, 0);				
				context:drawText (10, v, Long, -1, x1, y1-height, x1+width, y1, 0);
				end

		end
		
	
 
		 for k, v in pairs(dTPO) do
				length = (v / dmax) * NumberOfPoints; 
				visible, y1 = context:pointOfPrice (k * source:pipSize());
				y2 = y1;
				
	
				
  				if Type== "Consolidated" then		
					if Start[k]== nil then		
					Start[k]=context:right () ;	 
					end		
					
					x1= Start[k]- length;
					x2=Start[k];
				elseif  Type== "Aligned" then
					if Start[k]== nil then		
					Start[k]=context:right ()-max_length;	 
					end	
					
					x1= Start[k]- length;
					x2=Start[k];
				elseif  Type== "Numerical"  then
				x1= context:right ()-max_length;
				end					
			           
				
                if  Type~= "Numerical" then
				context:drawRectangle (-1, 4, x1, y1 , x2, y2-Box,Transparency)
				else
                width, height = context:measureText (10, v, 0);				
				context:drawText (10, v, Short, -1, x1-width, y1-height, x1, y1, 0);				
				end
		end
 
 

end	 

local Init = false;

-- Indicator calculation routine
function Update(period)
 
		  
    if period < source:size()-1 then
	return;
	end
	
	        uTPO = {};
			dTPO = {};
            umax = 0;
			dmax=0;	 
 
		    Loading(period); 

end

local v1,v2;
function Loading(period)
       local from, to = core.getcandle(TF, source:date(period), offset, weekoffset); 
 
 
       if bid == nil then
           loading = true;       		   
           bid = core.host:execute("getHistory", 1, source:instrument(), "m1", from, to, true);      
       end
	   
	   
			if loading then
			return;
			end
 
	   
 
        local bid_period = core.findDate(bid, from, false);
		for i= bid_period, bid:size()-1, 1 do
		Calculate(i); 
		end 


end

function Calculate (period)
   
        local Price2 = bid[period] / source:pipSize();
        Price2 = Price2 - Price2 % BoxSize; 
      
   	    local Price1 = bid[period-1] / source:pipSize();
        Price1 = Price1 - Price1 % BoxSize; 
		 
		 
        if uTPO[Price2] == nil then
           uTPO[Price2]=0;
        end


        if dTPO[Price2] == nil then	
           dTPO[Price2]=0;
        end 
  
		
		if Price2 > Price1 then
        uTPO[Price2] = uTPO[Price2] + 1;
		end
		if Price2 < Price1 then
        dTPO[Price2] = dTPO[Price2] + 1;
		end		
		
        if uTPO[Price2] > umax then
            umax = uTPO[Price2];
        end
		
        if dTPO[Price2] > dmax then
            dmax = dTPO[Price2];
        end
				
end




function AsyncOperationFinished(cookie, success, message)
       if cookie == 1 then
           loading = false;
       end
	   
	    if not loading then
	    instance:updateFrom(source:first());
		end
		
		return core.ASYNC_REDRAW ;
end