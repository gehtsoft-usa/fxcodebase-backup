-- Id: 19928
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65440

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
end

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
end

function Update(period, mode)
   if period>=first then
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
        elseif mom[period]<mom[period-1] then
          mom:setColor(period, clrDn);
        else
          mom:setColor(period, clrNe);
        end
      elseif ColorOn=="On middle" then
        if mom[period]>levmi[period] then
          mom:setColor(period, clrUp);
        elseif mom[period]<levmi[period] then
          mom:setColor(period, clrDn);
        else
          mom:setColor(period, clrNe);
        end
      else
        if mom[period]>levup[period] then
          mom:setColor(period, clrUp);
        elseif mom[period]<levdn[period] then
          mom:setColor(period, clrDn);
        else
          mom:setColor(period, clrNe);
        end
      end
    end
   end 
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
