-- Id: 13705
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61959

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MTF MCP SSD DASHBOARD");
    indicator:description("MTF MCP SSD DASHBOARD");
     indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
  
    indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
 
	
	indicator.parameters:addString("Component", "Component", "Component" , "K");
    indicator.parameters:addStringAlternative("Component", "K", "K" , "K");
    indicator.parameters:addStringAlternative("Component", "D", "D" , "D");
	
	
	indicator.parameters:addDouble("OB", "%K periods","", 80);
	indicator.parameters:addDouble("OS", "%K periods","", 20);
	
	indicator.parameters:addString("Live", "Live/End Of Turn", "Live/End Of Turn" , "Live");
    indicator.parameters:addStringAlternative("Live", "Live", "Live" , "Live");
    indicator.parameters:addStringAlternative("Live", "End Of Turn", "End Of Turn" , "End Of Turn");
	
	indicator.parameters:addInteger("K", "%K periods","", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods","", 3, 2, 1000);
    indicator.parameters:addInteger("D", "%D periods","", 3, 2, 1000);

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
 
	
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "OB Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "OS Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(0, 0, 255));

    indicator.parameters:addDouble("minusX", "Vertical spacing", "", 10 , 0, 50);
	indicator.parameters:addDouble("minusY", "Horizontal spacing", "", 10 , 0, 50);
 
 
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70 , 0, 100);
 
 
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addFile("Sound",   "Alert Sound", "", "");
    indicator.parameters:setFlag("Sound", core.FLAG_SOUND);
	
	
	indicator.parameters:addGroup("Alerts Dialog box");  	
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", false);
	 indicator.parameters:addBoolean("ShowAlert", "Show Log", "", true);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
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

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Filter;
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
local Up,  Down,Neutral ;
local minusX, minusY;  
local Indicator={};
local Live;
local Sound;
local  RecurrentSound ,SoundFile  ;
local Show;
local PlaySound;
local Alert=nil; 
local Def;
local ShowAlert;
 
local Email;
local SendEmail; 
local K, SD,D;
local Component;
local OB,OS;
local Status={};
-- Routine
function Prepare(nameOnly)
    OB= instance.parameters.OB;
	OS= instance.parameters.OS;
    Color= instance.parameters.Color; 
	Size= instance.parameters.Size;
	Mode= instance.parameters.Mode;    
	Type= instance.parameters.Type;  
	Up= instance.parameters.Up;
	Down= instance.parameters.Down; 
	Neutral= instance.parameters.Neutral;
	Live= instance.parameters.Live;
	K= instance.parameters.K;
	SD= instance.parameters.SD;
	D= instance.parameters.D;
	Component= instance.parameters.Component;
	minusX= (instance.parameters.minusX/100);
	minusY= (instance.parameters.minusY/100);
	source = instance.source; 
    local name = profile:id() .. "("  .. tostring(source:barSize())  .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	 
	ShowAlert= instance.parameters.ShowAlert;
	
	 SendEmail = instance.parameters.SendEmail;
	 
	if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	 
	RecurrentSound= instance.parameters.RecurrentSound;
    Show= instance.parameters.Show; 
	PlaySound = instance.parameters.PlaySound;
	
    if PlaySound then 
	  Sound=instance.parameters.Sound; 
    else  
      Sound=nil;
	 end
 
 
	  assert(not(PlaySound) or (PlaySound and Sound ~= "") or (PlaySound and Sound ~= ""), "Sound file must be chosen"); 
	
	 
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
	
	 for i = 1, Count, 1 do	
	 
	  Source[i] ={};
	  loading[i] ={};  
      Indicator[i]={};
	  Status[i]={};
      	  	  
		   for j = 1, Num, 1 do	 
		   
		    ID=ID+1;  
			Temp= core.indicators:create("SSD", source, K, SD, D  );
			first =  Temp.DATA:first()*2;  
		   Source[i][j]= core.host:execute("getSyncHistory", Pair[i], TF[j], source:isBid(),math.min(300,first),20000 + ID , 10000 +ID);
		   loading [i][j]=true;
		   
		   Indicator [i][j]= core.indicators:create("SSD", Source[i][j], K, SD, D );
		    		  
		   end
	 end 
	  

	
	 
	 instance:ownerDrawn(true); 
	 
	  core.host:execute ("setTimer", 1, 5);
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
	
	
	if not FLAG and cookie== 1 then
		for i= 1, Count,1 do 	
			for j= 1, Num,1 do 

             Decode(i,j); 		
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
function Update(period,mode) 

   local Loading=false; 
 
	
	for i = 1, Count, 1 do 
	    for j = 1, Num, 1 do 
		
	   
	  
	
                 if loading [i][j] then
				 Loading= true; 
				 else
				   Indicator[i][j]:update(mode );				 
				 end
		end		 
    end
	
	 
	 
