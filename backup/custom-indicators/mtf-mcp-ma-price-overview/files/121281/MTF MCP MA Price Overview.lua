-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66675

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MTF MCP MA Price Overview");
    indicator:description("MTF MCP MA Price Overview");
     indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period1" , "1. Period", "", 50);
    indicator.parameters:addInteger("Period2" , "1. Period", "", 100);
    indicator.parameters:addInteger("Period3" , "1. Period", "", 200);
	
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" ,  "All currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
 
	
	

	for i= 1 ,20, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");
	Add(i);
	end
	
	
	indicator.parameters:addGroup("Time Frame Selector");	
	AddTimeFrame (1 , "m1", false );
	AddTimeFrame (2 , "m5" , false );
	AddTimeFrame (3 , "m15", false );
	AddTimeFrame (4 , "m30" , false );
	AddTimeFrame (5 , "H1" , true );
	AddTimeFrame (6 , "H2", false );
	AddTimeFrame (7 , "H3" , false );
	AddTimeFrame (8 , "H4", false );
	AddTimeFrame (9 , "H6" , false  );
	AddTimeFrame (10 , "H8" , false );
    AddTimeFrame (11 , "D1", true );
	AddTimeFrame (12 , "W1" , true );
	AddTimeFrame (13 , "M1", true );
 
	
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","", core.rgb(0, 0, 255));
	
	
	indicator.parameters:addColor("CrossUp", "Up Trend Cross Color","", core.rgb(0, 255, 255));
	indicator.parameters:addColor("CrossDown", "Down Trend Cross Color","", core.rgb(255, 0, 255));
 
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70 , 0, 100);
 
	


end

function AddTimeFrame(id , FRAME , DEFAULT  )

 
	indicator.parameters:addBoolean("Use"..id , "Show "..  FRAME  , "", DEFAULT); 

end


function getInstrumentList()
    local list={};
	local point={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
		point[count] = row.PointSize;
        row = enum:next();
    end
	
	 
    return list, count,point;
end

 
function Add(id)

    local Init={"EUR/USD","USD/JPY", "GBP/USD","USD/CHF", "EUR/CHF"
	          , "AUD/USD","USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY"
			  , "GBP/JPY", "CHF/JPY","GBP/CHF", "EUR/AUD", "EUR/CAD"	
              , "AUD/CAD", "AUD/JPY","CAD/JPY", "NZD/JPY", "GBP/CAD"					  
			  };
	
    if id <= 15 then	
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
local Filter;
local Show; 
local iTF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}; 
local TF={};
local Period1,Period2, Period3; 
local pauto =  "(%a%a%a)/(%a%a%a)";
local Color;
local Source={};
local Size;
local transparency; 
local loading={}; 
local source;
local Pair={};
local  Count; 
local Type;  
local Dodaj={};   
local Point={};
local Use={};
local Num;
--local ShowCells;
local Up,  Down, Neutral;
local CrossUp, CrossDown; 
  
local Indicator1={};
local Indicator2={};
local Indicator3={};
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

   
	Size= instance.parameters.Size;
	Mode= instance.parameters.Mode;  
	Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3; 
	Type= instance.parameters.Type;  
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral; 
	CrossUp= instance.parameters.CrossUp;
	CrossDown= instance.parameters.CrossDown;
	source = instance.source; 
	 
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
				 
	elseif Type== "All currency pair" then 
	
	
	          Pair, Count,Point = getInstrumentList();
				 
	else

	           Pair[1]=source:instrument();
			   Point[1]=source:pipSize ();
			   Count=1;
	end
	
	Num=0;
		for i = 1 , 13 , 1 do  
	
		   Use[i]=instance.parameters:getBoolean("Use" .. i);
		   
		   if Use[i] then
			Num=Num+1;
			 
			TF[Num]=  iTF[i];	
			
		   end
	   end
 
	local ID=0;
	Color= instance.parameters.Color; 
	
	 
	  
	 for i = 1, Count, 1 do	
	 
	  Source[i] ={};
	  loading[i] ={};  
      Indicator1[i]={};
	  Indicator2[i]={};
	  Indicator3[i]={};
     
      	  	  
		   for j = 1, Num, 1 do	
		    ID=ID+1;  
			
			Temp1= core.indicators:create("MVA", source.close ,Period );
			Temp2= core.indicators:create("MVA", source.close ,Period );
			Temp3= core.indicators:create("MVA", source.close ,Period );
			first =  math.max(Temp1.DATA:first()+1 ,Temp2.DATA:first()+1 ,Temp3.DATA:first()+1)*2 ; 
		   Source[i][j]= core.host:execute("getSyncHistory", Pair[i], TF[j], source:isBid(),math.min(300,first ),20000 + ID , 10000 +ID);
		   loading [i][j]=true;
		   
		   Indicator1 [i][j]= core.indicators:create("MVA", Source[i][j].close, Period1);
		   Indicator2 [i][j]= core.indicators:create("MVA", Source[i][j].close, Period2);
		   Indicator3 [i][j]= core.indicators:create("MVA", Source[i][j].close, Period3);
		    		  
		   end
	 end 
	  

     
	 
	 instance:ownerDrawn(true); 
	 
	 core.host:execute ("setTimer", 1, 5);
   
