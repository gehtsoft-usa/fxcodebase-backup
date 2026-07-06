//+------------------------------------------------------------------+
//|                                                   ChannelEA2.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define MAGICMA  20035633

// input parameters
extern int StartChannelHour=1;
extern int EndChannelHour=10;
extern double Lots=0.1;

datetime LastTime;

int init()
{
 LastTime=Time[0];
 return(0);
}

int deinit()
{
 return(0);
}
  
void CloseAllOrders()
{
 int res;
 for (int i=OrdersTotal()-1;i>=0;i--)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
  {
   if(OrderType()==OP_BUY)  res=OrderClose(OrderTicket(),OrderLots(),Bid,5);
   if(OrderType()==OP_SELL) res=OrderClose(OrderTicket(),OrderLots(),Ask,5);
   if(OrderType()==OP_BUYSTOP) OrderDelete(OrderTicket());
   if(OrderType()==OP_SELLSTOP) OrderDelete(OrderTicket());
  }
 }
 return;
}

void CheckOrders()
// delete pending order if exist market order.
{
 bool Fl=false;
 for (int i=OrdersTotal()-1;i>=0;i--)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
  {
   if(OrderType()==OP_BUY || OrderType()==OP_SELL)  Fl=true;
  }
 }
 if (Fl)
 {
  for (i=OrdersTotal()-1;i>=0;i--)
  {
   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
   if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
   {
    if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP) OrderDelete(OrderTicket());
   }
  }
 }
 return;
}

void EntryOrders()
{
 int i=1;
 int res;
 datetime StartTime=StrToTime(""+DoubleToStr(StartChannelHour,0)+":00");
 if (StartChannelHour>EndChannelHour) StartTime=StartTime-86400;
 int TH=TimeHour(Time[i]);
 double MinPrice=10000000;
 double MaxPrice=-1000000;
 while (Time[i]>=StartTime)
 {
  TH=TimeHour(Time[i]);
  MinPrice=MathMin(MinPrice, Low[i]);
  MaxPrice=MathMax(MaxPrice, High[i]);
  i++;
 }
 if (i>2)
 {
  res=OrderSend(Symbol(),OP_SELLSTOP,Lots,MinPrice,5,MaxPrice,0,"",MAGICMA,0,Blue);
  res=OrderSend(Symbol(),OP_BUYSTOP,Lots,MaxPrice,5,MinPrice,0,"",MAGICMA,0,Blue);
 } 
}

int start()
{
 if (LastTime!=Time[0])
 {
  LastTime=Time[0];
  datetime StartTime=StrToTime(""+DoubleToStr(StartChannelHour,0)+":00");
  datetime EndTime=StrToTime(""+DoubleToStr(EndChannelHour,0)+":00");
  if (Time[0]>=StartTime && Time[1]<StartTime)
  {
   CloseAllOrders();
  }
  if (Time[1]>=EndTime && Time[2]<EndTime)
  {
   EntryOrders();
  }
 }
 CheckOrders();
 return(0);
}


