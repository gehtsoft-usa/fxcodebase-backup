
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61764

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



 function Add(id, TF,Flag, Instrument )
 
    indicator.parameters:addString("Price".. id , "Bid/Ask", "","Bid");	  
    indicator.parameters:addStringAlternative("Price".. id, "Bid", "Bid" , "Bid");
    indicator.parameters:addStringAlternative("Price".. id, "Ask", "Ask" , "Ask");
   
    indicator.parameters:addGroup(id..". Slot" );
	indicator.parameters:addString("On".. id , "Show This Slot", "",Flag);	  
     indicator.parameters:addStringAlternative("On".. id, "View", "View" , "View");
    indicator.parameters:addStringAlternative("On".. id, "Alert", "Alert" , "Alert");
	indicator.parameters:addStringAlternative("On".. id, "Off", "Off" , "Off");
	
    indicator.parameters:addString("TF" .. id, "Time Frame ", "", TF);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument);
    indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS);
	 
    
end

 
 
function Init()
    indicator:name("MTF MCP Heat Map DMI with Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Override" );
	
	indicator.parameters:addString("Method", "Override Method", "Method" , "Chart Instrument");
    indicator.parameters:addStringAlternative("Method", "Independent", "Independent" , "Independent");
    indicator.parameters:addStringAlternative("Method", "Chart Time Frame", "Chart Time Frame" , "Chart Time Frame");
	indicator.parameters:addStringAlternative("Method", "Chart Instrument", "Chart Instrument" , "Chart Instrument"); 	 
	indicator.parameters:addGroup("Calculation" );
	indicator.parameters:addInteger("Period" , "Number of periods for DMI", "", 14, 1, 200);
	indicator.parameters:addInteger("ADXPeriod" , "Number of periods for ADX", "", 14, 1, 200);
    indicator.parameters:addDouble("Level" , "ADX Level", "", 20, 0, 100);
	indicator.parameters:addBoolean("ShowADX", "Show ADX", "", true);
	
    Add(1, "m1",  "Alert", "EUR/USD"); 
    Add(2, "m5",  "Off", "USD/JPY"); 
    Add(3, "m15",  "Off", "GBP/USD"); 
    Add(4, "m30",  "Off", "USD/CHF"); 
    Add(5, "H1",  "Off", "EUR/CHF"); 
    Add(6, "H2", "Off", "AUD/USD"); 
    Add(7, "H3",  "Off", "USD/CAD"); 
    Add(8, "H4", "Off", "NZD/USD" ); 
    Add(9, "H6",  "Off", "NZD/USD" ); 
    Add(10, "H8", "Off", "EUR/JPY"); 
    Add(11, "D1",  "Off", "GBP/JPY"); 
    Add(12, "W1",  "Off", "CHF/JPY"); 
    Add(13, "M1",  "Off", "GBP/CHF");

 
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Color", "Label Color","", core.rgb(0, 0, 0));
	indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("Size", "Font Size (%)","",90, 50, 200);
	
	  indicator.parameters:addGroup("DMI Style");
	indicator.parameters:addColor("UpUp", "Up in Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Down in Up Trend Color","", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DownUp", "Up in Down Trend Color","", core.rgb(200, 0, 0));
	indicator.parameters:addColor("DownDown", "Down in Down Trend Color","", core.rgb(255, 0, 0));
 
    indicator.parameters:addGroup("ADX Style")
	
	indicator.parameters:addColor("ADXUpUp", "Strengthening in Strong Trend Color","", core.rgb(0, 0, 255));
	indicator.parameters:addColor("ADXUpDown", "Weakening in Strong Trend Color","", core.rgb(0, 0, 200));
	indicator.parameters:addColor("ADXDownUp", "Strengthening in Weak Trend Color","", core.rgb(128, 128, 128));
	indicator.parameters:addColor("ADXDownDown", "Weakening in Weak Trend Color","", core.rgb(0, 0, 0));
   
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
local ShowADX;
local VSpace,HSpace;
local Color;
local Size;
local SourceData={};
local TF={};
local loading1={};
local loading2={};
local Number;
local host;
local RSI={}; 
local UpUp, DownDown ;
local UpDown, DownUp ;

local ADXUpUp, ADXDownDown ;
local ADXUpDown, ADXDownUp ;

local Instrument={};

local Period  ;
local DMI_bid = {} ; 
local DMI_ask = {} ; 
local ADX_bid = {} ; 
local ADX_ask = {} ; 
local Last={};
local Count={}; 
 ---

 local CalcMode;
local Email;
local SendEmail; 
local Sound;
local  RecurrentSound ,SoundFile  ;
local Show;
local PlaySound;
local Alert=nil; 
local AlertNumber;
local Level;
local ADXPeriod;

local FIRST;


local bid={};
local ask={};
local Price={};
function Prepare(nameOnly)   
 
    source = instance.source;	
	 
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	ShowADX=instance.parameters.ShowADX;
	Method=instance.parameters.Method;
	Period = instance.parameters.Period;
	ADXPeriod=instance.parameters.ADXPeriod;
	UpUp=instance.parameters.UpUp;
	DownDown=instance.parameters.DownDown;
	UpDown=instance.parameters.UpDown;
	DownUp=instance.parameters.DownUp;
	Level=instance.parameters.Level;
	
	ADXUpUp=instance.parameters.ADXUpUp;
	ADXDownDown=instance.parameters.ADXDownDown;
	ADXUpDown=instance.parameters.ADXUpDown;
	ADXDownUp=instance.parameters.ADXDownUp;
	
	 host = core.host;
	Size=instance.parameters.Size;
    Color=instance.parameters.Color;

   
    
    FIRST= {};
     day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    local Id=0;
    Number=0;
    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	instance:name(name ..   " : "  ..  Method.. " ");
	if   (nameOnly) then
        return;
    end
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

	AlertNumber=0;
	  for i = 1, 13, 1 do
	s2, e2 = core.getcandle(iTF[i], 0, 0, 0);
	
	 if  instance.parameters:getString("On" .. i)~= "Off" and (e1 - s1) <= (e2 - s2)  then
	 Number=Number+1;
	 
	     
		  
		
		  
	 Label[Number]="";
	            On[Number]=instance.parameters:getString("On" .. i);
				
				Price[Number]=  instance.parameters:getString("Price" .. i);	 	
				
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
				
				
				
			  	Temp1= core.indicators:create("DMI", source ,  Period);  				
				ifirst= Temp1.DATA:first();
			
				
				   Id=Id+1;
				 bid[Number]= core.host:execute("getSyncHistory",  Instrument[Number],  TF[Number], source:isBid(),math.min(300,ifirst), 2000 + Id , 1000 +Id);	 	 
                 ask[Number]= core.host:execute("getSyncHistory",  Instrument[Number],  TF[Number], source:isBid(),math.min(300,ifirst), 4000 + Id , 3000 +Id);	 				 

				loading1[Number]  = true;  	 
                loading2[Number]  = true;  	 
				 
				  DMI_bid[Number] = core.indicators:create("DMI", bid[Number] ,  Period );    
				  DMI_ask[Number] = core.indicators:create("DMI", ask[Number],  Period);   		
				  
				  ADX_bid[Number] = core.indicators:create("ADX", bid[Number] ,  ADXPeriod );    
				  ADX_ask[Number] = core.indicators:create("ADX", ask[Number] ,  ADXPeriod);   		
				 
				   
       end
    end
  
	
	    
		
		
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
   
      instance:setLabelColor(Color);
   instance:ownerDrawn(true);
   	core.host:execute ("setTimer", 1, 1);
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 



function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset);
  
    if loading1[id]  or  loading2[id]or  bid[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(bid[id], Candle, false);
	 

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
			  loading1[j]  = true;
		      elseif  cookie == (2000 + Id ) then
			  loading1[j]  = false;   
			  end
			  
			  if cookie == (3000 + Id) then
			  loading2[j]  = true;
		      elseif  cookie == (4000 + Id ) then
			  loading2[j]  = false;   
			  end
		 
		       
                 if loading1[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
				 
				  if loading2[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
	
	
	 if not FLAG and cookie== 1 then
	   for i= 1, Number , 1 do 
	  DMI_bid[i]:update(core.UpdateLast ); 
	  DMI_ask[i]:update(core.UpdateLast ); 
	  
	  ADX_bid[i]:update(core.UpdateLast ); 
	  ADX_ask[i]:update(core.UpdateLast ); 
	  
	  Evaluate(j);
	  
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
		     
                 if loading1[j] or  loading2[j] then
				 FLAG= true;
				 end
				 
	end    
    
	
	if FLAG then
	return;	
	end
   
    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context.SOLID, 3, Color)       
			context:createSolidBrush(2, Color);
			
			 context:createPen (1, context.SOLID, 3, Color)       
			context:createSolidBrush(2, Color);
			
			context:createPen (11, context.SOLID, 3, ADXUpUp)       
			context:createSolidBrush(12, UpUp);
			
			context:createPen (21, context.SOLID, 3, ADXUpDown)       
			context:createSolidBrush(22, UpDown);
		
			
			context:createPen (31, context.SOLID, 3, ADXDownUp)       
			context:createSolidBrush(32, DownUp);
			
			context:createPen (41, context.SOLID, 3, ADXDownDown)       
			context:createSolidBrush(42, DownDown);
		 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1))*HSpace;
		 VCellSize =((context:bottom() -context:top())/ (Number+1)); 
	
       
			    for i= first, last, 1 do	 
			   x0, x1, x2 = context:positionOfBar (i);
			   
			    for j= 1, Number , 1 do
				  p=Initialization(i,j);
				  
				 
				  
				  if p~= false then
				   
						
								 if Price[j]== "Ask" then  
												if DMI_ask[j].DIP:hasData(p) and DMI_ask[j].DIP:hasData(p-1) then 
												
															if DMI_ask[j].DIP[p] > DMI_ask[j].DIM[p] then		 
																	if DMI_ask[j].DIP[p] > DMI_ask[j].DIP[p-1] then	
																	C2=12;
																	else
																	C2=22;
																	end		
														 
															else  
																	if DMI_ask[j].DIP[p] > DMI_ask[j].DIP[p-1] then	
																	C2=32;
																	else
																	C2=42;
																	end														
															 
															end
												
															if ShowADX then 
																  if ADX_ask[j].DATA[p] > Level then		 
																			if ADX_ask[j].DATA[p] > ADX_ask[j].DATA[p-1] then																
																			C1=11;
																			else
																			
																			C1=21;
																			end		
																 
																	else  
																			if ADX_ask[j].DATA[p] > ADX_ask[j].DATA[p-1] then															
																			C1=31;
																			else															
																			C1=41;
																			end														
																	 
																	end

															else													
																	
																   C1=-1;	 
															 end
														 
															 
											   else		
											   C1=1; C2=2;										   
											   end 
									   
						            else
									
												if DMI_bid[j].DIP:hasData(p) and DMI_bid[j].DIP:hasData(p-1) then 
												
															if DMI_bid[j].DIP[p] > DMI_bid[j].DIM[p] then		 
																	if DMI_bid[j].DIP[p] > DMI_bid[j].DIP[p-1] then	
																	C2=12;
																	else
																	C2=22;
																	end		
														 
															else  
																	if DMI_bid[j].DIP[p] > DMI_bid[j].DIP[p-1] then	
																	C2=32;
																	else
																	C2=42;
																	end														
															 
															end
												
															if ShowADX then 
																  if ADX_bid[j].DATA[p] > Level then		 
																			if ADX_bid[j].DATA[p] > ADX_bid[j].DATA[p-1] then																
																			C1=11;
																			else
																			
																			C1=21;
																			end		
																 
																	else  
																			if ADX_bid[j].DATA[p] > ADX_bid[j].DATA[p-1] then															
																			C1=31;
																			else															
																			C1=41;
																			end														
																	 
																	end

															else													
																	
																   C1=-1;	 
															 end
														 
															 
											   else		
											   C1=1; C2=2;										   
											   end 
									   									
									
									end
									
									
				 else
                   
					 C1=1; C2=2;		
										
				end						
				   context:drawRectangle (C1, C2, x1+HCellSize, context:top()+VCellSize * (j) +VCellSize* VSpace, x2-HCellSize, context:top() + VCellSize * (j+1)-VCellSize* VSpace);
				   
				   
					 if i== first then			 	 
					 local width, height; 
					 context:createFont(3, "Arial", ((X2-X1)/100)*Size, (VCellSize/100)*Size, context.NORMAL);
					 Value= tostring( Label[j]);
					 width, height = context:measureText (3,  Value , style)	 
					 context:drawText(3,  Value , Color, -1, X2 +(X2-X1), context:top()+VCellSize * (j) +VCellSize* VSpace ,X2+(X2-X1)+width, context:top() + VCellSize * (j+1)-VCellSize* VSpace, style);
					 
					 
									

					 end  				 
				 
				 
			 
			 end
			 
	   end
	   
	  
	      
 
	 
