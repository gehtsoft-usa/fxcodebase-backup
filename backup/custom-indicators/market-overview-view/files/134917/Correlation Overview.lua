 -- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69959

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Correlation Overview");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.View);
  
  
	indicator.parameters:addGroup("Correlation Calculation");
	
	
	indicator.parameters:addString("Instrument", "Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("Instrument" , core.FLAG_INSTRUMENTS);
	
	 indicator.parameters:addInteger("Period", "Period", "", 14);
	
    indicator.parameters:addString("Method", "Method", "", "Directional Count");
    indicator.parameters:addStringAlternative("Method", "Directional Count", "", "Directional Count");
	indicator.parameters:addStringAlternative("Method", "Directional Percantage", "", "Directional Percantage");
    indicator.parameters:addStringAlternative("Method", "Correlation Coefficient", "", "Correlation Coefficient");
   
 
   
   indicator.parameters:addGroup("Presentation");
	
	
    indicator.parameters:addBoolean("Use_Base", "Use Base", "Use Base", true);
	
	
	indicator.parameters:addString("Orientation", "Orientation", "", "Vertical");    
    indicator.parameters:addStringAlternative("Orientation", "Horizontal", "", "Horizontal");
    indicator.parameters:addStringAlternative("Orientation", "Vertical", "", "Vertical");

	
	indicator.parameters:addString("Base", "Base Pair", "", "USD");
    indicator.parameters:addStringAlternative("Base", "USD", "", "USD");
    indicator.parameters:addStringAlternative("Base", "EUR", "", "EUR");
    indicator.parameters:addStringAlternative("Base", "JPY", "", "JPY");
    indicator.parameters:addStringAlternative("Base","CHF", "", "CHF");
    indicator.parameters:addStringAlternative("Base", "GBP", "", "GBP");
	indicator.parameters:addStringAlternative("Base", "CAD", "", "CAD");
    indicator.parameters:addStringAlternative("Base", "AUD", "", "AUD");
    indicator.parameters:addStringAlternative("Base", "NZD", "", "NZD");	
 
	
	indicator.parameters:addString("TF", "Time Frame", "", "D1");
    indicator.parameters:setFlag("TF" , core.FLAG_PERIODS);
	
	
 
    indicator.parameters:addBoolean("Major", "Major Only", "Major Only", true);
 
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color","", core.rgb(255, 0, 0));
	--indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 50, 0, 100);

 
    indicator.parameters:addInteger("Font_Size", "Minimal Font Size", "", 5 , 0, 100);
	indicator.parameters:addInteger("Spacing", "Spacing", "", 20 , 0, 50);
	indicator.parameters:addColor("bg_color", "Background color", "", core.COLOR_BACKGROUND);

end
 

  

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Instrument;
local Base;
local Major; 
local TF; 
local pauto = "(%a%a%a)/(%a%a%a)"
local Color;
local Source={};
local transparency; 
local loading={}; 
local source;
--local Size;
local Up,  Down,Neutral ;
local minusX, minusY;  
local HISTORY_LOADING_ID = 1000;
local InstrumentList , InstrumentCount,Point;
local Change={};
local ChangeKey; 
local ShortList={};
local Inverse={};
local Method; 
local Font_Size; 
local Spacing;
local Use_Base;
local Orientation;
local Second, First;
local CorrelationIndex;
local Period;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	
	Use_Base= instance.parameters.Use_Base;
	Orientation= instance.parameters.Orientation;
	Period= instance.parameters.Period;
	
	Spacing= instance.parameters.Spacing;
	Base= instance.parameters.Base; 
	Major= instance.parameters.Major;   
	TF= instance.parameters.TF;
	Method= instance.parameters.Method;
	
	Instrument= instance.parameters.Instrument;
 
  
    Color= instance.parameters.Color; 
	Size= instance.parameters.Size;  
	Font_Size= instance.parameters.Font_Size;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down; 
	--Neutral= instance.parameters.Neutral; 
	
	 
	InstrumentList , InstrumentCount, Point , ShortList, Inverse,First, Second= getInstrumentList();
 
    	source = instance.source; 
 
    local ID=0;
     
        for i = 1, InstrumentCount, 1 do
            
			 
        
                ID = ID + 1;  
                Source[i] = core.host:execute("getHistory", HISTORY_LOADING_ID + ID, InstrumentList[i], TF, 0, 0, true);					
                loading[i] = true; 
          
        end
   
    
    
    instance:ownerDrawn(true); 
    core.host:execute("subscribeTradeEvents", 999, "offers");
    instance:initView("Dashboard", 0, 1, true, true);
 
 
    
 
	open = instance:addStream("open", core.Dot, "open", "open", 0, 0, 0);
    open:setVisible(false);
	
 
 
