//+------------------------------------------------------------------+
//|                                                          PCI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Yellow
#property indicator_color2 Green
#property indicator_color3 Red

extern int Length=34;
extern double OverBoughtLevel=80;
extern double OverSoldLevel=20;
extern int LevelWidth=1;
extern color LevelColor=Gray;                        
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted 

double PCI[], H1[], H2[], H3[];
double Signal[], Pr[];

int init()
{
 IndicatorShortName("Phase Change Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PCI);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,H1);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,H2);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,H3);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Signal);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,Pr);
 
 SetLevelValue(0, 50);
 SetLevelValue(1, OverBoughtLevel);
 SetLevelValue(2, OverSoldLevel);
 SetLevelStyle(EMPTY, LevelWidth, LevelColor);

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
 double Momentum, Gradient;
 int i;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);

  pos--;
 } 
 
 pos=limit;
 double Up, Dn;
 while(pos>=0)
 {
  Momentum=(Pr[pos]-Pr[pos+Length-1])/Length;
  Up=0.;
  Dn=0.;
  for (i=0;i<=Length;i++)
  {
   Gradient=Pr[pos+Length]+Momentum*i;
   if (Pr[pos+Length-i]-Gradient>0.)
   {
    Up=Up+MathAbs(Pr[pos+Length-i]-Gradient);
   }
   else
   {
    if (Pr[pos+Length-i]-Gradient<0.)
    {
     Dn=Dn+MathAbs(Pr[pos+Length-i]-Gradient);
    }
   }
  }
  
  if (Up+Dn!=0.)
  {
   PCI[pos]=100.*Up/(Up+Dn);
  }
  else
  {
   PCI[pos]=EMPTY_VALUE;
  }
  
  if (Momentum>0.)
  {
   if (PCI[pos]<OverSoldLevel)
   {
    Signal[pos]=1.;
   }
   else
   {
    Signal[pos]=Signal[pos+1];
   }
  }
  else
  {
   if (PCI[pos]>OverBoughtLevel)
   {
    Signal[pos]=-1.;
   }
   else
   {
    Signal[pos]=Signal[pos+1];
   }
  }
  
  if (Signal[pos]==1.)
  {
   if (PCI[pos]>50.)
   {
    H1[pos]=PCI[pos];
    H3[pos]=50.;
   }
   else
   {
    H1[pos]=50.;
    H3[pos]=PCI[pos];
   } 
   H2[pos]=EMPTY_VALUE;
  }
  else
  {
   if (Signal[pos]==-1.)
   {
   if (PCI[pos]>50.)
   {
    H2[pos]=PCI[pos];
    H3[pos]=50.;
   }
   else
   {
    H2[pos]=50.;
    H3[pos]=PCI[pos];
   } 
    H1[pos]=EMPTY_VALUE;
   }
  }

  pos--;
 }  
 
 return(0);
}

