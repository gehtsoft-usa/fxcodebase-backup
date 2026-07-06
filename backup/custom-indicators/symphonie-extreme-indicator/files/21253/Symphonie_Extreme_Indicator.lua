-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10152
-- Id: 5366

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Symphonie extreme indicator");
    indicator:description("Symphonie extreme indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PriceActionFilter", "PriceActionFilter", "PriceActionFilter", 1);
    indicator.parameters:addInteger("Length", "Length", "Length", 3);
    indicator.parameters:addInteger("MajorCycleStrength", "MajorCycleStrength", "MajorCycleStrength", 4);
    indicator.parameters:addInteger("UseCycleFilter", "UseCycleFilter", "UseCycleFilter", 0);
    indicator.parameters:addInteger("UseFilterSMAorRSI", "UseFilterSMAorRSI", "UseFilterSMAorRSI", 1);
    indicator.parameters:addInteger("FilterStrengthSMA", "FilterStrengthSMA", "FilterStrengthSMA", 12);
    indicator.parameters:addInteger("FilterStrengthRSI", "FilterStrengthRSI", "FilterStrengthRSI", 21);
    indicator.parameters:addBoolean("TrackMajorCycleHistory", "TrackMajorCycleHistory", "TrackMajorCycleHistory", true);

	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Line_color", "Color of Line", "Color of Line", core.rgb(128, 128, 128));
    indicator.parameters:addColor("MajorCycleBuy_color", "Color of MajorCycleBuy", "Color of MajorCycleBuy", core.rgb(255, 0, 0));
    indicator.parameters:addColor("MajorCycleSell_color", "Color of MajorCycleSell", "Color of MajorCycleSell", core.rgb(0, 0, 255));
    indicator.parameters:addColor("MinorCycleBuy_color", "Color of MinorCycleBuy", "Color of MinorCycleBuy", core.rgb(128, 128, 128));
    indicator.parameters:addColor("MinorCycleSell_color", "Color of MinorCycleSell", "Color of MinorCycleSell", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 4, 1, 5);
end

local first;
local source = nil;
local ZL1;
local PriceActionFilter;
local Length;
local MajorCycleStrength;
local UseCycleFilter;
local UseFilterSMAorRSI;
local FilterStrengthSMA;
local FilterStrengthRSI;
local TrackMajorCycleHistory;
local MA;
local MA_L;
local MA_H;
local RSI;
local Switch=0;
local SwitchA=0;
local SwitchB=0;
local SwitchC=0;
local SwitchD=0;
local SwitchE=0;
local SwitchAA=0;
local SwitchBB=0;
local SweepA;
local SweepB;
local Price1BuyA=0.;
local Price2BuyA=0.;
local Price1BuyB=1.;
local Price2BuyB=1.;
local Price1SellA=0.;
local Price2SellA=0.;
local Price1SellB=0;
local Price2SellB=0;
local Strength=0.;
local CyclePrice=0.;
local Switch2=0;
local ActiveSwitch=true;
local BuySwitchA=false;
local BuySwitchB=false;
local SellSwitchA=false;
local SellSwitchB=false;
local BuySellFac=1;
local Condition1;
local Condition2;
local Condition3;
local Condition6;
local pos;
local CyclePrice;

