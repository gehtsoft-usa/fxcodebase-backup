-- Id: 17790
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

function Init()
    indicator:name("Know Sure Thing Oscillator");
    indicator:description("Martin Pring's KST indicator combines the Rate Of Change Oscillator (ROC) for four different time periods into one smoothed indicator.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

 
	
    indicator.parameters:addGroup("Calculation");
    AddParam(1, "First", 10, 10);
    AddParam(2, "Second", 15, 10);
    AddParam(3, "Third", 20, 10);
    AddParam(4, "Fourth", 30, 15);
    AddParam("S", "Signal", nil, 9);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrKST", "Oscillator Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthKST", "Oscillator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleKST", "Oscillator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleKST", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrSIG", "Signal Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthSIG", "Signal Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSIG", "Signal Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSIG", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrLEV", "Level Line Color", "", core.rgb(96, 96, 138));
    indicator.parameters:addInteger("widthLEV", "Level Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleLEV", "Level Line Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("styleLEV", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts");   
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
    indicator.parameters:addString("Live", "Execution", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	
	Parameters (2, "Zero Line Cross");
    Parameters (1, "Signal Line Cross");

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

local 	Number = 2;

function AddParam(id, name, defROC, defMA)
    if defROC ~= nil then
        indicator.parameters:addInteger("ROC" .. id, name .. " ROC Periods", "", defROC, 2, 300);
    end
    indicator.parameters:addInteger("MA" .. id, name .. " MA Periods", "The methods marked with (*) must be downloaded and installed", defMA, 1, 300);
    indicator.parameters:addString("MET" .. id, name .. " Method", "", "MVA");
    indicator.parameters:addStringAlternative("MET" .. id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MET" .. id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MET" .. id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MET" .. id, "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MET" .. id, "SMMA(*)", "", "SMMA");
    indicator.parameters:addStringAlternative("MET" .. id, "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MET" .. id, "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MET" .. id, "Wilders*", "", "WMA");
end


local source;
local roc = {};
local k = {1,2,3,4};
local mva = {};
local kst, signal;
local firstkst, firstsignal;

local Up={};
local Down={};
local Label={};
local ON={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
local Alert;
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
function Prepare()
    source = instance.source;
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	
     font = core.host:execute("createFont", "Wingdings", Size, false, false);

    local i, name, total;
    local _roc, _ma, _met;
    firstkst = 0;
    total = 0;
    name = profile:id() .. "(";
    for i = 1, 4, 1 do
        _roc = instance.parameters:getInteger("ROC" .. i);
        _ma = instance.parameters:getInteger("MA" .. i);
        _met = instance.parameters:getString("MET" .. i);

        roc[i] = core.indicators:create("ROC", source, _roc);
    assert(core.indicators:findIndicator(_met) ~= nil, _met .. " indicator must be installed");
        mva[i] = core.indicators:create(_met, roc[i].DATA, _ma);
        firstkst = math.max(firstkst, mva[i].DATA:first());
        total = total + _roc;

        if i ~= 1 then
            name = name .. ",";
        end
        name = name .. _met .. "(ROC(" .. _roc .. ")," .. _ma .. ")";
    end 
	
    _ma = instance.parameters.MAS;
    _met = instance.parameters.METS;
    name = name .. "," .. _met .. "(" .. _ma .. "))";
    instance:name(name);
    kst = instance:addStream("KST", core.Line, name .. ".KST", "KST", instance.parameters.clrKST, firstkst);
    kst:setPrecision(4);
    kst:addLevel(0, instance.parameters.styleLEV, instance.parameters.widthLEV, instance.parameters.clrLEV);
    kst:setWidth(instance.parameters.widthKST);
    kst:setStyle(instance.parameters.styleKST);

    mva[5] = core.indicators:create(_met, kst, _ma);
    firstsignal = mva[5].DATA:first(); 
    signal = instance:addStream("SIG", core.Line, name .. ".SIG", "SIG", instance.parameters.clrSIG, firstsignal);
    signal:setPrecision(math.max(2, instance.source:getPrecision()));
    signal:setWidth(instance.parameters.widthSIG);
    signal:setStyle(instance.parameters.styleSIG);
	
	Initialization();
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

function Update(period, mode)
   
   Calculation(period,mode);
   
   core.host:execute ("removeLabel", source:serial(period)); 
   
     if period < firstsignal then
	 return;
	 end
	
    Activate (1, period);
    Activate (2, period);   
end

function Calculation (period, mode)
   local i;
    for i = 1, 4, 1 do
        roc[i]:update(mode);
        mva[i]:update(mode);
    end
    if period >= firstkst then
        kst[period] = mva[1].DATA[period] * k[1] + mva[2].DATA[period] * k[2] +
                      mva[3].DATA[period] * k[3] + mva[4].DATA[period] * k[4];
    end
    mva[5]:update(mode);
    if period >= firstsignal then
        signal[period] = mva[5].DATA[period];
    end
end



function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   


function Activate (id, period, SignalFlag)

   local Shift=0;
   

    if Live~= "Live" then
	period=period-1;
	Shift=Shift+1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if  kst[period]> signal[period]
			and kst[period-1]<= signal[period-1]
			then
			           
			 
			 D[id] = nil;
			  core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, signal[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");			   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  
							  EmailAlert(  Label[id], " Cross Over ", period);
							  SendAlert( Label[id], "  Cross Over ", period);							        
							  Pop(Label[id], " Cross Over ", period );  	
								    
								 
							  end
			elseif  kst[period]< signal[period]
			and kst[period-1]>= signal[period-1]
            then			
			
			            			 
			               
						   
		     U[id] = nil;
		     core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, signal[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");	
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);		
							 
							 EmailAlert(  Label[id], " Cross Under ", period);
							  SendAlert( Label[id], " Cross Under ", period);							        
							  Pop(Label[id], " Cross Under ", period); 
							 
			                  end			   
	         end
			
	   elseif id == 2  and ON[id]  then
	   
	      if  kst[period]> 0
			and kst[period-1]<= 0
			then
			           
			 
			 D[id] = nil;
			  core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0, core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");			   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  
							  EmailAlert(  Label[id], " Cross Over ", period);
							  SendAlert( Label[id], " Cross Over ", period);							        
							  Pop(Label[id], " Cross Over ", period );  	
								    
								 
							  end
			elseif  kst[period]< 0
			and kst[period-1]>= 0
            then			
			
			            			 
			               
						   
		     U[id] = nil;
		     core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0, core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");	
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);		
							 
							 EmailAlert(  Label[id], " Cross Under ", period);
							  SendAlert( Label[id], " Cross Under ", period);							        
							  Pop(Label[id], " Cross Under ", period); 
							 
			                  end			   
	         end
			 
			 
	   end
	  
	  
		   
        if FIRST then
        FIRST=false;      
        end		

end


function AsyncOperationFinished (cookie, success, message)
end


function Pop(label , Subject, period)
  
   if not Show then
   return;
   end
   
         local date = source:date(period);
	     local DATA = core.dateToTable (date);
	
			
		   local delim = "\013\010";  
		   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
		   local Symbol= "Instrument : " .. source:instrument() ;
		   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;     
		  
		   
			local text = Note  .. delim ..  Symbol   .. delim .. Time;
 
   core.host:execute ("prompt", 1, profile:id() ,  text );
  

end


function SendAlert(label , Subject, period)
    if not ShowAlert then
        return;
    end
 
   
	     local date = source:date(period);
	     local DATA = core.dateToTable (date);
	
			
		   local delim = "\013\010";  
		   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
		   local Symbol= "Instrument : " .. source:instrument() ;
		   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
		   
			local text = Note  .. delim ..  Symbol   .. delim .. Time;
	
 
    terminal:alertMessage(source:instrument(), source[NOW], text, source:date(NOW));
end

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

  if OnlyOnce and OnlyOnceFlag== false then
 return;
 end
   terminal:alertSound(Sound, RecurrentSound);
 
 
end
 


function EmailAlert( label , Subject, period)

if not SendEmail then
return
end

 if OnlyOnce and OnlyOnceFlag== false then
 return;
 end

 
 
 
    local date = source:date(period);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;     
 
   
    text = Note  .. delim ..  Symbol   .. delim .. Time;
 
	  terminal:alertEmail(Email, profile:id(), text);

  
end