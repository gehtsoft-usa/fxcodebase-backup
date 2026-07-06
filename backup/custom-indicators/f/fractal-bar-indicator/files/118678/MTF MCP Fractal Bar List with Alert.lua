-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61341
-- Id: 20998

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
    indicator:name("MTF MCP Fractal Bar List");
    indicator:description("MTF MCP Fractal Bar List");
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
	indicator.parameters:addColor("NeutralColor", "Neutral Trend Color","", core.rgb(0, 0, 255));
	indicator.parameters:addColor("SelectColor", "Select Color", "Select Color", core.rgb(128, 128,128));
    indicator.parameters:addColor("AlertColor", "Alert Color", "Alert Color", core.rgb(0, 0,255)); 
	
	indicator.parameters:addBoolean("ShowCells", "Show Cells", "", false);	
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 70, 0, 100);
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70 , 0, 100);
	
	  indicator.parameters:addGroup("Alert");
	indicator.parameters:addInteger("CoolDown", "Cool down period (in seconds)","", 10);
	
	indicator.parameters:addString("ExecutionType", "Execution Type", "Execution Type" , "EndOfTurn"); 
    indicator.parameters:addStringAlternative("ExecutionType", "EndOfTurn", "EndOfTurn" , "EndOfTurn");
	indicator.parameters:addStringAlternative("ExecutionType", "Live", "Liver" , "Live");
	
	 
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
 
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	indicator.parameters:addFile("Sound",   "Alert Sound", "", "");
    indicator.parameters:setFlag("Sound", core.FLAG_SOUND);
	
	indicator.parameters:addGroup("Alerts Dialog box");  
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
 
    
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

local CoolDown;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local LastSerial={};
local AlertColor;
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
  
local Indicator={};
local AlertOn=false;

local LastTime={};
local LastSignal={};

local Last;

local Email;
local SendEmail; 
local Sound;
local  RecurrentSound;
local Show;
local ShowAlert;
local PlaySound;

local ExecutionType;

-- Routine
function Prepare(nameOnly)
    
	source = instance.source; 
		
    local name = profile:id() .. "("  .. tostring(source:barSize())  .. ")";
    instance:name(name);
	
	if nameOnly then
		return
	end
	
	
    ExecutionType = instance.parameters.ExecutionType;	
	SendEmail = instance.parameters.SendEmail;
	 
	if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	
 
	
	RecurrentSound= instance.parameters.RecurrentSound;
    Show= instance.parameters.Show; 
	ShowAlert= instance.parameters.ShowAlert;
	PlaySound = instance.parameters.PlaySound;
	
    if PlaySound then 
	  Sound=instance.parameters.Sound; 
    else  
      Sound=nil;
	 end
	  
	  assert(not(PlaySound) or (PlaySound and Sound ~= "") or (PlaySound and Sound ~= ""), "Sound file must be chosen"); 
	 
	 
	 

    CoolDown= instance.parameters.CoolDown;
	AlertColor= instance.parameters.AlertColor;
	
	Size= instance.parameters.Size;
	--Mode= instance.parameters.Mode;  
	 
	Select= instance.parameters.Select;
    SelectColor= instance.parameters.SelectColor;
	Type= instance.parameters.Type; 
	ShowCells= instance.parameters.ShowCells;
	UpColor= instance.parameters.UpColor;
	DownColor= instance.parameters.DownColor;
	NeutralColor= instance.parameters.NeutralColor; 

	 
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
	
	 	assert(core.indicators:findIndicator("FRACTAL BAR INDICATOR") ~= nil, "Please, download and install FRACTAL BAR INDICATOR.LUA indicator");
	  
	 for i = 1, Count, 1 do	
	 
	  Source[i] ={};
	  loading[i] ={};  
      Indicator[i]={};
	  LastTime[i]={};
      LastSignal[i]={};
      LastSerial[i]={};
      	  	  
		   for j = 1, Num, 1 do	
		    ID=ID+1;  
			
			LastTime[i][j]=0;
            LastSignal[i][j]=0;
			LastSerial[i][j]=0;
			
			Temp= core.indicators:create("FRACTAL BAR INDICATOR", source , UpColor,DownColor,NeutralColor, true );
			first =  Temp.DATA:first()*2;  
		   Source[i][j]= core.host:execute("getSyncHistory", Pair[i], TF[j], source:isBid(),first+1,20000 + ID , 10000 +ID);
		   loading [i][j]=true;
		   
		   Indicator [i][j]= core.indicators:create("FRACTAL BAR INDICATOR", Source[i][j], UpColor,DownColor,NeutralColor, true);
		    		  
		   end
	 end 
	  


	
	 AlertOn=false;
	 Last=nil;
	 
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

