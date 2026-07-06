-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=63192

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
    indicator:name("MTF MCP Three Extreme TMA Alignment");
    indicator:description("MTF MCP Three Extreme TMA Alignment");
     indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
    indicator.parameters:addGroup("Calculation");
	--indicator.parameters:addInteger("Period" , "Period", "", 14);

	
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" ,  "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
 
	
	

	for i= 1 ,20, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");
	Add(i);
	end
	
	
	
	AddTimeFrame (1 , "m1", true, 5,10,20 );
	AddTimeFrame (2 , "m5" ,  true, 5,10,20 );
	AddTimeFrame (3 , "m15",  true, 5,10,20  );
	AddTimeFrame (4 , "m30" ,  true, 5,10,20   );
	AddTimeFrame (5 , "H1" , true, 5,10,20 );
	AddTimeFrame (6 , "H2",  true, 5,10,20 );
	AddTimeFrame (7 , "H3" ,  true, 5,10,20  );
	AddTimeFrame (8 , "H4", true, 5,10,20 );
	AddTimeFrame (9 , "H6" ,  true, 5,10,20   );
	AddTimeFrame (10 , "H8" , true, 5,10,20  );
    AddTimeFrame (11 , "D1", true, 5,10,20  );
	AddTimeFrame (12 , "W1" , true, 5,10,20  );
	AddTimeFrame (13 , "M1", true, 5,10,20 );
 
	
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","", core.rgb(0, 0, 255));  
 
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 70, 0, 100);
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70 , 0, 100);
 
	


end

function AddTimeFrame(id , FRAME , DEFAULT ,Period1,Period2,Period3 )


    indicator.parameters:addGroup(id..". Time Frame Selector");	
 
	indicator.parameters:addBoolean("Use"..id , "Show "..  FRAME  , "", DEFAULT); 
	
	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
    indicator.parameters:addInteger("Period1"..id, "1. Period", "", Period1);	
	indicator.parameters:addInteger("Period2"..id, "2. Period", "", Period2);
    indicator.parameters:addInteger("Period3"..id, "3. Period", "", Period3);
    indicator.parameters:addBoolean("Redraw"..id, "Redraw", "", true);  
	indicator.parameters:addDouble("TrendThreshold"..id, "Trend Threshold", "", 0.5);
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

