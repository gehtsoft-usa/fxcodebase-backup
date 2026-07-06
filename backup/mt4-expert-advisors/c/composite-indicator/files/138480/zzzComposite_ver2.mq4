// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65404

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+




#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow


extern ENUM_TIMEFRAMES Current_Timeframe = PERIOD_CURRENT; // Timeframe
extern string Current_Symbol = ""; // Symbol

extern bool RSI_Enable=true;
extern bool RSI_Inverse=false;
extern int RSI_Period=10;


extern bool CCI_Enable=true;
extern bool CCI_Inverse=false;
extern int CCI_Period=10;

extern bool EMA_Enable=true;
extern bool EMA_Inverse=false;
extern int EMA_Period=10;

extern bool AROON_Enable=true;
extern bool AROON_Inverse=false;
extern int AROON_Period=10;

extern bool DMI_Enable=true;
extern bool DMI_Inverse=false;
extern int DMI_Period=10;

extern bool FRAMA_Enable=true;
extern bool FRAMA_Inverse=false;
extern int FRAMA_Period=10;

extern bool SAR_Enable=true;
extern bool SAR_Inverse=false;
extern double SAR_Step=0.02;
extern double SAR_Max=0.2;

extern bool SDL_Enable=true;
extern bool SDL_Inverse=false;
extern int SDL_Period=10;

extern bool KRI_Enable=true;
extern bool KRI_Inverse=false;
extern int KRI_Period=10;

extern bool TRIX_Enable=true;
extern bool TRIX_Inverse=false;
extern int TRIX_Period=10;

extern bool MOMENTUM_Enable=true;
extern bool MOMENTUM_Inverse=false;
extern int MOMENTUM_Period=10;

extern bool WMA_Enable=true;
extern bool WMA_Inverse=false;
extern int WMA_Period=10;

extern bool KAMA_Enable=true;
extern bool KAMA_Inverse=false;
extern int KAMA_Period=10;

extern bool VORTEX_Enable=true;
extern bool VORTEX_Inverse=false;
extern int VORTEX_Period=10;

extern bool DEM_Enable=true;
extern bool DEM_Inverse=false;
extern int DEM_Period=10;

extern bool FORECAST_Enable=true;
extern bool FORECAST_Inverse=false;
extern int FORECAST_Period=10;

extern bool RLW_Enable=true;
extern bool RLW_Inverse=false;
extern int RLW_Period=10;

extern bool TMACD_Enable=true;
extern bool TMACD_Inverse=false;
extern int TMACD_Long_Period=10;
extern int TMACD_Short_Period=5;

extern bool SUPERTREND_Enable=true;
extern bool SUPERTREND_Inverse=false;
extern int SUPERTREND_Period=10;
extern double SUPERTREND_Multiplier=1.5;

extern bool HA_Enable=true;
extern bool HA_Inverse=false;

extern bool ROC_Enable=true;
extern bool ROC_Inverse=false;
extern int ROC_Period=14;

extern bool ADX_Enable=true;
extern bool ADX_Inverse=false;
extern int ADX_Period=14;
extern double ADX_Level=25.;

extern bool DMI2_Enable=true;
extern bool DMI2_Inverse=false;
extern int DMI2_Period=14;
extern double DMI2_Level=25.;

double CI[];

int init()
{
  
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,CI);

 return(0);
}

