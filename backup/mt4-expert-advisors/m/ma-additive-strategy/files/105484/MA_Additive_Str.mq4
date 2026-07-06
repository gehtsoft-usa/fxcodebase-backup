//+------------------------------------------------------------------+
//|                                              MA_Additive_Str.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

#define MAGICMA  36457736

input int First_Length=5;
input string Increment_Type_Str="0 - Add, 1 - Mult";
input int Increment_Type=0;    // 0 - Add, 1 - Mult
input int Length_Step=2;
input int MA_Count=10;
input int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
input int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

input bool Inverse_Direction=false;                                                        

input double Lots=0.1;

input bool Show_Alert=true;
input bool Play_Sound=false;
input string Sound_File="";
input bool Send_Email=false;

datetime LastBar;

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

void ChangeOrders(int CloseO, int OpenO)
{
 int i, res;
 
 if (CloseO!=0)
 {
  int _CloseO=CloseO;
  for(i=OrdersTotal()-1;i>=0;i--)
  {
   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
   if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
   {
    if(OrderType()==OP_BUY && _CloseO>0)
    {
     OrderClose(OrderTicket(), OrderLots(), Bid, 5);
     _Alert("Close Buy");
     _CloseO--;
    }
    if(OrderType()==OP_SELL && _CloseO<0)
    {
     OrderClose(OrderTicket(), OrderLots(), Ask, 5);
     _Alert("Close Sell");
     _CloseO++;
    }
   }
  }
  
 }
 
 if (OpenO>0)
 {
  for (i=1;i<=OpenO;i++)
  {
   res=OrderSend(Symbol(), OP_BUY, Lots, Ask, 5, 0, 0, "", MAGICMA, 0, Blue); 
   _Alert("Buy");
  }
 }
 
 if (OpenO<0)
 {
  for (i=1;i<=-OpenO;i++)
  {
   res=OrderSend(Symbol(), OP_SELL, Lots, Bid, 5, 0, 0, "", MAGICMA, 0, Blue); 
   _Alert("Sell");
  }
 }
}

void OnTick()
{
 if (LastBar==Time[1])
 {
  return;
 }
 LastBar=Time[1];
 
 int Length, i;
 double MA0, MA1, PMA0, PMA1;
 PMA0=0.; PMA1=0.;
 
 double Res=0.;
 double Res2=0.;
 
 for (i=1;i<=MA_Count;i++)
 {
  MA0=iMA(NULL, 0, Length, 0, Method, Price, 1);
  MA1=iMA(NULL, 0, Length, 0, Method, Price, 2);
  
  if (i!=1)
  {
   if (MA0<PMA0)
   {
    Res=Res+1.;
   }
   else
   {
    Res=Res-1.;
   }

   if (MA1<PMA1)
   {
    Res2=Res2+1.;
   }
   else
   {
    Res2=Res2-1.;
   }
  }
  
  PMA0=MA0;
  PMA1=MA1;
  
  if (Increment_Type==0)
  {
   Length=Length+Length_Step;
  }
  else
  {
   Length=Length*Length_Step;
  }
  
 } 
 
 Res=Res/2.;
 Res2=Res2/2.;
 
 if (MathFloor(MA_Count/2.)*2==MA_Count)
 {
  if (Res>0.)
  {
   Res=Res-0.5;
  }
  else
  {
   Res=Res+0.5;
  }
  if (Res2>0.)
  {
   Res2=Res2-0.5;
  }
  else
  {
   Res2=Res2+0.5;
  }
 }
 
 if (Inverse_Direction)
 {
  Res=-Res;
  Res2=-Res2;
 }
 
 int CO=CalculateOrders();
 int OrdersB, OrdersS;
 if (CO>0)
 {
  OrdersB=CO;
  OrdersS=0;
 }
 else
 {
  OrdersB=0;
  OrdersS=-CO;
 }
 
 if (Res2==CO && Res!=Res2)
 {
  int Diff=Res-Res2;
  if (Diff>0)
  {
   ChangeOrders(-MathMin(Diff, OrdersS), MathMax(0, Diff-OrdersS));
  }
  else
  {
   ChangeOrders(MathMin(-Diff, OrdersB), -MathMax(0, -Diff-OrdersB));
  }
 }
 
 

}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{

}
  