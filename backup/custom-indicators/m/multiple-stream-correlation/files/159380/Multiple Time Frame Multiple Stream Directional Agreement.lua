-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75950&p=159380#p159380

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
function Init()
    indicator:name("Multiple Time Frame Multiple Stream Directional Agreement");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "Period", 20);
	
    indicator.parameters:addGroup("Time Frames"); 	
	indicator.parameters:addString("TF1",  "1. Time frame", "", "m30");
    indicator.parameters:setFlag("TF1", core.FLAG_PERIODS);

	indicator.parameters:addString("TF2",  "2. Time frame", "", "H1");
    indicator.parameters:setFlag("TF2", core.FLAG_PERIODS);	

	indicator.parameters:addString("TF3",  "3. Time frame", "", "H8");
    indicator.parameters:setFlag("TF3", core.FLAG_PERIODS);	


	indicator.parameters:addString("TF4",  "4. Time frame", "", "D1");
    indicator.parameters:setFlag("TF4", core.FLAG_PERIODS);

 	indicator.parameters:addString("TF5",  "5. Time frame", "", "W1");
    indicator.parameters:setFlag("TF5", core.FLAG_PERIODS);

 
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("LabelSize", "Font Size", "", 20, 0, 100); 
    indicator.parameters:addColor("Label", "Label Color", "Label Color", core.COLOR_LABEL );
	indicator.parameters:addColor("Up", "Up Color", "Label Color", core.rgb(0, 255, 0));
     indicator.parameters:addColor("Down", "Down Color", "Label Color", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;
local loading={};
local  List={};
local  Count;  
local Label;
local Source={}; 
local host;
local offset;
local weekoffset;
  
 
local Up, Down;
local TF={};  
local Index={};
local Value={}; 
local Base;
-- Routine
function Prepare(nameOnly)


	source = instance.source;
	 local name = profile:id() .. "(" ..  source:name()  .. ")";
    instance:name(name); 


     if   (nameOnly) then
        return;
    end
	 
 
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;

	Label = instance.parameters.Label;
	LabelSize = instance.parameters.LabelSize;
    Period = instance.parameters.Period;

    first = source:first();
	
	host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	List, Count=getInstrumentList();
	
 
 
	for i=1, 5,1 do
	TF[i]= instance.parameters:getString("TF" .. i)  
	end
	
	
    local ID=0;	
	local i,j; 
	for i = 1, 5, 1 do 
	    Source[i]={};
	    loading[i]={};		
		Value[i]={};
		Index[i]={};
	    for j = 1, Count, 1 do
		 
		    ID = ID + 1
			Source[i][j]  = core.host:execute("getSyncHistory", List[j], TF[i], source:isBid(), Period, 2000 + (i-1)*Count+(j-1), 1000+(i-1)*Count+(j-1) ); 
			loading[i][j] = true;
			if List[j]==source:name() or  List[j]==source:instrument() then
			Base=j;
			end	
	    end

			
	end
 
	
	core.host:execute ("setTimer", 1, 5);
    core.host:execute("subscribeTradeEvents", 999, "offers")	
	instance:ownerDrawn(true);

   
end


function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


 

end

local init=false;

function Draw(stage, context)

   if stage  ~= 2    
   then
	return;
	end
	
   local ItIs=false; 	
	for i = 1, 5, 1 do	 
	        for j = 1, Count, 1 do
				if loading[i][j]  then		
				ItIs=true;
				end
			end
         		
	end
	

	
	
	if ItIs then
	return;
	end
	
 
	
 	top, bottom = context:top(), context:bottom();
	hCenter=  top+(bottom-top)/2;
    left, right = context:left(), context:right(); 
	slotSize= (right-left)/5;
	
	context:createFont (1, "Arial",slotSize/20, slotSize/20 , 0);
	
	--local Sorted;
	--for i = 1, 5, 1 do	
    --    for j = 1, Count, 1 do	
	--		if List[ Index[i][j]] == source:instrument() then
	--		Sorted=j;			
	--		end
	--	end
		
	--end	
	for i = 1, 5, 1 do	
        for j = 1, Count, 1 do	 
						
						if Value[i][Index[i][j]] ~= nil and List[ Index[i][j]] ~= source:instrument() then	
						
					         	width, height = context:measureText (1, tostring(List[ Index[i][j]]), context.CENTER  ); 
								if Value[i][Index[i][j]] >= Period/2  then								
							    context:drawText (1, tostring(List[ Index[i][j]]), Up, -1, left+(i-1)*slotSize, hCenter+(j*height)-height ,  left+(i-1)*slotSize+width, hCenter+(j*height), context.CENTER, 0); 
								else
								context:drawText (1, tostring(List[ Index[i][j]]), Down, -1, left+(i-1)*slotSize, hCenter+(j*height)-height ,  left+(i-1)*slotSize+width, hCenter+(j*height), context.CENTER, 0);						 
								end				 
				        end
				 
		end	
	end
	
	
end
							 
	  


function getInstrumentList()
    local list={};
   
    local count = 0;   
    local row, enum;   
   
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
        row = enum:next();
    end

    return list, count;
end





function AsyncOperationFinished(cookie)

    local ID=0;	
	for i = 1, 5, 1 do	
	    for j = 1, Count, 1 do	 
           ID=ID+1;		
		   if cookie == 1000+(i-1)*Count+(j-1) then
			  loading[i][j] = true;  
		      elseif  cookie == 2000+(i-1)*Count+(j-1) then
			  loading[i][j]= false;   
		    end
		end
	end
	
		
    local ItIs=false; 
	for i = 1, 5, 1 do	
	    for j = 1, Count, 1 do	 
		   if loading[i][j]    then 
			  ItIs=true;  
		    end
		end
	end
 
	   
    if ItIs then
    core.host:execute ("setStatus", "  Loading ");
	else
   
				if cookie == 999 or cookie == 1 then
				
				
						   Calculation()
				
				
						for i= 1, 5, 1 do 
						   
						   Index[i]= BubbleSortKey(i);
						   
						end
			 end 
   
       core.host:execute ("setStatus", "Loaded"); 
       instance:updateFrom(0);

 	 
   end
   
  
   
        
     return core.ASYNC_REDRAW;
end


function Calculation()


   local ItIs=false; 	
	for i = 1, 5, 1 do	 
	        for j = 1, Count, 1 do
				if loading[i][j]  then		
				ItIs=true;
				end
			end
         		
	end
	

	
	
	if ItIs then
	return;
	end
	
    local Number; 
		
		
		for i = 1, 5, 1 do	       
			 		   
					   
				 for j = 1, Count, 1 do		
				 
								
								p=Source[i][j].close:size()-1
								bp=Source[i][Base].close:size()-1
								Number=0
								
													for k  = 1, Period, 1 do
													
													
														
														
														 
															
															 
																	
																		if  p > Period and bp > Period and Source[i][Base].close:hasData(bp) and Source[i][j].close:hasData(p) then
																							if (
																							Source[i][Base].close[bp-k+1] > Source[i][Base].open[bp-k+1]
																							and 
																							Source[i][j].close[p-k+1] > Source[i][j].open[p-k+1]
																							)
																							or
																							(
																							Source[i][Base].close[bp-k+1] < Source[i][Base].open[bp-k+1]
																							and 
																							Source[i][j].close[p-k+1] < Source[i][j].open[p-k+1]
																							)
																							then
																							Number=Number+1;
																							end
																	
																		 end
															
															
															
														
													end		
													
							
				               Value[i][j]=Number;
									
										
								 
		         end
		 
	 
	   
	
		   
	end
		
end 



function BubbleSortKey(i)


   local ItIs=false; 	
	for i = 1, 5, 1 do	 
	        for j = 1, Count, 1 do
				if loading[i][j]  then		
				ItIs=true;
				end
			end
         		
	end
	

	
	
	if ItIs then
	return;
	end

 
 local Key={};
 local Temp;
 local Sort=true;
   
   
   for j=1, Count, 1 do
   Key[j]=j;
   end
   
 

 

					while Sort do
					Sort=false;
				   
							for j = 2,  Count , 1 do
						   
									if Value[i] [ Key[j] ] ~= nil then
									 
											if  Value[i][ Key[j] ] > Value[i][Key[j-1] ]   then
											 Sort=true;                  
											 
											 Temp= Key[j];                     
											 Key[j]=Key[j-1];
											 Key[j-1]=Temp;                       
											end
									end
						   
						  end
					
					end

 
    
  return Key;
end
 
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75950&p=159380#p159380

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