if period< source:size()-1 then
return;
end


	
	 local Loading=false; 
 
	
	for i = 1, Count, 1 do 
	    for j = 1, Num, 1 do 
		
		Indicator[i][j]:update(core.UpdateLast);   
                 if loading [i][j] then
				 Loading= true; 
				 end
		end		 
    end
	
	
	 if Loading then
           return;
     end
	 

	
	AlertOn=true;
	
	
	local AlertShift;
	
	if ExecutionType== "Live" then
	AlertShift=0;
	else
	AlertShift=1;
	end
	
	
	--local MyTime =  core.host:execute("getServerTime");-- source:date(source:size())-1;
	
	--local MyTime =  core.host:execute("getServerTime");-- source:date(source:size())-1;

	for i = 1, Count, 1 do 
	    for j = 1, Num, 1 do 
		
		          if LastTime[i][j]  ==0 then
				  
				        
				        
				         LastTime[i][j]=Source[i][j]:date(Source[i][j]:size()-1)+CoolDown*(1/86400);
				         
				  else
				  
				           
            
						  if Indicator[i][j].DATA:colorI(Indicator[i][j].DATA:size()-1-AlertShift) ==  UpColor
						  and  Indicator[i][j].DATA:colorI(Indicator[i][j].DATA:size()-2-AlertShift) ~=  UpColor
						  and Source[i][j]:serial(Source[i][j]:size()-1-AlertShift)~= LastSerial[i][j]
						  and Source[i][j]:date(Source[i][j]:size()-1) > LastTime[i][j] 
						  then
						  
						    LastSerial[i][j]= Source[i][j]:serial(Source[i][j]:size()-1-AlertShift);						   
							 
							LastTime[i][j]=Source[i][j]:date(Source[i][j]:size()-1)+CoolDown*(1/86400);
							
							 GiveAlert("Up Trend",i,j);
							
						  elseif Indicator[i][j].DATA:colorI(Indicator[i][j].DATA:size()-1-AlertShift) ==  DownColor
						 and  Indicator[i][j].DATA:colorI(Indicator[i][j].DATA:size()-2-AlertShift) ~=  DownColor
						  and  Source[i][j]:date(Source[i][j]:size()-1) > LastTime[i][j] 
						   and Source[i][j]:serial(Source[i][j]:size()-1-AlertShift)~= LastSerial[i][j]
						  then
						  
						    LastSerial[i][j]= Source[i][j]:serial(Source[i][j]:size()-1-AlertShift);
							
						    GiveAlert("Down Trend",i,j); 
						    
							LastTime[i][j]=Source[i][j]:date(Source[i][j]:size()-1)+CoolDown*(1/86400);
						
						  end
						end
				
				end
     end
		
		  

           
	 
end

function GiveAlert(Label,i,j)


   if not ShowAlert then
   return;
   end
   
    
	SoundAlert();
	Pop(Label,  i,j   ); 
	EmailAlert(  Label,  i,j   );
	
end



function EmailAlert( label, i,j )

if not SendEmail then
return
end
 
   
	local DATA = core.dateToTable (core.now());
    local delim = "\013\010";    
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .. delim .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;
    local text = " Instrument : " .. Pair[i]..  delim .. " Time Frame : " .. TF[j].. delim ..  Time.. delim  .. "Alert" .. " : " ..label;
	
    terminal:alertEmail(Email, profile:id(), text);
end

 

function Pop(label , i,j )

   if not Show then
   return;
   end
   
    local DATA = core.dateToTable (core.now());
    local delim = "\013\010";    
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .. delim .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;
    local text = " Instrument : " .. Pair[i]..  delim .. " Time Frame : " .. TF[j].. delim ..  Time.. delim  .. "Alert" .. " : " ..label;

   core.host:execute ("prompt", 1,  profile:id(),   text );


end

function SoundAlert( )
 if not PlaySound then
 return;
 end
 

  terminal:alertSound( Sound, RecurrentSound);
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
			context:createPen(11, context.SOLID, 2, AlertColor); 
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
	
	      if Indicator[i][j].DATA:colorI(Indicator[i][j].DATA:size()-1) ==  UpColor then
		  Symbol="\225"; 
		  elseif Indicator[i][j].DATA:colorI(Indicator[i][j].DATA:size()-1) ==  DownColor then
		  Symbol="\226"; 
		  else
		  Symbol="\167"; 
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
		
		if  Select == Pair[i] then
		context:drawRectangle( -1, 3 , x1+xGap, y1+yGap, x2+xGap, y2+yGap, transparency);	
		end 
		
		if core.host:execute("getServerTime") < LastTime[i][j] and AlertOn then
		context:drawRectangle( 11, -1 , x1+xGap, y1+yGap, x2+xGap, y2+yGap, transparency);	
		end
		
		if Symbol~= nil then
		 width, height = context:measureText (8, Symbol , context.CENTER  );  
		  context:drawText (8,  Symbol, color, -1, x1+xGap , y1+yGap, x2+xGap  , y2+yGap, context.CENTER   );	
		end
 
	  
 end
 
 