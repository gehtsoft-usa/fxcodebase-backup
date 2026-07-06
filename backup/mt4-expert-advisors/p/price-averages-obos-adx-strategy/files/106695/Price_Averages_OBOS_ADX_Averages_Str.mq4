// Id: 16203
//+------------------------------------------------------------------+
//|                         Price_Averages_OBOS_ADX_Averages_Str.mq4 |
//|                               Copyright � 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

#define MAGICMA  33457236

input string MethodStr="Method: 0-SMA, 1-EMA, 2-SMMA, 3-LWMA";
input int Price_Average_Method=0;  // 0 - SMA
                                   // 1 - EMA
                                   // 2 - SMMA
                                   // 3 - LWMA
input int Price_Average_Length=14;
input int OBOS1_Length=14;
input int OBOS2_Length=14;

input int ADX_Length=14;
input int ADX_Average_Method=0;  // 0 - SMA
                                 // 1 - EMA
                                 // 2 - SMMA
                                 // 3 - LWMA
input int ADX_Average_Length=14;

                      
input string Signal_Type_Str="Signal type: 0 - Direct, 1 - Reverse";
input int Signal_Type=0;  // 0 - Direct, 1 - Reverse

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
double Dist;

int OnInit()
{
     double temp = iCustom(NULL, 0, "OBOS", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'OBOS' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "ADX_MA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'ADX_MA' indicator");
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
 
 double PA0, PA1, PA2, OBOS1, OBOS2, ADX_MA0, ADX_MA1;
 
 PA0=iMA(NULL, 0, Price_Average_Length, 0, Price_Average_Method, PRICE_CLOSE, 1);
 PA1=iMA(NULL, 0, Price_Average_Length, 0, Price_Average_Method, PRICE_CLOSE, 2);
 PA2=iMA(NULL, 0, Price_Average_Length, 0, Price_Average_Method, PRICE_CLOSE, 3);
 
 OBOS1=iCustom(NULL, 0, "OBOS", OBOS1_Length, 100, 0, 1)-iCustom(NULL, 0, "OBOS", OBOS1_Length, 100, 1, 1);
 OBOS2=iCustom(NULL, 0, "OBOS", OBOS2_Length, 100, 0, 1)-iCustom(NULL, 0, "OBOS", OBOS2_Length, 100, 1, 1);
 
 ADX_MA0=iCustom(NULL, 0, "ADX_MA", ADX_Length, 0, ADX_Average_Length, ADX_Average_Method, 0, 1);
 ADX_MA1=iCustom(NULL, 0, "ADX_MA", ADX_Length, 0, ADX_Average_Length, ADX_Average_Method, 0, 2);
 
 int CO;
 int res;
 double SL, TP;
 
 CO=CalculateOrders();
 
 if ((Signal_Type==0 && PA0>PA1 && PA1>PA2 && OBOS1>0 && OBOS2>0 && ADX_MA0>ADX_MA1) || (Signal_Type==1 && PA0<PA1 && PA1<PA2 && OBOS1<0 && OBOS2<0 && ADX_MA0>ADX_MA1))
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
 
 if ((Signal_Type==1 && PA0>PA1 && PA1>PA2 && OBOS1>0 && OBOS2>0 && ADX_MA0>ADX_MA1) || (Signal_Type==0 && PA0<PA1 && PA1<PA2 && OBOS1<0 && OBOS2<0 && ADX_MA0>ADX_MA1))
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
  