end

function getInstrumentList()
    local list={};
	local point={};
	local short={};
    local count = 0;
    local inverse={};	
    local row, enum;	
	local first={};
	local second={};
	

	local crncy1, crncy2;
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
	
	   	crncy1, crncy2 = string.match(row.Instrument, pauto)
		
		
		 
		
		if  (((crncy1== Base or  crncy2== Base  )and Use_Base) or not Use_Base) 
        and  ((ItIsMajor(crncy1, crncy2) and Major) or not Major)  
		or Instrument == row.Instrument
		then 
		
					count = count + 1;
					
					if  Instrument == row.Instrument then
					CorrelationIndex=count;
					end
					
					list[count] = row.Instrument;
					point[count] = row.PointSize; 
					first[count]=crncy1;
					if crncy2==nil then 
					second[count]="";
					first[count]=row.Instrument;
					else
					second[count]=crncy2;
					end
					
					if crncy1==nil then  
					first[count]=row.Instrument; 
					end					
					
						if crncy1== Base  then
							
							short[count]=crncy2;	
							
						inverse[count]=0;
						
						elseif crncy2== Base then
								
								short[count]=crncy1;
								
						
							if Use_Base then
							inverse[count]=1;	
							else
							inverse[count]=0;	
							end			
							
							
						
						end
						
						
					end
		
		 row = enum:next();
    end
	
	 
    return list, count,point,short, inverse, first, second;
end

local Majors={"USD" ,"EUR","JPY", "CHF" , "GBP" ,"AUD" ,"NZD", "CAD" };
function ItIsMajor(crncy1, crncy2)


if crncy1==nil
or crncy2==nil
then
return false;
end

local Flag1=false;
local Flag2=false;


        for i= 1, 8, 1 do

		
             if crncy1== Majors[i] then
			  Flag1=true;
			 end
			 
			 if crncy2== Majors[i] then
			  Flag2=true;
			 end
	 
		end
	
    local Return =false;

	
	if 	Flag1 and Flag2 then
	Return=true;
	end
	
	return Return;

end
 

 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

 
   if cookie >= HISTORY_LOADING_ID then
        local i,j;
        local ID = 0;

        for i = 1, InstrumentCount, 1 do
            
                ID = ID + 1;
                if cookie == (HISTORY_LOADING_ID + ID) then
                    loading[i]  = false;
                end
				
				
				if i== 1 then
				
					--for j = 0, Source[i]:size() - 1 , 1 do
					j= Source[i]:size() - 1;
					if j>=0 then
					instance:addViewBar(Source[i]:date(j));				   
				    end
				
				end
             
        end

        local FLAG=false; 
        local Number=0;
        
        for i = 1, InstrumentCount, 1 do
           
                if loading[i]  then
                    FLAG = true;
                    Number=Number+1;
                end
            
        end
        
        if FLAG then
            core.host:execute ("setStatus", "Loading ".. (InstrumentCount- Number) .. " / " ..  InstrumentCount );	 
        else
            core.host:execute ("setStatus", "Loaded") 
             
        end
       
      
    elseif cookie == 999 then
        local Loading = false; 
        for i = 1, InstrumentCount, 1 do 
             
                if loading[i] then
                    Loading = true; 
                end
            end 
    end
	
	 if Loading then
	 return;
	 end
	 
	 
	 
 
	  
	     for i= 1, InstrumentCount,1 do  
		 Change[i]= CalculatePercentageChange (i,1); 		 
		 end
		 
		
	  		
	    ChangeKey= BubbleSortKey(Change, InstrumentCount );	 
	 

	 
    
	    return core.ASYNC_REDRAW;
end

