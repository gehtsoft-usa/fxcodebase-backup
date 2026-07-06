-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61339

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
    indicator:name("MTF MCP Heikin Ashi");
    indicator:description("MTF MCP Heikin Ashi");
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
	
	
	indicator.parameters:addGroup("Time Frame Selector");	
	AddTimeFrame (1 , "m1", false );
	AddTimeFrame (2 , "m5" , false  );
	AddTimeFrame (3 , "m15", false  );
	AddTimeFrame (4 , "m30" , false   );
	AddTimeFrame (5 , "H1" , true );
	AddTimeFrame (6 , "H2", false  );
	AddTimeFrame (7 , "H3" , false  );
	AddTimeFrame (8 , "H4", false  );
	AddTimeFrame (9 , "H6" ,false   );
	AddTimeFrame (10 , "H8" , false  );
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
      HA[i]={};
     
      	  	  
		   for j = 1, Num, 1 do	
		    ID=ID+1;  
			
			Temp= core.indicators:create("HA", source  );
			first =  Temp.DATA:first();  
		   Source[i][j]= core.host:execute("getSyncHistory", Pair[i], TF[j], source:isBid(),math.min(300,first*2),20000 + ID , 10000 +ID);
		   loading [i][j]=true;
		   
		   HA [i][j]= core.indicators:create("HA", Source[i][j]);
		    		  
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
	
	if cookie==1 and not FLAG then
	
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
		
		    iwidth = ((xGap/10)/100)*Size ;
			iheight=  (yGap/100)*Size;
 
		
		context:createFont (7, "Arial",iwidth, iheight , context.ITALIC); 
		context:createFont (8, "Wingdings",iwidth*2, iheight , 0); 
		
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
 
 