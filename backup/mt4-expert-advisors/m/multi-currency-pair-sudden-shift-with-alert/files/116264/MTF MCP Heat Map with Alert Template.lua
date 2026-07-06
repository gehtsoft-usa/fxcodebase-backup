
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32319

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


 function Add(id, TF,Flag, Instrument )
   
    indicator.parameters:addGroup(id..". Slot" );
	indicator.parameters:addString("On".. id , "Show This Slot", "",Flag);	  
     indicator.parameters:addStringAlternative("On".. id, "View", "View" , "View");
    indicator.parameters:addStringAlternative("On".. id, "Alert", "Alert" , "Alert");
	indicator.parameters:addStringAlternative("On".. id, "Off", "Off" , "Off");
	
    indicator.parameters:addString("TF" .. id, "Time Frame ", "", TF);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument);
    indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addInteger("Period".. id, "Number of periods", "", 14, 1, 200);
    
end

 
 
function Init()
    indicator:name("MTF MCP Heat Map with Alert Template");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Override" );
	
	indicator.parameters:addString("Method", "Override Method", "Method" , "Chart Instrument");
    indicator.parameters:addStringAlternative("Method", "Independent", "Independent" , "Independent");
    indicator.parameters:addStringAlternative("Method", "Chart Time Frame", "Chart Time Frame" , "Chart Time Frame");
	indicator.parameters:addStringAlternative("Method", "Chart Instrument", "Chart Instrument" , "Chart Instrument"); 	 
  
    Add(1, "m1",  "Off", "EUR/USD"); 
    Add(2, "m5",  "Off", "USD/JPY"); 
    Add(3, "m15",  "Off", "GBP/USD"); 
    Add(4, "m30",  "Off", "USD/CHF"); 
    Add(5, "H1",  "Off", "EUR/CHF"); 
    Add(6, "H2", "View", "AUD/USD"); 
    Add(7, "H3",  "Off", "USD/CAD"); 
    Add(8, "H4", "View", "NZD/USD" ); 
    Add(9, "H6",  "Off", "NZD/USD" ); 
    Add(10, "H8", "View", "EUR/JPY"); 
    Add(11, "D1",  "Off", "GBP/JPY"); 
    Add(12, "W1",  "Off", "CHF/JPY"); 
    Add(13, "M1",  "Off", "GBP/CHF");

 
     indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Color", "Label Color","", core.rgb(0, 0, 0));
	indicator.parameters:addColor("UpUp", "Up in Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Down in Up Trend Color","", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DownUp", "Up in Down Trend Color","", core.rgb(200, 0, 0));
	indicator.parameters:addColor("DownDown", "Down in Down Trend Color","", core.rgb(255, 0, 0));
 
   indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("Size", "Font Size (%)","",90, 50, 200);
   
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
local On={};
local Method;
local source;
local day_offset, week_offset;
local Label = {"First", "Second", "Third", "Fourth"};

local VSpace,HSpace;
local Color;
local Size;
local SourceData={};
local TF={};
local loading={};
local Number;
local host;
local RSI={}; 
local UpUp, DownDown ;
local UpDown, DownUp ;
local Instrument={};

local Period= {} ;
local Indicator = {} ;
 
local Last; 
 ---

 local CalcMode;
local Email;
local SendEmail; 
local Sound;
local  RecurrentSound ,SoundFile  ;
local Show;
local PlaySound;
local Alert=nil;
local Count;
local AlertNumber;

function Prepare()
 
    source = instance.source;	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	Method=instance.parameters.Method;
	
	UpUp=instance.parameters.UpUp;
	DownDown=instance.parameters.DownDown;
	UpDown=instance.parameters.UpDown;
	DownUp=instance.parameters.DownUp;
	
	 host = core.host;
	Size=instance.parameters.Size;
    Color=instance.parameters.Color;
   instance:setLabelColor(Color);
   instance:ownerDrawn(true);
   
   Last=nil;
    
     day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    local Id=0;
    Number=0;
    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	local ifirst;
	 local s1, e1, s2, e2;
	  s1, e1 = core.getcandle(source:barSize(), 0, 0, 0);
	 
	 local iTF={};
	 for i = 1, 13, 1 do
		       if   Method== "Chart Time Frame" then
	            iTF[i]=source:barSize();
				else
				iTF[i]=  instance.parameters:getString("TF" .. i);	
                		
				end
		 		
	end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
   
	AlertNumber=0;
	  for i = 1, 13, 1 do
	s2, e2 = core.getcandle(iTF[i], 0, 0, 0);
	
	 if  instance.parameters:getString("On" .. i)~= "Off" and (e1 - s1) <= (e2 - s2)  then
	 Number=Number+1;
	 
	      Period[Number]= instance.parameters:getInteger("Period" .. i);
		  
		
		  
	 Label[Number]="";
	            On[Number]=instance.parameters:getString("On" .. i);
				
				if On[Number]=="Alert" then
				AlertNumber=AlertNumber+1;
				end
				 
				if  Method== "Chart Instrument" then
	            Instrument[Number]=source:instrument();
				Label[Number]="";
	            else			
				Instrument[Number]=  instance.parameters:getString("Instrument" .. i);	 
				Label[Number]=Instrument[Number];
				end
				
				 
				 
				if   Method== "Chart Time Frame" then 
				TF[Number]=iTF[i];
				else
				TF[Number]=iTF[i];
                Label[Number]=Label[Number] .. " - " ..  TF[Number];				
				end
				
				
				
			  	Temp1= core.indicators:create("DMI", source ,  Period[Number]);  				
				ifirst= Temp1.DATA:first()*2;
			
				
				   Id=Id+1;
				 SourceData[Number]  = core.host:execute("getSyncHistory",  Instrument[Number],  TF[Number], source:isBid(), math.min(300,ifirst), 2000 + Id , 1000 +Id);	 	 
				 loading[Number]  = true;  	 
				 Indicator[Number] = core.indicators:create("DMI", SourceData[Number] ,  Period[Number]);   
			 
				   
       end
    end
  
	
	    instance:name(name ..   " : "  ..  Method.. " ");
		
		
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
      core.host:execute ("setTimer", 1, 1);
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 


function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset);
  
    if loading[id] or SourceData[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(SourceData[id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

local j;
local FLAG=false; 
local Num=0;
local Id=0;
    for j = 1, Number, 1 do
		      Id=Id+1;
			  if cookie == (1000 + Id) then
			  loading[j]  = true;
		      elseif  cookie == (2000 + Id ) then
			  loading[j]  = false;         
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
   
   
   if not FLAG and cookie== 1 then
		for i= 1, Number , 1 do
			  Indicator[i]:update(core.UpdateLast );
		end
		
		
	 if Method=="Chart Instrument"  then
	      
		  Count=0;
		  
	  	 for j= 1, Number, 1 do	 
		  Evaluate(j);
		 end 
		  
		   
		  core.host:execute ("setStatus", tostring(Count).. " / " .. tostring(AlertNumber))
		  
			  if Last== nil then
				  
				  
						if Count== AlertNumber then
						Last= 1;
						elseif -Count== AlertNumber then
						Last= -1;
						else
						Last= 0;
						end
						
				  else
				  
					   if Count== AlertNumber and Last~= 1 then
						 Last= 1;
						 GiveAlert("Up Trend");
						elseif -Count== AlertNumber  and Last~= -1 then
						Last= -1;
						 GiveAlert("Down Trend");
						elseif Last~= 0 and  math.abs(Count) ~= AlertNumber   then
						 Last= 0;
						 GiveAlert("Neutral Trend");
						end
					
				    end
		      
	  end	
		
	end
           
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Number) - Num) .. " / " .. (Number) );	 
	else
	core.host:execute ("setStatus", "Loaded");
	  instance:updateFrom(0);
	end
	
 
   
        
    return core.ASYNC_REDRAW ;
	
	
