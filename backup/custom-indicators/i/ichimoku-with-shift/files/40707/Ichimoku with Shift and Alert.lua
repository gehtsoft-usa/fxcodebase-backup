-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23664


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

-- The indicator corresponds to the Ichimoku Kinko Hyo indicator in MetaTrader.

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Ichimoku with Shift and Alert");
    indicator:description("Enables to quickly discern and filter  at a glance the low-probability trading setups from those of higher probability.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("X", "Tenkan-sen period", "", 9, 1, 10000);
    indicator.parameters:addInteger("Y", "Kijun-sen period", "", 26, 1, 10000);
    indicator.parameters:addInteger("Z", "Senkou Span B period", "", 52, 1, 10000);
	
	indicator.parameters:addGroup("Shift Period");
	indicator.parameters:addInteger("SLX", "SL Line Shift period", "", 0);
	indicator.parameters:addInteger("TLX", "TL Line Shift period", "", 0);
	indicator.parameters:addInteger("CSX", "CS Line Shift period", "", 0);
    indicator.parameters:addInteger("SAX", "Cloud Shift period", "", 0);
	
	indicator.parameters:addGroup("Selector");	
	indicator.parameters:addBoolean("On1" , "Show Tenkan-sen Line", "", true);	
	indicator.parameters:addBoolean("On2" , "Show Kijun-sen Line", "", true);	
	indicator.parameters:addBoolean("On3" , "Show Chinkou Span Line", "", true);	
	indicator.parameters:addBoolean("On4" , "Show Ichimoku Cloud", "", true);	
     
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrTS", " Tenkan-sen Line Color","", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthSL", "Tenkan-sen Line Width ","", 1, 1, 5);
    indicator.parameters:addInteger("styleSL", "Tenkan-sen Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSL", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrKS", "Kijun-sen Line Color","", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthTL", " Kijun-sen Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleTL","Kijun-sen Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleTL", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrCS","Chinkou Span Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthCS", "Chinkou Span Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleCS", "Chinkou Span Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCS", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSSA", "Span A Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthSSA", "Span A Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleSSA", "Span A Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSSA", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSSB", "Span B Line Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthSSB", "Span B Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleSSB", "Span B Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSSB", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addInteger("transp", "Cloud transparency, %", "The transparency of the SA-SB cloud. Must be in the range 0-100.", 80, 0, 100);
	
	
	indicator.parameters:addGroup("Price Line");	  
	 
	indicator.parameters:addBoolean("ShowLevel", "Show Price Line", "", true);
	 
	 indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128)); 
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);   
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	

	      indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "Execution", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "Tenkan-sen A Span");	
	Parameters (2, "Tenkan-sen B Span");	
	Parameters (3, "Kijun-sen A Span");	
	Parameters (4, "Kijun-sen B Span");	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Tenkan;
local Kijun;
local Senkou;
local On1, On2, On3, On4, On5;
local firstPeriod;
local source = nil;

local csFirst = nil;
local slFirst = nil;
local tlFirst = nil;
local saFirst = nil;
local sbFirst = nil;
local chFirst = nil;

