-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75957

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

function AddParam(id, frame )

    indicator.parameters:addGroup(id.. ". Time Frame");
	 
	
	indicator.parameters:addBoolean("USE".. id, "Use this Slot", "", true);	
	
    indicator.parameters:addString("TF" .. id,  "Time frame", "", frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);


end


function Init()
    indicator:name("Multi-Timeframe Yield Curve");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addBoolean("Absolute", "Absolute Value ", "", true);	 
	
    AddParam(1, "m1");	
    AddParam(2, "m5");	
    AddParam(3, "m15");	
    AddParam(4, "m30");
    AddParam(5, "H1");
	AddParam(6, "H2");	
    AddParam(7, "H3");	
    AddParam(8, "H4");	
    AddParam(9, "H6");
    AddParam(10, "H8");
	AddParam(11, "D1");	
    AddParam(12, "W1");
    AddParam(13, "M1");
	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Line Color", "", core.COLOR_LABEL );
	indicator.parameters:addInteger("Width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
	--indicator.parameters:addDouble("Size", "Font Size", "", 10);
	--indicator.parameters:addDouble("Multiplier", "Multiplier", "", 50);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

	local source = nil;
	local TF={};
	local SourceData={};
	local loading={};  
	--local Size;
	local USE={};
	local Count=13;
    local Number;
	local Style, Width, Color
    local Chart;
	local iLabel={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"};
	local Label={};
	local  Multiplier={}; 
	local Absolute;
 
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    	
	
    source = instance.source;
    Absolute=instance.parameters.Absolute;
	Style=instance.parameters.Style;
	Width=instance.parameters.Width;
	Color=instance.parameters.Color;
	

    
	
	Number=0;
	
	
    local s1, e1, s1, e1;
    s1, e1 = core.getcandle(source:barSize(), core.now(), 0, 0);
    size1=e1-s1;
   
    for i = 1, Count, 1 do	

          s2, e2 = core.getcandle(instance.parameters:getString("TF" .. i), core.now(), 0, 0);	
		  size2=e2-s2;
		
	     if instance.parameters:getBoolean("USE" .. i)    then
		 Number=Number+1;
		 		
			  TF[Number]= instance.parameters:getString("TF" .. i);	
			  Label[Number]=iLabel[i];
			  Multiplier[Number]=size1/size2;
			  
		 end   
		   
	  
    end
     
	
	 s1, e1 = core.getcandle(source:barSize(), core.now(), 0, 0);

    for i = 1, Number, 1 do	
	
	     
	    if (TF[i] == source:barSize() )     then
		SourceData[i]=source;
		Chart=i;
		loading[i]= false;
		else 	
	    SourceData[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(),  0 , 200+i, 100+i);	   
		loading[i]= true;		
		end
		
	end	  
    
	instance:ownerDrawn(true);

end

 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
	    
end

local init =true;

function Draw(stage, context)
    if stage ~= 2 
	then
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
		
 

	 
		
		
		local Max=0;
		local Yield={};
		local Percentage={};
		for i = 1, Number, 1  do 
		    Percentage[i]=(SourceData[i].close[SourceData[i].close:size()-1] - SourceData[i].open[SourceData[i].open:size()-1])/(SourceData[i].open[SourceData[i].open:size()-1]/100)
			if  Max < Percentage[i] then
			Max = math.abs(Percentage[i])
			end		
		end
		
			    for i = 1, Number, 1  do 
				
					if Absolute then
					Yield[i]=math.abs(Percentage[i])/Max;			
					else					
					Yield[i]=Percentage[i]/Max;		
					end
				
				end
			  
				local xSize = (context:right () -context:left ())/(Number+2);	
	
    		
		
		if Absolute then
		
               local ySize = (context:bottom () - context:top ()) /12;	
 	
				context:createPen (1, context:convertPenStyle (Style), Width, Color);
				context:createFont (2, "Arial", ySize/3, ySize/3, 0);		
				

				y= context:bottom () - ySize;		
				context:drawLine (1, context:left () + xSize , y, context:right () - xSize , y);		
		 
				for i = 1, Number, 1  do 	  
					width, height = context:measureText (2, TF[i], context.CENTER)
					context:drawText (2, TF[i], Color, -1, context:left () + xSize +  (i-1)*xSize, y+ySize/2,  context:left ()  + xSize +  (i)*xSize, y+ySize/2+height, context.CENTER)					
				end	
				for i = 2, Number, 1  do 			
					y1= context:bottom () - ySize- (ySize*10)*Yield[i-1]
					y2= context:bottom () - ySize- (ySize*10)*Yield[i]		
					
					x1=context:left () + xSize/2 +  (i-1)*xSize
					x2=context:left () + xSize/2 +  (i)*xSize
					context:drawLine (1, x1, y1, x2, y2)			
				end 
		else
	            local ySize = (context:bottom () - context:top ()) /24;		
	            local yCenter= context:bottom () - (context:bottom () -context:top ())/2;		
				
				context:createPen (1, context:convertPenStyle (Style), Width, Color);
				context:createFont (2, "Arial", ySize*4/6, ySize*4/6, 0);		
				

				--y= yCenter - ySize;		
				context:drawLine (1, context:left () + xSize , yCenter, context:right () - xSize , yCenter);		
		 
				for i = 1, Number, 1  do 	  
					width, height = context:measureText (2, TF[i], context.CENTER)
					context:drawText (2, TF[i], Color, -1, context:left () + xSize +  (i-1)*xSize, yCenter+ySize/2,  context:left ()  + xSize +  (i)*xSize, yCenter+ySize/2+height, context.CENTER)					
				end	
				for i = 2, Number, 1  do 			
					y1= yCenter -  (ySize*10)*Yield[i-1]
					y2= yCenter -  (ySize*10)*Yield[i]		
					
					x1=context:left () + xSize/2 +  (i-1)*xSize
					x2=context:left () + xSize/2 +  (i)*xSize
					context:drawLine (1, x1, y1, x2, y2)			
				end 
		
		end 
		
end




-- the function is called when the async operation is finished

function AsyncOperationFinished(cookie)

     local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	
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
	
     	if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded ".. (Number-Count) .."/" .. Number);
		instance:updateFrom(0);	
		end
   
        
		return core.ASYNC_REDRAW ;
   
end

-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75957

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