// Id: 16211
//+------------------------------------------------------------------+
//|                                         GHLA_Super_Trend_Str.mq4 |
//|                               Copyright � 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

#define MAGICMA  33457236

input int GHLA_Length=10;
input int ST_Length=14;
input int ST_Shift=20;
input bool ST_Use_Filter=true;

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
     double temp = iCustom(NULL, 0, "GHLA_ST_Bar", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'GHLA_ST_Bar' indicator");
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
 
 double U0, U1, D0, D1, N0, N1;
 
 U0=iCustom(NULL, 0, "GHLA_ST_Bar", GHLA_Length, ST_Length, ST_Shift, ST_Use_Filter, 0, 1);
 D0=iCustom(NULL, 0, "GHLA_ST_Bar", GHLA_Length, ST_Length, ST_Shift, ST_Use_Filter, 1, 1);
 N0=iCustom(NULL, 0, "GHLA_ST_Bar", GHLA_Length, ST_Length, ST_Shift, ST_Use_Filter, 2, 1);
 U1=iCustom(NULL, 0, "GHLA_ST_Bar", GHLA_Length, ST_Length, ST_Shift, ST_Use_Filter, 0, 2);
 D1=iCustom(NULL, 0, "GHLA_ST_Bar", GHLA_Length, ST_Length, ST_Shift, ST_Use_Filter, 1, 2);
 N1=iCustom(NULL, 0, "GHLA_ST_Bar", GHLA_Length, ST_Length, ST_Shift, ST_Use_Filter, 2, 2);
 
 int CO;
 int res;
 double SL, TP;
 
 CO=CalculateOrders();
 
 if (N0>0.5 && N1<0.5)
 {
   _Alert("Exit");
   if (Allow_Trade)
   {
    CloseAll();
   } 
 }
 
 if ((Signal_Type==0 && U0>0.5 && U1<0.5) || (Signal_Type==1 && D0>0.5 && D1<0.5))
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
 
 if ((Signal_Type==1 && U0>0.5 && U1<0.5) || (Signal_Type==0 && D0>0.5 && D1<0.5))
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
  