end



function Evaluate(j)	

     if On[j]~= "Alert" then
	 return;
	 end
	 
	 local   p=Initialization((source:size()-1),j);
	       
	
	 if Price[j]== "Ask" then  	 
		 if not DMI_ask[j].DIP:hasData(p) 
		 or not p
		 then
		 return;
		 end
		 
		if DMI_ask[j].DIP[p] > DMI_ask[j].DIM[p] then 
		Count[j]= 1;
		elseif DMI_ask[j].DIP[p] < DMI_ask[j].DIM[p] then  
		Count[j]= -1;
		end
		 
        
		
		if FIRST[j]==nil then
		FIRST[j]=1;	
			if DMI_ask[j].DIP[p] > DMI_ask[j].DIM[p] then 
			Last[j]= 1;
			elseif DMI_ask[j].DIP[p] < DMI_ask[j].DIM[p] then  
			Last[j]= -1;
			else
			Last[j]= 0;
			end 		
		return;
		end
    else
	
			 if not DMI_bid[j].DIP:hasData(p) 
		 or not p
		 then
		 return;
		 end
		 
		if DMI_bid[j].DIP[p] > DMI_bid[j].DIM[p] then 
		Count[j]= 1;
		elseif DMI_bid[j].DIP[p] < DMI_bid[j].DIM[p] then  
		Count[j]= -1;
		end
		 
        
		
		if FIRST[j]==nil then
		FIRST[j]=1;	
			if DMI_bid[j].DIP[p] > DMI_bid[j].DIM[p] then 
			Last[j]= 1;
			elseif DMI_bid[j].DIP[p] < DMI_bid[j].DIM[p] then  
			Last[j]= -1;
			else
			Last[j]= 0;
			end 		
		return;
		end
		
    end
	

				if Count[j]== 1 and Last[j]~= 1 then
						 Last[j]= 1;
						 GiveAlert(j, "DMI Up Trend");
						elseif Count[j]== -1  and Last[j]~= -1 then
						Last[j]= -1;
						 GiveAlert(j,"DMI Down Trend");
						elseif Count[j]== 0 and Last[j]~= 0   then
						 Last[j]= 0;
						 GiveAlert(j,"DMI Neutral Trend");
						end
			       	 
	 
 
