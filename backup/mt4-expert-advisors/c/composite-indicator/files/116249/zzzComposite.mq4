// Id: 19826
//+------------------------------------------------------------------+
//|                                                 zzzComposite.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

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
     double temp = iCustom(NULL, 0, "AROON", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'AROON' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "Frama", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Frama' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "Slope_Direction_Line", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Slope_Direction_Line' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "KRI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'KRI' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "Trix", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Trix' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "WMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'WMA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "KAMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'KAMA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "VORTEX", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'VORTEX' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "DEM", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'DEM' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "forecast", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'forecast' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "supertrend", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'supertrend' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "Heiken Ashi", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Heiken Ashi' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "TMACD", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'TMACD' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "ROC", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'ROC' indicator");
       return INIT_FAILED;
   }
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
 pos=limit;
 while(pos>=0)
 {
  Res=0;
  
  if (RSI_Enable)
  {
   Ind=iRSI(NULL, 0, RSI_Period, PRICE_CLOSE, pos);
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
   Ind=iCCI(NULL, 0, CCI_Period, PRICE_CLOSE, pos);
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
   Ind=iMA(NULL, 0, EMA_Period, 0, MODE_EMA, PRICE_CLOSE, pos);
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
   Ind1=iCustom(NULL, 0, "AROON", AROON_Period, 0, pos);
   Ind2=iCustom(NULL, 0, "AROON", AROON_Period, 1, pos);
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
   Ind=iSAR(NULL, 0, SAR_Step, SAR_Max, pos);
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
   Ind1=iADX(NULL, 0, DMI_Period, PRICE_CLOSE, MODE_PLUSDI, pos);
   Ind2=iADX(NULL, 0, DMI_Period, PRICE_CLOSE, MODE_MINUSDI, pos);
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
   Ind=iCustom(NULL, 0, "Frama", FRAMA_Period, 0, pos);
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
   Ind1=iCustom(NULL, 0, "Slope_Direction_Line", SDL_Period, 1, 0, 0, pos);
   Ind2=iCustom(NULL, 0, "Slope_Direction_Line", SDL_Period, 1, 0, 0, pos+1);
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
   Ind=iCustom(NULL, 0, "KRI", KRI_Period, 0, pos);
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
   Ind1=iCustom(NULL, 0, "Trix", TRIX_Period, 1, 1, 1, 9, 1, 0, 0, pos);
   Ind2=iCustom(NULL, 0, "Trix", TRIX_Period, 1, 1, 1, 9, 1, 0, 1, pos);
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
   Ind=iMomentum(NULL, 0, MOMENTUM_Period, PRICE_CLOSE, pos);
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
   Ind=iCustom(NULL, 0, "WMA", WMA_Period, 0, 0, pos);
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
   Ind=iCustom(NULL, 0, "KAMA", KAMA_Period, 0, 0, pos);
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
   Ind1=iCustom(NULL, 0, "VORTEX", VORTEX_Period, 0, pos);
   Ind2=iCustom(NULL, 0, "VORTEX", VORTEX_Period, 1, pos);
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
   Ind=iCustom(NULL, 0, "DEM", DEM_Period, 1, 0, pos);
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
   Ind=iCustom(NULL, 0, "DEM", DEM_Period, 1, 0, pos);
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
   Ind=iCustom(NULL, 0, "forecast", FORECAST_Period, 0, 0, pos);
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
   Ind1=iCustom(NULL, 0, "supertrend", SUPERTREND_Period, SUPERTREND_Multiplier, 0, pos);
   Ind2=iCustom(NULL, 0, "supertrend", SUPERTREND_Period, SUPERTREND_Multiplier, 1, pos);
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
   Ind1=iCustom(NULL, 0, "Heiken Ashi", 2, pos);
   Ind2=iCustom(NULL, 0, "Heiken Ashi", 3, pos);
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
   Ind=iCustom(NULL, 0, "TMACD", TMACD_Short_Period, TMACD_Long_Period, 0, 0, pos);
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
   Ind=iCustom(NULL, 0, "ROC", ROC_Period, 0, 0, pos);
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
   Ind1=iADX(NULL, 0, DMI2_Period, PRICE_CLOSE, MODE_PLUSDI, pos);
   Ind2=iADX(NULL, 0, DMI2_Period, PRICE_CLOSE, MODE_MINUSDI, pos);
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
   Ind=iADX(NULL, 0, ADX_Period, PRICE_CLOSE, MODE_MAIN, pos);
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

