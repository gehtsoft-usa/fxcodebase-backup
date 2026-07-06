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
    indicator:name("Cumulative Depth of Market");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
    indicator.parameters:addGroup("Calculation");
 
    indicator.parameters:addString("TF1", "Signal Time Frame ", "", "m1");
    indicator.parameters:setFlag("TF1", core.FLAG_PERIODS);

    indicator.parameters:addString("TF2", "Chart Time Frame ", "", "D1");
    indicator.parameters:setFlag("TF2", core.FLAG_PERIODS);
	
    indicator.parameters:addInteger("LookBack", "Lookback Period", "", 5);
	
    indicator.parameters:addInteger("BoxSize", "Size of price box in pips", "", 5);
 
	indicator.parameters:addString("Type", "Indicator Type", "", "Consolidated");
    indicator.parameters:addStringAlternative("Type", "Consolidated", "", "Consolidated");
    indicator.parameters:addStringAlternative("Type", "Aligned", "", "Aligned");
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addInteger("NumberOfPoints", "Number of points", "Number of points to display histogram", 200); 
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
local NumberOfPoints;
local  uTPO = {};
local  dTPO = {};
local source = nil; 
local first;
local Transparency;
local  Long,Short;

 
local bid;                 -- the additional data stream
local offset, weekoffset;    -- params for candle calculation
local load_from; 
local LookBack;

local umax = {};
local dmax= {};

local TF1,TF2;
local LabelSize;
local SourceData,loading; 
-- Routine
 function Prepare(nameOnly)   

    source = instance.source;
    first = source:first();
	Type= instance.parameters.Type;
	LookBack= instance.parameters.LookBack;
	LabelSize= instance.parameters.LabelSize;
	
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");

	TF1= instance.parameters.TF1;
	TF2= instance.parameters.TF2;	
--TF	
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(), offset, weekoffset);
    s2, e2 = core.getcandle(TF2, offset, weekoffset);
    assert((e2 - s2) >=(e1 - s1), "The chosen time frame must be longer than the source time frame");
	   

    BoxSize = instance.parameters.BoxSize;
	Long = instance.parameters.Long;
	Short = instance.parameters.Short;
 
 
    source = instance.source;
	
 	Source1 = core.host:execute("getSyncHistory", source:instrument(), TF1, source:isBid(), 300, 100, 101);
	loading1=true;
	
 	Source2 = core.host:execute("getSyncHistory", source:instrument(), TF2, source:isBid(), 300, 200, 201);
	loading2=true;  	
 
   instance:setLabelColor(Long);
   instance:ownerDrawn(true); 
   
end


local init = false; 
 
function Draw (stage, context)

    if stage  ~= 2 then
	return;
	end		
	
    if loading1 or loading2  then
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
	context:createPen (15, core.LINE_DOT, 1,  instance.parameters.Line_Color)
	end
	
 
 
	context:createFont (10, "Arial",(context:priceWidth (0, BoxSize*source:pipSize())/100)*LabelSize,  (context:priceWidth (0, BoxSize*source:pipSize())/100)*LabelSize, 0);
	
 

	AddContext( context);
	
 

end	 

function AddContext( context) 


 
 
if dmax== nil then
dmax=0;
end

if umax== nil then
umax=0;
end

 
 

local ShiftX, ShiftY  = context:measureText (10, "X", 0);	 
    
		local Box= context:priceWidth (0, BoxSize*source:pipSize());
	    local Start={};
		
		

	if uTPO~=nil then
			for k, v in pairs(uTPO) do
					visible, y1 = context:pointOfPrice (k * source:pipSize());
					y2 = y1;	
  
					length =  v *( NumberOfPoints/umax ); 
					max_length= NumberOfPoints

					if Type== "Consolidated" then

  					
 
						x1=context:right () - NumberOfPoints*2;	
						x2= x1+length ;						
						Start[k]=x2 ;	 
				    
				      
					end
                     if   Type== "Aligned" then						 

						x2=context:right ()- NumberOfPoints;
						x1= x2-	length;					
					end  
				 
						 context:drawRectangle (-1, 2, x1, y1 , x2, y2-Box,Transparency)				 



				 
            end
			end
		
 
 	 
			if dTPO~=nil then
			 for k, v in pairs(dTPO) do
			 		visible, y1 = context:pointOfPrice (k * source:pipSize());
					y2 = y1;
 

					length =  v * (NumberOfPoints /dmax); 
		
		           if Start[k]==nil then
				   Start[k]=context:right () - NumberOfPoints*2;	
                   end				   
					
					if Type== "Consolidated" then		

						x1= Start[k] ;						
						x2=x1+length;	  
				
					end
                     if   Type== "Aligned" then						 
						x1= context:right ()- NumberOfPoints;
						x2=x1+length;				 
					end  
					
					 
					 context:drawRectangle (-1, 4, x1, y1 , x2, y2-Box,Transparency)
			        
		 
	
					

					 
			end
		end 
		
 			
			


		
 
		
			if dTPO ~=nil then
				 for k, v in pairs(dTPO) do
						visible, y1 = context:pointOfPrice (k * source:pipSize()); 

						width, height = context:measureText (10, v, 0);				
							context:drawText (10, v, Short, core.COLOR_BACKGROUND ,context:right () - NumberOfPoints*2-ShiftX-width, y1-height,  context:right () - NumberOfPoints*2-ShiftX, y1, 0);

						 
				end
		end 
		
		if uTPO ~=nil then
					 for k, v in pairs(uTPO) do
							visible, y1 = context:pointOfPrice (k * source:pipSize());	
								
							
							width, height = context:measureText (10, v, 0);				
							context:drawText (10, v, Long, core.COLOR_BACKGROUND ,context:right () - NumberOfPoints*2-ShiftX*5-width, y1-height,  context:right () - NumberOfPoints*2-ShiftX*5, y1, 0);
				     end
        end		
end		

local Init = false;

-- Indicator calculation routine
function Update(period)
 
 
	  
	  if period < source:size()-1 then
	  return;
	  end
	  
	  if  loading1 or loading2  then
	  return;
	  end
	  
 
            for i=Source2:size()-1, math.max(Source2:size()-1 - LookBack+1, Source2:first()), -1 do
		    Loading(i); 
			end

end
--TF
local v1,v2;
function Loading(period)
       local from, to = core.getcandle(TF2, Source2:date(period), offset, weekoffset); 
 
 
 	
 	

        umax =0;	
        dmax =0;	 
 
        local bid_period_from = core.findDate(Source1, from, false);
 

		if bid_period_from <0    then
		return;
		end		
		
		for i= bid_period_from,Source1:size()-1, 1 do
		Calculate(i); 
			if Source1:date(i) >= to then
			break;
			end
		end 


end

function Calculate (period)




   
        local Price2 = Source1.close[period] / source:pipSize();
        Price2 = Price2 - Price2 % BoxSize; 
      
   	    local Price1 = Source1.close[period-1] / source:pipSize();
        Price1 = Price1 - Price1 % BoxSize; 
		 
		 
        if uTPO[Price2]== nil then
           uTPO[Price2]=0;
        end


        if dTPO[Price2] == nil then	
           dTPO[Price2] =0;
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

	   
	    if cookie == 100 then
        loading1 = false;
        elseif cookie == 101 then
        loading1 = true;
        end
		
	    if cookie == 200 then
        loading2 = false;
        elseif cookie == 201 then
        loading2 = true;
        end		
	   
	    if not loading1 or not loading2   then
        instance:updateFrom(0);
		end
		
		return core.ASYNC_REDRAW ;
end