function CalculatePercentageChange (i, id)


    if Source[i].close:size()-1<=Period
	or Source[CorrelationIndex].close:size()-1<=Period
	then
	return 0;
	end
	
	
	
	local Value=0; 
	
	 
	 
	  
      if Method== "Directional Count" then
	 
			  for j= 1, Period, 1 do
			  
			     if (Source[i].close[ Source[i].close:size()-1 -j+1 ] > Source[i].open[ Source[i].open:size()-1 -j+1 ] 
				 and Source[CorrelationIndex].close[ Source[CorrelationIndex].close:size()-1 -j+1 ] > Source[CorrelationIndex].open[ Source[CorrelationIndex].open:size()-1 -j+1 ] )
				 or
				 (Source[i].close[ Source[i].close:size()-1 -j+1 ] < Source[i].open[ Source[i].open:size()-1 -j+1 ] 
				 and Source[CorrelationIndex].close[ Source[CorrelationIndex].close:size()-1 -j+1 ] < Source[CorrelationIndex].open[ Source[CorrelationIndex].open:size()-1 -j+1 ] )
				 then
				 Value=Value+1;
				 end
			  
			  end
			  
			 
	       
		   
		            if Value > Period/2 then 
					Value= Value/Period ;
					else
					Value=  -Value/Period ;
					end
					
					
					 
			  if Use_Base  and Inverse[i] then
			  
			  Value=-Value;
			  
			  end
	 
	 
	  elseif Method== "Correlation Coefficient" then
	  
	               Value = mathex.correl( Source[i].close,  Source[CorrelationIndex].close, Source[i].close:size()-1-Period+1, Source[i].close:size()-1, Source[CorrelationIndex].close:size()-1-Period+1, Source[CorrelationIndex].close:size()-1);

	                if Use_Base  and Inverse[i] then
					  
					  Value=-Value;
					  
					  end
					  
	  else
	  
	  
	             for j= 1, Period, 1 do
				 
				 
				 
				--  All = Value+ ((math.abs(Source[i].close[ Source[i].close:size()-1 -j+1 ] - Source[i].open[ Source[i].open:size()-1 -j+1 ] )/Point[i] ) / (math.abs(Source[CorrelationIndex].close[ Source[CorrelationIndex].close:size()-1 -j+1 ] - Source[CorrelationIndex].open[ Source[CorrelationIndex].open:size()-1 -j+1 ] )/Point[CorrelationIndex])) ; 

					  
						 if (Source[i].close[ Source[i].close:size()-1 -j+1 ] > Source[i].open[ Source[i].open:size()-1 -j+1 ] 
						 and Source[CorrelationIndex].close[ Source[CorrelationIndex].close:size()-1 -j+1 ] > Source[CorrelationIndex].open[ Source[CorrelationIndex].open:size()-1 -j+1 ] )
						 or
						 (Source[i].close[ Source[i].close:size()-1 -j+1 ] < Source[i].open[ Source[i].open:size()-1 -j+1 ] 
						 and Source[CorrelationIndex].close[ Source[CorrelationIndex].close:size()-1 -j+1 ] < Source[CorrelationIndex].open[ Source[CorrelationIndex].open:size()-1 -j+1 ] )
						 then
						 Value= Value+ ((math.abs(Source[i].close[ Source[i].close:size()-1 -j+1 ] - Source[i].open[ Source[i].open:size()-1 -j+1 ] )/Point[i] ) / (math.abs(Source[CorrelationIndex].close[ Source[CorrelationIndex].close:size()-1 -j+1 ] - Source[CorrelationIndex].open[ Source[CorrelationIndex].open:size()-1 -j+1 ] )/Point[CorrelationIndex])) ;
						
						 end
			  
			  
	 
  	  
	             end
		   
		   
		     
		            if Value > (Period/2) then 
					Value= Value/Period ;
					else
					Value=  -Value/Period ;
					end
					
					
					 
			  if Use_Base  and Inverse[i] then
			  
			  Value=-Value;
			  
			  end
	 end
	  
	
	  

	
	return Value;
	 
end





function BubbleSortKey(Data, Index)
 
 local Key={};
 local Temp;
 local Repeat_The_Loop=true;
 
   
   for i=1, Index, 1 do
   Key[i]=i;
   end
   
   

     while Repeat_The_Loop do
    Repeat_The_Loop=false;
   
            for i = 2, Index , 1 do
                  
                    if Data[Key[i]] >  Data[Key[i-1]] then
                     Repeat_The_Loop=true;                  
                     
                            Temp= Key[i];                     
                     Key[i]=Key[i-1];
                     Key[i-1]=Temp;                      
                    end
          
          end
   
    end
 
  return Key;