end

function Update(period, mode)
        
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
	 
	local FLAG=false; 

    for j = 1, Number, 1 do
		     
                 if loading[j] then
				 FLAG= true;
				 end
				 
	end    
    
	
	if FLAG then
	return;
	end
   
    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context.SOLID, 1, Color)       
			context:createSolidBrush(2, Color);
			
			 context:createPen (1, context.SOLID, 1, Color)       
			context:createSolidBrush(2, Color);
			
			context:createPen (11, context.SOLID, 1, UpUp)       
			context:createSolidBrush(12, UpUp);
			
			context:createPen (21, context.SOLID, 1, UpDown)       
			context:createSolidBrush(22, UpDown);
		
			
			context:createPen (31, context.SOLID, 1, DownUp)       
			context:createSolidBrush(32, DownUp);
			
			context:createPen (41, context.SOLID, 1, DownDown)       
			context:createSolidBrush(42, DownDown);
		 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =(X2-X1)*HSpace;
		 VCellSize =((context:bottom() -context:top())/ (Number+1)); 
	
       
			    for i= first, last, 1 do	 
			   x0, x1, x2 = context:positionOfBar (i);
			   
			    for j= 1, Number , 1 do
				  p=Initialization(i,j);
				  
				 
				  
				  if p~= false then
				   
						
								
										if Indicator[j].DIP:hasData(p) and Indicator[j].DIP:hasData(p-1) then 
										
												    if Indicator[j].DIP[p] > Indicator[j].DIM[p] then		 
															if Indicator[j].DIP[p] > Indicator[j].DIP[p-1] then	
															C2=12;
															C1=11;
															else
															C2=22;
															C1=21;
															end		
												 
												    else  
													        if Indicator[j].DIP[p] > Indicator[j].DIP[p-1] then	
															C2=32;
															C1=31;
															else
															C2=42;
															C1=41;
															end														
													 
													end
										
																									
												
											 
												 
												     
									   else		
									   C1=1; C2=2;										   
									   end 
									   
						 
				 else
                   
					 C1=1; C2=2;		
										
				end						
				   context:drawRectangle (C1, C2, x1+HCellSize, context:top()+VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace, x2-HCellSize, context:top()+VCellSize/2 + VCellSize * (j )-VCellSize* VSpace);
				   
				   
					 if i== first then			 	 
					 local width, height; 
					 context:createFont(3, "Arial", ((X2-X1)/100)*Size, (VCellSize/100)*Size, context.NORMAL);
					 Value= tostring( Label[j]);
					 width, height = context:measureText (3,  Value , style)	 
					 context:drawText(3,  Value , Color, -1, X2 +(X2-X1), context:top()+VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace ,X2+(X2-X1)+width, context:top()+VCellSize/2 + VCellSize * (j )-VCellSize* VSpace, style);
					 
					 
									

					 end  				 
				 
				 
			 
			 end
			 
	   end
	   
	 