int deinit()
{

 return(0);
}
int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 int Res;
 double Ind, Ind1, Ind2;
 pos=10;
 while(pos>=0)
 {
  Res=0;
  
  if (RSI_Enable)
  {
   Ind=iRSI(Current_Symbol, 0, RSI_Period, PRICE_CLOSE, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
   if (Ind>50.)
   {
    if (RSI_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (RSI_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (CCI_Enable)
  {
   Ind=iCCI(Current_Symbol, 0, CCI_Period, PRICE_CLOSE, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
   if (Ind>50.)
   {
    if (CCI_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (CCI_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (EMA_Enable)
  {
   Ind=iMA(Current_Symbol, 0, EMA_Period, 0, MODE_EMA, PRICE_CLOSE, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
   if (Ind<Close[pos])
   {
    if (EMA_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (EMA_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (AROON_Enable)
  {
   Ind1=startAroon(0, pos);
   Ind2=startAroon(1, pos);
   if (Ind1>Ind2)
   {
    if (AROON_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (AROON_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (SAR_Enable)
  {
   Ind=iSAR(Current_Symbol, 0, SAR_Step, SAR_Max, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
   if (Ind>Close[pos])
   {
    if (SAR_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (SAR_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (DMI_Enable)
  {
   Ind1=iADX(Current_Symbol, 0, DMI_Period, PRICE_CLOSE, MODE_PLUSDI, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
   Ind2=iADX(Current_Symbol, 0, DMI_Period, PRICE_CLOSE, MODE_MINUSDI, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
   if (Ind1>Ind2)
   {
    if (DMI_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (DMI_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (FRAMA_Enable)
  {
   Ind=startFrama(pos);
   if (Ind<Close[pos])
   {
    if (FRAMA_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (FRAMA_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (SDL_Enable)
  {
   Ind1=startSlopeDirectionLine(0,pos);
   Ind2=startSlopeDirectionLine(0,pos+1);
   if (Ind1>Ind2)
   {
    if (SDL_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (SDL_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (KRI_Enable)
  {
   Ind=startKRI(pos);
   if (Ind>0.)
   {
    if (KRI_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (KRI_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (TRIX_Enable)
  {
   Ind1=startTrix(0, pos);
   Ind2=startTrix(1, pos);
   if (Ind1>Ind2)
   {
    if (TRIX_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (TRIX_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (MOMENTUM_Enable)
  {
   Ind=iMomentum(Current_Symbol, 0, MOMENTUM_Period, PRICE_CLOSE, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
   if (Ind>100.)
   {
    if (MOMENTUM_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (MOMENTUM_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (WMA_Enable)
  {
   Ind=startWMA(pos);
   if (Ind<Close[pos])
   {
    if (WMA_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (WMA_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (KAMA_Enable)
  {
   Ind=startKAMA(pos);
   if (Ind<Close[pos])
   {
    if (KAMA_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (KAMA_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (VORTEX_Enable)
  {
   Ind1=startVORTEX(0, pos);
   Ind2=startVORTEX(1, pos);
   if (Ind1>Ind2)
   {
    if (VORTEX_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (VORTEX_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (DEM_Enable)
  {
   Ind=startDEM(pos);
   if (Ind>0.5)
   {
    if (DEM_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (DEM_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (DEM_Enable)
  {
   Ind=startDEM(pos);
   if (Ind>0.5)
   {
    if (DEM_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (DEM_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (FORECAST_Enable)
  {
   Ind=startForecast(pos);
   if (Ind>0.)
   {
    if (FORECAST_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (FORECAST_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (RLW_Enable)
  {
   Ind=iWPR(NULL, 0, RLW_Period, pos);
   if (Ind>-50.)
   {
    if (RLW_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (RLW_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (SUPERTREND_Enable)
  {
   Ind1=startSuperTrend(0, pos);
   Ind2=startSuperTrend(1, pos);
   if (Ind1>Ind2)
   {
    if (SUPERTREND_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (SUPERTREND_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (HA_Enable)
  {
   Ind1=startHeikenAshi(2, pos);
   Ind2=startHeikenAshi(3, pos);
   if (Ind1<Ind2)
   {
    if (HA_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (HA_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (TMACD_Enable)
  {
   Ind=startTMACD(pos);
   if (Ind>0.)
   {
    if (TMACD_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (TMACD_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (ROC_Enable)
  {
   Ind=startROC(pos);
   if (Ind>0.)
   {
    if (ROC_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   else
   {
    if (ROC_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (DMI2_Enable)
  {
   Ind1=iADX(Current_Symbol, 0, DMI2_Period, PRICE_CLOSE, MODE_PLUSDI, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
   Ind2=iADX(Current_Symbol, 0, DMI2_Period, PRICE_CLOSE, MODE_MINUSDI, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
   if (Ind1>DMI2_Level)
   {
    if (DMI2_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   if (Ind2>DMI2_Level)
   {
    if (DMI2_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  if (ADX_Enable)
  {
   Ind=iADX(Current_Symbol, 0, ADX_Period, PRICE_CLOSE, MODE_MAIN, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
   if (Ind>ADX_Level && Res>0)
   {
    if (ADX_Inverse)
    {
     Res--;
    }
    else
    {
     Res++;
    }
   }
   if (Ind>ADX_Level && Res<0)
   {
    if (ADX_Inverse)
    {
     Res++;
    }
    else
    {
     Res--;
    }
   }
  }
  
  CI[pos]=Res;
  
  pos--;
 } 
 return(0);
}





double startAroon(int mode = 0,int _pos = 1)
{
 double UP[], DN[]; 
 int Length = AROON_Period;
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 int MinBar, MaxBar;
 pos=limit;
 while(pos>=0)
 {
  MinBar=iLowest(Current_Symbol, 0, MODE_CLOSE, Length, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  MaxBar=iHighest(Current_Symbol, 0, MODE_CLOSE, Length, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  if(_pos == pos)
  {
    UP[pos]=100.*(Length-MaxBar+pos)/Length;
    DN[pos]=100.*(Length-MinBar+pos)/Length;
  }

  pos--;
 } 
 return mode == 0 ? UP[_pos]:DN[_pos];
 return(0);
}



double startFrama(int _pos = 1)
{
 if(Bars<=3) return(0);
 double Frama[]; 
 int Length = FRAMA_Period;
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2*Length;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double High1, Low1, High2, Low2, High3, Low3;
 double N1, N2, N3, D, ALFA;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2*Length)
  {
   Frama[pos+1]=(iHigh(Current_Symbol,Current_Timeframe,iBarShift(Current_Symbol, Current_Timeframe, Time[pos+1]))+iLow(Current_Symbol,Current_Timeframe,iBarShift(Current_Symbol, Current_Timeframe, Time[pos+1])))/2.;
  }
  High1=High[iHighest(Current_Symbol, Current_Timeframe, MODE_HIGH, Length, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))];
  Low1=Low[iLowest(Current_Symbol, Current_Timeframe, MODE_LOW, Length, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))];
  High2=High[iHighest(Current_Symbol, Current_Timeframe, MODE_HIGH, Length, iBarShift(Current_Symbol, Current_Timeframe, Time[pos+Length]))];
  Low2=Low[iLowest(Current_Symbol, Current_Timeframe, MODE_LOW, Length, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))];
  High3=High[iHighest(Current_Symbol, Current_Timeframe, MODE_HIGH, 2*Length, iBarShift(Current_Symbol, Current_Timeframe, Time[pos+Length]))];
  Low3=Low[iLowest(Current_Symbol, Current_Timeframe, MODE_LOW, 2*Length, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))];
  
  N1=(High1-Low1)/Length;
  N2=(High2-Low2)/Length;
  N3=(High3-Low3)/(2*Length);
  
  D=(MathLog(N1+N2)-MathLog(N3))/MathLog(2.);
  ALFA=MathExp(-4.6*(D-1.));
  
  Frama[pos]=ALFA*(iHigh(Current_Symbol,Current_Timeframe,iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))+iLow(Current_Symbol,Current_Timeframe,iBarShift(Current_Symbol, Current_Timeframe, Time[pos])))/2.+(1.-ALFA)*Frama[pos+1];

//  Frama[pos]=D;

  pos--;
 } 
 
 return Frama[_pos];
 return(0);
}




double startSlopeDirectionLine(int mode = 0,int _pos = 1)
{

 int Length = SDL_Period;
 int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
 int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
 double SDL[], SDL_Up[], SDL_Dn[];
 double vect[], trend[];
 int Length2, LengthS;
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double MA, MA2, MA_A;
 pos=limit;
 while(pos>=0)
 {
  MA=iMA(Current_Symbol, Current_Timeframe, Length, 0, Method, Price, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  MA2=iMA(Current_Symbol, Current_Timeframe, Length2, 0, Method, Price, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  
  vect[pos]=2.*MA2-MA;
  
  pos--;
 }
  
 pos=limit;
 while(pos>=0)
 {
  MA_A=iMAOnArray(vect, 0, LengthS, 0, Method, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  
  SDL[pos]=MA_A;
  
  trend[pos]=trend[pos+1];
  if (SDL[pos]>SDL[pos+1])
  {
   trend[pos]=1.;
  }
  else
  {
   if (SDL[pos]<SDL[pos+1])
   {
    trend[pos]=-1.;
   }
  }
  
  if (trend[pos]>0.)
  {
   SDL_Up[pos]=SDL[pos];
   if (trend[pos+1]<0.)
   {
    SDL_Up[pos+1]=SDL[pos+1];
   }
  }
  else
  {
   SDL_Dn[pos]=SDL[pos];
   if (trend[pos+1]>0.)
   {
    SDL_Dn[pos+1]=SDL[pos+1];
   }
  }

  pos--;
 } 
 return mode == 0 ? SDL_Up[_pos]:SDL_Dn[_pos];
 return(0);
}




double startKRI(int _pos = 1)
{
 double KRI[];
 if(Bars<=3) return(0);
 int Length = KRI_Period;
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double mvaValue;
 double Pr;
 pos=limit;
 while(pos>=0)
 {
  mvaValue=iMA(Current_Symbol, Current_Timeframe, Length, 0, MODE_SMA, PRICE_CLOSE, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  Pr=iMA(Current_Symbol, Current_Timeframe, 1, 0, MODE_SMA, PRICE_CLOSE, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  
  if (mvaValue!=0.)
  {
   KRI[pos]=100.*(Pr-mvaValue)/mvaValue;
  }

  pos--;
 } 
 
 return KRI[_pos];
 return(0);
}


double startTrix(int mode = 0,int _pos = 1)
{
 double Trix[], Signal[], HistogramUp[], HistogramDn[];
 double MA1[], MA2[];
 int Length=TRIX_Period;
 int FirstMethod=0;
 int SecondMethod=0;
 int ThirdMethod=0;
 int SignalLength=9;
 int SignalMethod=0;
 int Price=0;    // Applied price
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 double Hist;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  MA1[pos]=iMA(Current_Symbol, Current_Timeframe, Length, 0, FirstMethod, Price, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  MA2[pos]=iMAOnArray(MA1, 0, Length, 0, SecondMethod, pos);
  pos--;
 }
 
 pos=limit;
 double MA3_0, MA3_1;
 while(pos>=0)
 {
  MA3_0=iMAOnArray(MA2, 0, Length, 0, ThirdMethod, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  MA3_1=iMAOnArray(MA2, 0, Length, 0, ThirdMethod, iBarShift(Current_Symbol, Current_Timeframe, Time[pos+1]));
  if (MA3_1!=0) Trix[pos]=(MA3_0-MA3_1)/MA3_1/Point;
  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(Trix, 0, SignalLength, 0, SignalMethod, pos);
  Hist=Trix[pos]-Signal[pos];
  if (Hist>=HistogramUp[pos+1]+HistogramDn[pos+1])
  {
   HistogramUp[pos]=Hist;
   HistogramDn[pos]=0;
  }
  else
  {
   HistogramUp[pos]=0;
   HistogramDn[pos]=Hist;
  } 
  pos--;
 }
 
 return mode == 0 ? HistogramUp[_pos]:HistogramDn[_pos];
 return(0);
}

double startWMA(int _pos = 1)
{

  int Length=WMA_Period;
  int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

 double WMA[];

 double k;
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   WMA[pos]=iMA(Current_Symbol, Current_Timeframe, Length, 0, MODE_SMA, Price, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  }
  else
  {
   WMA[pos]=(iMA(Current_Symbol, Current_Timeframe, 1, 0, MODE_SMA, Price, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))-WMA[pos+1])*k+WMA[pos+1];
  }
  pos--;
 } 
 return WMA[_pos];
 return(0);
}

double startKAMA(int _pos = 1)
{
 int Length=KAMA_Period;
 int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

 double KAMA[];
 double Pr[], Abs[];
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(Current_Symbol, Current_Timeframe, 1, 0, MODE_SMA, Price, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Abs[pos]=MathAbs(Pr[pos]-Pr[pos+1]);
  pos--;
 } 
 
 double er, sc;
 pos=limit;
 while(pos>=0)
 {
  er=iMAOnArray(Abs, 0, Length, 0, MODE_SMA, pos)*Length;
  if (er!=0)
  {
   er=MathAbs(Pr[pos]-Pr[pos+Length-1])/er;
  }
  sc=er*0.6015+0.0645;
  sc=sc*sc;
  KAMA[pos]=KAMA[pos+1]+sc*(Pr[pos]-KAMA[pos+1]);
  pos--;
 }  
 return KAMA[_pos];
 return(0);
}

double startVORTEX(int mode = 0,int _pos = 1)
{
 int Length=VORTEX_Period;

 double VIP[], VIM[];
 double iVIP[], iVIM[], _ATR[];
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  iVIP[pos]=MathAbs(iHigh(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))-iLow(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos+1])));
  iVIM[pos]=MathAbs(iLow(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))-iHigh(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos+1])));
  _ATR[pos]=iATR(Current_Symbol, Current_Timeframe, 1, pos);

  pos--;
 } 
 
 double svip, svim, satr;
 pos=limit;
 while(pos>=0)
 {
  svip=iMAOnArray(iVIP, 0, Length, 0, MODE_SMA, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  svim=iMAOnArray(iVIM, 0, Length, 0, MODE_SMA, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  satr=iMAOnArray(_ATR, 0, Length, 0, MODE_SMA, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  if (satr!=0.)
  {
   VIP[pos]=100.*svip/satr;
   VIM[pos]=100.*svim/satr;
  }
  else
  {
   VIP[pos]=EMPTY_VALUE;
   VIM[pos]=EMPTY_VALUE;
  }

  pos--;
 }
 return mode == 0 ? VIP[_pos]:VIM[_pos];  
 return(0);
}

double startDEM(int _pos = 1)
{
 int Length=DEM_Period;
 int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

 double DEM[];
 double max[], min[];
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  if (iHigh(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))>iHigh(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos+1])))
  {
   max[pos]=iHigh(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))-iHigh(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos+1]));
  }
  else
  {
   max[pos]=0.;
  }
  
  if (iLow(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))<iLow(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos+1])))
  {
   min[pos]=iLow(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos+1]))-iLow(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  }
  else
  {
   min[pos]=0.;
  }
  
  pos--;
 } 
 
 double vmax, vmin;
 pos=limit;
 while(pos>=0)
 {
  vmax=iMAOnArray(max, 0, Length, 0, Method, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  vmin=iMAOnArray(min, 0, Length, 0, Method, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  
  if (vmax==0. && vmin==0.)
  {
   DEM[pos]=EMPTY_VALUE;
  }
  else
  {
   DEM[pos]=vmax/(vmax+vmin);
  }

  pos--;
 }
 return DEM[_pos];
 return(0);
}


double startForecast(int _pos = 1)
{
 int Length=FORECAST_Period;
 int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

 double FO[];
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double sx, sy, sxy, sx2, a, b, tsf;
 double Pr;
 int i, t;
 pos=limit;
 while(pos>=0)
 {
  t=Length;
  sx=0.;
  sy=0.;
  sxy=0.;
  sx2=0.;
  for (i=pos+Length;i>=pos+1;i--)
  {
   Pr=iMA(Current_Symbol, Current_Timeframe, 1, 0, MODE_SMA, Price,iBarShift(Current_Symbol, Current_Timeframe, Time[i]));
   sy=sy+Pr;
   sx=sx+t;
   sx2=sx2+t*t;
   sxy=sxy+Pr*t;
   t--;
  }
  b=(Length*sxy-sx*sy)/(Length*sx2-sx*sx);
  a=(sy-b*sx)/Length;
  tsf=a+b;
  
  Pr=iMA(Current_Symbol, Current_Timeframe, 1, 0, MODE_SMA, Price, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  if (Pr!=0.)
  {
   FO[pos]=100.*(Pr-tsf)/Pr;
  } 

  pos--;
 } 
 return FO[_pos];
 return(0);
}



double startSuperTrend(int mode = 0,int _pos = 1)
{
 int Length=SUPERTREND_Period;
 double Multiplier=SUPERTREND_Multiplier;

 double TrUP[], TrDN[];
 double UP[], DN[], TR[];
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double atr, median;
 int flag, flagh;
 bool change;
 pos=limit;
 while(pos>=0)
 {
  atr=iATR(Current_Symbol, Current_Timeframe, Length, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  median=(iHigh(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))+iLow(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos])))/2.;
  
  UP[pos]=median+atr*Multiplier;
  DN[pos]=median-atr*Multiplier;
  
  change=false;
  
  if (iClose(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))>UP[pos+1])
  {
   TR[pos]=1.;
   if (TR[pos+1]<0.)
   {
    change=true;
   }
  }
  else if (iClose(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))<DN[pos+1])
  {
   TR[pos]=-1.;
   if (TR[pos+1]>0.)
   {
    change=true;
   }
  }
  else
  { 
   TR[pos]=TR[pos+1];
  }
  
  if (TR[pos]<0. && TR[pos+1]>0.)
  {
   flag=1;
  }
  else
  {
   flag=0;
  }

  if (TR[pos]>0. && TR[pos+1]<0.)
  {
   flagh=1;
  }
  else
  {
   flagh=0;
  }
  
  if (TR[pos]>0. && DN[pos]<DN[pos+1])
  {
   DN[pos]=DN[pos+1];
  }
  
  if (TR[pos]<0. && UP[pos]>UP[pos+1])
  {
   UP[pos]=UP[pos+1];
  }
  
  if (flag==1)
  {
   UP[pos]=median+atr*Multiplier;
  }
  
  if (flagh==1)
  {
   DN[pos]=median-atr*Multiplier;
  }
  
  if (TR[pos]>0.)
  {
   TrUP[pos]=DN[pos];
   if (change)
   {
    TrUP[pos+1]=TrDN[pos+1];
   }
  }
  
  if (TR[pos]<0.)
  {
   TrDN[pos]=UP[pos];
   if (change)
   {
    TrDN[pos+1]=TrUP[pos+1];
   }
  }

  pos--;
 } 
 return mode == 0 ? TrUP[_pos]:TrDN[_pos]; 
 return(0);
}

double startROC(int _pos = 1)
{

 int Length=ROC_Period;
 int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

 double ROC[];
 double Pr[];
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(Current_Symbol, Current_Timeframe, 1, 0, MODE_SMA, Price, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (Pr[pos+Length]!=0)
  {
   ROC[pos]=(Pr[pos]/Pr[pos+Length]-1)*100;
  } 
  pos--;
 }
 return ROC[_pos]; 
 return(0);
}

double startTMACD(int _pos = 1)
{

  int Fast_Length=TMACD_Long_Period;
 int Slow_Length=TMACD_Short_Period;
 int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double TMACD[];
double F_WMA[], S_WMA[];
int len_F, len_S;
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  F_WMA[pos]=iMA(Current_Symbol, Current_Timeframe, len_F, 0, MODE_SMA, Price, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))*Point;
  S_WMA[pos]=iMA(Current_Symbol, Current_Timeframe, len_S, 0, MODE_SMA, Price, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))*Point;

  pos--;
 } 
 
 double F_TMA, S_TMA;
 pos=limit;
 while(pos>=0)
 {
  F_TMA=iMAOnArray(F_WMA, 0, len_F, 0, MODE_SMA, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  S_TMA=iMAOnArray(S_WMA, 0, len_S, 0, MODE_SMA, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]));
  
  TMACD[pos]=(F_TMA-S_TMA)/Point;

  pos--;
 }
  return TMACD[_pos];   
 return(0);
}

double startHeikenAshi(int mode = 0,int _pos = 1)
  {
  
   double ExtMapBuffer1[];
   double ExtMapBuffer2[];
   double ExtMapBuffer3[];
   double ExtMapBuffer4[];
   int ExtCountedBars=0;
   double haOpen, haHigh, haLow, haClose;
   if(Bars<=10) return(0);
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
   int pos=Bars-ExtCountedBars-1;
   while(pos>=0)
     {
      haOpen=(ExtMapBuffer3[pos+1]+ExtMapBuffer4[pos+1])/2;
      haClose=(iOpen(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))+iHigh(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))+iLow(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos]))+iClose(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos])))/4;
      haHigh=MathMax(iHigh(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos])), MathMax(haOpen, haClose));
      haLow=MathMin(iLow(Current_Symbol,Current_Timeframe, iBarShift(Current_Symbol, Current_Timeframe, Time[pos])), MathMin(haOpen, haClose));
      if (haOpen<haClose) 
        {
         ExtMapBuffer1[pos]=haLow;
         ExtMapBuffer2[pos]=haHigh;
        } 
      else
        {
         ExtMapBuffer1[pos]=haHigh;
         ExtMapBuffer2[pos]=haLow;
        } 
      ExtMapBuffer3[pos]=haOpen;
      ExtMapBuffer4[pos]=haClose;
 	   pos--;
     }
//----
   if(mode == 0) return ExtMapBuffer1[_pos];
   if(mode == 1) return ExtMapBuffer2[_pos];
   if(mode == 2) return ExtMapBuffer3[_pos];
   if(mode == 3) return ExtMapBuffer4[_pos];
   return(0);
  }