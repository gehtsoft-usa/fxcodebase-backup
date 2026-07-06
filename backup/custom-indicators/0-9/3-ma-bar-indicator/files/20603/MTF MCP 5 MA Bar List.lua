-- Id: 13757

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9634

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
    indicator:name("MTF MCP 5 MA Bar List");
    indicator:description("MTF MCP 5 MA Bar List");
     indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
  
    indicator.parameters:addGroup("Period");	
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "All currency pair");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
 
	
	

	for i= 1 ,20, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");
	Add(i);
	end
	
	
	indicator.parameters:addGroup("Time Frame Selector");	
	AddTimeFrame (1 , "m1", true );
	AddTimeFrame (2 , "m5" , true );
	AddTimeFrame (3 , "m15", true );
	AddTimeFrame (4 , "m30" , true  );
	AddTimeFrame (5 , "H1" , true );
	AddTimeFrame (6 , "H2", true );
	AddTimeFrame (7 , "H3" , true );
	AddTimeFrame (8 , "H4", true );
	AddTimeFrame (9 , "H6" , true  );
	AddTimeFrame (10 , "H8" , true );
    AddTimeFrame (11 , "D1", true );
	AddTimeFrame (12 , "W1" , true );
	AddTimeFrame (13 , "M1", true );
	
	

 

	
    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addBoolean("O1", "Use 1. Indicator", "", true);
	indicator.parameters:addBoolean("O2", "Use 2. Indicator", "", true);
	indicator.parameters:addBoolean("O3", "Use 3. Indicator", "", true);
	indicator.parameters:addBoolean("O4", "Use 4. Indicator", "", true);
	indicator.parameters:addBoolean("O5", "Use 5. Indicator", "", true);
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
 
 
    indicator.parameters:addInteger("P1", "1. Period", "1. Period", 34);
    indicator.parameters:addInteger("P2", "2. Period", "2. Period", 68);
    indicator.parameters:addInteger("P3", "3. Period", "3. Period", 102);
    indicator.parameters:addInteger("P4", "4. Period", "4. Period", 136);
	indicator.parameters:addInteger("P5", "5. Period", "5. Period", 200);
	
	indicator.parameters:addString("MAType", "Smoothing type", "", "EMA");
    indicator.parameters:addStringAlternative("MAType", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MAType", "EMA", "EMA", "EMA");
	indicator.parameters:addStringAlternative("MAType" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MAType" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MAType" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MAType" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MAType" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MAType" , "WMA", "", "WMA");	
 
	
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","", core.rgb(0, 0, 255));
	indicator.parameters:addColor("SelectColor", "Select Color", "Select Color", core.rgb(128, 128,128));
	 
	
	indicator.parameters:addBoolean("ShowCells", "Show Cells", "", false);	
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 70, 0, 100);
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 50 , 0, 100);
 
	


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
local Period={}; 
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
 
local Select;
local SelectColor;
local Price, MAType, O1, O2,O3, O4,O5, P1,P2,P3,P4,P5;  
local Indicator={};