end


function GiveAlert(i,Label)

    if Count[i]== 0 then
    return;
    end	
    
	SoundAlert(Sound);
	Pop(i,"Alert",  source:instrument(), Label   ); 
	EmailAlert(  i, "Alert",   source:instrument(), Label  );
end


function EmailAlert( i, label ,  Instrument,Label )

if not SendEmail then
return
end
 
   
	local DATA = core.dateToTable (core.now());
	
    
   local delim = "\013\010";  
  
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .. delim .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
   local text;
   
     if Price[j]== "Ask" then   
     text = " Instrument : " .. Instrument.. delim ..  Time.. delim  .. label .. " : " ..Label
	 .. delim  .. "ADX : " .. ADX_ask[i].DATA[ADX_ask[i].DATA:size()-1];
	 else
	 
	  text = " Instrument : " .. Instrument.. delim ..  Time.. delim  .. label .. " : " ..Label
	 .. delim  .. "ADX : " .. ADX_bid[i].DATA[ADX_bid[i].DATA:size()-1];
	 end	 

  terminal:alertEmail(Email,  label .. " : " ..Label, text);
end
 
function Pop(i, label , Instrument,Label )

   if not Show then
   return;
   end
   
  	local DATA = core.dateToTable (core.now());
	
    
   local delim = "\013\010";  
  
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day.. delim .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
   
   local text;
   
     if Price[j]== "Ask" then   
     text = " Instrument : " .. Instrument.. delim ..  Time.. delim  .. label .. " : " ..Label
	 .. delim  .. "ADX : " .. ADX_ask[i].DATA[ADX_ask[i].DATA:size()-1];
	 
	 else
	 
	  text = " Instrument : " .. Instrument.. delim ..  Time.. delim  .. label .. " : " ..Label
	 .. delim  .. "ADX : " .. ADX_bid[i].DATA[ADX_bid[i].DATA:size()-1];
	 
	 end

   core.host:execute ("prompt", 1,  label .. " : " ..Label ,   text );


end

function SoundAlert(iAlert )
 if not PlaySound then
 return;
 end
  
  terminal:alertSound(iAlert, RecurrentSound);
 
 
end

	 