function Init()
    indicator:name("Polynomial regression indicator");
    indicator:description("Polynomial regression indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 50);
    indicator.parameters:addInteger("Power", "Power", "", 2, 1, 9);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrReg", "Color regression", "Color regression", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "width", "width", 1, 1, 5);
    indicator.parameters:addInteger("style", "style", "style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
end

local first;
local source = nil;
local Period;
local Power;
local Deviation;
local BuffReg=nil;

function Prepare()
    source = instance.source;
    Period=instance.parameters.Period;
    Power=instance.parameters.Power;
    Deviation=instance.parameters.Deviation;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Power .. ", " .. instance.parameters.Deviation .. ")";
    instance:name(name);
    BuffReg = instance:addStream("BuffReg", core.Line, name .. ".Regression", "Regression", instance.parameters.clrReg, first);
    BuffReg:setWidth(instance.parameters.width);
    BuffReg:setStyle(instance.parameters.style);
end

function Update(period, mode)
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
     k=k+1;
    end
    BuffReg[period-Period]=nil;
    
    sum=0;
    for i=period-Period+1,period,1 do
     sum=sum+math.pow(source[i]-BuffReg[i],2)
    end
    local variance=math.sqrt(sum/Period);
   end 
end

