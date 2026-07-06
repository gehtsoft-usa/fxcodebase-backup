//+------------------------------------------------------------------+
//|                                       Heiken_Ashi_Zone_Trade.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Gray

extern string Source_Str="Source: 0 - Price, 1 - HA";
extern int Source=0;   // 0 - Price, 1 - HA
extern int Fast_Length=5;
extern int Slow_Length=35;
extern int AC_Length=5;
extern string Mode_Str="Mode: 0 - AO, 1 - AC, 2 - AC+AO";
extern int Mode=2;    // 0 - AO, 1 - AC, 2 - AC+AO

double Up[], Dn[], Ne[];
double HA_O[], HA_C[], HA_M[], AO[], AC[];

int init()
{
 IndicatorShortName("Heiken Ashi Zone Trade");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Up);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,Dn);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,Ne);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,HA_O);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,HA_C);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,HA_M);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,AO);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,AC);

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
 int limit=Bars-3;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double HA_L, HA_H;
 pos=limit;
 while(pos>=0)
 {
  if (Source==1)
  {
   if (pos==Bars-2)
   {
    HA_O[pos]=(Open[pos+1]+Close[pos+1])/2.;
   }
   else
   {
    HA_O[pos]=(HA_O[pos+1]+HA_C[pos+1])/2.;
   }
   HA_C[pos]=(Open[pos]+High[pos]+Low[pos]+Close[pos])/4.;
   HA_H=MathMax(HA_O[pos], MathMax(HA_C[pos], High[pos]));
   HA_L=MathMin(HA_O[pos], MathMin(HA_C[pos], Low[pos]));
   HA_M[pos]=(HA_H+HA_L)/2.;
  }
  else
  {
   HA_M[pos]=(High[pos]+Low[pos])/2.;
  } 

  pos--;
 } 
 
 double AO_F, AO_S;
 pos=limit;
 while(pos>=0)
 {
  AO_F=iMAOnArray(HA_M, 0, Fast_Length, 0, MODE_SMA, pos);
  AO_S=iMAOnArray(HA_M, 0, Slow_Length, 0, MODE_SMA, pos);
  
  AO[pos]=AO_F-AO_S;

  pos--;
 }
 
 double AO_MA;
 pos=limit;
 while(pos>=0)
 {
  AO_MA=iMAOnArray(AO, 0, AC_Length, 0, MODE_SMA, pos);
  
  AC[pos]=AO[pos]-AO_MA;

  pos--;
 }  
 
 bool AO_Dir, AC_Dir;
 pos=limit;
 while(pos>=0)
 {
  if (AO[pos]>AO[pos+1])
  {
   AO_Dir=true;
  }
  else
  {
   AO_Dir=false;
  }
  
  if (AC[pos]>AC[pos+1])
  {
   AC_Dir=true;
  }
  else
  {
   AC_Dir=false;
  }
  
  Up[pos]=0.; Dn[pos]=0.; Ne[pos]=0.;
  
  if (Mode==0)
  {
   if (AO_Dir)
   {
    Up[pos]=1000.;
   }
   else
   {
    if (!AO_Dir)
    {
     Dn[pos]=1000.;
    }
    else
    {
     Ne[pos]=1000.;
    }
   }
  }
  else
  {
   if (Mode==1)
   {
    if (AC_Dir)
    {
     Up[pos]=1000.;
    }
    else
    {
     if (!AC_Dir)
     {
      Dn[pos]=1000.;
     }
     else
     {
      Ne[pos]=1000.;
     }
    }
   }
   else
   {
    if (AO_Dir && AC_Dir)
    {
     Up[pos]=1000.;
    }
    else
    {
     if (!AO_Dir && !AC_Dir)
     {
      Dn[pos]=1000.;
     }
     else
     {
      Ne[pos]=1000.;
     }
    }
   }
  }

  pos--;
 }  
   
 return(0);
}

