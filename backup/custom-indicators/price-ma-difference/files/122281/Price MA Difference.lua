-- Id: 22883
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66954

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
    indicator:name("Price MA Difference");
    indicator:description("Price MA Difference");
     indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
  
    indicator.parameters:addGroup("Period");	 

 
	
    indicator.parameters:addString("Mode", "Calculation Mode", "Calculation Mode" , "Pip"); 
    indicator.parameters:addStringAlternative("Mode", "Pip", "Pip" , "Pip");
	indicator.parameters:addStringAlternative("Mode", "Percentage", "Percentage" , "Percentage");
	
	
	
	
	indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addString("Price2", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");	

	
	indicator.parameters:addInteger("Period", "MA Period", "Period" , 50);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	local iTF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}; 
	 indicator.parameters:addString("SortBy", "Sort By", "", "D1");
     for i= 1, 13, 1 do
	  indicator.parameters:addStringAlternative("SortBy", iTF[i], iTF[i] , iTF[i]);
	 end
	 
	 
	  indicator.parameters:addString("Select" , "Tag Data", "", "EUR/USD");
      indicator.parameters:setFlag("Select", core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" ,"Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
 
	
	
	indicator.parameters:addBoolean("Show", "Show Values", "", true);	
	for i= 1 ,20, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");
	Add(i);
	end
	
	
	indicator.parameters:addGroup("Time Frame Selector");	
	AddTimeFrame (1 , "m1", false );
	AddTimeFrame (2 , "m5" , false );
	AddTimeFrame (3 , "m15", false );
	AddTimeFrame (4 , "m30" , false  );
	AddTimeFrame (5 , "H1" , true );
	AddTimeFrame (6 , "H2", false );
	AddTimeFrame (7 , "H3" , false );
	AddTimeFrame (8 , "H4", false );
	AddTimeFrame (9 , "H6" , false  );
	AddTimeFrame (10 , "H8" , true );
    AddTimeFrame (11 , "D1", true );
	AddTimeFrame (12 , "W1" , true );
	AddTimeFrame (13 , "M1", true );
 
	
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("UpColor", "Up Color", "Label Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownColor", "Down Color", "Label Color", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NeutralColor", "Neutral Color", "Neutral Color", core.rgb(0, 0,255));
	indicator.parameters:addColor("SelectColor", "Select Color", "Select Color", core.rgb(128, 128,128));
	 
	
	indicator.parameters:addBoolean("ShowCells", "Show Cells", "", true);	
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 70, 0, 100);
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 90 , 0, 100);
 
	


end

function AddTimeFrame(id , FRAME , DEFAULT  )

    
 
	indicator.parameters:addBoolean("Use"..id , "Show "..  FRAME  , "", DEFAULT); 
  --  indicator.parameters:addInteger("Period"..id, "Period", "Period",0);
	
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
local Method;
local Price1;
local Price2;
local MA={};

local Mode;
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
local Max={};
local Min={};
local Value={};
local Point={};
local Use={};
local Num;
local ShowCells;
local UpColor,  DownColor, NeutralColor;
local SortBy;
local Select;
local SelectColor;
local Sorted={} ;
local Index;
function Sort ()
 
	
    local Flag= true;
	
	
	for i= 1, Count, 1 do
	   for j= 1, Num+1, 1 do
	   Sorted[i][j]=Value[i][j];
	   end
	end
	
	
	if Index == nil then
	return  ;
	end
	
	local Temp;
	local SortFlag=true;
	
	     while SortFlag do
		 
		       SortFlag=false;
		   
			   for j= 2, Count, 1 do
					
					if Sorted[j-1][Index]<  Sorted[j][Index] then
							SortFlag=true;
							
							for k= 1, Num+1, 1 do
							Temp=Sorted[j-1][k];
							Sorted[j-1][k]= Sorted[j][k];
							Sorted[j][k]= Temp;
							end
						  Flag= false;
					end
					
			   end
		   
		   if Flag then 
		   break;
		   end
		   
		end  

