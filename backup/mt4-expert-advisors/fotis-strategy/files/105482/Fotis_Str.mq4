// Id: 15760
//+------------------------------------------------------------------+
//|                                                    Fotis_Str.mq4 |
//|                               Copyright � 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

#define MAGICMA  36457436

input int EMA_Length=17;
input int TMACD_Fast_Length=17;
input int TMACD_Slow_Length=51;
input int RSI_Length=17;
input int RSI_MA_Length=51;
                            
input string Allowed_Side_Str="Allowed side: 0 - Both, 1 - Buy, 2 - Sell";
input int Allowed_Side=0;  // 0 - Both, 1 - Buy, 2 - Sell
input bool Allow_Trade=true;
input double Lots=0.1;
input bool Set_Stop=true;
input int Stop=50;
input bool Set_Limit=true;
input int Limit=100;
input bool Show_Alert=true;
input bool Play_Sound=false;
input string Sound_File="";
input bool Send_Email=false;

datetime LastBar;

int OnInit()
{
     double temp = iCustom(NULL, 0, "RSI_MA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'RSI_MA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "TMACD", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'TMACD' indicator");
       return INIT_FAILED;
   }
   LastBar=0;
 
 return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

}
  
void CloseAll()
{
 bool res;
 int OT=OrdersTotal();
 for (int i=OT-1;i>=0;i--)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
  {
   if(OrderType()==OP_BUY)  res=OrderClose(OrderTicket(), OrderLots(), Bid, 5);
   if(OrderType()==OP_SELL) res=OrderClose(OrderTicket(), OrderLots(), Ask, 5);
  }
 }
 
}  

void _Alert(string op)
{
 if (Show_Alert)
 {
  Alert(Symbol()+" :"+op);
 } 
 
 if (Play_Sound)
 {
  PlaySound(Sound_File);
 }
 
 if (Send_Email)
 {
  SendMail(Symbol()+" :", op);
 }
}

int CalculateOrders()
{
 int Count=0;
 for(int i=0;i<OrdersTotal();i++)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
  {
   if(OrderType()==OP_BUY) Count++;
   if(OrderType()==OP_SELL) Count--;
  }
 }
 return (Count);  
}

int Flag_RSI, Flag_TMACD, Flag_Price;

void OnTick()
{
 if (LastBar==Time[1])
 {
  return;
 }
 LastBar=Time[1];
 
 double RSI0, RSI1, RSI_MA0, RSI_MA1;
 double TMACD0, TMACD1;
 double EMA_H0, EMA_H1, EMA_L0, EMA_L1;

 RSI0=iRSI(NULL, 0, RSI_Length, PRICE_CLOSE, 1); 
 RSI1=iRSI(NULL, 0, RSI_Length, PRICE_CLOSE, 2); 
 RSI_MA0=iCustom(NULL, 0, "RSI_MA", RSI_Length, RSI_MA_Length, MODE_SMA, PRICE_CLOSE, 0, 1);
 RSI_MA1=iCustom(NULL, 0, "RSI_MA", RSI_Length, RSI_MA_Length, MODE_SMA, PRICE_CLOSE, 0, 2);
 
 TMACD0=iCustom(NULL, 0, "TMACD", TMACD_Fast_Length, TMACD_Slow_Length, PRICE_CLOSE, 0, 1);
 TMACD1=iCustom(NULL, 0, "TMACD", TMACD_Fast_Length, TMACD_Slow_Length, PRICE_CLOSE, 0, 2);
 
 EMA_H0=iMA(NULL, 0, EMA_Length, 0, MODE_EMA, PRICE_HIGH, 1);
 EMA_H1=iMA(NULL, 0, EMA_Length, 0, MODE_EMA, PRICE_HIGH, 2);
 EMA_L0=iMA(NULL, 0, EMA_Length, 0, MODE_EMA, PRICE_LOW, 1);
 EMA_L1=iMA(NULL, 0, EMA_Length, 0, MODE_EMA, PRICE_LOW, 2);
 
 if (RSI0>RSI_MA0 && RSI1<RSI_MA1)
 {
  Flag_RSI=1;
 }
 else
 {
  if (RSI0<RSI_MA0 && RSI1>RSI_MA1)
  {
   Flag_RSI=-1;
  }
 }
 
 if (TMACD0>0 && TMACD1<0)
 {
  Flag_TMACD=1;
 }
 else
 {
  if (TMACD0<0 && TMACD1>0)
  {
   Flag_TMACD=-1;
  }
 }
 
 if (EMA_H0<Close[1] && EMA_H1>Close[2])
 {
  Flag_Price=1;
 }
 else
 {
  if (EMA_L0>Close[1] && EMA_L1<Close[2])
  {
   Flag_Price=-1;
  }
  else
  {
   if (EMA_H0>Close[1] && EMA_H1<Close[2])
   {
    Flag_Price=0;
   }
   else
   {
    if (EMA_L0<Close[1] && EMA_L1>Close[2])
    {
     Flag_Price=0;
    }
   }
  }
 }
 
 int CO;
 int res;
 double SL, TP;
 
 CO=CalculateOrders();
 
 if (CO<=0 && Flag_Price==1 && Flag_RSI==1 && Flag_TMACD==1 && Close[1]>Open[1])
 {
  _Alert("Buy");
  CO=CalculateOrders();
  if (CO<=0)
  {
   if (Allow_Trade)
   {
    CloseAll();
    if (Allowed_Side!=2)
    {
     if (Set_Stop)
     {
      SL=NormalizeDouble(Bid-Stop*Point, Digits);
     }
     else
     {
      SL=0.;
     } 
     if (Set_Limit)
     {
      TP=NormalizeDouble(Bid+Limit*Point, Digits);
     }
     else
     {
      TP=0.;
     }
     res=OrderSend(Symbol(), OP_BUY, Lots, Ask, 5, SL, TP, "", MAGICMA, 0, Blue); 
    } 
   } 
   
  }
 }
 
 if (CO>=0 && Flag_Price==-1 && Flag_RSI==-1 && Flag_TMACD==-1 && Close[1]<Open[1])
 {
  _Alert("Sell");
  CO=CalculateOrders();
  if (CO>=0)
  {
   if (Allow_Trade)
   {
    CloseAll();
    if (Allowed_Side!=1)
    {
     if (Set_Stop)
     {
      SL=NormalizeDouble(Ask+Stop*Point, Digits);
     }
     else
     { 
      SL=0.;
     } 
     if (Set_Limit)
     {
      TP=NormalizeDouble(Ask-Limit*Point, Digits);
     }
     else
     {
      TP=0.;
     }
     res=OrderSend(Symbol(), OP_SELL, Lots, Bid, 5, SL, TP, "", MAGICMA, 0, Blue); 
    } 
   } 
   
  }
 }
 

}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{

}
  