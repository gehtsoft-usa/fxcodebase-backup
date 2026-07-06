-- Id: 16624

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63853

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
    indicator:name("MTF MCP MA Alert");
    indicator:description("MTF MCP MA Alert");
     indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
    indicator.parameters:addGroup("Calculation");

	
	indicator.parameters:addString("Price1", "MA Price Source", "", "close");
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
	
	indicator.parameters:addInteger("Period" , "Period", "", 14);

	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
 
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
	indicator.parameters:addColor("UpColor", "Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownColor", "Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","", core.rgb(0, 0, 255));
 	
	
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 70, 0, 100);
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70 , 0, 100);
	
	
	indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
 
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

  Parameters (1, "Alert");	
	 
end

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local	Number = 1;
local Up={};
local Down={};
local Label={};
local ON={};
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
local Alert;
local PlaySound;
--local Live;
--local FIRST=true;
--local OnlyOnce;
local U={};
local D={};
--local OnlyOnceFlag;
local font;
local ShowAlert;
--local Shift=0; 

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
local UpColor,  DownColor, Neutral;
local Indicator={};
local Method, Period, Price1, Price2;
local SignalArray={};
local SignalCount={};
local Last={};
local LastFlag={};
local CandleSize;
-- Routine
function Prepare(nameOnly) 

    --OnlyOnceFlag=true;
	--FIRST=true;
	--OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	--Live = instance.parameters.Live;
   
	Size= instance.parameters.Size;
	Mode= instance.parameters.Mode;  
	Period= instance.parameters.Period;
	Method	= instance.parameters.Method;
	Price1 = instance.parameters.Price1;
	Price2 = instance.parameters.Price2;
	 
	Type= instance.parameters.Type; 
 
	UpColor= instance.parameters.UpColor;
	DownColor= instance.parameters.DownColor;
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
	
	
	 s1, e1 = core.getcandle(TF[1], core.now(), 0, 0);
	 CandleSize=e1-s1;
	  
	 for i = 1, Count, 1 do	
	 
	  Source[i] ={};
	  loading[i] ={};  
      Indicator[i]={};
      SignalArray[i]={};
      Last[i]= core.now()+60/86400;	  	  
		   for j = 1, Num, 1 do	
		    ID=ID+1;  
			
		
		   Source[i][j]= core.host:execute("getSyncHistory", Pair[i], TF[j], source:isBid(),math.max(300,Period*2),20000 + ID , 10000 +ID);
		   loading [i][j]=true;
		   
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		   Indicator [i][j]= core.indicators:create(Method, Source[i][j][Price1], Period);
		    		  
		   end
	 end 
	  

   
	
	 
	 instance:ownerDrawn(true); 
   
   
    Initialization();
	
	core.host:execute ("setTimer", 1, 1);
		 
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 



