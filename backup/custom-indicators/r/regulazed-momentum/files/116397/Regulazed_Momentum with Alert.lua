-- Id: 22371
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65440

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

function Init()
    indicator:name("Regulazed Momentum indicator");
    indicator:description("Regulazed Momentum indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Length", "Length", "", 14);

    indicator.parameters:addString("Price", "Price", "", "Close");
    indicator.parameters:addStringAlternative("Price", "Close", "", "Close");
    indicator.parameters:addStringAlternative("Price", "Open", "", "Open");
    indicator.parameters:addStringAlternative("Price", "High", "", "High");
    indicator.parameters:addStringAlternative("Price", "Low", "", "Low");
    indicator.parameters:addStringAlternative("Price", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Price", "Typical", "", "Typical");
    indicator.parameters:addStringAlternative("Price", "Weighted", "", "Weighted");
    indicator.parameters:addStringAlternative("Price", "Average (high+low+open+close)/4", "", "Average (high+low+open+close)/4");
    indicator.parameters:addStringAlternative("Price", "Average median body (open+close)/2", "", "Average median body (open+close)/2");
    indicator.parameters:addStringAlternative("Price", "Trend biased price", "", "Trend biased price");
    indicator.parameters:addStringAlternative("Price", "Trend biased (extreme) price", "", "Trend biased (extreme) price");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi close", "", "Heiken ashi close");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi open", "", "Heiken ashi open");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi high", "", "Heiken ashi high");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi low", "", "Heiken ashi low");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi median", "", "Heiken ashi median");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi typical", "", "Heiken ashi typical");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi weighted", "", "Heiken ashi weighted");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi average", "", "Heiken ashi average");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi median body", "", "Heiken ashi median body");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi trend biased price", "", "Heiken ashi trend biased price");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi trend biased (extreme) price", "", "Heiken ashi trend biased (extreme) price");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi (better formula) close", "", "Heiken ashi (better formula) close");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi (better formula) open", "", "Heiken ashi (better formula) open");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi (better formula) high", "", "Heiken ashi (better formula) high");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi (better formula) low", "", "Heiken ashi (better formula) low");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi (better formula) median", "", "Heiken ashi (better formula) median");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi (better formula) typical", "", "Heiken ashi (better formula) typical");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi (better formula) weighted", "", "Heiken ashi (better formula) weighted");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi (better formula) average", "", "Heiken ashi (better formula) average");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi (better formula) median body", "", "Heiken ashi (better formula) median body");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi (better formula) trend biased price", "", "Heiken ashi (better formula) trend biased price");
    indicator.parameters:addStringAlternative("Price", "Heiken ashi (better formula) trend biased (extreme) price", "", "Heiken ashi (better formula) trend biased (extreme) price");

    indicator.parameters:addDouble("Lambda", "Lambda", "", 7);

    indicator.parameters:addString("LevelType", "Level type", "", "Quantile level");
    indicator.parameters:addStringAlternative("LevelType", "Floating levels", "", "Floating levels");
    indicator.parameters:addStringAlternative("LevelType", "Quantile level", "", "Quantile level");

    indicator.parameters:addInteger("MinMaxPeriod", "Min max period", "", 15);
    indicator.parameters:addDouble("LevelUp", "Level up", "", 90);
    indicator.parameters:addDouble("LevelDown", "Level down", "", 10);

    indicator.parameters:addString("ColorOn", "Change color on", "", "On slope");
    indicator.parameters:addStringAlternative("ColorOn", "On slope", "", "On slope");
    indicator.parameters:addStringAlternative("ColorOn", "On middle", "", "On middle");
    indicator.parameters:addStringAlternative("ColorOn", "On levels", "", "On levels");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUp", "Color Up", "Color Up", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDn", "Color Dn", "Color Dn", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrNe", "Color Ne", "Color Ne", core.rgb(128, 128, 0));
    indicator.parameters:addInteger("LineWidth", "Line width", "", 3, 1, 5);
    indicator.parameters:addColor("clrSh", "Shadow Color", "Shadow Color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("ShWidth", "Shadow width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "Execution", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");  

 
	 
	indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
	indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6);	

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

	
	Parameters (1, "Cross");	
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

local 	Number = 1;
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
local ShowAlert;
local Alert={}; 
local AlertLevel={};
local ToTime;
local Shift=0; 



