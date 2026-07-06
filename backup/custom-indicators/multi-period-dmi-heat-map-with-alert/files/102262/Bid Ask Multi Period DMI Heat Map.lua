-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62641

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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

 function Add(id, Period,Level,Flag )
   
    indicator.parameters:addGroup(id..". Slot" );
	
	
 
	indicator.parameters:addString("Price".. id , "Bid/Ask", "","Bid");	  
     indicator.parameters:addStringAlternative("Price".. id, "Bid", "Bid" , "Bid");
    indicator.parameters:addStringAlternative("Price".. id, "Ask", "Ask" , "Ask");
	
	indicator.parameters:addString("On".. id , "Show This Slot", "",Flag);	  
     indicator.parameters:addStringAlternative("On".. id, "View", "View" , "View");
    indicator.parameters:addStringAlternative("On".. id, "Alert", "Alert" , "Alert");
	indicator.parameters:addStringAlternative("On".. id, "Off", "Off" , "Off");
	
    indicator.parameters:addInteger("Period" .. id, "Period ", "", Period);
	indicator.parameters:addBoolean("Use"..id, "Use DMI Filter", "", false);
    indicator.parameters:addDouble("Level" .. id, "DMI Level ", "", Level);
	 
    
end

 
 
function Init()
    indicator:name("Multi Period DMI Heat Map with Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
  
	indicator.parameters:addGroup("Calculation" ); 
	
    Add(1, 5, 25, "Alert" ); 
    Add(2, 10,25,  "Off" ); 
    Add(3, 15,25,  "Off" ); 
    Add(4, 30,25,  "Off" ); 
    Add(5, 35,25,  "Off" ); 
    Add(6, 40,25, "Off" ); 
    Add(7, 45,25,  "Off" ); 
    Add(8, 50,25, "Off"  ); 
    Add(9, 100,25,  "Off"  ); 
    Add(10, 150,25, "Off" ); 
    Add(11, 200,25,  "Off" ); 
    Add(12, 250,25,  "Off" ); 
    Add(13, 300,25,  "Off" );

 
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
	
	
	indicator.parameters:addColor("NeutralUpUp", "Neutral Up in Up Trend Color","", core.rgb(138, 138, 138));
	indicator.parameters:addColor("NeutralUpDown", "Neutral Down in Up Trend Color","", core.rgb(138, 138, 138));
	indicator.parameters:addColor("NeutralDownUp", "Neutral Up in Down Trend Color","", core.rgb(118, 118, 118));
	indicator.parameters:addColor("NeutralDownDown", "Neutral Down in Down Trend Color","", core.rgb(118, 118, 118));
 
   
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
local Period={};
local day_offset, week_offset;
local Label = {"First", "Second", "Third", "Fourth"};
 
local VSpace,HSpace;
local Color;
local Size;
 
local TF={};
local loading={};
local Number;
local host;
 
local UpUp, DownDown ;
local UpDown, DownUp ;
local NeutralUpUp, NeutralDownDown ;
local NeutralUpDown, NeutralDownUp ;
 
local DMI_bid = {} ; 
local DMI_ask = {} ; 
local Last={};
local Count={}; 
local Email;
local SendEmail; 
local Sound;
local  RecurrentSound ,SoundFile  ;
local Show;
local PlaySound;
local Alert=nil; 
local AlertNumber;
local Level={}; 
local Use={};
local bid, ask,source;
local FIRST;


local Price={};
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	source = instance.source;
	
    if instance.source:isBid() then
     bid = instance.source;
     ask = core.host:execute("getAskPrice");
    else
     ask = instance.source;
     bid = core.host:execute("getBidPrice");
    end
	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100); 
	UpUp=instance.parameters.UpUp;
	DownDown=instance.parameters.DownDown;
	UpDown=instance.parameters.UpDown;
	DownUp=instance.parameters.DownUp; 
	
	
	NeutralUpUp=instance.parameters.NeutralUpUp;
	NeutralDownDown=instance.parameters.NeutralDownDown;
	NeutralUpDown=instance.parameters.NeutralUpDown;
	NeutralDownUp=instance.parameters.NeutralDownUp; 
	 
	
	 host = core.host;
	Size=instance.parameters.Size;
    Color=instance.parameters.Color;
   instance:setLabelColor(Color);
   instance:ownerDrawn(true);
   
    
    FIRST= {};
     day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    local Id=0;
    Number=0;
   
	local ifirst;
	 
	 

	AlertNumber=0;
	
	
	
	  for i = 1, 13, 1 do
	  
	 if  instance.parameters:getString("On" .. i)~= "Off"  then
	 Number=Number+1;
	 
	     
		  
		
		  
	 Label[Number]="";
	            On[Number]=instance.parameters:getString("On" .. i);
				
				if On[Number]=="Alert" then
				AlertNumber=AlertNumber+1;
				end
				 
			 	Price[Number]=  instance.parameters:getString("Price" .. i);	 	
				Period[Number]=  instance.parameters:getInteger("Period" .. i);	 
				Level[Number]=  instance.parameters:getDouble("Level" .. i);	
                Use[Number]=  instance.parameters:getBoolean("Use" .. i);				
				Label[Number]=Period[Number]; 
				
				   Id=Id+1;
			 
				 
				 
				 DMI_bid[Number] = core.indicators:create("DMI", bid ,  Period[Number]);    
				 DMI_ask[Number] = core.indicators:create("DMI", ask ,  Period[Number]);   		
       		 
				   
       end
    end
  
	
	 
		
		
	 SendEmail = instance.parameters.SendEmail;
	 
	if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	
