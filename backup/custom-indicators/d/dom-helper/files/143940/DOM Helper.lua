-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71571

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
    indicator:name("DOM Helper");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Id", "Database Id", "", "1"); 
    indicator.parameters:addString("TF", "Signal Time Frame ", "", "m1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);

 
	
    indicator.parameters:addInteger("BoxSize", "Size of price box in pips", "", 2);
 
	indicator.parameters:addString("Type", "Indicator Type", "", "Consolidated");
    indicator.parameters:addStringAlternative("Type", "Consolidated", "", "Consolidated");
    indicator.parameters:addStringAlternative("Type", "Aligned", "", "Aligned");
 
	
	indicator.parameters:addGroup("Style");
  --  indicator.parameters:addInteger("NumberOfPoints", "Number of points", "Number of points to display histogram", 200); 
	indicator.parameters:addDouble("transparency", "Transparency", "Transparency", 50); 
	indicator.parameters:addColor("Long", "Long Color", "", core.COLOR_UPCANDLE );
	indicator.parameters:addColor("Short", "Short Color", "", core.COLOR_DOWNCANDLE);
	indicator.parameters:addColor("Line_Color", "Line Color", "", core.COLOR_LABEL );	
	
	indicator.parameters:addInteger("LabelSize", "Label Size as Percentage", "", 75);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Type;
local BoxSize;
--local NumberOfPoints;

local source = nil; 
local first;
local Transparency;
local  Long,Short;
 
local offset, weekoffset;    -- params for candle calculation
  
local min,max ;

local TF;
local LabelSize;
local Source, loading; 

local db;

local Up={};
local Down={};
local Max;
local Last;

local Id;
-- Routine
 function Prepare(nameOnly)   

    source = instance.source;
    first = source:first();
	Type= instance.parameters.Type; 
	LabelSize= instance.parameters.LabelSize;
	
	Id= instance.parameters.Id;
	
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");

	TF= instance.parameters.TF;

--TF	
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(), offset, weekoffset);  
    s2, e2 = core.getcandle(TF, offset, weekoffset);
    assert((e2 - s2) >=(e1 - s1), "The chosen time frame must be longer than the source time frame");
	   

    BoxSize = instance.parameters.BoxSize;
	Long = instance.parameters.Long;
	Short = instance.parameters.Short;
 
 
    source = instance.source;
	
 	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 300, 200, 100);
	loading=true;  	
 
   instance:setLabelColor(Long);
   instance:ownerDrawn(true); 
   
   
   -- min = instance:addInternalStream(0, 0);
    --max = instance:addInternalStream(0, 0);  
   
   	require("storagedb")
	db = storagedb.get_db(Id)
   
end


local init = false; 
 
function Draw (stage, context)

    if stage  ~= 2 then
	return;
	end		
	
    if loading   then
	return;
	end	
	
	 
 
 
	if not init then
	init=true;
	context:createPen (1, 1, 1, Long);
	context:createSolidBrush (2, Long);
	
	context:createPen (3, 1, 1, Short);
	context:createSolidBrush (4, Short);
	Transparency= context:convertTransparency (instance.parameters.transparency)
	context:createPen (15, core.LINE_DOT, 1,  instance.parameters.Line_Color)
	end
	
	

 	
	context:createFont (10, "Arial",(context:priceWidth (0, BoxSize*source:pipSize())/100)*LabelSize,  (context:priceWidth (0, BoxSize*source:pipSize())/100)*LabelSize, 0);
	


	AddPeriod( context);


end	 

function AddPeriod(context) 

local period =source:size()-1;

local from, to = core.getcandle(TF, source:date(period), offset, weekoffset); 
local x, x1, x2 = context:positionOfDate (from);
 

   
X1, o, o = context:positionOfDate (from);
X2, o, o = context:positionOfDate (to);

NumberOfPoints=(X2-X1)/Max;

context:drawLine (15, x, context:top() , x, context:bottom(), 0)

 

