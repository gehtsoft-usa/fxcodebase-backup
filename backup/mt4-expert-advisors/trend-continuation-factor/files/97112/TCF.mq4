//+------------------------------------------------------------------+
//|                                                          TCF.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Red

extern int CP_Length=1;
extern int Length=35;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double PTCF[], NTCF[];
double pc[], nc[], pcf[], ncf[];

int init()
{
 IndicatorShortName("Trend Continuation Factor");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PTCF);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,NTCF);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,pc);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,nc);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,pcf);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,ncf);

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
 double ROC;
 double Pr, Pr_CP;
 pos=limit;
 while(pos>=0)
 {
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr_CP=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+CP_Length);
  if (Pr_CP!=0.)
  {
   ROC=100.*(Pr-Pr_CP)/Pr_CP;
  }
  
  if (ROC>0.) 
  {
   pc[pos]=ROC;
   nc[pos]=0.;
   pcf[pos]=pcf[pos+1]+ROC;
   ncf[pos]=0.;
  }
  else
  {
   pc[pos]=0.;
   nc[pos]=-ROC;
   pcf[pos]=0.;
   ncf[pos]=ncf[pos+1]-ROC;
  }
  

  pos--;
 } 
 
 double pc_sum, nc_sum, pcf_sum, ncf_sum;
 pos=limit;
 while(pos>=0)
 {
  pc_sum=iMAOnArray(pc, 0, Length, 0, MODE_SMA, pos)*Length;
  nc_sum=iMAOnArray(nc, 0, Length, 0, MODE_SMA, pos)*Length;
  pcf_sum=iMAOnArray(pcf, 0, Length, 0, MODE_SMA, pos)*Length;
  ncf_sum=iMAOnArray(ncf, 0, Length, 0, MODE_SMA, pos)*Length;
  
  PTCF[pos]=pc_sum-ncf_sum;
  NTCF[pos]=nc_sum-pcf_sum;

  pos--;
 }
   
 return(0);
}