--source
	
	RecurrentSound= instance.parameters.RecurrentSound;
    Show= instance.parameters.Show; 
	PlaySound = instance.parameters.PlaySound;
	
    if PlaySound then 
	  Sound=instance.parameters.Sound; 
    else  
      Sound=nil;
	 end
	 
	 
	  assert(not(PlaySound) or (PlaySound and Sound ~= "") or (PlaySound and Sound ~= ""), "Sound file must be chosen"); 
	  
	  
	        core.host:execute ("setTimer", 1, 5);
 
end

 function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

--DMI

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

   if cookie== 1 then
 
	   for i= 1, Number , 1 do
	  DMI_bid[i]:update(core.UpdateLast ); 
	  DMI_ask[i]:update(core.UpdateLast ); 
	  end
	 
	     for j= 1, Number, 1 do	 
		  Evaluate(j);
		 end 
  end
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
		     context:createPen (1, context.SOLID, 3, Color)       
			context:createSolidBrush(2, Color);
			
			 context:createPen (1, context.SOLID, 3, Color)       
			context:createSolidBrush(2, Color);
			
			context:createPen (11, context.SOLID, 3, UpUp)       
			context:createSolidBrush(12, UpUp);
			
			context:createPen (21, context.SOLID, 3, UpDown)       
			context:createSolidBrush(22, UpDown);
			
			context:createPen (13, context.SOLID, 3, NeutralUpUp)       
			context:createSolidBrush(14, NeutralUpUp);
			
			context:createPen (23, context.SOLID, 3, NeutralUpDown)       
			context:createSolidBrush(24, NeutralUpDown);
		
			
			context:createPen (31, context.SOLID, 3, DownUp)       
			context:createSolidBrush(32, DownUp);
			
			context:createPen (41, context.SOLID, 3, DownDown)       
			context:createSolidBrush(42, DownDown);
			
			 context:createPen (33, context.SOLID, 3, NeutralDownUp)       
			context:createSolidBrush(34, NeutralDownUp);
			
			context:createPen (43, context.SOLID, 3, NeutralDownDown)       
			context:createSolidBrush(44, NeutralDownDown);
			
		 
			
	 
		 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1))*HSpace;
		 VCellSize =((context:bottom() -context:top())/ (Number+1)); 
	
       local  C1=1;
	   local C2=2;
			    for i= first, last, 1 do	 
			   x0, x1, x2 = context:positionOfBar (i);
			   
			    for j= 1, Number , 1 do
				  p=i;
				  
				 
				  
			 
				 if Price[j]== "Ask" then  
						
								
										if DMI_ask[j].DIP:hasData(p) and DMI_ask[j].DIP:hasData(p-1)										
										then 
										
										            
												    if DMI_ask[j].DIP[p] >  DMI_ask[j].DIM[p]  then		 
															if  DMI_ask[j].DIP[p] >  Level[j] or not Use[j] then	
															    if   DMI_ask[j].DIP[p] > DMI_ask[j].DIP[p-1]   then
																C1=11
																C2=12;
																else
																C1=21;
																C2=22;
																end	
                                                            else
															     if DMI_ask[j].DIP[p] > DMI_ask[j].DIP[p-1]   then
																C1=13
																C2=14;
																else
																C1=23;
																C2=24;
																end	  
															end
												 
												    else  
													
													        if  DMI_ask[j].DIM[p] >  Level[j]  or not Use[j] then	
																if DMI_ask[j].DIM[p] > DMI_ask[j].DIM[p-1] then	
																C1=31;
																C2=32;
																else
																C1=41;
																C2=42;
																end		
                                                            else
															    if DMI_ask[j].DIM[p] > DMI_ask[j].DIM[p-1] then	
																C1=33;
																C2=34;
																else
																C1=43;
																C2=44;
																end		   
                                                            end  															
													 
													end
										
													 
												 
												     
									   else		
									   C1=1; C2=2;										   
									   end 
									   
					else 
					
					                   
										if DMI_bid[j].DIP:hasData(p) and DMI_bid[j].DIP:hasData(p-1)										
										then 
										
										            
												    if DMI_bid[j].DIP[p] >  DMI_bid[j].DIM[p]  then		 
															if  DMI_bid[j].DIP[p] >  Level[j] or not Use[j] then	
															    if   DMI_bid[j].DIP[p] > DMI_bid[j].DIP[p-1]   then
																C1=11
																C2=12;
																else
																C1=21;
																C2=22;
																end	
                                                            else
															     if DMI_bid[j].DIP[p] > DMI_bid[j].DIP[p-1]   then
																C1=13
																C2=14;
																else
																C1=23;
																C2=24;
																end	  
															end
												 
												    else  
													
													        if  DMI_bid[j].DIM[p] >  Level[j]  or not Use[j] then	
																if DMI_bid[j].DIM[p] > DMI_bid[j].DIM[p-1] then	
																C1=31;
																C2=32;
																else
																C1=41;
																C2=42;
																end		
                                                            else
															    if DMI_bid[j].DIM[p] > DMI_bid[j].DIM[p-1] then	
																C1=33;
																C2=34;
																else
																C1=43;
																C2=44;
																end		   
                                                            end  															
													 
													end
										
													 
												 
												     
									   else		
									   C1=1; C2=2;										   
									   end 

                    end					
			 				
				   context:drawRectangle (C1, C2, x1+HCellSize, context:top()+VCellSize * (j) +VCellSize* VSpace-VCellSize/2, x2-HCellSize, context:top() + VCellSize * (j+1)-VCellSize* VSpace-VCellSize/2);
				   
				   
					 if i== first then			 	 
					 local width, height; 
					 context:createFont(3, "Arial", ((X2-X1)/100)*Size, (VCellSize/100)*Size, context.NORMAL);
					 Value= tostring( Label[j]);
					 width, height = context:measureText (3,  Value , style)	 
					 context:drawText(3,  Value , Color, -1, X2 +(X2-X1), context:top()+VCellSize * (j) +VCellSize* VSpace-VCellSize/2 ,X2+(X2-X1)+width, context:top() + VCellSize * (j+1)-VCellSize* VSpace-VCellSize/2, style);
					 
					 
									

					 end  				 
				 
				 
			 
			 end
			 
	   end
	    
	 
