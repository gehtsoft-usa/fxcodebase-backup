//+------------------------------------------------------------------+
//|                                            Fractal_Breakdown.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define MAGICMA  20050643

extern int Frames=2;
extern int Shift=0;
extern double Lots=0.1;

datetime LastTime;
int TicketB, TicketS, TicketBS, TicketSS;

int Fractals(int bar)
{
 bool Up=true;
 bool Dn=true;
 int i;
 for (i=1;i<=Frames;i++)
 {
  if (High[bar+Frames+i]>=High[bar+Frames] || High[bar+Frames-i]>=High[bar+Frames]) Up=false;
  if (Low[bar+Frames+i]<=Low[bar+Frames] || Low[bar+Frames-i]<=Low[bar+Frames]) Dn=false;
 }
 if (Up)
 {
  if (Dn)
  {
   return (2); // Up and Dn
  }
  else
  {
   return (1); // Up
  }
 }
 else
 {
  if (Dn)
  {
   return (-1); // Dn
  }
  else
  {
   return (0); // None
  }
 }
}

int FindUpFractal(int bar)
{
 int bar_=bar;
 int Fr;
 while (bar_<Bars-Frames)
 {
  Fr=Fractals(bar_);
  if (Fr==2 || Fr==1) return (bar_);
  bar_++;
 }
 return (-1);
}

int FindDnFractal(int bar)
{
 int bar_=bar;
 int Fr;
 while (bar_<Bars-Frames)
 {
  Fr=Fractals(bar_);
  if (Fr==2 || Fr==-1) return (bar_);
  bar_++;
 }
 return (-1);
}

int init()
{
 LastTime=Time[0];
 return(0);
}

int deinit()
{

 return(0);
}
  
void CalculateOrders(string symbol)
{
 TicketB=0; TicketS=0; TicketBS=0; TicketSS=0;
 for(int i=0;i<OrdersTotal();i++)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
  {
   if(OrderType()==OP_BUY) TicketB=OrderTicket();
   if(OrderType()==OP_SELL) TicketS=OrderTicket();
   if(OrderType()==OP_BUYSTOP) TicketBS=OrderTicket();
   if(OrderType()==OP_SELLSTOP) TicketSS=OrderTicket();
  }
 }
 return ;  
}  
  

int start()
{
 int Frac;
 int res;
 double OpenPrice;
 double SL;
 int UpFractal, DnFractal;
 UpFractal=-1;
 DnFractal=-1;
 if (LastTime!=Time[0])
 {
  UpFractal=FindUpFractal(1);
  DnFractal=FindDnFractal(1);
  if (UpFractal>0)  // Up fractal
  {
   CalculateOrders(Symbol());
   if (TicketB==0 && TicketBS==0)
   {
    OpenPrice=High[Frames+UpFractal]+Shift*Point;
    res=OrderSend(Symbol(),OP_BUYSTOP,Lots,OpenPrice,5,0,0,"",MAGICMA,0,Blue);
   }
   if (TicketBS!=0)
   {
    OpenPrice=High[Frames+UpFractal]+Shift*Point;
    OrderSelect(TicketBS,SELECT_BY_TICKET);
    if (OpenPrice!=OrderOpenPrice()) OrderModify(TicketBS,OpenPrice,OrderStopLoss(),0,0);
   }
   if (TicketS!=0)
   {
    SL=High[Frames+UpFractal]+Shift*Point;
    OrderSelect(TicketS,SELECT_BY_TICKET);
    if (SL!=OrderStopLoss()) OrderModify(TicketS,0,SL,0,0);
   }
   if (TicketSS!=0)
   {
    SL=High[Frames+UpFractal]+Shift*Point;
    OrderSelect(TicketSS,SELECT_BY_TICKET);
    if (SL!=OrderStopLoss()) OrderModify(TicketSS,OrderOpenPrice(),SL,0,0);
   }
  }
  if (DnFractal>0) // Dn fractal
  {
   CalculateOrders(Symbol());
   if (TicketS==0 && TicketSS==0)
   {
    OpenPrice=Low[Frames+DnFractal]-Shift*Point;
    res=OrderSend(Symbol(),OP_SELLSTOP,Lots,OpenPrice,5,0,0,"",MAGICMA,0,Blue);
   }
   if (TicketSS!=0)
   {
    OpenPrice=Low[Frames+DnFractal]-Shift*Point;
    OrderSelect(TicketSS,SELECT_BY_TICKET);
    if (OpenPrice!=OrderOpenPrice()) OrderModify(TicketSS,OpenPrice,OrderStopLoss(),0,0);
   }
   if (TicketB!=0)
   {
    SL=Low[Frames+DnFractal]-Shift*Point;
    OrderSelect(TicketB,SELECT_BY_TICKET);
    if (SL!=OrderStopLoss()) OrderModify(TicketB,0,SL,0,0);
   }
   if (TicketBS!=0)
   {
    SL=Low[Frames+DnFractal]-Shift*Point;
    OrderSelect(TicketBS,SELECT_BY_TICKET);
    if (SL!=OrderStopLoss()) OrderModify(TicketBS,OrderOpenPrice(),SL,0,0);
   }
  }
  LastTime=Time[0];
 }
 return(0);
}