-- Streams block
local SL = nil;
local RSL = nil;
local TL = nil;
local RTL = nil;
local CS = nil;
local RCS = nil;
local SA = nil;
local RSA = nil;
local SB = nil;
local RSB = nil;
local SA1 = nil;
local RSA1 = nil;
local SB1 = nil;
local RB1 = nil;
local clrSSA, clrSSB;
local LabelSize;
local SLX,TLX,CSX,SAX;

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 4;
local Up={};
local Down={};
local Label={};
local ON={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
local PlaySound;
local Live;
local FIRST=true;
local OnlyOnce;
local U={};
local D={};
local UpTrendColor, DownTrendColor;
local OnlyOnceFlag;
local font;
local ShowAlert;
local Shift=0; 
local Alert={}; 
local AlertLevel={};



-- Routine
function Prepare(nameOnly) 

    OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;	
  
    ShowLevel = instance.parameters.ShowLevel; 
	SLX = instance.parameters.SLX;
	TLX = instance.parameters.TLX;
	CSX = instance.parameters.CSX;
	SAX = instance.parameters.SAX;
	
	On1 = instance.parameters.On1;
	On2 = instance.parameters.On2;
	On3 = instance.parameters.On2;
	On4 = instance.parameters.On4;
	
	
    Tenkan = instance.parameters.X;
    Kijun = instance.parameters.Y;
    Senkou = instance.parameters.Z;
    source = instance.source;
    firstPeriod = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Tenkan .. ", " .. Kijun .. ", " .. Senkou .. ")";
    instance:name(name);
	
	if nameOnly then
        return;
    end
	
	local A,B;
	
	 local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
	LabelSize= e-s;
	
	RSL= instance:addInternalStream(firstPeriod + Tenkan - 1,0);
	
	if  RSL:first()+SLX  > firstPeriod then
	A = RSL:first()+SLX ;
	else
	A=firstPeriod;
	end
	
	if On1 then
    SL = instance:addStream("SL", core.Line, name .. ".SL", "SL", instance.parameters.clrTS, A,SLX);
    SL:setWidth(instance.parameters.widthSL);
    SL:setStyle(instance.parameters.styleSL);
	else
	SL = instance:addInternalStream( A,SLX);
	end
	
	
	RTL= instance:addInternalStream(firstPeriod + Kijun - 1,0);
	
	if  RTL:first()+TLX  > firstPeriod then
	A = RTL:first()+TLX ;
	else
	A=firstPeriod;
	end
	if On2 then
    TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.clrKS, A ,TLX)
    TL:setWidth(instance.parameters.widthTL);
    TL:setStyle(instance.parameters.styleTL);
	else
	TL = instance:addInternalStream( A ,TLX);
	end
	
	--CSX
	RCS= instance:addInternalStream(firstPeriod, -Kijun);
	
	if  RCS:first()+CSX  > firstPeriod then
	A = RCS:first()+CSX ;
	else
	A=firstPeriod;
	end
	
	if On3 then
     CS = instance:addStream("CS", core.Line, name .. ".CS", "CS", instance.parameters.clrCS,  A, -Kijun+CSX)
    CS:setWidth(instance.parameters.widthCS);
    CS:setStyle(instance.parameters.styleCS);
	else
	CS = instance:addInternalStream(  A, -Kijun+CSX);
	end
	
	
	
	RSA= instance:addInternalStream( math.max(RSL:first(), RTL:first()), Kijun);
	
	if  RSA:first()+SAX  > firstPeriod then
	A = RSA:first()+SAX ;
	else
	A=firstPeriod;
	end
	if On4 then
    SA = instance:addStream("SA", core.Line, name .. ".SA", "SA", instance.parameters.clrSSA, A, Kijun+SAX )
    SA:setWidth(instance.parameters.widthSSA);
    SA:setStyle(instance.parameters.styleSSA);
	else
	SA = instance:addInternalStream(  A, Kijun+SAX);
	end
	
	
	RSB= instance:addInternalStream(firstPeriod + Senkou - 1, Kijun);
	
	if  RSB:first()+SAX  > firstPeriod then
	B = RSB:first()+SAX ;
	else
	B=firstPeriod;
	end
	if On4 then
    SB = instance:addStream("SB", core.Line, name .. ".SB", "SB", instance.parameters.clrSSB,  B,  Kijun+SAX)
    SB:setWidth(instance.parameters.widthSSB);
    SB:setStyle(instance.parameters.styleSSB);	
	else
	SB = instance:addInternalStream(  A, Kijun+SAX);
	end

    csFirst = RCS:first() + Kijun;
    slFirst = RSL:first();
    tlFirst = RTL:first();
		
    saFirst = RSA:first();
    sbFirst = RSB:first();

   -- chFirst = math.max(saFirst, sbFirst)+CSP;
    chFirst = math.max(saFirst, sbFirst);
	
	
    SA1 = instance:addInternalStream(A, Kijun+SAX);
    SB1 = instance:addInternalStream(B, Kijun+SAX);
	
    instance:createChannelGroup("SA-SB", "SA-SB", SA1, SB1, instance.parameters.clrSSA, 100 - instance.parameters.transp);
    clrSSA = instance.parameters.clrSSA;
    clrSSB = instance.parameters.clrSSB;
	
	 for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
     end
	
	Initialization();	
	instance:ownerDrawn(true);	 
	
	
	 
end