local first;
local source = nil;
local Length;
local Price;
local Lambda;
local LevelType;
local MinMaxPeriod;
local LevelUp;
local LevelDown;
local ColorOn;
local clrUp, clrDn, clrNe;

local HAopen, HAclose, HAhigh, HAlow;
local HABF;

local _workQuant={};
local _sortQuant={};

local levup, levmi, levdn, mom;
local rema;
local alpha, regf1, regf2;

function GetPrice(index)
  if Price=="Close" then
    return source.close[index];
  elseif Price=="Open" then
    return source.open[index];
  elseif Price=="High" then
    return source.high[index];
  elseif Price=="Low" then
    return source.low[index];
  elseif Price=="Median" then
    return (source.high[index]+source.low[index])/2;
  elseif Price=="Typical" then
    return (source.high[index]+source.low[index]+source.close[index])/3;
  elseif Price=="Weighted" then
    return (source.high[index]+source.low[index]+2*source.close[index])/4;
  elseif Price=="Average (high+low+open+close)/4" then
    return (source.high[index]+source.low[index]+source.open[index]+source.close[index])/4;
  elseif Price=="Average median body (open+close)/2" then
    return (source.open[index]+source.close[index])/2;
  elseif Price=="Trend biased price" then
    if source.close[index]>source.open[index] then
      return (source.high[index]+source.close[index])/2;
    else
      return (source.low[index]+source.close[index])/2;
    end
  elseif Price=="Heiken ashi close" then
    return HAclose[index];
  elseif Price=="Heiken ashi open" then
    return HAopen[index];
  elseif Price=="Heiken ashi high" then
    return HAhigh[index];
  elseif Price=="Heiken ashi low" then
    return HAlow[index];
  elseif Price=="Heiken ashi median" then
    return (HAhigh[index]+HAlow[index])/2;
  elseif Price=="Heiken ashi typical" then
    return (HAhigh[index]+HAlow[index]+HAclose[index])/3;
  elseif Price=="Heiken ashi weighted"   then
    return (HAhigh[index]+HAlow[index]+2*HAclose[index])/4;
  elseif Price=="Heiken ashi average" then
    return (HAclose[index]+HAopen[index]+HAhigh[index]+HAlow[index])/4;
  elseif Price=="Heiken ashi median body" then
    return (HAopen[index]+HAclose[index])/2;
  elseif Price=="Heiken ashi trend biased price" then
    if HAclose[index]>HAopen[index] then
      return (HAhigh[index]+HAclose[index])/2;
    else
      return (HAlow[index]+HAclose[index])/2;
    end
  elseif Price=="Heiken ashi (better formula) close" then
    return HAclose[index];
  elseif Price=="Heiken ashi (better formula) open" then
    return HAopen[index];
  elseif Price=="Heiken ashi (better formula) high" then
    return HAhigh[index];
  elseif Price=="Heiken ashi (better formula) low" then
    return HAlow[index];
  elseif Price=="Heiken ashi (better formula) median" then
    return (HAhigh[index]+HAlow[index])/2;
  elseif Price=="Heiken ashi (better formula) typical" then
    return (HAhigh[index]+HAlow[index]+HAclose[index])/3;
  elseif Price=="Heiken ashi (better formula) weighted"   then
    return (HAhigh[index]+HAlow[index]+2*HAclose[index])/4;
  elseif Price=="Heiken ashi (better formula) average" then
    return (HAclose[index]+HAopen[index]+HAhigh[index]+HAlow[index])/4;
  elseif Price=="Heiken ashi (better formula) median body" then
    return (HAopen[index]+HAclose[index])/2;
  elseif Price=="Heiken ashi (better formula) trend biased price" then
    if HAclose[index]>HAopen[index] then
      return (HAhigh[index]+HAclose[index])/2;
    else
      return (HAlow[index]+HAclose[index])/2;
    end
  end  
end

