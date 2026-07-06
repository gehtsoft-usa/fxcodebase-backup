-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63054

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
    indicator:name("MCP Correlation Dashboard");
    indicator:description("MCP Correlation Dashboard");
     indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
    indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("Period" , "Correlation Period", "", 14);
	
	local TF={"Chart","m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}
	
	indicator.parameters:addString("TF", "Timeframe", "", "Chart"); 
    for i = 1, 14, 1 do
	indicator.parameters:addStringAlternative("TF", TF[i], "", TF[i]);
    end
	
	
	indicator.parameters:addString("Type", "Y Currency pair Selector", "Currency pair Selector" , "Selected currency pair");
	indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Selected currency pair", "Selected currency pair" , "Selected currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair (first 20 from list)", "All currency pair" , "All currency pair");
 
	
    indicator.parameters:addGroup( "Selector ");
	for i= 1 ,20, 1 do	 
	CurrencySelector(i);
	end
  
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","", core.rgb(0, 0, 255));
	 
	
	indicator.parameters:addBoolean("ShowCells", "Show Cells", "", false);	
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 70, 0, 100);
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 50 , 0, 100);
 
	
   

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
		if count== 20 then
		break;
		end
    end
	
	 
    return list, count,point;
end

 
function CurrencySelector(id)

    local Init={"EUR/USD","USD/JPY", "GBP/USD","USD/CHF", "EUR/CHF"
	          , "AUD/USD","USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY"
			  , "GBP/JPY", "CHF/JPY","GBP/CHF", "EUR/AUD", "EUR/CAD"	
              , "AUD/CAD", "AUD/JPY","CAD/JPY", "NZD/JPY", "GBP/CAD"					  
			  };
	
     
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", true);	
     
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
local loading={};
local Period; 
local pauto =  "(%a%a%a)/(%a%a%a)";
local Color;

local Size;
local transparency; 
local source;

local  Count; 
local Type;  
local Num;
local ShowCells;
local Up,  Down, Neutral;
--X
local Dodaj={};   
local Point={};
local Use={};
local Pair={};

local TF;

local CountX; 
local Source={};
 

 
-- Routine
function Prepare(nameOnly)

     
    TF= instance.parameters.TF;
	Size= instance.parameters.Size;
	Mode= instance.parameters.Mode;  
	Period= instance.parameters.Period;
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
	 
	if Type== "Selected currency pair" or Type== "Chart"  then 
	
	Count=0;
				 for i= 1, 20 , 1 do	 
					 Dodaj[i]=instance.parameters:getBoolean("Dodaj" .. i);
					 if Dodaj[i] then					
					 Count=Count+1;
					 CountX=Count;
					 Pair[Count]=   instance.parameters:getString ("Pair"..i);	
					 Point[Count]= core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize;
					 end
				   
				 end
				 
	elseif Type== "All currency pair" then 
	
	
	          Pair, Count,Point = getInstrumentList(); 
              CountX=Count;
  
	    
	end
	 
	if Type== "Chart"	 then
    CountX=1;
	end
	
	
	if TF== "Chart" then
	TF=source:barSize();
	end
	
	local ID=0;
	Color= instance.parameters.Color; 
	  
	 for i = 1, Count, 1 do	
	                
            Source[i]= core.host:execute("getSyncHistory", Pair[i], TF, source:isBid(),Period*2 +1 ,200 +i , 100+i); 
	   		loading[i]= true;   
	 end 
	  
    Source[Count+1]= core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(),Period*2 +1 ,200 +Count+1 , 100+Count+1); 
	loading[Count+1]= true;
	
    
	
	 
	 instance:ownerDrawn(true); 
   
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
 
 
   local Loading= false;
	
	for i = 1, Count+1, 1 do 
		
 		if loading[i] then
		 Loading= true;
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
		
	
		
		xGap=  (right-left)/(Count+1);	 
		yGap=  (context:bottom()-context:top())/(CountX+2);
		
		top=context:top()+yGap;
		bottom=context:bottom();
 
				
 
		if xGap> 250 then
		xGap= 250;
		end
		
		
		for i= 1, CountX,1 do 	
			for j= 1, Count,1 do 	
			 Calculate (context,i, j);		 
			end
		end
 
end	

 function Calculate (context,i, j )
 
      
   
        y1=bottom -(i+1)*yGap;
		y2=bottom -(i )*yGap;
		
		x1=left +(j-1)*xGap;
		x2=left +(j )*xGap;
		
		    iwidth = ((xGap/7)/100)*Size ;
			iheight=  (yGap/100)*Size;
			
			 context:createFont (3, "Arial",iwidth, iheight , 0);	
		 
	   	if j== 1 and Type ~= "Chart" then 
		width, height = context:measureText (3, Pair[i], 0  ); 
		context:drawText (3,Pair[i], Color, -1, x1 , y2, x2, context:right(), context.CENTER   );	
		end
		
		
 	  
	    if i== CountX 		
		then 
		width, height = context:measureText (3, Pair[j], 0); 
		context:drawText (3,  Pair[j], Color, -1, x1+xGap , y1,x2+xGap,  y2, context.CENTER   );	
		end
		
	 
     if  not   Source[i].close:hasData(Source[i].close:size()-1)
     or  not   Source[j].close:hasData(Source[j].close:size()-1) 
     then
     return;
     end
	 
     
	local Symbol1=nil;
    local SymbolColor=Neutral;	
	local Value1;
	
	      if Type== "Chart" then
		   Value1= mathex.correl (Source[Count+1].close,Source[j].close, Source[Count+1].close:size()-1-Period+1,  Source[Count+1].close:size()-1,Source[j].close:size()-1-Period+1,  Source[j].close:size()-1); 
		  else
		  Value1= mathex.correl (Source[i].close, Source[j].close,Source[i].close:size()-1-Period+1,  Source[i].close:size()-1,Source[j].close:size()-1-Period+1,  Source[j].close:size()-1);  
		  end
		  
		  Symbol1=win32.formatNumber(Value1, false, 1);
		  
		 
		 
		  if Value1 > 0 then		 
		  SymbolColor=Up;
		  elseif Value1 < 0 then
		  SymbolColor=Down;
		  else
		  SymbolColor=Neutral;
		  end
		   
	   
	 
		if ShowCells then	 		
		context:drawRectangle( 1,  -1, x1+xGap, y1+yGap, x2+xGap, y2+yGap, transparency);				
		end
				
		mid = x1+(x2-x1)/2+xGap;
		if Symbol1~= nil then
		 width, height = context:measureText (3, Symbol1 , 0  );  
		  context:drawText (3,  Symbol1, SymbolColor, -1, mid -width  , y1+yGap, mid   , y1+yGap+height, context.LEFT  );	
		end
  
 end
 
 function AsyncOperationFinished(cookie)


 local i ;
 
 
		 for i = 1, Count+1, 1 do	
		     
			 
 
					  if cookie ==  100+i then
					  loading[i] = true;
					  elseif  cookie ==  200+i then
					  loading[i]= false;   
					  end
			  	  
		 
		       
          end
 
	
    local FLAG=false; 
	local Number=0;
	
	for i = 1, Count+1, 1 do
		 
      
                 if loading[i] then
				 FLAG= true;
				 Number=Number+1;
				 end
				 
		 
           
    end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count+1) - Number) .. " / " ..  (Count+1) );	 
	else
	core.host:execute ("setStatus", "Loaded")
	instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end
  