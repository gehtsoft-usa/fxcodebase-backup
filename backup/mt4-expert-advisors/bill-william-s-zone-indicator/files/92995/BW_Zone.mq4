// Id: 11281
//+------------------------------------------------------------------+
//|                                                      BW_Zone.mq4 |
//|                               Copyright � 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Fast_Length=5;
extern int Slow_Length=35;
extern int AD_Length=5;

double UP[], DN[];
double Dir[];

int init()
{
     double temp = iCustom(NULL, 0, "AwesomeOscillator", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'AwesomeOscillator' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "Accelerator_Oscillator", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Accelerator_Oscillator' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("Bill William's zone indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,4);
 SetIndexArrow(0,119);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_ARROW,0,4);
 SetIndexArrow(1,119);
 SetIndexBuffer(1,DN);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Dir);

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
 double AO0, AO1, AO2, AO3, AO4;
 double AC0, AC1, AC2, AC3, AC4;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  Dir[pos]=Dir[pos+1];
  AO0=iCustom(NULL, 0, "AwesomeOscillator", Fast_Length, Slow_Length, 0, 4, 0, pos);
  AO1=iCustom(NULL, 0, "AwesomeOscillator", Fast_Length, Slow_Length, 0, 4, 0, pos+1);
  AO2=iCustom(NULL, 0, "AwesomeOscillator", Fast_Length, Slow_Length, 0, 4, 0, pos+2);
  AO3=iCustom(NULL, 0, "AwesomeOscillator", Fast_Length, Slow_Length, 0, 4, 0, pos+3);
  AO4=iCustom(NULL, 0, "AwesomeOscillator", Fast_Length, Slow_Length, 0, 4, 0, pos+4);
  AC0=iCustom(NULL, 0, "Accelerator_Oscillator", Fast_Length, Slow_Length, AD_Length, 0, 4, 0, pos);
  AC1=iCustom(NULL, 0, "Accelerator_Oscillator", Fast_Length, Slow_Length, AD_Length, 0, 4, 0, pos+1);
  AC2=iCustom(NULL, 0, "Accelerator_Oscillator", Fast_Length, Slow_Length, AD_Length, 0, 4, 0, pos+2);
  AC3=iCustom(NULL, 0, "Accelerator_Oscillator", Fast_Length, Slow_Length, AD_Length, 0, 4, 0, pos+3);
  AC4=iCustom(NULL, 0, "Accelerator_Oscillator", Fast_Length, Slow_Length, AD_Length, 0, 4, 0, pos+4);
  if (AO0>AO1 && AO1>AO2 && AO2>AO3 && AO3>AO4 && AC0>AC1 && AC1>AC2 && AC2>AC3 && AC3>AC4)
  {
   if (Dir[pos]!=1)
   {
    Dir[pos]=1;
    UP[pos]=High[pos];
   }
   else
   {
    UP[pos]=EMPTY_VALUE;
   }
  }
  
  if (AO0<AO1 && AO1<AO2 && AO2<AO3 && AO3<AO4 && AC0<AC1 && AC1<AC2 && AC2<AC3 && AC3<AC4)
  {
   if (Dir[pos]!=-1)
   {
    Dir[pos]=-1;
    DN[pos]=Low[pos];
   }
   else
   {
    UP[pos]=EMPTY_VALUE;
   }
  }
  
  if ((AO0<AO1 || AC0<AC1) && Dir[pos]==1)
  {
   Dir[pos]=0;
  }
  else
  {
   if ((AO0>AO1 || AC0>AC1) && Dir[pos]==-1)
   {
    Dir[pos]=0;
   }
  }
  
  pos--;
 } 
 return(0);
}