function Prepare(nameOnly) 
    source = instance.source;
    Length=instance.parameters.Length;
    Price=instance.parameters.Price;
    Lambda=instance.parameters.Lambda;
    LevelType=instance.parameters.LevelType;
    MinMaxPeriod=instance.parameters.MinMaxPeriod;
    LevelUp=instance.parameters.LevelUp;
    LevelDown=instance.parameters.LevelDown;
    ColorOn=instance.parameters.ColorOn;
    clrUp=instance.parameters.clrUp;
    clrDn=instance.parameters.clrDn;
    clrNe=instance.parameters.clrNe;
    first = source:first()+2;
    HAopen = instance:addInternalStream(first, 0);
    HAclose = instance:addInternalStream(first, 0);
    HAhigh = instance:addInternalStream(first, 0);
    HAlow = instance:addInternalStream(first, 0);

    if string.find(Price, "(better formula)")==nil then
      HABF=false;
    else
      HABF=true;
    end

    alpha=2/(1+Length);      
    regf1=1+Lambda*2;
    regf2=1+Lambda;

    rema=instance:addInternalStream(first);

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	ToTime=instance.parameters.ToTime;
	
	if ToTime == 1 then
	ToTime=core.TZ_EST;
	elseif ToTime == 2 then
	ToTime=core.TZ_UTC;
	elseif ToTime == 3 then
	ToTime=core.TZ_LOCAL;
	elseif ToTime == 4 then
	ToTime=core.TZ_SERVER;
	elseif ToTime == 5 then
	ToTime=core.TZ_FINANCIAL;
	elseif ToTime == 6 then
	ToTime=core.TZ_TS;
	end
	
    
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	
	
    levup = instance:addStream("levup", core.Line, name .. ".levup", "levup", instance.parameters.clrSh, first);
    levup:setPrecision(math.max(2, instance.source:getPrecision()));
    levmi = instance:addStream("levmi", core.Line, name .. ".levmi", "levmi", instance.parameters.clrSh, first);
    levmi:setPrecision(math.max(2, instance.source:getPrecision()));
    levdn = instance:addStream("levdn", core.Line, name .. ".levdn", "levdn", instance.parameters.clrSh, first);
    levdn:setPrecision(math.max(2, instance.source:getPrecision()));
    levup:setWidth(instance.parameters.ShWidth);
    levmi:setWidth(instance.parameters.ShWidth);
    levdn:setWidth(instance.parameters.ShWidth);
    mom = instance:addStream("mom", core.Line, name .. ".mom", "mom", instance.parameters.clrUp, first);
    mom:setPrecision(math.max(2, instance.source:getPrecision()));
    mom:setWidth(instance.parameters.LineWidth);
	
	
	for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
     end
	
	Initialization();	
	instance:ownerDrawn(true);	 
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
		     
		    if Alert[Level][period]== 1 
			and Alert[Level][period-1]~= 1 
			then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			
			  width, height = context:measureText (1,  "\225", 0);
              context:drawText (1,   "\225", UpTrendColor, -1,  x-width/2 ,  y , x+width/2 , y+height, 0 );	
   
			elseif Alert[Level][period]== -1
			and Alert[Level][period-1]~= -1 
			then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			width, height = context:measureText (1,  "\226", 0);
			 context:drawText (1,   "\226", DownTrendColor, -1,  x-width/2  ,  y-height, x+width/2 ,y, 0 );	
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

