
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3715

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
    indicator:name("Customizable Polynomial regression indicator");
    indicator:description("Polynomial regression indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 50);
    indicator.parameters:addInteger("Power", "Power", "", 2, 1, 9);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("RegUp", "Central Line Up Color", "Central Line Up Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("RegDn", "Central Line Down Color", "Central Line Up Color", core.rgb(255, 0, 0));
	  indicator.parameters:addInteger("width", "width", "width", 1, 1, 5);
    indicator.parameters:addInteger("style", "style", "style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
	
    indicator.parameters:addColor("clrUp", "Color band Up", "Color band", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width1", "width", "width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "style", "style", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addColor("clrDown", "Color band Down", "Color band", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width2", "width", "width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "style", "style", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
end
local db; 
local first;
local source = nil;
local Period;
local Power;
local Deviation;
local BuffReg=nil;
local BuffBandUp=nil;
local BuffBandDn=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Power=instance.parameters.Power;
    Deviation=instance.parameters.Deviation;
    first = source:first()+2;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Power .. ", " .. instance.parameters.Deviation .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    BuffReg = instance:addStream("BuffReg", core.Line, name .. ".Regression", "Regression", instance.parameters.RegUp, first);
	BuffReg:setWidth(instance.parameters.width);
    BuffReg:setStyle(instance.parameters.style);
	
	
    BuffBandUp = instance:addStream("BuffBandUp", core.Line, name .. ".BandUp", "BandUp", instance.parameters.clrUp, first);
    BuffBandDn = instance:addStream("BuffBandDn", core.Line, name .. ".BandDn", "BandDn", instance.parameters.clrDown, first);
   
    BuffBandUp:setWidth(instance.parameters.width1);
    BuffBandUp:setStyle(instance.parameters.style1);
    BuffBandDn:setWidth(instance.parameters.width2);
    BuffBandDn:setStyle(instance.parameters.style2);
	
	
	require("storagedb");
    db = storagedb.get_db(name);	
	core.host:execute("addCommand", 1, "Select Start Date", "");
	core.host:execute("addCommand", 2, "Reset"  , "");	
	core.host:execute ("setTimer", 3,  1);
end

function Update(period, mode)

 
 local Date=tonumber(db:get ( "Period", 0));
 local X= core.findDate (source, Date, false);
  
	  
		    if  Date>=0 then	
            return;
            end			

		   Old(period);

	
 
end

function ReleaseInstance()
core.host:execute ("killTimer", 3);
end

function New(period, x)


  if (period== x) then  
  
    local i,ii;
    local sumxvalue={};
    local sumyvalue={};
    local constant={};
    local matrix={};
    local pos=period-Period+1;
    
    for i=0,Power+1,1 do
     sumyvalue[i]=0;
     constant[i]=0;
     matrix[i]={};
     for ii=0,Power+1,1 do
      matrix[i][ii]=0;
     end
    end
    for i=0,2*Power+1,1 do
     sumxvalue[i]=0;
    end
    sumxvalue[0]=Period;
    local exp;
    for exp=1,2*Power,1 do
     local sumx=0;
     local sumy=0;
     local k;
     for k=1,Period,1 do
      sumx=sumx+math.pow(k,exp);
      if exp==1 then
       sumy=sumy+source[pos+k-1];
      elseif exp<=Power+1 then
       sumy=sumy+source[pos+k-1]*math.pow(k,exp-1);
      end
     end
     sumxvalue[exp]=sumx;
     if sumy~=0 then
      sumyvalue[exp-1]=sumy;
     end
    end

    local row;
    local col;
    for row=0,Power,1 do
     for col=0,Power,1 do
      matrix[row][col]=sumxvalue[row+col];
     end
    end  
    local initialRow=1;
    local initialCol=1;
    for i=1,Power,1 do
     for row=initialRow,Power,1 do
      sumyvalue[row]=sumyvalue[row]-(matrix[row][i-1]/matrix[i-1][i-1])*sumyvalue[i-1];
      for col=initialCol,Power,1 do
       matrix[row][col]=matrix[row][col]-(matrix[row][i-1]/matrix[i-1][i-1])*matrix[i-1][col];
      end
     end
     initialCol=initialCol+1;
     initialRow=initialRow+1;
    end
    local j=0;
    for i=Power,0,-1 do
     if j==0 then
      constant[i]=sumyvalue[i]/matrix[i][i];
     else
      local sum=0;
      local k;
      for k=j,1,-1 do
       sum=sum+constant[i+k]*matrix[i][i+k];
      end 
      constant[i]=(sumyvalue[i]-sum)/matrix[i][i];
     end
     j=j+1;
    end
    k=1;
    for i=period-Period+1,period,1 do
     sum=0;
     for j=0,Power,1 do
      sum=sum+constant[j]*math.pow(k,j);
     end
     BuffReg[i]=sum;
	 if  BuffReg[i] >  BuffReg[i-1] then
	 BuffReg:setColor(i, instance.parameters.RegUp);
	 else
	 BuffReg:setColor(i, instance.parameters.RegDn);
	 end
     k=k+1;
    end
    BuffReg[period-Period]=nil;
    
    sum=0;
    for i=period-Period+1,period,1 do
     sum=sum+math.pow(source[i]-BuffReg[i],2)
    end
    local variance=math.sqrt(sum/Period);
    for i=period-Period+1,period,1 do
     BuffBandUp[i]=BuffReg[i]+Deviation*variance;
     BuffBandDn[i]=BuffReg[i]-Deviation*variance;
	 
    end
    BuffBandUp[period-Period]=nil;
    BuffBandDn[period-Period]=nil;
   end 
end

function Old(period)


  if (period==source:size()-1) then
  
    local i,ii;
    local sumxvalue={};
    local sumyvalue={};
    local constant={};
    local matrix={};
    local pos=period-Period+1;
    
    for i=0,Power+1,1 do
     sumyvalue[i]=0;
     constant[i]=0;
     matrix[i]={};
     for ii=0,Power+1,1 do
      matrix[i][ii]=0;
     end
    end
    for i=0,2*Power+1,1 do
     sumxvalue[i]=0;
    end
    sumxvalue[0]=Period;
    local exp;
    for exp=1,2*Power,1 do
     local sumx=0;
     local sumy=0;
     local k;
     for k=1,Period,1 do
      sumx=sumx+math.pow(k,exp);
      if exp==1 then
       sumy=sumy+source[pos+k-1];
      elseif exp<=Power+1 then
       sumy=sumy+source[pos+k-1]*math.pow(k,exp-1);
      end
     end
     sumxvalue[exp]=sumx;
     if sumy~=0 then
      sumyvalue[exp-1]=sumy;
     end
    end

    local row;
    local col;
    for row=0,Power,1 do
     for col=0,Power,1 do
      matrix[row][col]=sumxvalue[row+col];
     end
    end  
    local initialRow=1;
    local initialCol=1;
    for i=1,Power,1 do
     for row=initialRow,Power,1 do
      sumyvalue[row]=sumyvalue[row]-(matrix[row][i-1]/matrix[i-1][i-1])*sumyvalue[i-1];
      for col=initialCol,Power,1 do
       matrix[row][col]=matrix[row][col]-(matrix[row][i-1]/matrix[i-1][i-1])*matrix[i-1][col];
      end
     end
     initialCol=initialCol+1;
     initialRow=initialRow+1;
    end
    local j=0;
    for i=Power,0,-1 do
     if j==0 then
      constant[i]=sumyvalue[i]/matrix[i][i];
     else
      local sum=0;
      local k;
      for k=j,1,-1 do
       sum=sum+constant[i+k]*matrix[i][i+k];
      end 
      constant[i]=(sumyvalue[i]-sum)/matrix[i][i];
     end
     j=j+1;
    end
    k=1;
    for i=period-Period+1,period,1 do
     sum=0;
     for j=0,Power,1 do
      sum=sum+constant[j]*math.pow(k,j);
     end
     BuffReg[i]=sum;
	 if  BuffReg[i] >  BuffReg[i-1] then
	 BuffReg:setColor(i, instance.parameters.RegUp);
	 else
	 BuffReg:setColor(i, instance.parameters.RegDn);
	 end
     k=k+1;
    end
    BuffReg[period-Period]=nil;
    
    sum=0;
    for i=period-Period+1,period,1 do
     sum=sum+math.pow(source[i]-BuffReg[i],2)
    end
    local variance=math.sqrt(sum/Period);
    for i=period-Period+1,period,1 do
     BuffBandUp[i]=BuffReg[i]+Deviation*variance;
     BuffBandDn[i]=BuffReg[i]-Deviation*variance;
	 
    end
    BuffBandUp[period-Period]=nil;
    BuffBandDn[period-Period]=nil;
   end 
end

local pattern = "([^;]*);([^;]*)";
function AsyncOperationFinished(cookie, success, message)

 local i;

if cookie == 1 then
local level, date;
 level, date = string.match(message, pattern, pos);
db:put("Period", tostring(date));

 for i = first, source:size()-1 ,1  do 
  BuffBandUp[i]=nil;
  BuffBandDn[i]=nil;
  BuffReg[i]=nil;
  end

elseif cookie ==  2 then
db:put("Period", tostring(-1));


  for i = first, source:size()-1 ,1  do 
  BuffBandUp[i]=nil;
  BuffBandDn[i]=nil;
  BuffReg[i]=nil;
  end
  
  
  end 
  if cookie ==  3  or cookie ==  1 then


 local Date=tonumber(db:get ( "Period", 0));
   local X= core.findDate (source, Date, false);
   
	if   Date == -1  or Date == 0 then	
	return;
	end 
	
 local i;
 
	 for i= first, source:size()-1, 1 do  
	
		   New(i, X);
		  
	 end  
    
  end
end
