-- Id: 18681
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MTF MCP Heikin-Ashi Smoothed");
    indicator:description("MTF MCP Heikin-Ashi Smoothed");
     indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
  
    indicator.parameters:addGroup("Period");
	indicator.parameters:addString("Select" , "Tag Data", "", "EUR/USD");
    indicator.parameters:setFlag("Select", core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "All currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
 
	
	

	for i= 1 ,20, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");
	Add(i);
	end
	
	

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
 
	
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("UpColor", "Up Color", "Label Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownColor", "Down Color", "Label Color", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NeutralColor", "Neutral Color", "Neutral Color", core.rgb(0, 0,255));
	indicator.parameters:addColor("SelectColor", "Select Color", "Select Color", core.rgb(128, 128,128));
	 
	
	indicator.parameters:addBoolean("ShowCells", "Show Cells", "", false);	
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 70, 0, 100);
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70 , 0, 100);
 
	


end

function AddTimeFrame(id , FRAME , DEFAULT  )

    	indicator.parameters:addGroup(id.. "Time Frame");	
	indicator.parameters:addBoolean("Use"..id , "Show "..  FRAME  , "", DEFAULT); 
	
 
    indicator.parameters:addString("Method1"..id, "The smoothing method for prices", "The methods marked by the star (*) requires to have approriate indicators installed", "MVA");
    indicator.parameters:addStringAlternative("Method1"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1"..id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1"..id, "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method1"..id, "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1"..id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1"..id, "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1"..id, "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1"..id, "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1"..id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1"..id, "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1"..id, "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1"..id, "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1"..id, "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1"..id, "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1"..id, "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1"..id, "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1"..id, "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1"..id, "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1"..id, "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1"..id, "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1"..id, "JSmooth", "", "JSmooth");

    indicator.parameters:addInteger("N1"..id, "Periods to smooth prices", "", 6, 1, 1000);

    indicator.parameters:addString("Method2"..id, "The smoothing method for candles", "The methods marked by the star (*) requires to have approriate indicators installed", "MVA");
    indicator.parameters:addStringAlternative("Method2"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2"..id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2"..id, "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method2"..id, "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2"..id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2"..id, "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2"..id, "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2"..id, "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2"..id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2"..id, "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2"..id, "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2"..id, "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2"..id, "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2"..id, "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2"..id, "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2"..id, "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2"..id, "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2"..id, "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2"..id, "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2"..id, "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2"..id, "JSmooth", "", "JSmooth");

    indicator.parameters:addInteger("N2"..id, "Periods to smooth candles", "", 6, 1, 1000);

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
local UpColor,  DownColor, NeutralColor;
 
local Select;
local SelectColor;
local Method1={};
local Method2={};
local N1={};
local N2={};
local HA={};

