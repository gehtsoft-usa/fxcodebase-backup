-- Id: 21618
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66232

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
function Init()
    indicator:name("StochRSI Currency Screen");
    indicator:description("StochRSI Currency Screen");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("N", "Number of periods for RSI", "", 8, 1, 200);
    indicator.parameters:addInteger("K", "%K Stochastic Periods", "", 5, 1, 200);
    indicator.parameters:addInteger("KS", "%K Slowing Periods", "", 3, 1, 200);
    indicator.parameters:addInteger("D", "%D Slowing Stochastic Periods", "", 3, 1, 200);
	
	 indicator.parameters:addDouble("OB", "OB Level", "",75 );	 
	  indicator.parameters:addDouble("OS", "OS Level", "", 25);
	
	
 
	
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
 
	
	

	for i= 1 ,20, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");
	Add(i);
	end
	
	
	indicator.parameters:addGroup("Time Frame Selector");	
	AddTimeFrame (1 , "m1", false );
	AddTimeFrame (2 , "m5" , false);
	AddTimeFrame (3 , "m15", false );
	AddTimeFrame (4 , "m30" , false  );
	AddTimeFrame (5 , "H1" , true );
	AddTimeFrame (6 , "H2", false );
	AddTimeFrame (7 , "H3" , false );
	AddTimeFrame (8 , "H4", true );
	AddTimeFrame (9 , "H6" , false  );
	AddTimeFrame (10 , "H8" , false );
    AddTimeFrame (11 , "D1", true );
	AddTimeFrame (12 , "W1" , true );
	AddTimeFrame (13 , "M1", false );
 
	
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","", core.rgb(128, 128, 128));
    
	indicator.parameters:addColor("OBC", "OB Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("OSC", "OS Color","", core.rgb(255, 0, 0));
	 
	 
	 indicator.parameters:addColor("OBCC", "OB Cross Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("OSCC", "OS Cross  Color","", core.rgb(0, 255, 0));
	
	indicator.parameters:addBoolean("ShowCells", "Show Cells", "", false);	
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 70, 0, 100);
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
	
    if id <= 5 then	
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
local Period; 
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
local ShowCells;
local Up,  Down, Neutral;
 
--local Select;
--local SelectColor;
  
local Indicator={};

local N, K, KS,D,OB,OS;

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
   
    N= instance.parameters.N;
	K= instance.parameters.K;
	KS= instance.parameters.KS;
	D= instance.parameters.D;
	
	assert(core.indicators:findIndicator("STOCHRSI") ~= nil, "Please, download and install STOCHRSI.LUA indicator");
	
	OB= instance.parameters.OB;
	OS= instance.parameters.OS;
   
	Size= instance.parameters.Size;
	Mode= instance.parameters.Mode; 
	--Select= instance.parameters.Select;
   -- SelectColor= instance.parameters.SelectColor;
	Type= instance.parameters.Type; 
	ShowCells= instance.parameters.ShowCells;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	
	OBC= instance.parameters.OBC;
	OSC= instance.parameters.OSC;
	
	OBCC= instance.parameters.OBCC;
	OSCC= instance.parameters.OSCC;
	
	Neutral= instance.parameters.Neutral; 
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
      Indicator[i]={};
     
      	  	  
		   for j = 1, Num, 1 do	
		    ID=ID+1;  
			
			Temp= core.indicators:create("STOCHRSI", source.close ,N, K, KS,D );
			first =  Temp.DATA:first()*2;  
		   Source[i][j]= core.host:execute("getSyncHistory", Pair[i], TF[j], source:isBid(),first,20000 + ID , 10000 +ID);
		   loading [i][j]=true;
		   
		   Indicator [i][j]= core.indicators:create("STOCHRSI", Source[i][j].close, N, K, KS,D);
		    		  
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
			 Indicator[i][j]:update(core.UpdateLast);
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
			 
           
            transparency = context:convertTransparency(instance.parameters.transparency);
						
            init = true;
        end
		
	    
		
    	
		left, right = context:left(), context:right();
		
	
		
		xGap=  (right-left)/(Num+1);	 
		yGap=  (context:bottom()-context:top())/(Count+2);
		
		top=context:top()+yGap;
		bottom=context:bottom();
 
				
 
		if xGap> 250 then
		xGap= 250;
		end
			   
		
		
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
		
		    iwidth = ((xGap/17)/100)*Size ;
			iheight=  (yGap/100)*Size;
			
			
	   context:createFont (7, "Arial",iwidth, iheight , context.ITALIC);
			
	   	if j== 1 then 
		width, height = context:measureText (7, Pair[i], context.CENTER  ); 
		context:drawText (7,Pair[i], Color, -1, x1 , y2, x2, context:right(), context.CENTER   );	
		end
		
		
 	  
	    if i== Count then 
		width, height = context:measureText (7, TF[j], 0); 
		context:drawText (7,  TF[j], Color, -1, x1+xGap , y1,x2+xGap,  y2, context.CENTER   );	
		end
		
	 
     if  not   Indicator[i][j].DATA:hasData(Indicator[i][j].DATA:size()-1)
     or  not   Indicator[i][j].DATA:hasData(Indicator[i][j].DATA:size()-2)  
 
     then
     return;
     end
	 
 
	
	local SymbolColor=Neutral;
    local Symbol="No Signal"; 
	 
	 
	 
 


		 
		  if Indicator[i][j].K [Indicator[i][j].K:size()-1] < OB
          and Indicator[i][j].D [Indicator[i][j].D:size()-1] < OB
		  and Indicator[i][j].D [Indicator[i][j].D:size()-1] > OS
		  and  Indicator[i][j].K [Indicator[i][j].K:size()-1] > OS
		  and Indicator[i][j].K [Indicator[i][j].K:size()-1] > Indicator[i][j].D [Indicator[i][j].D:size()-1]		  
		  then
		  Symbol="Bullish"; 
		  SymbolColor=Up;		  
		  end
		  
		  
		  if Indicator[i][j].K [Indicator[i][j].K:size()-1] < OB
          and Indicator[i][j].D [Indicator[i][j].D:size()-1] < OB
		  and Indicator[i][j].D [Indicator[i][j].D:size()-1] > OS
		  and  Indicator[i][j].K [Indicator[i][j].K:size()-1] > OS
		  and Indicator[i][j].K [Indicator[i][j].K:size()-1] < Indicator[i][j].D [Indicator[i][j].D:size()-1]		  
		  then
		  Symbol="Bearish"; 
		  SymbolColor=Down;		  
		  end
		  

		  
	      if Indicator[i][j].K [Indicator[i][j].K:size()-1] > OB
          and Indicator[i][j].D [Indicator[i][j].D:size()-1] > OB
		  and Indicator[i][j].K [Indicator[i][j].K:size()-1] > Indicator[i][j].D [Indicator[i][j].D:size()-1]		  
		  then
		  Symbol="Overbought"; 
		  SymbolColor=Down;		  
		  end
		  
	     
		  if Indicator[i][j].K [Indicator[i][j].K:size()-1] < OS
          and Indicator[i][j].D [Indicator[i][j].D:size()-1] < OS
		  and Indicator[i][j].K [Indicator[i][j].K:size()-1] < Indicator[i][j].D [Indicator[i][j].D:size()-1]		  
		  then
		  Symbol="Oversold"; 
		  SymbolColor=Up;		  
		  end
		  
		  
		     if   Indicator[i][j].D [Indicator[i][j].D:size()-1] > OB
		  and Indicator[i][j].K [Indicator[i][j].K:size()-1] < Indicator[i][j].D [Indicator[i][j].D:size()-1]		  
		  then
		  Symbol="Overbought Crossover"; 
		  SymbolColor=Down;		  
		  end
		  
	     
		  if  Indicator[i][j].D [Indicator[i][j].D:size()-1] < OS
		  and Indicator[i][j].K [Indicator[i][j].K:size()-1] > Indicator[i][j].D [Indicator[i][j].D:size()-1]		  
		  then
		  Symbol="Oversold Crossover"; 
		  SymbolColor=Up;		  
		  end

 
 
		
		
     
		
	
		
	 
		if ShowCells then	 		
		context:drawRectangle( 1,  -1, x1+xGap, y1+yGap, x2+xGap, y2+yGap, transparency);				
		end
		
	 
		
 
		 width, height = context:measureText (7, Symbol , context.CENTER  );  
		  context:drawText (7,  Symbol, SymbolColor, -1, x1+xGap , y1+yGap, x2+xGap  , y2+yGap, context.CENTER   );	
	 
 end
 
 