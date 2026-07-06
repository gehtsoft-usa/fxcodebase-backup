//+------------------------------------------------------------------+
//|                                                SL_Calculator.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

extern color TextColor=Yellow;
extern int Corner=1;
extern int VOffset=5;
extern int HOffset=15;
extern int HStep=15;
extern int TextSize=12;

string ObjName="SL_Calculator_Text";

int init()
  {

   return(0);
  }

int deinit()
  {
   ObjectDelete(ObjName+"1");
   ObjectDelete(ObjName+"2");
   return(0);
  }

int start()
{
 int WithoutSL=0;
 double SLAmount=0;
 double LotSize, SymbPoint, TickSize, TickValue;
 int ProfitCalcMode;
 string Symb;
 string Str1="";
 string Str2="";
 for(int i=0;i<OrdersTotal();i++)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
  {
   if(OrderType()==OP_BUY || OrderType()==OP_SELL)
   {
    if (OrderStopLoss()==0)
    {
     WithoutSL++;
    }
    else
    {
     Symb=OrderSymbol();
     SymbPoint=MarketInfo(Symb, MODE_POINT);
     LotSize=MarketInfo(Symb, MODE_LOTSIZE);
     TickSize=MarketInfo(Symb, MODE_TICKSIZE);
     TickValue=MarketInfo(Symb, MODE_TICKVALUE);
     ProfitCalcMode=MarketInfo(Symb, MODE_PROFITCALCMODE);
     if (OrderType()==OP_BUY)
     {
      if (ProfitCalcMode==0)
      {
       SLAmount+=(OrderOpenPrice()-OrderStopLoss())*TickValue*OrderLots()/SymbPoint;
      } 
      else
      {
       SLAmount+=(OrderOpenPrice()-OrderStopLoss())*TickValue*OrderLots()/(SymbPoint*TickSize*LotSize);
      } 
     }
     if (OrderType()==OP_SELL)
     {
      if (ProfitCalcMode==0)
      {
       SLAmount+=(OrderStopLoss()-OrderOpenPrice())*TickValue*OrderLots()/SymbPoint;
      } 
      else
      {
       SLAmount+=(OrderStopLoss()-OrderOpenPrice())*TickValue*OrderLots()/(SymbPoint*TickSize*LotSize);
      } 
     }
     SLAmount+=OrderCommission()-OrderSwap();
    }
   }
  }
 }
 Str1="The maximum possible loss: "+DoubleToStr(SLAmount,2)+" "+AccountCurrency();
 if (WithoutSL==1)
 {
  Str2="There is 1 order without stoploss level";
 }
 else
 {
  if (WithoutSL>1)
  {
   Str2="There are "+DoubleToStr(WithoutSL,0)+" orders without stoploss level";
  }
 }
 
 if (ObjectFind(ObjName+"1")==-1) ObjectCreate(ObjName+"1", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(ObjName+"2")==-1) ObjectCreate(ObjName+"2", OBJ_LABEL, 0, 0, 0);
 ObjectSetText(ObjName+"1", Str1, TextSize);
 ObjectSet(ObjName+"1", OBJPROP_COLOR, TextColor);
 ObjectSet(ObjName+"1", OBJPROP_XDISTANCE, VOffset);
 ObjectSet(ObjName+"1", OBJPROP_YDISTANCE, HOffset);
 ObjectSet(ObjName+"1", OBJPROP_CORNER, Corner);
 ObjectSetText(ObjName+"2", Str2, TextSize);
 ObjectSet(ObjName+"2", OBJPROP_COLOR, TextColor);
 ObjectSet(ObjName+"2", OBJPROP_XDISTANCE, VOffset);
 ObjectSet(ObjName+"2", OBJPROP_YDISTANCE, HOffset+HStep);
 ObjectSet(ObjName+"2", OBJPROP_CORNER, Corner);
 return(0);
}

