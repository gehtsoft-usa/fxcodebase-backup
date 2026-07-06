-- Id: 10041
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59565

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
    indicator:name("Polynomial Regression Slope");
    indicator:description("Polynomial Regression Slope");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 50);
    indicator.parameters:addInteger("Power", "Power", "", 2, 1, 9);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Positiv", "Positiv Polynomial vRegression Slope", "Positiv Regression Slope", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Negativ", "Negativ Polynomial Regression Slope", "Negativ Regression Slope", core.rgb(255,0 , 0));

 
 
end

local first;
local source = nil;
local Period;
local Power;
local Positiv, Negativ; 
local End, Start,Slope;
 

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Power=instance.parameters.Power;
	Negativ=instance.parameters.Negativ;
	Positiv=instance.parameters.Positiv;
    
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Power .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Slope = instance:addStream("Slope", core.Bar, name .. ".Polynomial Regression  Slope" , "Regression Slope ",  Positiv, first);
    Slope:setPrecision(math.max(2, instance.source:getPrecision()));
 
end

function Update(period, mode)
Calculate(period);
end



function Calculate(period)
   if (period< first) then
   return;
   end
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
     if i== period-Period+1 then
	 Start=sum;
	 end
	 
     k=k+1;
    end
    End=sum;
    Slope[period]= End-Start;
	
	 if  Slope[period] >  Slope[period-1] then
	 Slope:setColor(period,Positiv);
	 else
	 Slope:setColor(period, Negativ);
	 end
   
end
 
