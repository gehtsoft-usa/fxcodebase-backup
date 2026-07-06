// Id: 15734
//+------------------------------------------------------------------+
//|                                              Two_EWO_SAR_Str.mq4 |
//|                               Copyright � 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

#define MAGICMA  36457436

input int EWO1_Fast_MA_Length=5;
input int EWO1_Slow_MA_Length=35;
input int EWO1_Price=0;    // Applied price
                           // 0 - Close
                           // 1 - Open
                           // 2 - High
                           // 3 - Low
                           // 4 - Median
                           // 5 - Typical
                           // 6 - Weighted  
input int EWO1_Smoothing_Method=0;  // 0 - SMA
                                    // 1 - EMA
                                    // 2 - SMMA
                                    // 3 - LWMA
                                    
input int EWO2_Fast_MA_Length=5;
input int EWO2_Slow_MA_Length=35;
input int EWO2_Price=0;    // Applied price
                           // 0 - Close
                           // 1 - Open
                           // 2 - High
                           // 3 - Low
                           // 4 - Median
                           // 5 - Typical
                           // 6 - Weighted  
input int EWO2_Smoothing_Method=0;  // 0 - SMA
                                    // 1 - EMA
                                    // 2 - SMMA
                                    // 3 - LWMA
                                    
input double SAR_Step=0.02;
input double SAR_Max=0.2;                                    
                                    
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

int OnInit()
{
     double temp = iCustom(NULL, 0, "EWO", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'EWO' indicator");
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
 
 double EWO1_0, EWO1_1, EWO2_0, EWO2_1, SAR0;

 EWO1_0=iCustom(NULL, 0, "EWO", EWO1_Fast_MA_Length, EWO1_Slow_MA_Length, EWO1_Price, EWO1_Smoothing_Method, 4, 1);
 EWO1_1=iCustom(NULL, 0, "EWO", EWO1_Fast_MA_Length, EWO1_Slow_MA_Length, EWO1_Price, EWO1_Smoothing_Method, 4, 2);
 EWO2_0=iCustom(NULL, 0, "EWO", EWO2_Fast_MA_Length, EWO2_Slow_MA_Length, EWO2_Price, EWO2_Smoothing_Method, 4, 1);
 EWO2_1=iCustom(NULL, 0, "EWO", EWO2_Fast_MA_Length, EWO2_Slow_MA_Length, EWO2_Price, EWO2_Smoothing_Method, 4, 2);

 SAR0=iSAR(NULL, 0, SAR_Step, SAR_Max, 1);

 int CO;
 int res;
 double SL, TP;
 
 CO=CalculateOrders();
 
 if ((EWO1_0>EWO1_1 && EWO2_0>EWO2_1 && SAR0<Close[1] && Signal_Type==0) || (EWO1_0<EWO1_1 && EWO2_0<EWO2_1 && SAR0>Close[1] && Signal_Type==1))
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
 
 if ((EWO1_0>EWO1_1 && EWO2_0>EWO2_1 && SAR0<Close[1] && Signal_Type==1) || (EWO1_0<EWO1_1 && EWO2_0<EWO2_1 && SAR0>Close[1] && Signal_Type==0))
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
  