end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i ;
 local ID=0;
 
		 for i = 1, Count, 1 do	
		     for j = 1, Num, 1 do	
			  ID=ID+1;
			  if cookie == ( 10000 +  ID) then
			  loading[i][j] = true;
		      elseif  cookie == (20000+ ID) then
			  loading[i][j] = false;  
			  end
			  
		       end
          end

	
	
    local FLAG=false; 
	local Number=0;
	
	for i = 1, Count, 1 do
		 for j = 1, Num, 1 do

                 if loading [i][j] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end
    end
	
	if cookie == 1 
	and FLAG== false 
	then
	     for i = 1, Count, 1 do
			 for j = 1, Num, 1 do
			 Indicator1[i][j]:update(core.UpdateLast);
			 Indicator2[i][j]:update(core.UpdateLast);
			 Indicator3[i][j]:update(core.UpdateLast);
			 end
		 end
		 
	end
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count*Num - Number) .. " / " ..  Count*Num );	 
	else
	core.host:execute ("setStatus", "Loaded") 
	 instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end

local top, bottom;
local left, right;
local xGap;	 
local yGap;




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
	    for j = 1, Num, 1 do 
		
		 
                 if loading [i][j] then
				 Loading= true; 
				 end
		end		 
    end
	
	
	 if Loading then
           return;
     end
	 
	 
	
        if not init then
		
		    context:createPen(1, context.SOLID, 1, Color); 
            context:createSolidBrush(2, Color);  
						
            init = true;
        end
		
	    
		
    	
		left, right = context:left(), context:right();
		
	
		
		xGap=  (right-left)/(Num+1);	 
		yGap=  (context:bottom()-context:top())/(Count+2);
		
		top=context:top()+yGap;
		bottom=context:bottom();
 
				
 
--		if xGap> 250 then
--		xGap= 250;
--		end
			   
		
		
		for i= 1, Count,1 do 	
			for j= 1, Num,1 do 	
			 Calculate (context,i, j);
		 
			end
		end
 