end



function Evaluate(j)	

     if On[j]~= "Alert" then
	 return;
	 end
	 
	 local   p=Initialization((source:size()-1),j);
	       
		 
		 if not Indicator[j].DIP:hasData(p) 
		 or not p
		 then
		 return;
		 end
		 
		if Indicator[j].DIP[p] > Indicator[j].DIM[p] then 
		Count= Count+1;
		elseif Indicator[j].DIP[p] < Indicator[j].DIM[p] then  
		Count= Count-1;  
		end
		  	         	 
	 
 
end


function GiveAlert(Label)

    if Count== 0 then
    return;
    end	
    
	SoundAlert(Sound);
	Pop("Alert",  source:instrument(), Label   ); 
	EmailAlert(  "Alert",   source:instrument(), Label  );
end


function EmailAlert( label ,  Instrument,Label )

if not SendEmail then
return
end

 
   
	local DATA = core.dateToTable (core.now());
	
    
   local delim = "\013\010";  
  
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .. delim .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
     local text = " Instrument : " .. Instrument.. delim ..  Time.. delim  .. Label .. " : " ..label;
	 
   terminal:alertEmail(Email, Label .. " : " ..label , text);
end
 
function Pop(label , Instrument,Label )

   if not Show then
   return;
   end
   
  	local DATA = core.dateToTable (core.now());
	
    
   local delim = "\013\010";  
  
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day.. delim .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
     local text = " Instrument : " .. Instrument.. delim ..  Time.. delim  ..  label .. " : " .. Label ;

   core.host:execute ("prompt", 1,   profile:id()  ,   text );


end

function SoundAlert(iAlert )
 if not PlaySound then
 return;
 end 
  
     terminal:alertSound(iAlert, RecurrentSound);
end

	 