end


local init = false;
 
function Draw(stage, context)
    if stage~= 2 then
	 return;
	end
	
	 
	
	 local Loading=false; 
 
	
	for i = 1, Count, 1 do 
	    for j = 1, Num, 1 do 
		
	---	Indicator[i][j]:update(core.UpdateLast);   
	  ---  Indicator[i][j]:update(core.UpdateAll );
	
                 if loading [i][j] then
				 Loading= true; 
				 end
		end		 
    end
	
	
	 if Loading then
           return;
     end
	 
	 
	
        if not init then
	
			
			 context:createPen(11, context.SOLID, 1, Up); 
            context:createSolidBrush(12, Up);
			
			 context:createPen(21, context.SOLID, 1, Down); 
            context:createSolidBrush(22, Down);
		 		 			
            init = true;
        end
		
	    
		
    	top, bottom = context:top(), context:bottom();
		left, right = context:left(), context:right();
		
	
		
		xGap=  (right-left)/(Num+1);	 
		yGap=  (bottom-top)/(Count+1);
				
 
		if xGap> 250 then
		xGap= 250;
		end
			   
		
		
		for i= 1, Count,1 do 	
			for j= 1, Num,1 do 

            -- Decode(i,j); 			
			 Calculate (context,i, j);
		 
			end
		end
 
end	

function Decode(i,j)

         local Shift=0;
		 if Live~="Live" then
		 Shift=1;
		 end
		 
		 
		 
		 if Status[i][j] == nil then
		 
		    	 if Indicator[i][j][Component][Indicator[i][j][Component]:size()-1-Shift] > OB				 
				 then         
					 
					 Status[i][j] = 1;
				 
				 elseif Indicator[i][j][Component][Indicator[i][j][Component]:size()-1-Shift] < OS			
				 then
					  
					 Status[i][j]=-1;
				 
				 else
					  Status[i][j]=0;
				 end
				 
		 else
		 
				 if Indicator[i][j][Component][Indicator[i][j][Component]:size()-1-Shift] > OB
				 and Status[i][j] ~= 1
				 then          
				 
					 
					 GiveAlert(" OB CrossOver ", i,j);
					 
					 
					 Status[i][j] = 1;
				 
				 elseif Indicator[i][j][Component][Indicator[i][j][Component]:size()-1-Shift] < OS				
				 and Status[i][j] ~= -1
				 then
					 
					 GiveAlert(" OS CrossUnder ", i,j);
					  
					 Status[i][j]=-1;
				 
				 elseif  Indicator[i][j][Component][Indicator[i][j][Component]:size()-1-Shift] >  OS	
                 and Indicator[i][j][Component][Indicator[i][j][Component]:size()-1-Shift] <  OB
                 then				 
						 if  Status[i][j] == -1
						 then 
							  
							 GiveAlert( " OS CrossOver ", i,j); 
							 
							  Status[i][j]=0;
							 
						 elseif  Status[i][j] == 1						 
						 then 
							 
							 GiveAlert( " OB CrossUnder ", i,j); 
							  
							  Status[i][j]=0;
				           end
				end		   
		 	end	 