end	

 function Calculate (context,i, j )
 
 
        
   
        y1=bottom -(i+1)*yGap ;
		y2=bottom -(i )*yGap ;
		
		x1=left +(j-1)*xGap;
		x2=left +(j )*xGap;
		
		    iwidth = ((xGap/10)/100)*Size ;
			iheight=  (yGap/100)*Size;
		
			context:createFont (7, "Arial",iwidth , iheight  , context.ITALIC);
			context:createFont (9, "Arial",iwidth/3 , iheight/3  , context.ITALIC);
			
	   	if j== 1 then 
		width, height = context:measureText (7, Pair[i], context.CENTER  ); 
		context:drawText (7,Pair[i], Color, -1, x1 , y2, x2, context:right(), context.CENTER   );	
		end
		
		
 	  
	    if i== Count then 
		width, height = context:measureText (7, TF[j], 0); 
		context:drawText (7,  TF[j], Color, -1, x1+xGap , y1,x2+xGap,  y2, context.CENTER   );	
		end
	
		
		y1=bottom -(i+1)*yGap +yGap*1/3;
 
		
	 
     if  not   Indicator1[i][j].DATA:hasData(Indicator1[i][j].DATA:size()-1)
     or  not   Indicator1[i][j].DATA:hasData(Indicator1[i][j].DATA:size()-2)  
     or  not   Indicator2[i][j].DATA:hasData(Indicator2[i][j].DATA:size()-1)
     or  not   Indicator2[i][j].DATA:hasData(Indicator2[i][j].DATA:size()-2)  
	 or  not   Indicator3[i][j].DATA:hasData(Indicator3[i][j].DATA:size()-1)
     or  not   Indicator3[i][j].DATA:hasData(Indicator3[i][j].DATA:size()-2)  
     then
     return;
     end
	 
     
	local Symbol=nil;
    local SymbolColor=Neutral;	
	
 
		 
		  if Source[i][j].close[Source[i][j].close:size()-1] > Indicator1[i][j].DATA [Indicator1[i][j].DATA:size()-1]  then
		  Symbol1="\108"; 
		  SymbolColor1=Up;
		  if Source[i][j].close[Source[i][j].close:size()-2] <= Indicator1[i][j].DATA [Indicator1[i][j].DATA:size()-2] then
		  SymbolColor1=CrossUp;
		  end
		  elseif Source[i][j].close[Source[i][j].close:size()-1] < Indicator1[i][j].DATA [Indicator1[i][j].DATA:size()-1]  then
		  Symbol1="\108"; 
		  SymbolColor1=Down;
		  if Source[i][j].close[Source[i][j].close:size()-2] >= Indicator1[i][j].DATA [Indicator1[i][j].DATA:size()-2] then
		  SymbolColor1=CrossDown;
		  end
		  else
		  SymbolColor1=Neutral;
		  Symbol1="\108"; 
		  end
		   
		   
		   
	  
	 
          if Source[i][j].close[Source[i][j].close:size()-1] >  Indicator2[i][j].DATA [Indicator2[i][j].DATA:size()-1]   then
		  Symbol2="\108"; 
		  SymbolColor2=Up;
		  if Source[i][j].close[Source[i][j].close:size()-2] <=  Indicator2[i][j].DATA [Indicator2[i][j].DATA:size()-2]   then
		  SymbolColor2=CrossUp;
		  end
		  elseif Source[i][j].close[Source[i][j].close:size()-1] <  Indicator2[i][j].DATA [Indicator2[i][j].DATA:size()-1]   then
		  Symbol2="\108"; 
		  SymbolColor2=Down;
		  if Source[i][j].close[Source[i][j].close:size()-2] >=  Indicator2[i][j].DATA [Indicator2[i][j].DATA:size()-2]   then
		  SymbolColor2=CrossDown;
		  end
		  else
		  SymbolColor2=Neutral;
		  Symbol2="\108"; 
		  end
	
	      if Source[i][j].close[Source[i][j].close:size()-1] >   Indicator3[i][j].DATA [Indicator3[i][j].DATA:size()-1]  then
		  Symbol3="\108"; 
		  SymbolColor3=Up;
		  if Source[i][j].close[Source[i][j].close:size()-2] <=   Indicator3[i][j].DATA [Indicator3[i][j].DATA:size()-2]  then
		  SymbolColor3=CrossUp;
		  end
		  elseif Source[i][j].close[Source[i][j].close:size()-1] < Indicator3[i][j].DATA [Indicator3[i][j].DATA:size()-1] then
		  Symbol3="\108"; 
		  SymbolColor3=Down;
		  if Source[i][j].close[Source[i][j].close:size()-2] >=   Indicator3[i][j].DATA [Indicator3[i][j].DATA:size()-2]  then
		  SymbolColor3=CrossDown;
		  end
		  else
		  SymbolColor3=Neutral;
		  Symbol3="\108"; 
		  end
		  
		  
		  if  Indicator1[i][j].DATA [Indicator1[i][j].DATA:size()-1]  >   Indicator2[i][j].DATA [Indicator2[i][j].DATA:size()-1]  then
		  Symbol4="\108"; 
		  SymbolColor4=Up;
		  if  Indicator1[i][j].DATA [Indicator1[i][j].DATA:size()-2]  <=   Indicator2[i][j].DATA [Indicator2[i][j].DATA:size()-2]  then
		  SymbolColor4=CrossUp;
		  end
		  elseif  Indicator1[i][j].DATA [Indicator1[i][j].DATA:size()-1]  < Indicator2[i][j].DATA [Indicator2[i][j].DATA:size()-1] then
		  Symbol4="\108"; 
		  SymbolColor4=Down;
		  if  Indicator1[i][j].DATA [Indicator1[i][j].DATA:size()-2]  >=  Indicator2[i][j].DATA [Indicator2[i][j].DATA:size()-2]  then
		  SymbolColor4=CrossDown;
		  end
		  else
		  SymbolColor4=Neutral;
		  Symbol4="\108"; 
		  end
		  
		  
		  if  Indicator1[i][j].DATA [Indicator1[i][j].DATA:size()-1]  >   Indicator3[i][j].DATA [Indicator3[i][j].DATA:size()-1]  then
		  Symbol5="\108"; 
		  SymbolColor5=Up;
		  if  Indicator1[i][j].DATA [Indicator1[i][j].DATA:size()-2]  <=   Indicator3[i][j].DATA [Indicator3[i][j].DATA:size()-2]  then
		  SymbolColor5=CrossUp;
		  end
		  elseif  Indicator1[i][j].DATA [Indicator1[i][j].DATA:size()-1]  < Indicator3[i][j].DATA [Indicator3[i][j].DATA:size()-1] then
		  Symbol5="\108"; 
		  SymbolColor5=Down;
		  if  Indicator1[i][j].DATA [Indicator1[i][j].DATA:size()-2]  >=   Indicator3[i][j].DATA [Indicator3[i][j].DATA:size()-2]  then
		  SymbolColor5=CrossDown;
		  end
		  else
		  SymbolColor5=Neutral;
		  Symbol5="\108"; 
		  end
		  
		  
		  if  Indicator2[i][j].DATA [Indicator2[i][j].DATA:size()-1]  >   Indicator3[i][j].DATA [Indicator3[i][j].DATA:size()-1]  then
		  Symbol6="\108"; 
		  SymbolColor6=Up;
		  if  Indicator2[i][j].DATA [Indicator2[i][j].DATA:size()-2]  <=   Indicator3[i][j].DATA [Indicator3[i][j].DATA:size()-2]  then
		  SymbolColor6=CrossUp;
		  end
		  elseif  Indicator2[i][j].DATA [Indicator2[i][j].DATA:size()-1]  < Indicator3[i][j].DATA [Indicator3[i][j].DATA:size()-1] then
		  Symbol6="\108"; 
		  SymbolColor6=Down;
		  if  Indicator2[i][j].DATA [Indicator2[i][j].DATA:size()-2] >=   Indicator3[i][j].DATA [Indicator3[i][j].DATA:size()-2]  then
		  SymbolColor6=CrossDown;
		  end
		  else
		  SymbolColor6=Neutral;
		  Symbol6="\108"; 
		  end
 
		
	
        iwidth = ( xGap  /100)*Size ;		
		context:createFont (8, "Wingdings",iwidth/6, iheight , context.CENTER  ); 
		
 
 
		Index=1;
		
		y1=y1-yGap/3;
		
		if Symbol1~= nil then
		 width, height = context:measureText (8, Symbol1 , context.CENTER  );  
		  context:drawText (8,  Symbol1, SymbolColor1, -1, x1+xGap  +(Index-1)* width  , y1+yGap, x1+xGap +(Index)* width  , y1+yGap+ height, context.CENTER   );	
		  
	 
		end
		
		
		Index=2;
		
		if Symbol2~= nil then
		 width, height = context:measureText (8, Symbol2 , context.CENTER  );  
		  context:drawText (8,  Symbol2, SymbolColor2, -1, x1+xGap  +(Index-1)* width  , y1+yGap, x1+xGap +(Index)* width  , y1+yGap+ height, context.CENTER   );	
		 
		 
		end
		
		
		Index=3;
		
		if Symbol3~= nil then
		 width, height = context:measureText (8, Symbol3 , context.CENTER  );  
		  context:drawText (8,  Symbol3, SymbolColor3, -1, x1+xGap  +(Index-1)* width  , y1+yGap, x1+xGap +(Index)* width  , y1+yGap+ height, context.CENTER   );	
	 
		 
		end
 
 
 
         Index=4;
		
		if Symbol4~= nil then
		 width, height = context:measureText (8, Symbol4 , context.CENTER  );  
		  context:drawText (8,  Symbol4, SymbolColor4, -1, x1+xGap  +(Index-1)* width  , y1+yGap, x1+xGap +(Index)* width  , y1+yGap+ height, context.CENTER   );	
		  
	 
		end
		
		
		Index=5;
		
		if Symbol5~= nil then
		 width, height = context:measureText (8, Symbol5 , context.CENTER  );  
		  context:drawText (8,  Symbol5, SymbolColor5, -1, x1+xGap  +(Index-1)* width  , y1+yGap, x1+xGap +(Index)* width  , y1+yGap+ height, context.CENTER   );
  
		end
		
		
		Index=6;
		
		if Symbol6~= nil then
		 width, height = context:measureText (8, Symbol6 , context.CENTER  );  
		  context:drawText (8,  Symbol6, SymbolColor6, -1, x1+xGap  +(Index-1)* width  , y1+yGap, x1+xGap +(Index)* width  , y1+yGap+ height, context.CENTER   );	
		 
		end
		
		
 
	  
 end
 
 