function Prepare(nameOnly)
    source = instance.source;
    PriceActionFilter=instance.parameters.PriceActionFilter;
    TrackMajorCycleHistory=instance.parameters.TrackMajorCycleHistory;
    Length=instance.parameters.Length;
    MajorCycleStrength=instance.parameters.MajorCycleStrength;
    UseCycleFilter=instance.parameters.UseCycleFilter;
    UseFilterSMAorRSI=instance.parameters.UseFilterSMAorRSI;
    FilterStrengthSMA=instance.parameters.FilterStrengthSMA;
    FilterStrengthRSI=instance.parameters.FilterStrengthRSI;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. PriceActionFilter .. ", " .. Length .. ", " .. MajorCycleStrength .. ", " .. UseCycleFilter .. ", " .. UseFilterSMAorRSI .. ", " .. FilterStrengthSMA .. ", " .. FilterStrengthRSI .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    ZL1 = instance:addInternalStream(0, 0);
    MA = core.indicators:create("MVA", source.close, PriceActionFilter);
    MA_L = core.indicators:create("MVA", source.low, 250);
    MA_H = core.indicators:create("MVA", source.high, 250);
    RSI = core.indicators:create("RSI", source.close, 14);
    
    first = MA.DATA:first()+250;
    MinorCycleBuy = instance:addStream("MinorCycleBuy", core.Bar, name .. ".MinorCycleBuy", "MinorCycleBuy", instance.parameters.MinorCycleBuy_color, first);
    MinorCycleBuy:setPrecision(math.max(2, instance.source:getPrecision()));
    MinorCycleSell = instance:addStream("MinorCycleSell", core.Bar, name .. ".MinorCycleSell", "MinorCycleSell", instance.parameters.MinorCycleSell_color, first);
    MinorCycleSell:setPrecision(math.max(2, instance.source:getPrecision()));
    MajorCycleBuy = instance:addStream("MajorCycleBye", core.Bar, name .. ".MajorCycleBye", "MajorCycleBye", instance.parameters.MajorCycleBuy_color, first);
    MajorCycleBuy:setPrecision(math.max(2, instance.source:getPrecision()));
    MajorCycleSell = instance:addStream("MajorCycleSell", core.Bar, name .. ".MajorCycleSell", "MajorCycleSell", instance.parameters.MajorCycleSell_color, first);
    MajorCycleSell:setPrecision(math.max(2, instance.source:getPrecision()));
    LineBuff = instance:addStream("Linebuff", core.Line, name .. ".Linebuff", "Linebuff", instance.parameters.Line_color, first);
    LineBuff:setPrecision(math.max(2, instance.source:getPrecision()));
    if TrackMajorCycleHistory then
     MajorCycleBuyHistory = instance:addStream("MajorCycleByeHistory", core.Dot, name .. ".MajorCycleByeHistory", "MajorCycleByeHistory", instance.parameters.MajorCycleBuy_color, first);
    MajorCycleBuyHistory:setPrecision(math.max(2, instance.source:getPrecision()));
     MajorCycleSellHistory = instance:addStream("MajorCycleSellHistory", core.Dot, name .. ".MajorCycleSellHistory", "MajorCycleSellHistory", instance.parameters.MajorCycleSell_color, first);
    MajorCycleSellHistory:setPrecision(math.max(2, instance.source:getPrecision()));
     MajorCycleBuyHistory:setWidth(instance.parameters.DotSize);
     MajorCycleSellHistory:setWidth(instance.parameters.DotSize);
    end
end