-- Routine
function Prepare(nameOnly)
   
	Size= instance.parameters.Size;
	Mode= instance.parameters.Mode;  
	 
	Select= instance.parameters.Select;
    SelectColor= instance.parameters.SelectColor;
	Type= instance.parameters.Type; 
	ShowCells= instance.parameters.ShowCells;
	UpColor= instance.parameters.UpColor;
	DownColor= instance.parameters.DownColor;
	NeutralColor= instance.parameters.NeutralColor; 
	source = instance.source; 
	
	 local name = profile:id() .. "("  .. tostring(source:barSize())  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end 
	
	
	assert(core.indicators:findIndicator("HASM3") ~= nil, "Please, download and install HASM3.LUA indicator");
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 

	 
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

           Method1[Num]=instance.parameters:getString("Method1" .. i);	
           Method2[Num]=instance.parameters:getString("Method2" .. i);				   
		   N1[Num]=instance.parameters:getInteger("N1" .. i);	
           N2[Num]=instance.parameters:getInteger("N2" .. i);
		   end
	   end
 
	local ID=0;
	Color= instance.parameters.Color; 
	
	 
	  
	 for i = 1, Count, 1 do	
	 
	  Source[i] ={};
	  loading[i] ={};  
      HA[i]={};
     
      	  	  
		   for j = 1, Num, 1 do	
		    ID=ID+1;  
			
			Temp= core.indicators:create("HASM3", source, Method1[j], N1[j], Method2[j], N2[j], true   );
			first =  Temp.DATA:first()*2;  
		   Source[i][j]= core.host:execute("getSyncHistory", Pair[i], TF[j], source:isBid(),math.min(300,first),20000 + ID , 10000 +ID);
		   loading [i][j]=true;
		   
		   HA [i][j]= core.indicators:create(  "HASM3", Source[i][j], Method1[j], N1[j], Method2[j], N2[j], true );
		    		  
		   end
	 end 
	  

   
	 core.host:execute ("setTimer", 1, 5);
	  
	 instance:ownerDrawn(true); 
   
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
	
	 if cookie == 1 and FLAG== false then
	 
	 
         for i = 1, Count, 1 do
		   for j = 1, Num, 1 do
           HA[i][j]:update(core.UpdateLast);   
		   end
		end
    end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count*13 - Number) .. " / " ..  Count*13 );	 
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
		
	
		
		xGap=  (right-left)/(Count+1);	 
		yGap=  (bottom-top)/(Num+2);
				
 
		
			   
		
		
		for i= 1, Count,1 do 	
			for j= 1, Num,1 do 	
			 Calculate (context,i, j);
		 
			end
		end
 
end	

 function Calculate (context,i, j )
   
     
	 
     if  not   HA[i][j].DATA:hasData(HA[i][j].DATA:size()-1)
     or  not   HA[i][j].DATA:hasData(HA[i][j].DATA:size()-2)  
 
     then
     return;
     end
	 
     
	local Symbol="\243";
    local color=Neutral;	
	
	 if HA[i][j].close[HA[i][j].close:size()-1] >  HA[i][j].open[HA[i][j].open:size()-1] then
	   
		   if  HA[i][j].close[HA[i][j].close:size()-2] <  HA[i][j].open[HA[i][j].open:size()-2] then
		   Symbol="\200";
		   else
		   Symbol="\241";
		   end
	  color=UpColor;
	  elseif HA[i][j].close[HA[i][j].close:size()-1] <  HA[i][j].open[HA[i][j].open:size()-1]  then
	       if  HA[i][j].close[HA[i][j].close:size()-2] >  HA[i][j].open[HA[i][j].open:size()-2] then
		   Symbol="\202";
		   else
		   Symbol="\242";
		   end
		 color=DownColor;
	 else
	     Symbol="\243";
		  color=NeutralColor;
	  end
	  
	  

	
	     y1=bottom -j*yGap-yGap;
		y2=bottom -(j-1)*yGap-yGap;
		
		x1=left +(i-1)*xGap;
		x2=left +i*xGap;
		
		    iwidth =  ((xGap/8)/100)*Size ;
			iheight=  (yGap/100)*Size;
 
		
		context:createFont (7, "Arial",iwidth, iheight , context.ITALIC); 
		context:createFont (8, "Wingdings",iwidth, iheight , 0); 
		
		if j== 1 then 
		width, height = context:measureText (7, Pair[i], 0); 
		context:drawText (7,Pair[i], Color, -1, x1 , y2, x2, context:right(), 0 );	
		end
		
		
 	  
	    if i== Count then 
		width, height = context:measureText (7, TF[j], 0); 
		context:drawText (7,  TF[j], Color, -1, x2 , y1,context:right(),  y2, 0 );	
		end

		
	 
		if ShowCells then	 		
		context:drawRectangle( 1,  -1, x1, y1, x2, y2, transparency);				
		end
		
		if  Select == Pair[i] then
		context:drawRectangle( -1, 3 , x1, y1, x2, y2, transparency);	
		end 
		
		
		 width, height = context:measureText (8, Symbol , 0);  
		 context:drawText (8,  Symbol, color, -1, x1 +(x2-x1)/2-width/2, y1, x1+(x2-x1)/2 +width/2, y2, 0 );	
		
 
	  
 end
 
 