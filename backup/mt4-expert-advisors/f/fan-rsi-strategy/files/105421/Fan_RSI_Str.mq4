// Id: 15722
//+------------------------------------------------------------------+
//|                                                   Fan_RSI_Str.mq4 |
//|                               Copyright � 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

#define MAGICMA  36457736

input int First_Length=5;
input string Increment_Type_Str="0 - Add, 1 - Mult";
input int Increment_Type=0;    // 0 - Add, 1 - Mult
input int Length_Step=2;
input int RSI_Count=10;
input int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  
input int Average_Length=10;
input int Average_Method=0;  // 0 - SMA
                              // 1 - EMA
                              // 2 - SMMA
                              // 3 - LWMA
input double Buy_Level=0.5;
input double Sell_Level=-0.5; 

input bool Inverse_Direction=false;                             
                      
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
     double temp = iCustom(NULL, 0, "Fan_RSI2", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Fan_RSI2' indicator");
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
 
 double FRSI0, FRSI1;
 
 FRSI0=iCustom(NULL, 0, "Fan_RSI2", First_Length, Increment_Type_Str, Increment_Type, Length_Step, RSI_Count, Price, Average_Length, Average_Method, 2, 1);
 FRSI1=iCustom(NULL, 0, "Fan_RSI2", First_Length, Increment_Type_Str, Increment_Type, Length_Step, RSI_Count, Price, Average_Length, Average_Method, 2, 2);
 
 int CO;
 int res;
 double SL, TP;
 
 if ((FRSI1<Buy_Level && FRSI0>=Buy_Level && !Inverse_Direction) || (FRSI1>Sell_Level && FRSI0<=Sell_Level && Inverse_Direction))
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
 
 if ((FRSI1>Sell_Level && FRSI0<=Sell_Level && !Inverse_Direction) || (FRSI1<Buy_Level && FRSI0>=Buy_Level && Inverse_Direction))
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
  