//+------------------------------------------------------------------+
//|                                              Equity_Balance2.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window

#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Magenta

extern string Instrument="";
extern string Direction="";
extern int MaxBars=100;

datetime OpenTimes[], CloseTimes[];
double OpenPrices[], ClosePrices[], Profits[];
string Symbols[];
double EquityArray[], BalanceArray[];

double Equity[], Balance[];

void ReadHistory()
{
 ArrayResize(OpenTimes,0);
 ArrayResize(CloseTimes,0);
 ArrayResize(OpenPrices,0);
 ArrayResize(ClosePrices,0);
 ArrayResize(Profits,0);
 ArrayResize(Symbols,0);
 int ArraysSize;
 int Order_Type;
 string Order_Symbol;
 int i;
 for(i=0;i<OrdersHistoryTotal();i++)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) break;
   Order_Type=OrderType();
   Order_Symbol=OrderSymbol();
   if (Instrument!="" && Instrument!=Order_Symbol) continue;
   if (Direction!="" && ((Direction=="B" && Order_Type!=OP_BUY) || (Direction=="S" && Order_Type!=OP_SELL))) continue;
   if (Order_Type==OP_BUY || Order_Type==OP_SELL)
   {
    ArraysSize=ArraySize(OpenTimes);
    ArrayResize(OpenTimes,ArraysSize+1);
    ArrayResize(CloseTimes,ArraysSize+1);
    ArrayResize(OpenPrices,ArraysSize+1);
    ArrayResize(ClosePrices,ArraysSize+1);
    ArrayResize(Profits,ArraysSize+1);
    ArrayResize(Symbols,ArraysSize+1);
    OpenTimes[ArraysSize]=OrderOpenTime();
    CloseTimes[ArraysSize]=OrderCloseTime();
    OpenPrices[ArraysSize]=OrderOpenPrice();
    ClosePrices[ArraysSize]=OrderClosePrice();
    Profits[ArraysSize]=OrderProfit()+OrderSwap();
    Symbols[ArraysSize]=Order_Symbol;
   }
 }

 for(i=0;i<OrdersTotal();i++)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
   Order_Type=OrderType();
   Order_Symbol=OrderSymbol();
   if (Instrument!="" && Instrument!=Order_Symbol) continue;
   if (Direction!="" && ((Direction=="B" && Order_Type!=OP_BUY) || (Direction=="S" && Order_Type!=OP_SELL))) continue;
   if (Order_Type==OP_BUY || Order_Type==OP_SELL)
   {
    ArraysSize=ArraySize(OpenTimes);
    ArrayResize(OpenTimes,ArraysSize+1);
    ArrayResize(CloseTimes,ArraysSize+1);
    ArrayResize(OpenPrices,ArraysSize+1);
    ArrayResize(ClosePrices,ArraysSize+1);
    ArrayResize(Profits,ArraysSize+1);
    ArrayResize(Symbols,ArraysSize+1);
    OpenTimes[ArraysSize]=OrderOpenTime();
    CloseTimes[ArraysSize]=iTime(Order_Symbol,0,0);
    OpenPrices[ArraysSize]=OrderOpenPrice();
    ClosePrices[ArraysSize]=iClose(Order_Symbol,0,0);
    Profits[ArraysSize]=OrderProfit()+OrderSwap();
    Symbols[ArraysSize]=Order_Symbol;
   }
 }

}

int init()
  {
   IndicatorDigits(2);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Equity);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Balance);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
    ReadHistory();
    ArrayResize(EquityArray,Bars);
    ArrayResize(BalanceArray,Bars);
    ArrayInitialize(EquityArray,0);
    ArrayInitialize(BalanceArray,0);
    int ArraysSize=ArraySize(OpenTimes);
    int i, i2;
    double d;
    int limit;
    if (MaxBars==0) limit=Bars; else limit=MaxBars;
    if (limit<Bars)
    {
     Equity[limit+1]=EMPTY_VALUE;
     Balance[limit+1]=EMPTY_VALUE;
    }
    for (i=0;i<ArraysSize;i++)
    {
     if (ClosePrices[i]==OpenPrices[i]) continue;
     int OpenBar=iBarShift(NULL,0,OpenTimes[i]);
     int CloseBar=iBarShift(NULL,0,CloseTimes[i]);
     if (CloseBar<limit)
     {
      for (i2=MathMin(limit,OpenBar);i2>=0;i2--)
      {
       if (i2>CloseBar) d=(iClose(Symbols[i],0,i2)-OpenPrices[i])/(ClosePrices[i]-OpenPrices[i])*Profits[i]; else d=Profits[i];
       EquityArray[i2]=EquityArray[i2]+d;
       if (CloseBar!=0 && i2<=CloseBar) BalanceArray[i2]=BalanceArray[i2]+Profits[i];
      } 
     }
    }
    for (i=limit;i>=0;i--)
    {
     Equity[i]=EquityArray[i];
     Balance[i]=BalanceArray[i];
    }
   return(0);
  }

