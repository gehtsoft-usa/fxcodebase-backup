-- Id: 23518
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67224

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("MTF MCP Two MA Cross");
    indicator:description("");
     indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period1" , "Period", "", 50);
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addInteger("Period2" , "Period", "", 200);
	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addBoolean("Specific", "Base Instrument Specific", "", true);
	
	local Instruments={"USD", "EUR", "JPY", "GBP", "AUD", "NZD", "SEK", "NOK"}; 
	
	
	indicator.parameters:addString("Instrument", "Base Instrument", "", Instruments[1]);
	for i= 1, 8, 1 do
    indicator.parameters:addStringAlternative("Instrument", Instruments[i], "", Instruments[i]);
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
	indicator.parameters:addColor("Up", "Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","", core.rgb(0, 0, 255));
	--indicator.parameters:addColor("SelectColor", "Select Color", "Select Color", core.rgb(128, 128,128));
	 
	
--	indicator.parameters:addBoolean("ShowCells", "Show Cells", "", false);	
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 70, 0, 100);
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70 , 0, 100);
 
	


end

function AddTimeFrame(id , FRAME , DEFAULT  )

 
	indicator.parameters:addBoolean("Use"..id , "Show "..  FRAME  , "", DEFAULT); 

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
 
local Num;
--local ShowCells;
local Up,  Down, Neutral;
 
local Select;
--local SelectColor;
  
local Indicator1={};
local Indicator2={};
local Method2
local Method1
local Period1
local Period2; 
local Instrument;

local patern = "(%a%a%a)/(%a%a%a)";

local Direction={};
local When={};
local Specific;

function getInstrumentList()
    local list={};
	local point={};
	local where={};
	
    local count = 0;	
    local row, enum;	
	local crncy1, crncy2;
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
	
	    
		crncy1, crncy2 = string.match(row.Instrument, patern)
		
		if crncy1== Instrument or  crncy2== Instrument then 
        count = count + 1;
        list[count] = row.Instrument;
		point[count] = row.PointSize;
		
		    if crncy1== Instrument then
			where[count]=1;
			else
			where[count]=2;
			end
		end
		
		
        row = enum:next();
    end
	
	 
    return list, count,point,where;
end


-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
    Method1= instance.parameters.Method1;
    Method2= instance.parameters.Method2;
	
    Specific= instance.parameters.Specific;
	Size= instance.parameters.Size;
	Mode= instance.parameters.Mode;  
	
	Select= instance.parameters.Select;
   -- SelectColor= instance.parameters.SelectColor;
	Type= instance.parameters.Type; 
	--ShowCells= instance.parameters.ShowCells;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral; 
	source = instance.source; 
    Instrument= instance.parameters.Instrument;	 
 
	
	          Pair, Count,Point,Where = getInstrumentList();
 
	 
	
	Num=0;
		for i = 1 , 13 , 1 do  
	
		 
		   
		   if instance.parameters:getBoolean("Use" .. i) then
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
      Direction[i]={};
      When[i]={};

      	  	  
		   for j = 1, Num, 1 do	
		    ID=ID+1;  
			
			Temp= core.indicators:create("MVA", source.close ,math.max(Period1,Period2) );
			first =  Temp.DATA:first()*2;  
		   Source[i][j]= core.host:execute("getSyncHistory", Pair[i], TF[j], source:isBid(),math.min(300,first*2),20000 + ID , 10000 +ID);
		   loading [i][j]=true;
		   
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
		   Indicator1[i][j]= core.indicators:create(Method1, Source[i][j].close, Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
		   Indicator2[i][j]= core.indicators:create(Method2, Source[i][j].close, Period2);
		    		  
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
			 
			 	
	 
			 Calculate (i, j);
		 
 
			 
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
			--context:createSolidBrush(3,SelectColor); 
           
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
			 DrawCalculate (context,i, j);
		 
			end
		end
 
end	

 function Calculate ( i, j )
   
   
     Direction[i][j]=0;
	 When[i][j]="";

 	 
	  local Return;
	 
	  local x=0;
	  while true do 
			  Return= Find(i,j,x)
			  x=x+1;
			  
			  if Return== 0 
			  or Direction[i][j]~=0
			  then 
			  break;
			  end
	  end
 
 end
 
 function Find(i,j,x)
 
 
    if not Indicator1[i][j].DATA:hasData(Indicator1[i][j].DATA:size()-1-x)
	or not Indicator1[i][j].DATA:hasData(Indicator1[i][j].DATA:size()-1-x-1)
	or not Indicator2[i][j].DATA:hasData(Indicator2[i][j].DATA:size()-1-x)
	or not Indicator2[i][j].DATA:hasData(Indicator2[i][j].DATA:size()-1-x-1)
	then
	return 0;
	end
   
	 if  Indicator1[i][j].DATA[Indicator1[i][j].DATA:size()-1-x]  > Indicator2[i][j].DATA[Indicator2[i][j].DATA:size()-1-x] 
	 and Indicator1[i][j].DATA[Indicator1[i][j].DATA:size()-1-x-1]  <= Indicator2[i][j].DATA[Indicator2[i][j].DATA:size()-1-x-1] 
	 then
	 Direction[i][j]=1;
     When[i][j]=x;	 
	 elseif  Indicator1[i][j].DATA[Indicator1[i][j].DATA:size()-1-x]  < Indicator2[i][j].DATA[Indicator2[i][j].DATA:size()-1-x]
	 and Indicator1[i][j].DATA[Indicator1[i][j].DATA:size()-1-x-1]  >= Indicator2[i][j].DATA[Indicator2[i][j].DATA:size()-1-x-1]
	 then
	 Direction[i][j]=-1;
	 When[i][j]=x;
	 end
	 
	 
	 if Where[i]== 2 and  Specific  and  Direction[i][j]==1 then	 
	 Direction[i][j]=-1;
	 elseif Where[i]== 2 and  Specific  and  Direction[i][j]==-1 then
	 Direction[i][j]=1;
	 end
	 
 
 
 end
 --Indicator
 
  function DrawCalculate (context, i, j )
   
        y1=bottom -(i+1)*yGap ;
		y2=bottom -(i )*yGap ;
		
		x1=left +(j-1)*xGap;
		x2=left +(j )*xGap;
		
		    iwidth = ((xGap/7)/100)*Size ;
			iheight=  (yGap/100)*Size;
			
	   	if j== 1 then 
		width, height = context:measureText (7, Pair[i], context.CENTER  ); 
		context:drawText (7,Pair[i], Color, -1, x1 , y2, x2, context:right(), context.CENTER   );	
		end
		
		
 	  
	    if i== Count then 
		width, height = context:measureText (7, TF[j], 0); 
		context:drawText (7,  TF[j], Color, -1, x1+xGap , y1,x2+xGap,  y2, context.CENTER   );	
		end
		
	 
 
	 
     
 
    local SymbolColor=Neutral;	
	
	    
		 
		  if Direction[i][j] == 1  then 
		  SymbolColor=Up;
		  elseif Direction[i][j] == -1  then 
		  SymbolColor=Down;
		  else
		  SymbolColor=Neutral; 
		  end
		   
	  
	 
 
	 
		
		if When[i][j]~= nil then
		 width, height = context:measureText (7, When[i][j] , context.CENTER  );  
		  context:drawText (7,  When[i][j], SymbolColor, -1, x1+xGap , y1+yGap, x2+xGap  , y2+yGap, context.CENTER   );	
		end
 
	  
 end
 
 