-- Indicator calculation routine
function Update(period)

    if ShowLevel and period == source:size()-1 then
	
	local DATE =  source:date(source.close:size()-1)+ LabelSize * ( math.max(SLX, TLX,Kijun+SAX, CSX - Kijun )) ;
	
	core.host:execute("drawLine", 1, source:date(source.close:first()), source.close[source.close:size()-1] ,DATE , source.close[source.close:size()-1], 
	instance.parameters.level_overboughtsold_color, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width);
	end
	



     if (period >= csFirst) then
        RCS[period - Kijun] = source.close[period];
    end

    local p, hh, ll;

    if (period >= slFirst) then
        ll, hh = mathex.minmax(source, period - Tenkan + 1, period);
        RSL[period] = (hh + ll) / 2;
    end

    if (period >= tlFirst) then
        ll, hh = mathex.minmax(source, period - Kijun + 1, period);
        RTL[period] = (hh + ll) / 2;
    end

   -- local p = period + Kijun + CSP;
    local p = period + Kijun;
   
    if (period >= saFirst) then
        RSA[p] = (RSL[period] + RTL[period]) / 2;
    end

    if (period >= sbFirst) then
        ll, hh = mathex.minmax(source, period - Senkou + 1, period);
        RSB[p] = (hh + ll) / 2;
    end
	
	ShiftFunction (period);
	
	
    if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	 
	
    Activate (1, period);
    Activate (2, period);
	Activate (3, period);
	Activate (4, period);
end
 

function ShiftFunction(period)
  local p;
   
   
   if period + SLX > slFirst   then 
  SL[period + SLX] = RSL[period];
  end
  
  
   if period + TLX > tlFirst   then  
   TL[period + TLX]  =  RTL[period];
   end
     
   p= period-Kijun; 
   
   if p +CSX  > csFirst and  p >= RCS:first()  and  p >= RCS:size()-1    then  
    CS[p+CSX] = RCS[p];
  --CS[p+CSX] = 1.3;
   end
   
   p= period+Kijun; 
   if p +SAX > chFirst  then
   
    SB[p+SAX] = RSB[p];
    SA[p+SAX] = RSA[p];
    SA1[p+SAX] = RSB[p];
    SB1[p+SAX] =  RSA[p]; 
  
      if (SA[p+SAX] > SB[p+SAX]) then
            SA1:setColor(p+SAX, clrSSB);
        else
            SA1:setColor(p+SAX, clrSSA);
        end 
   
   end 
   
   
end