function Update(period, mode)
   
     local srange=0.;
     local range=0.;
     MA:update(mode);
     MA_L:update(mode);
     MA_H:update(mode);
     RSI:update(mode);
	 
	  if (period<first) then
	  return;
	  end
	  
     for pos=first+2,period,1 do
      CyclePrice=MA.DATA[pos];
      srange=MA_H.DATA[pos]-MA_L.DATA[pos];
      range=srange*Length;

      if (UseFilterSMAorRSI==1) then
       ZL1[pos]=ZeroLag(CyclePrice,FilterStrengthSMA,pos);
      end
      if (UseFilterSMAorRSI==2) then
       ZL1[pos]=ZeroLag(RSI.DATA[pos],FilterStrengthRSI,pos);
      end
      
      if ZL1[pos]>ZL1[pos-1] then
       SwitchC=1;
      end
      if ZL1[pos]<ZL1[pos-1] then
       SwitchC=2;
      end
      
      SweepA=range;
    
      if pos-first<=3 then
       CyclePrice=MA.DATA[pos];
       Price1BuyA=CyclePrice;
       Price1SellA=CyclePrice;
      end
      
      if pos-first>3 then
      
       CyclePrice=MA.DATA[pos];
       if Switch>-1 then
        if CyclePrice<Price1BuyA then
         if UseCycleFilter==1 and SwitchC==2 and BuySwitchA and Price1BuyB>=first and Price1BuyB<=period then
          MinorCycleBuy[Price1BuyB]=0;
          LineBuff[Price1BuyB]=0;
         end
         if UseCycleFilter==0 and BuySwitchA and Price1BuyB>=first and Price1BuyB<=period then
          MinorCycleBuy[Price1BuyB]=0;
          LineBuff[Price1BuyB]=0;
         end
         Price1BuyA=CyclePrice;
         Price1BuyB=pos;
         BuySwitchA=true;
        else
	 SwitchA=pos-Price1BuyB;
	 if UseCycleFilter==0 and (pos-SwitchA)>=first and (pos-SwitchA)<=period then
	  MinorCycleBuy[pos-SwitchA]=-1;
	  LineBuff[pos-SwitchA]=-1;
	 end
	 if UseCycleFilter==1 and SwitchC==1 and (pos-SwitchA)>=first and (pos-SwitchA)<=period then
	  MinorCycleBuy[pos-SwitchA]=-1;
	  LineBuff[pos-SwitchA]=-1;
	  SwitchD=1;
	 else
	  SwitchD=0; 
	 end
	 BuySwitchA=true;
	 local CyclePrice1=MA.DATA[pos-SwitchA];
	 if ActiveSwitch then
	  if CyclePrice-CyclePrice1>=SweepA then
 	   Condition1=true;
 	  else
	   Condition1=false;
	  end 
	 else
	  if CyclePrice>=CyclePrice1*(1+SweepA/1000.) then
 	   Condition1=true;
	  else
	   Condition1=false;
	  end
	 end
	 if Condition1 and (SwitchA)>=BuySellFac then
	  Switch=-1;
	  Price1SellA=CyclePrice;
	  Price1SellB=pos;
	  SellSwitchA=false;
	  BuySwitchA=false;
	 end
        end
       end
      
      if Switch<1 then
       if CyclePrice>Price1SellA then
        if UseCycleFilter==1 and SwitchC==1 and SellSwitchA  and Price1SellB>=first and Price1SellB<=period then
         MinorCycleSell[Price1SellB]=0;
         LineBuff[Price1SellB]=0;
        end
        if UseCycleFilter==0 and SellSwitchA and Price1SellB>=first and Price1SellB<=period then
         MinorCycleSell[Price1SellB]=0;
         LineBuff[Price1SellB]=0;
        end
        Price1SellA=CyclePrice;
        Price1SellB=pos;
        SellSwitchA=true;
       else
        SwitchA=pos-Price1SellB;
	if UseCycleFilter==0 and (pos-SwitchA)>=first and (pos-SwitchA)<=period then
	 MinorCycleSell[pos-SwitchA]=1;
	 LineBuff[pos-SwitchA]=1;
	end
	if UseCycleFilter==1 and SwitchC==2 and (pos-SwitchA)>=first and (pos-SwitchA)<=period then
	 MinorCycleSell[pos-SwitchA]=1;
	 LineBuff[pos-SwitchA]=1;
	 SwitchD=2;
	else
	 SwitchD=0; 
	end
	SellSwitchA=true;
	local CyclePrice2=MA.DATA[pos-SwitchA];
	if ActiveSwitch then
	 if CyclePrice2-CyclePrice>=SweepA then
	  Condition1=true;
	 else
	  Condition1=false;
	 end
	else
	 if CyclePrice<=CyclePrice2*(1-SweepA/1000.) then
	  Condition1=true;
	 else
	  Condition1=false;
	 end
	end
	if Condition1 and (SwitchA)>=BuySellFac then
	 Switch=1;
	 Price1BuyA=CyclePrice;
	 Price1BuyB=pos;
	 SellSwitchA=false;
	 BuySwitchA=false;
	end
       end
      end
     end
      
     LineBuff[pos]=0;
     MinorCycleBuy[pos]=0;
     MinorCycleSell[pos]=0;
     
     SweepB=range*MajorCycleStrength;
      
      if pos-first<=3 then
       CyclePrice=MA.DATA[pos];
       Price2BuyA=CyclePrice;
       Price2SellA=CyclePrice;
      end
      
      if pos-first>3 then
      
       CyclePrice=MA.DATA[pos];
            
       if Switch2>-1 then
        if CyclePrice<Price2BuyA then
         if UseCycleFilter==1 and SwitchC==2 and BuySwitchB and Price2BuyB>=first and Price2BuyB<=period then
          MajorCycleBuy[Price2BuyB]=nil;
         end
         if UseCycleFilter==0 and BuySwitchB and Price2BuyB>=first and Price2BuyB<=period then
          MajorCycleBuy[Price2BuyB]=nil;
         end
         Price2BuyA=CyclePrice;
         Price2BuyB=pos;
         BuySwitchB=true;
        else
	 SwitchB=pos-Price2BuyB;
	 if UseCycleFilter==0 and (pos-SwitchB)>=first and (pos-SwitchB)<=period then
	  MajorCycleBuy[pos-SwitchB]=-1; 
	  if TrackMajorCycleHistory then
	   MajorCycleBuyHistory[pos-SwitchB]=-1; 
	  end 
	 end
	 if UseCycleFilter==1 and SwitchC==1 and (pos-SwitchB)>=first and (pos-SwitchB)<=period then
	  MajorCycleBuy[pos-SwitchB]=-1;
	  if TrackMajorCycleHistory then
	   MajorCycleBuyHistory[pos-SwitchB]=-1;
	  end 
	  SwitchE=1;
	 else
	  SwitchE=0; 
	 end
	 BuySwitchB=true;
	 local CyclePrice3=MA.DATA[pos-SwitchB];
	 if ActiveSwitch then
	  if CyclePrice-CyclePrice3>=SweepB then
 	   Condition6=true;
 	  else
	   Condition6=false;
	  end 
	 else
	  if CyclePrice>=CyclePrice3*(1+SweepB/1000.) then
 	   Condition6=true;
	  else
	   Condition6=false;
	  end
	 end
	 if Condition6 and (SwitchB)>=BuySellFac then
	  Switch2=-1;
	  Price2SellA=CyclePrice;
	  Price2SellB=pos;
	  SellSwitchB=false;
	  BuySwitchB=false;
	 end
        end
       end
      
      if Switch2<1 then
       if CyclePrice>Price2SellA then
        if UseCycleFilter==1 and SwitchC==1 and SellSwitchB and Price2SellB>=first and Price2SellB<=period then
         MajorCycleSell[Price2SellB]=nil;
        end
        if UseCycleFilter==0 and SellSwitchB and Price2SellB>=first and Price2SellB<=period then
         MajorCycleSell[Price2SellB]=nil;
        end
        Price2SellA=CyclePrice;
        Price2SellB=pos;
        SellSwitchB=true;
       else
        SwitchB=pos-Price2SellB;
	if UseCycleFilter==0 and (pos-SwitchB)>=first and (pos-SwitchB)<=period then
	 MajorCycleSell[pos-SwitchB]=1;
	 if TrackMajorCycleHistory then
  	  MajorCycleSellHistory[pos-SwitchB]=1;
  	 end 
	end
	if UseCycleFilter==1 and SwitchC==2 and (pos-SwitchB)>=first and (pos-SwitchB)<=period then
	 MajorCycleSell[pos-SwitchB]=1;
	 if TrackMajorCycleHistory then
 	  MajorCycleSellHistory[pos-SwitchB]=1;
 	 end 
	 SwitchE=2;
	else
	 SwitchE=0; 
	end
	SellSwitchB=true;
	local CyclePrice4=MA.DATA[pos-SwitchB];
	if ActiveSwitch then
	 if CyclePrice4-CyclePrice>=SweepB then
	  Condition6=true;
	 else
	  Condition6=false;
	 end
	else
	 if CyclePrice<=CyclePrice4*(1-SweepB/1000.) then
	  Condition6=true;
	 else
	  Condition6=false;
	 end
	end
	if Condition6 and (SwitchB)>=BuySellFac then
	 Switch2=1;
	 Price2BuyA=CyclePrice;
	 Price2BuyB=pos;
	 SellSwitchB=false;
	 BuySwitchB=false;
	end
       end
      end
     end
      
     MajorCycleBuy[pos]=nil;
     MajorCycleSell[pos]=nil;
     end
     
    
end

function ZeroLag(price, length, pos)
 if length<3 then
  return price;
 end
 local aa=math.exp(-1.414*3.14159/length);
 local bb=2.*aa*math.cos(1.414*180./length);
 local CB=bb;
 local CC=-aa*aa;
 local CA=1.-CB-CC;
 local CD=CA*price+CB*ZL1[pos-1]+CC*ZL1[pos-2];
 return CD;
end

