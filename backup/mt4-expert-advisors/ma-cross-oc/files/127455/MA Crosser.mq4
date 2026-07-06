 
//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 2
#property  indicator_color1  Red
#property  indicator_color2  MediumSeaGreen
#property  indicator_width1  2
#property  indicator_width2  2
//---- indicator parameters
extern int Ma = 8;
extern int SecondMa = 21;
extern int Mode = 1;    /* MODE_SMA 0 ??????? ?????????? ??????? 
                           MODE_EMA 1 ???????????????? ?????????? ??????? 
                           MODE_SMMA 2 ?????????? ?????????? ??????? 
                           MODE_LWMA 3 ???????-?????????? ?????????? ??????? 
                        */
extern int AppliedPrice = 0;  // 0=PRICE_CLOSE; 1=PRICE_OPEN; 5=PRICE_TYPICAL
extern int VarPeriod = 240;   // old timeframe
         //PERIOD_M5   5         5 minutes
         //PERIOD_M15  15        15 minutes 
         //PERIOD_M30  30        30 minutes 
         //PERIOD_H1   60        1 hour 
         //PERIOD_H4   240       4 hours 
         //PERIOD_D1   1440      1 day 
         //PERIOD_W1   10080     1 week 
         //PERIOD_MN1  43200     1 month 
//---- indicator buffers
extern bool second_Ma = true;
double     MaFBuffer[], MaSBuffer[];
int p;  // current period
int k;  // repetition factor old timeframe
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexDrawBegin(0, SecondMa);
   SetIndexDrawBegin(1, SecondMa);   
   IndicatorDigits(Digits + 1);
//---- indicator buffers mapping
   SetIndexBuffer(0, MaFBuffer);
   SetIndexBuffer(1, MaSBuffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MA 4H (" + Ma + ", " + SecondMa + 
                      ", " + VarPeriod + " min)");
   SetIndexLabel(0, "MA 4H fast(" + Ma + ", " + VarPeriod + ")");
   SetIndexLabel(1, "MA 4H slow(" + SecondMa + ", " + VarPeriod + ")");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   Comment("");
//----
   return(0);
  }
//+-------------------------------------------------------------+
//| Moving Averages  (MA) for all timeframe  		       	         |
//+-------------------------------------------------------------+
int start()
  {
   
   int i, limit;
   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if(counted_bars < 0)       
       return(-1);
   if(counted_bars <= SecondMa)
       limit = Bars - SecondMa ;
   else
       limit = Bars - counted_bars;   
   p = Period();
   k = VarPeriod / p;         // repetition factor old timeframe
   i = limit - 1;
   while(i>=0)
     {
       // definition of HighBar, having symbol, lowTF,
       int bb = HighBar(Symbol(), 0, i, VarPeriod);
       // and bar's number in lowTF, calculated highTF;
       // (symbol, lowTF, bar's number, highTF)     
       if(bb == -1) 
           continue;       
       MaFBuffer[i] = iMA(Symbol(), VarPeriod, Ma, 0, Mode, AppliedPrice, bb);
       if(second_Ma) 
           MaSBuffer[i] = iMA(Symbol(), VarPeriod, SecondMa, 0, Mode, AppliedPrice, bb);
       i--;
     }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
//|  Definition of HighBar, having symbol, lowTF, and bar's number   |
//|  in lowTF, calculated highTF;                                    |
//|  (symbol, lowTF, bar's number, highTF)                           |
//+------------------------------------------------------------------+
int HighBar(string symbol,int TFLow,int BarLow,int TFHigh)                                                       
  {
   // time's value of bar means in BarLow
   datetime BarTimeLow = iTime(symbol, TFLow, BarLow);    
   int error = GetLastError();
   if(error == 4066) 
       return (-1);
   // displacement of bar means in BarTimeLow
   int res = iBarShift(symbol, TFHigh, BarTimeLow, false);
   error = GetLastError();
   if(error == 4066) 
       return (-1);
   return (res);
 }
//+------------------------------------------------------------------+