end

local top, bottom;
local left, right;
 
 
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 
    --shoudn't be called
end

local init = false; 

local BG = 3;
local BG_PEN = 4;
function Draw(stage, context)
	if stage ~= 2 then
        return;
	end
	

	local Loading=false;
	
	for i = 1, InstrumentCount, 1 do 
	   
            if loading [i] then
            Loading=true;      
            end
		
    end
	
	if Loading then
	return;
	end
	

    if not init then 
		
		transparency = context:convertTransparency(instance.parameters.transparency); 
		context:createSolidBrush(BG, instance.parameters.bg_color);
		context:createPen(BG_PEN, context.SOLID, 1, instance.parameters.bg_color);
		
		
		context:createSolidBrush(12, Up);
		context:createPen(11, context.SOLID, 1, Up);
		
		
		context:createSolidBrush(22, Down);
		context:createPen(21, context.SOLID, 1, Down);
                        
        init = true;
    end
	
	
		
   context:setClipRectangle(0, 0, 5000, 5000);
   context:drawRectangle(BG_PEN, BG, 0, 0, 5000, 5000);

 
	    
    
    local top, bottom = context:top(), context:bottom();
    local left, right = context:left(), context:right(); 
	
	
	if Orientation== "Horizontal" then
	
					local v_size= (bottom- top);
					
					local x_cell = (right-left)/ (InstrumentCount+1);
					local y_central = top+ (bottom-top)/ 2;

                     
					context:createFont (1, "Arial",math.max(Font_Size, (x_cell -(x_cell/100)*Spacing*2)/4), math.max(Font_Size, (x_cell -(x_cell/100)*Spacing*2)/4) , 0);--Size
                   
					
					local MaxSize=0;
					for i= 1, InstrumentCount,1 do 	
					
						if math.abs(Change[i]) > MaxSize then
						MaxSize=math.abs(Change[i]);
						end
					end
					
				 
						local Text;
					   for i= 1, InstrumentCount,1 do 	
				 
									x1= left+i*x_cell + (x_cell/100)*Spacing;
									x2=x1+x_cell- (x_cell/100)*Spacing;
									
									 
									 
									if Use_Base then
									Text= tostring(ShortList[ChangeKey[i]]);									 
									
									width, height = context:measureText (1, Text, context.CENTER  ); 
									context:drawText (1,Text, Color, -1, left+i*x_cell +(x_cell/100)*Spacing , y_central -height/2 ,   left+i*x_cell + width + (x_cell/100)*Spacing ,   y_central +height/2, context.CENTER   );
									
									else
									
									 
									 Text= tostring(First[ChangeKey[i]]);									 
									
									width, height = context:measureText (1, Text, context.CENTER  ); 
									context:drawText (1,Text, Color, -1, left+i*x_cell +(x_cell/100)*Spacing , y_central -height/2 ,   left+i*x_cell + width + (x_cell/100)*Spacing ,   y_central +height/2, context.CENTER   );
									
									
									Text= tostring(Second[ChangeKey[i]]);									 
									
									width, height = context:measureText (1, Text, context.CENTER  ); 
									context:drawText (1,Text, Color, -1, left+i*x_cell +(x_cell/100)*Spacing , y_central +height/2  ,   left+i*x_cell + width + (x_cell/100)*Spacing ,   y_central +height/2 +height, context.CENTER   );
									 
									end
									
								
									 
									 
									 height1= height
								 
									P_Low=  y_central -height/2;
									N_High=  y_central +height/2;
									
									SizeOfOne=(v_size/2)*(math.abs(Change[ChangeKey[i]] )/MaxSize);  
									
									
									local Text= win32.formatNumber(Change[ChangeKey[i]], false, 2) ;
									width, height = context:measureText (1, Text, context.CENTER  ); 
									---
								   if Change[ChangeKey[i]] > 0 then
									
									y1=P_Low-SizeOfOne; 
									y2= P_Low; 
								   
										 context:drawRectangle (11, 12, x1, y1, x2, y2, transparency);
										 
										 
										 width, height = context:measureText (1, Text, context.CENTER  ); 
									context:drawText (1,Text, Color, -1, left+i*x_cell+(x_cell/100)*Spacing  , y_central - height/2  -height1*2 + height,   left+i*x_cell + width+(x_cell/100)*Spacing,   y_central -height1*2  +height/2  + height, context.CENTER   );	
									
									
									else
									y1=N_High; 
									y2 = N_High+SizeOfOne; 
									 
										context:drawRectangle (21, 22, x1, y1, x2, y2, transparency);
										 width, height = context:measureText (1, Text, context.CENTER  ); 
										context:drawText (1,Text, Color, -1, left+i*x_cell+(x_cell/100)*Spacing  , y_central - height/2  + height1*3 -height,   left+i*x_cell + width+(x_cell/100)*Spacing,   y_central +  height1*3 +height/2  - height, context.CENTER   );	
										
									end
									
									
								
									
					
				 
									
								 
						
						end
						 
 
 
        else   
		
 
				   h_size= (right- left);
				   
		 
			 
				local y_cell = (bottom-top)/ (InstrumentCount+1);	

                local font_y_cell = y_cell - (y_cell/100)*Spacing*3				
			 
					local x_central = left+ (right-left)/ 2;
				   
				    if  Use_Base then 
					context:createFont (1, "Arial",math.max(Font_Size, font_y_cell),math.max(Font_Size, font_y_cell) , 0);--Size
					else
					context:createFont (1, "Arial",math.max(Font_Size, font_y_cell),math.max(Font_Size,font_y_cell) , 0);--Size
					end
					
				 
					local MaxSize=0;
					for i= 1, InstrumentCount,1 do 	
					
						if math.abs(Change[i]) > MaxSize then
						MaxSize=math.abs(Change[i]);
						end
					end
					
				 
						local Text;
					   for i= 1, InstrumentCount,1 do 	
				 
									y1= top+i*y_cell + (y_cell/100)*Spacing;
									y2=top+i*y_cell- (y_cell/100)*Spacing;
									
									 
									if Use_Base then
									Text= tostring(ShortList[ChangeKey[i]]);
									 else
									Text= tostring(InstrumentList[ChangeKey[i]]);
									end
									 
									
									width, height = context:measureText (1, Text, context.CENTER  ); 
									context:drawText (1,Text, Color, -1,  x_central -width/2 ,   top+i*y_cell -(y_cell/100)*Spacing ,   x_central +width/2, top+i*y_cell + height -(y_cell/100)*Spacing , context.CENTER   );	
									                                   --  x1, y1, x2, y2 
																	   
									width1=	width*1.2;							   
								    
									P_Low=  x_central -width/2;
									N_High=  x_central +width/2;
									
									SizeOfOne=(h_size/2 -width1)*(math.abs(Change[ChangeKey[i]] )/MaxSize);  
									
									
									local Text= win32.formatNumber(Change[ChangeKey[i]], false, 2) ;
									width, height = context:measureText (1, Text, context.CENTER  ); 
									
								  if Change[ChangeKey[i]] > 0 then
									
									  x1=P_Low-SizeOfOne; 
									  x2= P_Low; 
								   
										 context:drawRectangle (11, 12, x1, y1, x2, y2, transparency);
										 
										 
										 width, height = context:measureText (1, Text, context.LEFT  ); 
									context:drawText (1,Text, Color, -1,  x_central -width1/2 - width     ,   top+i*y_cell -(y_cell/100)*Spacing ,   x_central - width1/2    , top+i*y_cell + height -(y_cell/100)*Spacing, context.LEFT   );	
									
									
									else
									x1=N_High; 
									x2 = N_High+SizeOfOne; 
									 
										context:drawRectangle (21, 22, x1, y1, x2, y2, transparency);
										
										
										 
										 width, height = context:measureText (1, Text, context.LEFT  ); 
									 	context:drawText (1,Text, Color, -1, x_central +width1/2   ,   top+i*y_cell -(y_cell/100)*Spacing,   x_central +width1/2  + width , top+i*y_cell + height-(y_cell/100)*Spacing, context.CENTER   );	
										
									end
									
									 
						
						end 
		
		end

end	

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+