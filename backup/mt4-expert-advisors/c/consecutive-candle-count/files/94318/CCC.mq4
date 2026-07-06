//+------------------------------------------------------------------+
//|                                                          CCC.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern bool Use_Heiken_Ashi=false;

double CCC[], CCC_Dn[];
double HA_O[], HA_C[];

int init()
{
 IndicatorShortName("Consecutive Candle Count");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,CCC);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,CCC_Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,HA_O);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,HA_C);

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
 double O, C;
 pos=limit;
 while(pos>=0)
 {
  if (Use_Heiken_Ashi)
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
   O=HA_O[pos];
   C=HA_C[pos];
  }
  else
  {
   O=Open[pos];
   C=Close[pos];
  }
  
  if (CCC[pos+1]>0. && C>=O)
  {
   CCC[pos]=CCC[pos+1]+1.;
  }
  else
  {
   if (CCC[pos+1]<0. && C<=O)
   {
    CCC[pos]=CCC[pos+1]-1.;
   }
   else
   {
    if (C>O)
    {
     CCC[pos]=1.;
    }
    else
    {
     if (C<O)
     {
      CCC[pos]=-1.;
     }
     else
     {
      CCC[pos]=CCC[pos+1];
     }
    }
   }
  }
  
  if (CCC[pos]>0.)
  {
   CCC_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   CCC_Dn[pos]=CCC[pos];
  }
  
  pos--;
 } 
 return(0);
}