-- Routine
function Prepare(nameOnly)


     Price= instance.parameters.Price;
	 MAType= instance.parameters.MAType;
	 O1= instance.parameters.O1;
	 O2= instance.parameters.O2;
	 O3= instance.parameters.O3;
	 O4= instance.parameters.O4;
	 O5= instance.parameters.O5;
	 P1= instance.parameters.P1;
	 P2= instance.parameters.P2;
	 P3= instance.parameters.P3;
	 P4= instance.parameters.P4;
	 P5= instance.parameters.P5;
	 
   
	Size= instance.parameters.Size;
	Mode= instance.parameters.Mode;  
	 
	
    SelectColor= instance.parameters.SelectColor;
	Type= instance.parameters.Type; 
	ShowCells= instance.parameters.ShowCells;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral; 
	source = instance.source; 
	
	local name = profile:id() .. "("  .. tostring(source:barSize())  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
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
			
    assert(core.indicators:findIndicator("3 MA BAR") ~= nil, "3 MA BAR" .. " indicator must be installed");
			Temp= core.indicators:create("3 MA BAR", source.close , O1, O2, O3,O4,O5, P1, P2, P3,P4,P5,MAType, Up, Down, Neutral );
			first =  Temp.DATA:first()*2;  
		   Source[i][j]= core.host:execute("getSyncHistory", Pair[i], TF[j], source:isBid(),math.min(first+1, 300),20000 + ID , 10000 +ID);
		   loading [i][j]=true;
		   
		   Indicator[i][j] = core.indicators:create("3 MA BAR", Source[i][j][Price], O1, O2, O3,O4,O5, P1, P2, P3,P4,P5,MAType, Up, Down, Neutral);
		    		  
		   end
	 end 
	  

    
	
	 
	 instance:ownerDrawn(true); 
    core.host:execute ("setTimer", 1, 1);
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
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
	
	
	if cookie == 1 and 	not FLAG  then
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
			context:createSolidBrush(3,SelectColor); 
           
            transparency = context:convertTransparency(instance.parameters.transparency);
						
            init = true;
        end
		
	    
		
    	top, bottom = context:top(), context:bottom();
		left, right = context:left(), context:right();
		
	
		
		xGap=  (right-left)/(Num+1);	 
		yGap=  (bottom-top)/(Count+1);
				
						
		for i= 1, Count,1 do 	
			for j= 1, Num,1 do 	
			 Calculate (context,i, j);
		 
			end
		end
 
end	

 function Calculate (context,i, j )
   
     
	 
     if  not   Indicator[i][j].DATA:hasData(Indicator[i][j].DATA:size()-1)
     or  not   Indicator[i][j].DATA:hasData(Indicator[i][j].DATA:size()-2)  
 
     then
     return;
     end
	 
     
	local Symbol=nil;
    local color=Neutral;	
	 
		  
		if Indicator[i][j].DATA:colorI(Indicator[i][j].DATA:size()-1) == Up then            
		Symbol="\233"; 
        elseif Indicator[i][j].DATA:colorI(Indicator[i][j].DATA:size()-1) == Down then
        Symbol="\234"; 		
        else
        Symbol="\160"; 
        end
		
		   
	  
		  color=Indicator[i][j].DATA:colorI(Indicator[i][j].DATA:size()-1); 

	
	     y1=bottom -(i+1)*yGap;
		y2=bottom -(i )*yGap;
		
		x1=left +(j-1)*xGap;
		x2=left +(j )*xGap;
		
		    iwidth = ((xGap/7)/100)*Size ;
			iheight=  (yGap/100)*Size;
 
		
		context:createFont (7, "Arial",iwidth, iheight , context.ITALIC);
        iwidth = ( xGap  /100)*Size ;		
		context:createFont (8, "Wingdings",iwidth, iheight , context.CENTER  ); 
		
		if j== 1 then 
		width, height = context:measureText (7, Pair[i], context.CENTER  ); 
		context:drawText (7,Pair[i], Color, -1, x1 , y2, x2, context:right(), context.CENTER   );	
		end
		
		
 	  
	    if i== Count then 
		width, height = context:measureText (7, TF[j], 0); 
		context:drawText (7,  TF[j], Color, -1, x1+xGap , y1,x2+xGap,  y2, context.CENTER   );	
		end

		
	 
		if ShowCells then	 		
		context:drawRectangle( 1,  -1, x1+xGap, y1+yGap, x2+xGap, y2+yGap, transparency);				
		end
		
			
		if Symbol~= nil then
		 width, height = context:measureText (8, Symbol , context.CENTER  );  
		  context:drawText (8,  Symbol, color, -1, x1+xGap , y1+yGap, x2+xGap  , y2+yGap, context.CENTER   );	
		end
 
	  
 end
 
 