return;
end
-- Routine
function Prepare(nameOnly)  
    Show= instance.parameters.Show;
	Size=  instance.parameters.Size/100;
	Mode= instance.parameters.Mode;  
	SortBy= instance.parameters.SortBy;
	Select= instance.parameters.Select;
    SelectColor= instance.parameters.SelectColor;
	Type= instance.parameters.Type; 
	ShowCells= instance.parameters.ShowCells;
	UpColor= instance.parameters.UpColor;
	DownColor= instance.parameters.DownColor;
	NeutralColor= instance.parameters.NeutralColor; 
	source = instance.source;
	Index=nil;
	
	
	local name = profile:id() .. "("  .. tostring(source:barSize())  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	Method=   instance.parameters.Method;
	Period=   instance.parameters.Period;
	Price1=   instance.parameters.Price1;
	Price2=   instance.parameters.Price;
	 
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
 
      Value[i]={};
	  MA[i]={};
	  Sorted[i]={};
	  Value[i][Num+1]=Pair[i];
      	  	  
		   for j = 1, Num, 1 do	
		    ID=ID+1;  
		   Source[i][j]= core.host:execute("getSyncHistory", Pair[i], TF[j], source:isBid(), math.min(300 , Period),20000 + ID , 10000 +ID);
		   loading [i][j]=true;
		   
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		   MA[i][j]= core.indicators:create(Method, Source[i][j][Price1], Period);
		   
		     if SortBy == TF[j]  then
			 Index= j;
			 end
		  
		   end
	 end 
	 
	 
	 

    
	 
	 instance:ownerDrawn(true); 
    core.host:execute ("setTimer", 1, 1);
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
	
	
	if not FLAG and cookie== 1 then
	
	    Max={};
		Min={};
		
		for i= 1, Count,1 do 

        
		
         Initialize ( i ); 			 
		end	
		
		 Sort();		   
		
		
		end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count*13 - Number) .. " / " ..  Count*13 );	 
	else
	core.host:execute ("setStatus", "Loaded")
	--core.host:execute ("setStatus", tostring(Index))
	
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
		
	
		
		xGap=  (right-left)/(Count+1);	 
		yGap=  (bottom-top)/(Num+2);
				
	  
		
		for i= 1, Count,1 do 	
			for j= 1, Num,1 do 	
			ReCalculate (context,i, j );
			end
		end
 
end	

function Coloring (value )



local color;
if value> 0 then
color= UpColor;
elseif value< 0 then
color= DownColor;
else 
color= NeutralColor;
end


return  color;



end

 


function ReCalculate (context,i, j)

 
   
        y1=bottom -j*yGap-yGap;
		y2=bottom -(j-1)*yGap-yGap;
		
		x1=left +(i-1)*xGap;
		x2=left +i*xGap;
		
		    iwidth = ( math.abs(x2-x1)/10)*Size ;
			iheight=  math.abs(y2-y1)*Size;
		 
		
		context:createFont (7, "Arial",iwidth, iheight , context.ITALIC); 
		
		if Sorted[i][Num+1]== nil then
		return;
		end
		
		if j== 1 then 
		width, height = context:measureText (7, Sorted[i][Num+1], 0); 
		context:drawText (7,Sorted[i][Num+1], Color, -1, x1 , y2, x2, context:right(), 0 );	
		end
		
		
 	  
	    if i== Count then 
		width, height = context:measureText (7, TF[j], 0); 
		
		context:drawText (7,  TF[j], Color, -1, x2 , y1,context:right(),  y2, 0 );	
		end

		
		local color;
		
		if  Sorted  [i][j] ~= nil
		then
		
			if Filter == "TimeFrame" then 	    
			k= j;
			elseif Filter == "CurrencyPair" then 	    
			k= i; 
			else
			k= 1;
			end
		

		color =  Coloring (Sorted  [i][j] );
		
	 
		if ShowCells then	 		
		context:drawRectangle( 1,  -1, x1, y1, x2, y2, transparency);				
		end
		
		if  Select == Sorted[i][Num+1] then
		context:drawRectangle( -1, 3 , x1, y1, x2, y2, transparency);	
		end 
		
			if Show then
			
			 
			 
			width, height = context:measureText (7, string.format("%." .. 2 .. "f", Sorted  [i][j]), context.ITALIC);  
				context:drawText (7,  string.format("%." .. 2 .. "f", Sorted  [i][j]), color, -1, x1, y2-height, x1+width, y2, 0 );	
				 
			end
        end
end

function Initialize ( i )

		
	

       for j= 1, Num, 1 do 
         
		  Calculate (i, j);
	   end
 
	    
 end
 
 
 function Calculate (i, j )
 
 
     MA[i][j]:update(core.UpdateLast );
      
     if  not   MA[i][j].DATA:hasData(MA[i][j].DATA:size()-1)
     or not MA[i][j].DATA:hasData(MA[i][j].DATA:size()-2)
     then
     return;
     end
	 
     if Mode== "Pip" then
	            Value [i][j]= (Source[i][j].close[Source[i][j].close:size()-1]  - MA[i][j].DATA[MA[i][j].DATA:size()-1 ]  )/Point[i];
				
	   elseif Mode== "Percentage" then
	            Value  [i][j]= (Source[i][j].close[Source[i][j].close:size()-1]  - MA[i][j].DATA[MA[i][j].DATA:size()-1 ]  )/ (Source[i][j].close[Source[i][j].close:size()-1]/100);			
				
	  end
	  
	     
	  
 end