local ShiftX, ShiftY  = context:measureText (10, "X", 0);	 
    
		local Box= context:priceWidth (0, BoxSize*source:pipSize());
	    local Start={};

 
		
 
  	
 
							 for k, v in pairs(Down) do
									visible, y1 = context:pointOfPrice (k * source:pipSize());
				 
				 

									length = v * NumberOfPoints; 
						
									
									if Type== "Consolidated" then		
											
										
										x1= x;
										x2=x+ length;			
										Start[k]=x2 ;	 
								
									end
									 if   Type== "Aligned" then
										 
										x1= x- length;
										x2=x;			
					 
									end  
									
									 
									 
									 context:drawRectangle (-1, 4, x1, y1 , x2, y1-Box,Transparency)
									
									width, height = context:measureText (10, v, 0);				
									context:drawText (10, v, Short, core.COLOR_BACKGROUND , x-ShiftX-width, y1-height, x-ShiftX, y1, 0);
					
									

									 
							end
				 
		
 		
		 
						for k, v in pairs(Up ) do
								visible, y1 = context:pointOfPrice (k * source:pipSize());
								y2 = y1;	
			  
								length =  v * NumberOfPoints; 
								max_length= NumberOfPoints

								if Type== "Consolidated" then

								if Start[k]== nil then
								Start[k]=x;
								end
								
								x1= Start[k] ;
								x2= Start[k]+length; 
								end					
								 if   Type== "Aligned" then
									 
									x1= x;
									x2=x+ length;			
				 
								end 
					 
							 
									 context:drawRectangle (-1, 2, x1, y1 , x2, y1-Box,Transparency)				 

							
								
								width, height = context:measureText (10, v, 0);				
								context:drawText (10, v, Long, core.COLOR_BACKGROUND , x+ShiftX, y1-height, x+ShiftX+width, y1, 0);

							 

					 
		 
		
    end
end		

local Init = false;

-- Indicator calculation routine
function Update(period)
  
	  
	  if  loading  then
	  return;
	  end
	  
	if period < 300 then
	return;
	end
	  
	if period < source:size()-1 -300 then
    return;
    end
	

	Loading(period); 
 

end


function Loading(period)


		
        local from, to = core.getcandle(TF, source:date(period), offset, weekoffset); 

 	   
    if Last~= from then
	Up={};
	Down={};
	Last= from;
	min= math.huge;
	max= 0	
	Max=0;
	end
	

       Calculate (from,period )
	   
	   
 

end

function Calculate (from,period)


		
   
        local Price2 = source[period] / source:pipSize();
        Price2 = Price2 - Price2 % BoxSize; 
      
   	    local Price1 = source[period-1] / source:pipSize();
        Price1 = Price1 - Price1 % BoxSize; 
		
		

		
        local v1 = rawget(Up, Price2);
        local v2 = rawget(Down, Price2);		
		
        if v1 == nil then
            v1 = 0;--inivilizes the row to 0 , if the row was not set 
        end			
 
        if v2 == nil then
            v2 = 0;--inivilizes the row to 0 , if the row was not set 
        end		
		
	
		
		if source[period] > source[period-1] then
        v1=v1+1;
		rawset(Up, Price2, v1)
        db:put(tostring("Up" .. from ..  Price2),  tostring(v1))	 
		end

		if source[period] <  source[period-1] then
		--Down[Price2]=Down[Price2]+1	
        v2=v2+1;		
        rawset(Down, Price2, v2) 		
        db:put(tostring("Down" ..from ..  Price2), tostring(v2))	
		end		 
	  
		if  Price2 <  min then
		min=Price2;		
        db:put(tostring("MinData" ..from ), tostring(min));
		end
		
		if  Price2 >  max then
		max=Price2;		
        db:put(tostring("MaxData" ..from ), tostring(max));			
		end
  
		


		
		if v1 > Max then
		Max=v1;
		end
		if v2 > Max then
		Max=v2;
		end	
		
			
   	    core.host:execute("setStatus", Max.. ", " .. min .. ", " .. max  .. ", " ..  from); 
				
end




function AsyncOperationFinished(cookie, success, message)

	   
	    if cookie == 100 then
        loading = true;
        elseif cookie == 200 then
        loading = false;
        end
		 
	    if not loading    then
        instance:updateFrom(0);
		end
		
		return core.ASYNC_REDRAW ;
end