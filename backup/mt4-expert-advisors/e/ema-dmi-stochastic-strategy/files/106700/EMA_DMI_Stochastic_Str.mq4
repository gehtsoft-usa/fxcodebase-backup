//+------------------------------------------------------------------+
//|                                        EMA_DMI_Stochastic_Str.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

#define MAGICMA  33457236

input string PriceStr="Price: 0-Close, 1-Open, 2-High, 3-Low, 4-Median, 5-Typical, 6-Weighted";
input int Price=0;    // Applied price
                      // 0 - Close
                      // 1 - Open
                      // 2 - High
                      // 3 - Low
                      // 4 - Median
                      // 5 - Typical
                      // 6 - Weighted 
input int MA_Short_Length=12;
input int MA_Mid_Length=30;
input int MA_Long_Length=60;

input int DMI_Length=14;

input int Stoch_K_Length=5;
input int Stoch_D_Length=3;
input int Stoch_Slowing=3;
input string MethodStr="Method: 0-SMA, 1-EMA, 2-SMMA, 3-LWMA";
input int Stoch_Method=0;  // 0 - SMA
                           // 1 - EMA
                           // 2 - SMMA
                           // 3 - LWMA
input string Price_FieldStr="Price field: 0-Low/High, 1-Close/Close";                           
input int Stoch_Price_Field=0; // 0 -Low/High
                               // 1 - Close/Close
input double Sell_Level=50.;                                                          
input double Buy_Level=50.;                                                          
                      
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
 
 double MA1, MA2, MA3, DMIP, DMIM, Stoch_K0, Stoch_K1, Stoch_D0, Stoch_D1;
   
 MA1=iMA(NULL, 0, MA_Short_Length, 0, MODE_EMA, Price, 1); 
 MA2=iMA(NULL, 0, MA_Mid_Length, 0, MODE_EMA, Price, 1); 
 MA3=iMA(NULL, 0, MA_Long_Length, 0, MODE_EMA, Price, 1); 
 
 DMIP=iADX(NULL, 0, DMI_Length, Price, 1, 1);
 DMIM=iADX(NULL, 0, DMI_Length, Price, 2, 1);
 
 Stoch_K0=iStochastic(NULL, 0, Stoch_K_Length, Stoch_D_Length, Stoch_Slowing, Stoch_Method, Stoch_Price_Field, 0, 1);
 Stoch_K1=iStochastic(NULL, 0, Stoch_K_Length, Stoch_D_Length, Stoch_Slowing, Stoch_Method, Stoch_Price_Field, 0, 2);
 Stoch_D0=iStochastic(NULL, 0, Stoch_K_Length, Stoch_D_Length, Stoch_Slowing, Stoch_Method, Stoch_Price_Field, 1, 1);
 Stoch_D1=iStochastic(NULL, 0, Stoch_K_Length, Stoch_D_Length, Stoch_Slowing, Stoch_Method, Stoch_Price_Field, 1, 2);
 
 int CO;
 int res;
 double SL, TP;
 
 CO=CalculateOrders();
 
 if ((Signal_Type==0 && MA1>MA2 && MA2>MA3 && DMIP>DMIM && Stoch_K0<Buy_Level && Stoch_K0>Stoch_D0 && Stoch_K1<=Stoch_D1) || (Signal_Type==1 && MA1<MA2 && MA2<MA3 && DMIP<DMIM && Stoch_K0>Sell_Level && Stoch_K0<Stoch_D0 && Stoch_K1>=Stoch_D1))
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
 
 if ((Signal_Type==1 && MA1>MA2 && MA2>MA3 && DMIP>DMIM && Stoch_K0<Buy_Level && Stoch_K0>Stoch_D0 && Stoch_K1<=Stoch_D1) || (Signal_Type==0 && MA1<MA2 && MA2<MA3 && DMIP<DMIM && Stoch_K0>Sell_Level && Stoch_K0<Stoch_D0 && Stoch_K1>=Stoch_D1))
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
  