end

 function Calculate (context,i, j )
   
   
    if Status[i][j]== nil then
	return;
	end
     
	 
     if  not   Indicator[i][j][Component]:hasData(Indicator[i][j][Component]:size()-1)
     or  not   Indicator[i][j][Component]:hasData(Indicator[i][j][Component]:size()-2)  
 
     then
     return;
     end
	 
	
	     y1=bottom -(i+1)*yGap;
		y2=bottom -(i )*yGap;
		y0=y1 +yGap*3/2;
		
		x1=right -(j+1)*xGap;
		x2=right -(j )*xGap;
		
		iwidth = ((xGap/7)/100)*Size ;
		iheight=  (yGap/100)*Size;
	
		context:createFont (7, "Arial",iwidth, iheight , 0);
 
		
		if j== Num then 
		width, height = context:measureText (7, Pair[i], context.CENTER  ); 
		context:drawText (7, Pair[i], Color, -1, x1, y0-height/2, x2, y0+height/2, context.CENTER, 0);
		end
		
		
 	  
	    if i== Count then 
		width, height = context:measureText (7, TF[j], 0); 
		context:drawText (7,  TF[j], Color, -1, x1+xGap , y1,x2+xGap,  y2, context.CENTER   );	
		end
        
		Value = Indicator[i][j][Component][Indicator[i][j][Component]:size()-1];  
		Value= string.format("%." .. 2 .. "f", Value); 
		
	    if  Indicator[i][j][Component][Indicator[i][j][Component]:size()-1] > OB then					  
	    context:drawText (7, Value, Up, -1, x1+xGap, y1+yGap, x2+xGap, y2+yGap, context.CENTER); 
		elseif  Indicator[i][j][Component][Indicator[i][j][Component]:size()-1]< OS then
		context:drawText (7, Value, Down, -1, x1+xGap, y1+yGap, x2+xGap, y2+yGap, context.CENTER); 
        else		
        context:drawText (7, Value, Neutral, -1, x1+xGap, y1+yGap, x2+xGap, y2+yGap, context.CENTER); 
        end		
	  
 end
 
 
 
 
function EmailAlert( Label, i,j)

if not SendEmail then
return
end
 
   
	local DATA = core.dateToTable (core.now());	    
    local delim = "\013\010";    
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day.. delim .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;    
    local text ="MTF MCP SSD DASHBOARD"  .. delim  ..   " Instrument : " .. Pair[i].. delim  .. " Time Frame : " .. TF[j] .. delim  ..  Time.. delim  .. " Alert" .. " : " ..Label;
	

  
 terminal:alertEmail(Email, "MTF MCP SSD DASHBOARD", text);
end



function Pop(Label, i,j) 

  	local DATA = core.dateToTable (core.now());	    
    local delim = "\013\010";    
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day.. delim .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;    
    local text ="MTF MCP SSD DASHBOARD"  .. delim  ..   " Instrument : " .. Pair[i].. delim  .. " Time Frame : " .. TF[j] .. delim  ..  Time.. delim  .. " Alert" .. " : " ..Label;

   core.host:execute ("prompt", 1, "MTF MCP SSD DASHBOARD" ,   text );


end

function SoundAlert(iAlert )
 if not PlaySound then
 return;
 end
 
 
 terminal:alertSound(iAlert, RecurrentSound);
end


function SendAlert(Label, i,j)
    if not ShowAlert then
        return;
    end

  	local DATA = core.dateToTable (core.now());	    
    local delim = "\013\010";    
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day.. delim .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;    
    local text ="MTF MCP SSD DASHBOARD "..    " Instrument : " .. Pair[i].. delim  .. " Time Frame : " .. TF[j] .. delim  ..  Time.. delim  .. " Alert" .. " : " ..Label;

 
    terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
end


 function GiveAlert(Label , i,j) 
	 
		SoundAlert(Sound);
								 
		if Show   then
		Pop( Label , i,j );  	
		end			

		EmailAlert( Label , i,j);	
		SendAlert(  Label  , i,j);	 
	 
end

 
 