local Indicator1={};  
local Indicator2={};
local Indicator3={};
local Period1={};
local Period2={};
local Period3={};
local Redraw={};
local TrendThreshold={};
-- Routine
function Prepare(nameOnly)
   
	Size= instance.parameters.Size;
	Mode= instance.parameters.Mode;  
	Period= instance.parameters.Period;
	Type= instance.parameters.Type; 
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
		
	    	Period1[Num]=  instance.parameters:getInteger ("Period1"..i);
	        Period2[Num]=  instance.parameters:getInteger ("Period2"..i);
			Period3[Num]=  instance.parameters:getInteger ("Period3"..i);
			Redraw[Num]=  instance.parameters:getBoolean ("Redraw"..i);
			TrendThreshold[Num]=  instance.parameters:getDouble ("TrendThreshold"..i);
		   end
	   end
	   
	  assert(core.indicators:findIndicator("EXTREME_TMA_LINE") ~= nil, "Please, download and install EXTREME_TMA_LINE.LUA indicator"); 
 
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
			
			Test1 =   core.indicators:create("EXTREME_TMA_LINE", source, Period1[j],Period1[j],2, TrendThreshold[j], true, TrendThreshold[j],Neutral,Up, Down);
			Test2 =   core.indicators:create("EXTREME_TMA_LINE", source, Period2[j], Period2[j],Period2[j],2, TrendThreshold[j], true, TrendThreshold[j],Neutral,Up, Down);
			Test3 =   core.indicators:create("EXTREME_TMA_LINE", source, Period3[j], Period3[j],Period3[j],2, TrendThreshold[j], true, TrendThreshold[j],Neutral,Up, Down);
			first =  math.max(Test1.DATA:first(), Test2.DATA:first(), Test3.DATA:first())*2;  
			
		   Source[i][j]= core.host:execute("getSyncHistory", Pair[i], TF[j], source:isBid(),math.min(300,first),20000 + ID , 10000 +ID);
		   loading [i][j]=true; 
		   Indicator1[i][j] =   core.indicators:create("EXTREME_TMA_LINE", Source[i][j], Period1[j],Period1[j],2, TrendThreshold[j], true, TrendThreshold[j],Neutral,Up, Down);
		   Indicator2[i][j] =   core.indicators:create("EXTREME_TMA_LINE", Source[i][j], Period2[j],Period2[j],2, TrendThreshold[j], true, TrendThreshold[j],Neutral,Up, Down);
		   Indicator3[i][j] =   core.indicators:create("EXTREME_TMA_LINE", Source[i][j], Period3[j],Period3[j],2, TrendThreshold[j], true, TrendThreshold[j],Neutral,Up, Down);
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
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count*Num - Number) .. " / " ..  Count*Num );	 
	else
	core.host:execute ("setStatus", "Loaded") 
	 instance:updateFrom(0);	
	end
	
	
	if not FLAG and cookie == 1 then
	
	 
	
	for i = 1, Count, 1 do 
	    for j = 1, Num, 1 do 
		
		
             
				 Indicator1[i][j]:update(core.UpdateLast);   
				 Indicator2[i][j]:update(core.UpdateLast);   
				 Indicator3[i][j]:update(core.UpdateLast);   
				 
		end		 
     end
	
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
 
 
 
                if not Indicator1[i][j].DATA:hasData( Indicator1[i][j].DATA:size()-1)
			   and not Indicator2[i][j].DATA:hasData(Indicator2[i][j].DATA:size()-1)
			   and not  Indicator3[i][j].DATA:hasData(Indicator3[i][j].DATA:size()-1)
			   then
			   return;
			   end
			   
   
        y1=bottom -(i)*yGap;		
		x1=left +(j-1)*xGap+xGap/2;
		 
		
		    iwidth = ((xGap/7)/100)*Size ;
			iheight=  (yGap/100)*Size;
			
			context:createFont (7, "Arial",iwidth, iheight , context.ITALIC);
			
	   	if j== 1 then 
		width, height = context:measureText (7, Pair[i], context.LEFT  ); 
		context:drawText (7,Pair[i], Color, -1, x1 -xGap/2, y1, x1+width-xGap/2,y1+height, context.LEFT   );	
		end
		
		
 	  
	    if i== Count then 
		width, height = context:measureText (7, TF[j], 0); 
		context:drawText (7,  TF[j], Color, -1, x1+xGap , y1-yGap,x1+xGap+width,  y1+height-yGap, context.CENTER   );	
		end
		

     
	local Style=nil;
    local SymbolColor=Neutral;	
	
	      	   if Indicator1[i][j].DATA:colorI(Indicator1[i][j].DATA:size()-1) == Up
			   and  Indicator2[i][j].DATA:colorI(Indicator2[i][j].DATA:size()-1) == Up
			   and  Indicator3[i][j].DATA:colorI(Indicator3[i][j].DATA:size()-1) == Up
			   then
										
											
											SymbolColor = Up;
											Style= "\225";
				 elseif Indicator1[i][j].DATA:colorI(Indicator1[i][j].DATA:size()-1) == Down
			     and  Indicator2[i][j].DATA:colorI(Indicator2[i][j].DATA:size()-1) == Down
			     and  Indicator3[i][j].DATA:colorI(Indicator3[i][j].DATA:size()-1) == Down
				 then
											  SymbolColor = Down;									
												Style= "\226";	
												
						 else				
                                              Style= "\158";							 
											 SymbolColor = Neutral;
						 end 			
 
	
		context:createFont (8, "Wingdings",iwidth, iheight , context.CENTER  ); 
		if Style~= nil then
		 width, height = context:measureText (8, Style , context.CENTER  );  
		  context:drawText (8,  Style, SymbolColor, -1, x1+xGap , y1, x1+xGap+width  , y1+height, context.CENTER   );	
		end
 
	  
 end
 
 