function Activate (id, period)

   --SL, TL, SA,SB
   Alert[id][period]=0;
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	  
	   if SA[period]== nil   
	   or SA[period-1]== nil
	   or  SL[period]== nil 
	   or SL[period]== nil
	   then
	   return;
	   end
 
	       
			if  SL[period] > SA[period] 
			and   SL[period-1] <= SA[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= SA[period] 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over ", period);
							  SendAlert( Label[id]," Crossed over ", period); 
							  Pop(Label[id], " Cross Over ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  SL[period] < SA[period] 
			and   SL[period-1] >= SA[period-1] 
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= SA[period] 
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under ", period);								 
							 Pop(Label[id], " Cross Under ", period );  	
							 SendAlert( Label[id]," Crossed under ", period);
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
			
			
	  
	 
	  end
	  
	  
	  if id == 2  and ON[id]  then
	  
	   
	   if SB[period]== nil   
	   or SB[period-1]== nil
	   or  SL[period]== nil 
	   or SL[period]== nil
	   then
	   return;
	   end
	  
	       
			if  SL[period] > SB[period] 
			and   SL[period-1] <= SB[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= SB[period] 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over ", period);
							  SendAlert( Label[id]," Crossed over ", period); 
							  Pop(Label[id], " Cross Over ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  SL[period] < SB[period] 
			and   SL[period-1] >= SB[period-1] 
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= SB[period] 
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under ", period);								 
							 Pop(Label[id], " Cross Under ", period );  	
							 SendAlert( Label[id]," Crossed under ", period);
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
			
			
	  
	 
	  end
	  
	  
	  if id == 3  and ON[id]  then
	  
	  
	   if SA[period]== nil   
	   or SA[period-1]== nil
	   or  TL[period]== nil 
	   or TL[period]== nil
	   then
	   return;
	   end
	  
	       
			if  TL[period] > SA[period] 
			and   TL[period-1] <= SA[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= SA[period] 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over ", period);
							  SendAlert( Label[id]," Crossed over ", period); 
							  Pop(Label[id], " Cross Over ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  TL[period] < SA[period] 
			and   TL[period-1] >= SA[period-1] 
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= SA[period] 
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under ", period);								 
							 Pop(Label[id], " Cross Under ", period );  	
							 SendAlert( Label[id]," Crossed under ", period);
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
			
			
	  
	 
	  end
	  
	  
	  
	 if id == 4  and ON[id]  then
	  
	       
	   if SB[period]== nil   
	   or SB[period-1]== nil
	   or  TL[period]== nil 
	   or TL[period]== nil
	   then
	   return;
	   end
	   
				if  TL[period] > SB[period] 
				and   TL[period-1] <= SB[period-1] 
				then
						   
								
			 
					Alert[id][period]= 1;	
					AlertLevel[id][period]= SB[period] 
							   
				
				 D[id] = nil;
							   
								  if U[id]~=source:serial(period) 
								  and period == source:size()-1-Shift
								  and not FIRST 
								  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
								  then
								  
								  U[id]=source:serial(period);
								  SoundAlert(Up[id]);
								  EmailAlert(  Label[id], " Cross Over ", period);
								  SendAlert( Label[id]," Crossed over ", period); 
								  Pop(Label[id], " Cross Over ", period );  
								  OnlyOnceFlag=false;
								  end
								  
				elseif  TL[period] < SB[period] 
				and   TL[period-1] >= SB[period-1] 
				then			
				
										 
								Alert[id][period]= -1;	
								AlertLevel[id][period]= SB[period] 
							   
				 U[id] = nil;
			   
								 if  D[id]~=source:serial(period)
								 and period == source:size()-1-Shift
								 and not FIRST 
								 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
								 then							
								 D[id]=source:serial(period);
								 SoundAlert(Down[id]);			 
								 EmailAlert( Label[id] , " Cross Under ", period);								 
								 Pop(Label[id], " Cross Under ", period );  	
								 SendAlert( Label[id]," Crossed under ", period);
								 OnlyOnceFlag=false;
								 end			   
				 end
			 
			 end
		   
        if FIRST then
        FIRST=false;      
        end		

end


function AsyncOperationFinished (cookie, success, message)
end

 

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

  terminal:alertSound(Sound, RecurrentSound);
end

 


function EmailAlert( label , Subject, period)

if not SendEmail then
return
end
 
    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 
	 
	 
	 

function Pop(label , Subject, period)
  
   if not Show then
   return;
   end
   
    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
   
   core.host:execute ("prompt", 1, label , text );


end


function SendAlert(label ,Subject, period)
    if not ShowAlert then
        return;
    end
	
	local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
 
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
 
    terminal:alertMessage(source:instrument(), source[NOW], text, source:date(NOW));
end

 
 
 



local init = false;
 
function Draw(stage, context)
 
	 if stage~= 2 then
	  return;
	  end
	  
	  
	
        if not init then
           context:createFont (1, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
		
		

		
		for period= math.max(context:firstBar (),source:first()), math.min( context:lastBar (), source:size()-1), 1 do
		
		 
		
		 x, x1, x2= context:positionOfBar (period);
		 
		 for Level = 1 , Number ,  1 do
		   if Alert[Level]:hasData(period) then
		     
		    if Alert[Level][period]== 1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			
			  width, height = context:measureText (1,  "\225", 0);
              context:drawText (1,   "\225", UpTrendColor, -1,  x-width/2 ,  y-height , x+width/2 , y, 0 );	
   
			elseif Alert[Level][period]== -1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			width, height = context:measureText (1,  "\226", 0);
			 context:drawText (1,   "\226", DownTrendColor, -1,  x-width/2  ,  y , x+width/2 ,y+height, 0 );	
		    end
		  end
		    
		 
		end
		end
		
  
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
	
    assert(not (SendEmail and (Email == "" or Email == nil )), "E-mail address must be specified");
	
	
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
	  	 assert( not(PlaySound  and (Up[i] == "" or Up[i] == nil ) ), "Sound file must be chosen");
        assert (not (PlaySoundand  and (Down[i] == "" or Down[i] == nil)), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	 
	end
		 
end	
