// Id: 16374
//+------------------------------------------------------------------+
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+



#property indicator_buffers 8
#property indicator_chart_window

extern int RSI_Period = 13;         //8-25
extern int RSI_Price = 0;           //0-6
extern int Volatility_Band = 34;    //20-40
extern int RSI_Price_Line = 2;      
extern int RSI_Price_Type = 0;      //0-3
extern int Trade_Signal_Line = 7;   
extern int Trade_Signal_Type = 0;   //0-3

double RSIBuf[],UpZone[],MdZone[],DnZone[],MaBuf[],MbBuf[],TMS_Up[],TMS_Dn[];
datetime LastAlert;

int init()
  {
       double temp = iCustom(NULL, 0, "Heiken Ashi", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Heiken Ashi' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("TMS");
   SetIndexBuffer(0,RSIBuf);
   SetIndexBuffer(1,UpZone);
   SetIndexBuffer(2,MdZone);
   SetIndexBuffer(3,DnZone);
   SetIndexBuffer(4,MaBuf); // TDI Green
   SetIndexBuffer(5,MbBuf); // TDI Red
   SetIndexBuffer(6,TMS_Up);
   SetIndexBuffer(7,TMS_Dn);
   
   SetIndexStyle(0,DRAW_NONE); 
   SetIndexStyle(1,DRAW_NONE); 
   SetIndexStyle(2,DRAW_NONE);   //,0,2
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_NONE);   //,0,2
   SetIndexStyle(5,DRAW_NONE);   //,0,2
   SetIndexStyle(6,DRAW_ARROW,STYLE_SOLID,1,clrLime);
   SetIndexArrow(6,233);
   SetIndexStyle(7,DRAW_ARROW,STYLE_SOLID,1,clrRed);
   SetIndexArrow(7,234);
   
   SetIndexLabel(6,"TMS Bullish"); 
   SetIndexLabel(7,"TMS Bearish"); 
   
   return(0);
  }

int start()
  {
   double MA,RSI[];
   ArrayResize(RSI,Volatility_Band);
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   for(int i=limit; i>=0; i--){
      RSIBuf[i] = (iRSI(NULL,0,RSI_Period,RSI_Price,i)); 
      MA = 0;
      for(int x=i; x<i+Volatility_Band; x++) {
         RSI[x-i] = RSIBuf[x];
         MA += RSIBuf[x]/Volatility_Band;
      }
      UpZone[i] = (MA + (1.6185 * StDev(RSI,Volatility_Band)));
      DnZone[i] = (MA - (1.6185 * StDev(RSI,Volatility_Band)));  
      MdZone[i] = ((UpZone[i] + DnZone[i])/2);
   }
   // TDI
   for (i=limit-1;i>=0;i--){
       MaBuf[i] = (iMAOnArray(RSIBuf,0,RSI_Price_Line,0,RSI_Price_Type,i));
       MbBuf[i] = (iMAOnArray(RSIBuf,0,Trade_Signal_Line,0,Trade_Signal_Type,i));   
   }
   // TMS Signals
   for (i=limit-1;i>=0;i--){
      // Bullish: TDI green line crosses red line from below, Stochastic moving upwards, Heiken Ashi 1st or 2nd candle bullish
      if (   MaBuf[i] > MbBuf[i] && MaBuf[i+1] < MbBuf[i+1] // TDI bullish cross
          && iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_MAIN,i)>iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_SIGNAL,i) // upwards
          && iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,2,i) < iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,3,i) // Open > Close
          && (   iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,2,i+1) > iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,3,i+1) // first
              || (   iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,2,i+1) < iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,3,i+1) // or second
                  && iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,2,i+2) > iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,3,i+2)
                  )
              )
          ){
            TMS_Up[i] = Low[i];
            if (i==0 && Time[0] > LastAlert){
               Alert(Symbol() + "," + TFToStr(Period()) + ": TMS Bullish Signal");
               LastAlert = TimeCurrent();
            }
       }
       // Bearish: TDI green line crosses red line from above, Stochastic moving downwards, Heiken Ashi 1st or 2nd candle bearish
       if (   MaBuf[i] < MbBuf[i] && MaBuf[i+1] > MbBuf[i+1] // TDI bearish cross
          && iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_MAIN,i)<iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_SIGNAL,i) // downwards
          && iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,2,i) > iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,3,i) // Open > Close
          && (   iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,2,i+1) < iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,3,i+1) // first
              || (   iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,2,i+1) > iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,3,i+1) // or second
                  && iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,2,i+2) < iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,3,i+2)
                  )
              )
          ){
            TMS_Dn[i] = High[i];
            if (i==0 && Time[0] > LastAlert){
               Alert(Symbol() + "," + TFToStr(Period()) + ": TMS Bearish Signal");
               LastAlert = TimeCurrent();
            }
       }
   }
   
//----
   return(0);
}
  
double StDev(double& Data[], int Per)
{return(MathSqrt(Variance(Data,Per)));
}
double Variance(double& Data[], int Per)
{double sum, ssum;
  for (int i=0; i<Per; i++)
  {sum += Data[i];
   ssum += MathPow(Data[i],2);
  }
  return((ssum*Per - sum*sum)/(Per*(Per-1)));
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+                                                                          //
string TFToStr(int tf)   {                                                                                                                      //
//+------------------------------------------------------------------+                                                                          //
  if (tf == 0)        tf = Period();                                                                                                            //
  if (tf >= 43200)    return("MN");                                                                                                             //
  if (tf >= 10080)    return("W1");                                                                                                             //
  if (tf >=  1440)    return("D1");                                                                                                             //
  if (tf >=   240)    return("H4");                                                                                                             //
  if (tf >=    60)    return("H1");                                                                                                             //
  if (tf >=    30)    return("M30");                                                                                                            //
  if (tf >=    15)    return("M15");                                                                                                            //
  if (tf >=     5)    return("M5");                                                                                                             //
  if (tf >=     1)    return("M1");                                                                                                             //
  return("");                                                                                                                                   //
}