end



function Evaluate(j)	

     if On[j]~= "Alert" then
	 return;
	 end
 
	 local   p= source:size()-1;
	       
		 
		
		 
		 
		if Price[j] == "Ask" then 
		
		
		
		 if not DMI_ask[j].DIP:hasData(p) 
		 or not p
		 then
		 return;
		 end
		 
		
				if DMI_ask[j].DIP[p] > DMI_ask[j].DIM[p]
				and DMI_ask[j].DIP[p]> Level[j]
				then 
				Count[j]= 1;
				elseif DMI_ask[j].DIP[p] < DMI_ask[j].DIM[p]		
				and DMI_ask[j].DIM[p]>Level[j]
				then 
				Count[j]= -1;
				end
				 
		 
				
				if FIRST[j]==nil then
				FIRST[j]=1;	
					if DMI_ask[j].DIP[p] > DMI_ask[j].DIM[p] 
					and DMI_ask[j].DIP[p]> Level[j]
					then 
					Last[j]= 1;
					elseif DMI_ask[j].DIP[p] < DMI_ask[j].DIM[p]
					and DMI_ask[j].DIM[p]>Level[j]
					then  
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
		 
		        if DMI_bid[j].DIP[p] > DMI_bid[j].DIM[p]
				and DMI_bid[j].DIP[p]> Level[j]
				then 
				Count[j]= 1;
				elseif DMI_bid[j].DIP[p] < DMI_bid[j].DIM[p]		
				and DMI_bid[j].DIM[p]>Level[j]
				then 
				Count[j]= -1;
				end
				 
		 
				
				if FIRST[j]==nil then
				FIRST[j]=1;	
					if DMI_bid[j].DIP[p] > DMI_bid[j].DIM[p] 
					and DMI_bid[j].DIP[p]> Level[j]
					then 
					Last[j]= 1;
					elseif DMI_bid[j].DIP[p] < DMI_bid[j].DIM[p]
					and DMI_bid[j].DIM[p]>Level[j]
					then  
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
    --source
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
   
       local text = " Instrument : " .. Instrument.. delim ..  Time.. delim  .. label .. " : " ..Label
	 .. delim  .. "ADX : " .. ADX[i].DATA[ADX[i].DATA:size()-1];
	

 -- Alert:invoke( "SendEmail", Email, label .. " : " ..Label,  text );
 
   terminal:alertEmail(Email, profile:id(), text);
 
end

function Pop(i, label , Instrument,Label )

   if not Show then
   return;
   end
   
  	local DATA = core.dateToTable (core.now());
	
    
   local delim = "\013\010";  
  
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day.. delim .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
     local text = " Instrument : " .. Instrument.. delim ..  Time.. delim  .. label .. " : " ..Label
	 .. delim  .. "ADX : " .. ADX[i].DATA[ADX[i].DATA:size()-1];

   core.host:execute ("prompt", 1,  label .. " : " ..Label ,   text );


end

function SoundAlert(iAlert )
 if not PlaySound then
 return;
 end
  
  terminal:alertSound(iAlert, RecurrentSound);
  --Alert:invoke( "PlaySound", iAlert, RecurrentSound);

end

	 