function  Initialization ()
    
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label[i]=instance.parameters:getString("Label" .. i);
	  ON[i]=instance.parameters:getBoolean("ON" .. i);
	 end
	 
	 
	 

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	
	
	 PlaySound = instance.parameters.PlaySound;
    if PlaySound then
    
	  for i = 1, Number , 1 do 
	  Up[i]=instance.parameters:getString("Up" .. i);
	  Down[i]=instance.parameters:getString("Down" .. i);
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Up[i]=nil;
	  Down[i]=nil;
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen"); 
	 assert(not(PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	 
	end
		 
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
	
	if cookie== 1 and not FLAG then
			for i = 1, Count, 1 do 
			for j = 1, Num, 1 do 
			
			Indicator[i][j]:update(core.UpdateLast);  
			end
			end
		
			for i= 1, Count,1 do 	
		    SignalCount[i]=0;
			for j= 1, Num,1 do 	
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
		
		    context:createPen(1, context.SOLID, 1, UpColor); 
            context:createSolidBrush(2, UpColor);
			
			context:createPen(3, context.SOLID, 1, DownColor); 
            context:createSolidBrush(4, DownColor);
 
           
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
			   
		
		
	
   
   local Active;
   
   for i= 1, Count,1 do 	
   Active=false;
   
            if (SignalCount[i]== Num	
			or SignalCount[i]== -Num)	
			and Last[i]< core.now() 
			then
			Last[i]= core.now() +CandleSize;
            Active=true;			
			end
			
			
			
			for j= 1, Num,1 do 	
             DrawCell (context,i, j, Active);
	         end
	end
end	


 function DrawCell (context,i, j , Active)
 
 
         y1=bottom -(i+1)*yGap-yGap/2;
		y2=bottom -(i )*yGap-yGap/2; 
		
		x1=left +(j-1)*xGap;
		x2=left +(j )*xGap;
		
		    iwidth = ((xGap/7)/100)*Size ;
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
		
 
     
 
    local SymbolColor=Neutral;	
	
	    
		 
		  if SignalArray[i][j]==1   then
		  Symbol="\225"; 
		  SymbolColor=UpColor;				 
		  elseif SignalArray[i][j]==-1  then
		  Symbol="\226"; 
		  SymbolColor=DownColor;				  
		  else
		  SymbolColor=Neutral;
		  Symbol="\167"; 
		  end
	
		
        iwidth = ( xGap  /100)*Size ;		
		context:createFont (8, "Wingdings",iwidth, iheight , context.CENTER  ); 
		
	    if SignalCount[i]== Num	
		and Active
		then	
		          if j== 1 then
				  Activate (i, 1);
				  end
		context:drawRectangle( 1,  2, x1+xGap, y1+yGap, x2+xGap, y2+yGap, transparency);				
		elseif SignalCount[i]== -Num
        and Active 		
		then	
		         if j== 1 then
				   Activate (i, -1);
				   end
		context:drawRectangle( 3,  4, x1+xGap, y1+yGap, x2+xGap, y2+yGap, transparency);				
        end		
		
 
		if Symbol~= nil then
		 width, height = context:measureText (8, Symbol , context.CENTER  );  
		  context:drawText (8,  Symbol, SymbolColor, -1, x1+xGap , y1+yGap, x2+xGap  , y2+yGap, context.CENTER   );	
		end
 
 
 end
 
 
 function Activate (i, AlertFlag)

   
	 if not ON[1]  then
	 return;
	 end
	 
	 
	  
	       
			if AlertFlag == 1 
			and LastFlag[i]~=1
			then
			            
			LastFlag[i]=1;
			 
							  
							
							  SoundAlert(Up[1]);
							  EmailAlert(  Label[1], " Up Trend ", i);
							  SendAlert( Label[1], " Up Trend ", i);  
							   Pop(Label[1], " Up Trend ", i );  	
								    
								 
							 
			elseif AlertFlag == -1 
			and LastFlag[i]~=-1
            then	     			 
			             	   
			 LastFlag[i]=-1;			   
		     
							 SoundAlert(Down[1]);			 
							 EmailAlert( Label[1] , " Down Trend ", i);
							 Pop(Label[1], " Down Trend ",i );  	
							 SendAlert(Label[1] , " Down Trend ", i);
							 		   
	         end
			
	  
	 
	 
end

 function Calculate (i, j )
 
	 
     if  not   Indicator[i][j].DATA:hasData(Indicator[i][j].DATA:size()-1)
     then
     return;
     end
 
 
		 
		  if Source[i][j][Price2][ Source[i][j][Price2]:size()-1] > Indicator[i][j].DATA [Indicator[i][j].DATA:size()-1]   then
		  SignalArray[i][j]=1;
		  SignalCount[i]=SignalCount[i]+1;
		  elseif Source[i][j][Price2][ Source[i][j][Price2]:size()-1] < Indicator[i][j].DATA [Indicator[i][j].DATA:size()-1]then
		  SignalArray[i][j]=-1;
		  SignalCount[i]=SignalCount[i]-1;
		  else
		  SignalArray[i][j]=0;		   
		  end
 
	  
 end
 
 
 
function Pop(label , note, i)
  
   if not Show then
   return;
   end
   
  
  core.host:execute ("prompt", 1, label ,   " ( " .. Pair[i] .. " ) "  ..   label .. " : " .. note );
  

end


function SendAlert(label , Subject, i)
    if not ShowAlert then
        return;
    end
	
	
	local DATA = core.dateToTable (core.now ());
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. Pair[i] ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
     
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;    
    local text = Note  .. delim ..  Symbol   .. delim .. Time;
 
    terminal:alertMessage(source:instrument(), source[NOW], text, source:date(NOW));
end

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

 
  terminal:alertSound(Sound, RecurrentSound);
end

 


function EmailAlert( label , Subject, i)

if not SendEmail then
return
end
 
 
 
	local DATA = core.dateToTable (core.now ());
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. Pair[i] ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
     
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;    
    local text = Note  .. delim ..  Symbol   .. delim .. Time;
	 
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 


 
 