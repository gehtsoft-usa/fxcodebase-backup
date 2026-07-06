// Id: 7573
//+------------------------------------------------------------------+
//|                                                  SerialMA_EA.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define MAGICMA  2034510

extern bool Reverse=false;
extern double Lots=0.1;
extern int Slippage=5;
extern int SL=0;
extern int TP=0;

datetime LastTime;

int init()
  {
       double temp = iCustom(NULL, 0, "SerialMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'SerialMA' indicator");
       return INIT_FAILED;
   }
   LastTime=Time[0];
   return(0);
  }

int deinit()
  {

   return(0);
  }
  
int CalculateCurrentOrders(string symbol)
{
 int buys=0,sells=0;
 for(int i=0;i<OrdersTotal();i++)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
  {
   if(OrderType()==OP_BUY)  buys++;
   if(OrderType()==OP_SELL) sells++;
  }
 }
 if(buys>0) return(buys);
 else       return(-sells);
}

void CloseOrders()
{
 bool res;
 for (int i=OrdersTotal()-1;i>=0;i--)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderType()==OP_BUY)
  {
   RefreshRates();
   res=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage);
   if (!res) Print("LastError = ",GetLastError());
  }
  if(OrderType()==OP_SELL)
  {
   RefreshRates();
   res=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage);
   if (!res) Print("LastError = ",GetLastError());
  }
 } 
 return;
}
  
void ChangeDir(int Dir)
{
 int res;
 double SL_Level, TP_Level;
 int CCO=CalculateCurrentOrders(Symbol());
 if (Dir==OP_BUY)
 {
  if (CCO<0) CloseOrders();
  if (CCO<=0)
  {
   if (SL==0) SL_Level=0; else SL_Level=NormalizeDouble(Bid-SL*Point,Digits);
   if (TP==0) TP_Level=0; else TP_Level=NormalizeDouble(Bid+TP*Point,Digits);
   res=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,SL_Level,TP_Level,"",MAGICMA,0,Blue);
   if (res==-1) Print("LastError = ",GetLastError());
  }
 }
 if (Dir==OP_SELL)
 {
  if (CCO>0) CloseOrders();
  if (CCO>=0)
  {
   if (SL==0) SL_Level=0; else SL_Level=NormalizeDouble(Ask+SL*Point,Digits);
   if (TP==0) TP_Level=0; else TP_Level=NormalizeDouble(Ask-TP*Point,Digits);
   res=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,SL_Level,TP_Level,"",MAGICMA,0,Blue);
   if (res==-1) Print("LastError = ",GetLastError());
  }
 }
 return;
}  
  

int start()
  {
   if (Time[0]!=LastTime)
   {
    double SerialMA1=iCustom(NULL, 0, "SerialMA", 0, 1);
    double SerialMA2=iCustom(NULL, 0, "SerialMA", 0, 2);
    double SerialMA_Cross2=iCustom(NULL, 0, "SerialMA", 1, 2);
    if (MathAbs(SerialMA2-SerialMA_Cross2)<Point)
    {
     if (Close[1]>SerialMA1) if (!Reverse) ChangeDir(OP_BUY); else ChangeDir(OP_SELL);
     if (Close[1]<SerialMA1) if (!Reverse) ChangeDir(OP_SELL); else ChangeDir(OP_BUY);
    }
    
    LastTime=Time[0];
   }
   return(0);
  }

