// Id: 24244
//+------------------------------------------------------------------+
//|                                             Breakout_Str.mq4.mq4 |
//|                               Copyright © 2019, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

#define MAGICMA  3454363

enum Side_Types{Both, Buy, Sell};

input string PeriodBegin="00:00";
input string PeriodEnd="05:00";
input string BoxEnd="23:00";
                            
input Side_Types Allowed_Side=Both;
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
     double temp = iCustom(NULL, 0, "Breakout", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Breakout' indicator");
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

void OnTick()
{
 if (LastBar==Time[1])
 {
  return;
 }
 LastBar=Time[1];
 
 double BrU, BrL;
 
 BrU=iCustom(NULL, 0, "Breakout", PeriodBegin, PeriodEnd, BoxEnd, 2, 1);
 BrL=iCustom(NULL, 0, "Breakout", PeriodBegin, PeriodEnd, BoxEnd, 3, 1);
 
 int CO;
 int res;
 double SL, TP;
 
 CO=CalculateOrders();
 
 if (Low[1]<BrL && Close[1]>BrU)
 {
  if (CO<0)
  {
   _Alert("Close Sell");
   CloseAll();
  }
  _Alert("Buy");
  if (Allow_Trade)
  {
   if (Allowed_Side!=Sell)
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
 
 if (High[1]>BrU && Close[1]<BrL)
 {
  if (CO>0)
  {
   _Alert("Close Buy");
   CloseAll();
  }
  _Alert("Sell");
  if (Allow_Trade)
  {
   if (Allowed_Side!=Buy)
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

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{

}
  