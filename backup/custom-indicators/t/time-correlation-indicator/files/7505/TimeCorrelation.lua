-- Id: 2905
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3187&sid=6eb856b7a0e3a5289eb215e2282f8b31

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Time correlation indicator");
    indicator:description("Time correlation indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("TF", "Time frame to calculate correlation", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
    indicator.parameters:addInteger("PeriodsBack", "Number of back periods", "", 2, 1, 100);
    indicator.parameters:addInteger("PeriodsForward", "Number of forward periods", "", 2, 1, 100);
    indicator.parameters:addDouble("Level", "Neutral level", "", 20, 0, 100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", "Color of up signal", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DOWN_color", "Color of down signal", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("NE_color", "Color of neutral signal", "", core.rgb(192, 192, 192));
end

local first;
local source = nil;
local TF;
local PeriodsBack;
local PeriodsForward;
local Level;
local UP;
local DOWN;
local NE1;
local NE2;
local PositiveArray={};
local NegativeArray={};
local LastTime=nil;
local TimeCoeff;
local TimeSize;

function Prepare(nameOnly)
    source = instance.source;
    TF=instance.parameters.TF;
    PeriodsBack=instance.parameters.PeriodsBack;
    PeriodsForward=instance.parameters.PeriodsForward;
    Level=instance.parameters.Level;
    first = source:first()+2;

    local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(TF, core.now(), 0, 0);
    assert ((e - s) < (e1 - s1), "The chosen time frame must be bigger than the chart time frame!");
    local t=math.floor((e-s)*1440+0.1);
    TimeSize=t;
    local t1=math.floor((e1-s1)*1440+0.1);
    local i,f=math.modf(t1/t);
    TimeCoeff=i;
    assert (f<0.01, "The chosen time frame must be multiply of the chart time frame!");
    SizeArray=0;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.TF .. ", " .. instance.parameters.PeriodsBack .. ", " .. instance.parameters.PeriodsForward .. ", " .. instance.parameters.Level .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    UP = instance:addStream("UP", core.Bar, name .. "UP", "UP", instance.parameters.UP_color, first,PeriodsForward*TimeCoeff);
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
    DOWN = instance:addStream("DN", core.Bar, name .. "DN", "DN", instance.parameters.DOWN_color, first,PeriodsForward*TimeCoeff);
    DOWN:setPrecision(math.max(2, instance.source:getPrecision()));
    NE1 = instance:addStream("NE1", core.Bar, name .. "NE", "NE", instance.parameters.NE_color, first,PeriodsForward*TimeCoeff);
    NE1:setPrecision(math.max(2, instance.source:getPrecision()));
    NE2 = instance:addStream("NE2", core.Bar, name .. "NE", "NE", instance.parameters.NE_color, first,PeriodsForward*TimeCoeff);
    NE2:setPrecision(math.max(2, instance.source:getPrecision()));
    UP:addLevel(-100);
    UP:addLevel(-50);
    UP:addLevel(50);
    UP:addLevel(100);
end

function Update(period, mode)
   if (period>first and period==source:size()-1) then
    if LastTime~=source:date(period) then
     LastTime=source:date(period);
     local i;
     for i=1,TimeCoeff+3,1 do
      PositiveArray[i]=0;
      NegativeArray[i]=0;
     end
     local i2;
     for i2=first,period-1,1 do
      local s,e=core.getcandle(source:barSize(),source:date(i2),0,0)
      local t=math.floor(s*1440/TimeSize+0.1);
      local i,f=math.modf(t/TimeCoeff);
      f=math.floor(f*TimeCoeff+0.1)+1;
      if source.open[i2]>source.close[i2] then
       NegativeArray[f]=NegativeArray[f]+1;
      elseif source.open[i2]<source.close[i2] then
       PositiveArray[f]=PositiveArray[f]+1;
      end
     end 

     s,e=core.getcandle(source:barSize(),source:date(period),0,0)
     t=math.floor(s*1440/TimeSize+0.1);
     local ii;
     ii,f=math.modf(t/TimeCoeff);
     local Maxi=ii;
     i2=period;
     while Maxi-ii<PeriodsBack and i2>first do
      local s,e=core.getcandle(source:barSize(),source:date(i2),0,0)
      local t=math.floor(s*1440/TimeSize+0.1);
      local i,f=math.modf(t/TimeCoeff);
      f=math.floor(f*TimeCoeff+0.1)+1;
      if NegativeArray[f]~=0 or PositiveArray[f]~=0 then
       local up=PositiveArray[f]/(PositiveArray[f]+NegativeArray[f])*100;
       local down=NegativeArray[f]/(PositiveArray[f]+NegativeArray[f])*100;
       if up>=Level then
        UP[i2]=up;
        NE1[i2]=0;
       else
        NE1[i2]=up;
        UP[i2]=0;
       end
       if down>=Level then
        DOWN[i2]=-down;
        NE2[i2]=0;
       else
        NE2[i2]=-down;
        DOWN[i2]=0;
       end
      else
       UP[i2]=0;
       DOWN[i2]=0; 
       NE1[i2]=0;
       NE2[i2]=0;
      end
      
      i2=i2-1;
      s,e=core.getcandle(source:barSize(),source:date(i2),0,0)
      t=math.floor(s*1440/TimeSize+0.1);
      ii,f=math.modf(t/TimeCoeff);
     end
     
     s,e=core.getcandle(source:barSize(),source:date(period),0,0)
     t=math.floor(s*1440/TimeSize+0.1);
     i,f=math.modf(t/TimeCoeff);
     f=math.floor(f*TimeCoeff+0.1)+1;
     
     for ii=period+1,period+PeriodsForward*TimeCoeff,1 do
      f=f+1;
      if f>TimeCoeff then
       f=1;
      end
      if NegativeArray[f]~=0 or PositiveArray[f]~=0 then
       up=PositiveArray[f]/(PositiveArray[f]+NegativeArray[f])*100;
       down=NegativeArray[f]/(PositiveArray[f]+NegativeArray[f])*100;
       if up>=Level then
        UP[ii]=up;
        NE1[ii]=0;
       else
        NE1[ii]=up;
        UP[ii]=0;
       end
       if down>=Level then
        DOWN[ii]=-down;
        NE2[ii]=0;
       else
        NE2[ii]=-down;
        DOWN[ii]=0;
       end
      else
       UP[i2]=0;
       DOWN[i2]=0; 
       NE1[i2]=0;
       NE2[i2]=0;
      end 
      
     end
     
     
    end
   else
    LastTime=nil; 
   end 
end