function Update(period, mode)
   if period<first then
   return;
   end
   
    if period==first then
      HAopen[period]=(source.open[period]+source.close[period])/2;
    else
      HAopen[period]=(HAopen[period-1]+HAclose[period-1])/2;
    end
    HAclose[period]=(source.open[period]+source.close[period]+source.low[period]+source.high[period])/4;

    if HABF then
      if source.high[period]~=source.low[period] then
        HAclose[period]=(source.open[period]+source.close[period])/2+(((source.close[period]-source.open[period])/(source.high[period]-source.low[period]))*math.abs((source.close[period]-source.open[period])/2));
      else
        HAclose[period]=(source.open[period]+source.close[period])/2;
      end
    end

    HAlow[period]=math.min(source.low[period], HAopen[period], HAclose[period]);
    HAhigh[period]=math.max(source.high[period], HAopen[period], HAclose[period]);

    local pr=GetPrice(period);

    if period==first then
      rema[period]=pr;
    else
      rema[period]=(regf1*rema[period-1]+alpha*(pr-rema[period-1])-Lambda*rema[period-2])/regf2;
    end
    mom[period]=(rema[period]-rema[period-1])/rema[period];

    if period>first+MinMaxPeriod then

      local hi, lo=mom[period], mom[period];

      if LevelType=="Floating levels" then
        if MinMaxPeriod>0 then
          local min, max, minb, maxb=mathex.minmax(mom, period-MinMaxPeriod+1, period);
          hi=mom[maxb];
          lo=mom[minb];
          hi=lo+(hi-lo)*LevelUp/100;
          lo=lo+(hi-lo)*LevelDown/100;
        end
        levup[period]=hi;
        levdn[period]=lo;
        levmi[period]=(hi+lo)/2;
      else
        levup[period]=iQuantile(mom[period], MinMaxPeriod, LevelUp, period, source:size()-1);
        levdn[period]=iQuantile(mom[period], MinMaxPeriod, LevelDown, period, source:size()-1);
        levmi[period]=iQuantile(mom[period], MinMaxPeriod, (LevelUp+LevelDown)/2, period, source:size()-1);
      end
      if ColorOn=="On slope" then
        if mom[period]>mom[period-1] then
          mom:setColor(period, clrUp);
		  
		       Alert[1][period]=1;	
			   AlertLevel[1][period]= mom[period]
							
        elseif mom[period]<mom[period-1] then
          mom:setColor(period, clrDn);
		      Alert[1][period]=-1;	
			   AlertLevel[1][period]= mom[period]
        else
          mom:setColor(period, clrNe);
		  
		      Alert[1][period]=0;	
			   AlertLevel[1][period]= mom[period]
        end
      elseif ColorOn=="On middle" then
        if mom[period]>levmi[period] then
          mom:setColor(period, clrUp);
		  
		       Alert[1][period]=1;	
			   AlertLevel[1][period]= mom[period]
        elseif mom[period]<levmi[period] then
          mom:setColor(period, clrDn); 
		  
		       Alert[1][period]=-1;	
			   AlertLevel[1][period]= mom[period]
        else
          mom:setColor(period, clrNe);
		  
		        Alert[1][period]=0;	
			   AlertLevel[1][period]= mom[period]
        end
      else
        if mom[period]>levup[period] then
          mom:setColor(period, clrUp);
		  
		       Alert[1][period]=1;	
			   AlertLevel[1][period]= mom[period]
        elseif mom[period]<levdn[period] then
          mom:setColor(period, clrDn);
		       Alert[1][period]=-1;	
			   AlertLevel[1][period]= mom[period]
        else
          mom:setColor(period, clrNe);
		       Alert[1][period]=0;	
			   AlertLevel[1][period]= mom[period]
        end
      end
    end
    
	
	if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	
     if period < first then
	 return;
	 end
	
    Activate (1, period)
	
end

function iQuantile(value, period, qp, i, bars)
  if period==source:size()-1 then
    return value;
  end
  _workQuant[i]=value;
  local k, k2, lastk;

  for k=0, period, 1 do
    lastk=k;
    if i-k<0 then
      break;
    end
    _sortQuant[k]=_workQuant[i-k];
  end

  for k2=lastk, period, 1 do
    _sortQuant[k2]=0;
  end

  table.sort(_sortQuant);

  local index=(period-1)*qp/100;
  local ind=math.floor(index);
  local delta=index-ind;

  if math.abs(ind-index)<=0.00001 then
    return _sortQuant[ind];
  else
    if _sortQuant[ind]~=nil and _sortQuant[ind+1]~=nil then
      return (1-delta)*_sortQuant[ind]+delta*_sortQuant[ind+1];
    else
      return _sortQuant[ind];
    end  
  end

end



function Activate (id, period)


  
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if   Alert[id][period]==1 
			and   Alert[id][period-1]~=1 
			then
			           
						    
         
               
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over ");
							  SendAlert( Label[id]," Crossed over "); 
							  Pop(Label[id], " Cross Over ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif Alert[id][period]==-1 
			and   Alert[id][period-1]~=-1 
            then			
			
			            			 
			           
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under ");								 
							 Pop(Label[id], " Cross Under ", period );  	
							 SendAlert( Label[id]," Crossed under ");
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

 


function EmailAlert( label , Subject)

if not SendEmail then
return
end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 
	 
	 
	 

function Pop(label , Subject )
  
   if not Show then
   return;
   end
   
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
	
    
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
	
	local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
 
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
 
    terminal:alertMessage(source:instrument(), source[NOW], text, now);
end
