-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63098

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
    indicator:name("MCP Candle");
    indicator:description("MCP Candle");
     indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
  
    indicator.parameters:addGroup("Calculation");	
	 
	
	indicator.parameters:addString("TF", "Time frame", "", "H1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);	

	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");


	
	
	for i= 1 ,10, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");
	Add(i);
	end

	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	--indicator.parameters:addBoolean("ShowLabel", "Show Level Label", "", false);
	indicator.parameters:addInteger("LabelHeight", "Label Height (% of chart height)", "", 5);
	
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
	indicator.parameters:addInteger("Height", "Chart Height (% of chart height)", "", 100);
	indicator.parameters:addInteger("Space", "Interspace (% of bar width)", "", 20);
	
   indicator.parameters:addColor("Up", "Up Color", "Up Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "Down Color", core.rgb(255, 0, 0));
	
	
	indicator.parameters:addGroup("Central Line Style");  
	indicator.parameters:addColor("Central", "Central Line Color", "", core.rgb(0, 0,255));
    indicator.parameters:addInteger("cwidth","Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("cstyle","Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("cstyle", core.FLAG_LEVEL_STYLE);
   
	 

end

 
function Add(id)

    local Init={"EUR/USD","USD/JPY", "GBP/USD","USD/CHF", "EUR/CHF"
	          , "AUD/USD","USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY"
			  , "GBP/JPY", "CHF/JPY","GBP/CHF", "EUR/AUD", "EUR/CAD"	
              , "AUD/CAD", "AUD/JPY","CAD/JPY", "NZD/JPY", "GBP/CAD"					  
			  };
	
    if id <= 10 then	
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", true);		
    else
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", false);		
    end	
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local LabelHeight;
local TF;
local Type;
local Period;
local Up;
local Down;
local pauto =  "(%a%a%a)/(%a%a%a)";
local Color;
local Source={};
local Size;
local transparency;
local loading={};
local Space;
local source;
local Pair={};
local  Count;
local Point={};
local Dodaj={};
local Central;
local cwidth;
local cstyle;
local Delta;

-- Routine
function Prepare(nameOnly)
    Up= instance.parameters.Up;
	Down= instance.parameters.Down; 
	TF= instance.parameters.TF;
	LabelHeight= instance.parameters.LabelHeight;
	cwidth= instance.parameters.cwidth;
	cstyle= instance.parameters.cstyle;	
	Central= instance.parameters.Central;		
	Space=(1/ (100/ instance.parameters.Space) );	
	Type= instance.parameters.Type;



	
	source = instance.source;
	
    local iname = profile:id() .. "("  .. tostring(source:barSize())  .. ", "  .. tostring(TF) .. ")";
	instance:name(iname);
	if nameOnly then
		return;
	end
  
	if Type== "Multiple currency pair" then 
	
	Count=0;
				 for i= 1, 20 , 1 do	 
					 Dodaj[i]=instance.parameters:getBoolean("Dodaj" .. i);
					 if Dodaj[i] then		                     					 
					 Count=Count+1;
					 Pair[Count]=   instance.parameters:getString ("Pair"..i);	
					 Point[Count]= core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize;		
					 end
				 
				 end
				 
					 
	else 
	
	        

	           Pair[1]=source:instrument();
			   Point[1]=source:pipSize ();
			   Count=1;	
			   i=1;
			   
			  
	end
	
	
	Color= instance.parameters.Color;
	Height = instance.parameters.Height; 
	 
	
	 for i = 1, Count, 1 do	

      Source[i]= core.host:execute("getSyncHistory", Pair[i], TF, source:isBid(), 0 ,20000 + i , 10000 +i);
	  loading[i] = true;  

	 end 

	
	 
	 
	 
	if (not (nameOnly)) then
	instance:ownerDrawn(true); 
	end
   
end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i ;
 
 
		 for i = 1, Count, 1 do	
			  if cookie == ( 10000 +  i) then
			  loading[i] = true;
		      elseif  cookie == (20000+ i) then
			  loading[i] = false;           
			  elseif cookie == ( 30000 +  i) then
			  loading[10+i] = true;
		      elseif  cookie == (40000+ i) then
			  loading[10+i] = false;    	  
			  end
		       
          end

	
	
    local FLAG=false; 
	local Number=0;
	
	for i = 1, Count, 1 do
		 

                 if loading [i] then
				 FLAG= true;
				 Number=Number+1;
				 end
				 
				  if loading [10+i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         
    end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count*2 - Number) .. " / " ..  Count*2 );	 
	else
	core.host:execute ("setStatus", "Loaded");
	 instance:updateFrom(0);		
	end
   
        
    return core.ASYNC_REDRAW ;
end






-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period) 
	 
end



local init = false;
 
function Draw(stage, context)
    if stage~= 2 then
	return;
	end
	
	
	 local Loading=false; 
 
	
	for i = 1, Count, 1 do 
		if loading [i] then
		Loading= true; 
		end 
	
    end
	
	
	 if Loading then
         return;
     end
	 
 

	
        if not init then
		
		    context:createPen(31, context.SOLID, 1, Up); --1
             context:createSolidBrush(32, Up);--2
			 
			 context:createPen(33, context.SOLID, 1, Down);--3 
             context:createSolidBrush(34, Down);--3
			  
			  
            transparency = context:convertTransparency(instance.parameters.transparency);
			Size = 300;
		 
			
            init = true;
        end
		
		
		local top=context:top() +(context:bottom()-context:top())/10;
		local bottom =  context:bottom();
		local left, right = context:left(), context:right();
		local mid= bottom-(bottom-top)/2;
		
		 
   context:createPen(45,context:convertPenStyle (cstyle), context:pointsToPixels (cwidth), Central);
   context:drawLine (45, context:left(), mid,  context:right(), mid, 0);
		
		------------------
		         MaxPriceHeight=((bottom-top)/2)*(Height/100); 	
				   iWidth=((right-left)/(Count));
				 v1Width=((bottom-top)/100)*LabelHeight;
				  
				   
					if iWidth > Size and Count ==1  then
					iWidth=Size;
					end
				
				   context:createFont (46, "Arial",((iWidth/100)*LabelHeight), v1Width, context.CENTER);
	   
	   
	   Delta=0;
	   	for i= 1, Count,1 do
		Delta= math.max(Delta, (( Source[i].high[ Source[i].high:size()-1]- Source[i].low[ Source[i].low:size()-1])/Point[i]));
		end
	   
 
		for i= 1, Count,1 do
				
				
				
				  c1=(i-1)*iWidth ;
				  c2= c1 +  iWidth;
				  size=(c2-c1)*Space;
				  c1=c1 +size;      --x
				  c2=c2 -size;
				  c3=c1+ (c2-c1)/2; -- x
				  w1=c2+  (c3-c2)/3;
				  w2=c3- (c3-c2)/3;
				                       
				                          
										
										  cHeight=MaxPriceHeight*(math.abs(    (Source[i].close[ Source[i].close:size()-1] -   Source[i].open[ Source[i].open:size()-1])/Point[i]) / (Delta));
										  hHeight=MaxPriceHeight*(math.abs(    (Source[i].high[ Source[i].high:size()-1] -   Source[i].open[ Source[i].open:size()-1])/Point[i]) / (Delta));
								          lHeight=MaxPriceHeight*(math.abs(    (Source[i].low[ Source[i].low:size()-1] -   Source[i].open[ Source[i].open:size()-1])/Point[i]) / (Delta));
									
																
						 -----------------------------------
												 
									
							                   if Source[i].close[ Source[i].close:size()-1] <   Source[i].open[ Source[i].open:size()-1] then 
										        Code1=33;
												Code2=34;
												x1=(mid+cHeight); --C 
												x2=mid;           --O  
											  else
											   Code1=31;
											   Code2=32;
											   x1=(mid-cHeight); --C 
											   x2=mid;           --O  											   
											  end	
											  
										      context:drawRectangle( Code1,  Code2,c2, x1, c3, x2, transparency);	--C				
										
												
												
												y5=(mid-hHeight); -- H
                                                y6=(mid+lHeight); --L	
												
												 						
												  context:drawRectangle (Code1,  Code2, w1, y5, w2, math.min(x1,x2), transparency);	 --H 
		                                          context:drawRectangle (Code1,  Code2,  w1,  math.max(x1,x2), w2, y6, transparency);   --L
										
                             
												 
										 
                   
                                                     												  
								 
                       
					                             	  width1, height1 = context:measureText (46,  Pair[i], 0);
													 context:drawText (46, Pair[i], Color, -1, c1 , context:top()+height1, c2,context:top()+height1+ height1, context.CENTER );   
													 
												
									 					 
                end

 
      	 
	
							  
			
	 
		
end
		 

	 
 