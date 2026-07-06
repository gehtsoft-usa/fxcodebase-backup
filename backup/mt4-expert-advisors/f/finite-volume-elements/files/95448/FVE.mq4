//+------------------------------------------------------------------+
//|                                                          FVE.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length1=22;
extern int MA1_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int Length2=22;
extern int MA2_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA

double FVE[], Signal[];
double Intra[], Inter[], VE[], Vol[];

int init()
{
 IndicatorShortName("Finite Volume Elements");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,FVE);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Intra);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Inter);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,VE);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,Vol);

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
 pos=limit;
 while(pos>=0)
 {
  Intra[pos]=MathLog(High[pos])-MathLog(Low[pos]);
  Inter[pos]=MathLog((High[pos]+Low[pos]+Close[pos])/3.)-MathLog((High[pos+1]+Low[pos+1]+Close[pos+1])/3.);
  Vol[pos]=Volume[pos];

  pos--;
 } 
 
 double Vintra, Vinter, Cutoff, MF, MA1;
 pos=limit;
 while(pos>=0)
 {
  Vintra=iStdDevOnArray(Intra, 0, Length1, 0, MODE_SMA, pos);
  Vinter=iStdDevOnArray(Inter, 0, Length1, 0, MODE_SMA, pos);
  Cutoff=0.1*(Vintra+Vinter)*Close[pos];
  MF=Close[pos]-(High[pos]+Low[pos])/2.+High[pos]+Low[pos]+Close[pos]-High[pos+1]-Low[pos+1]-Close[pos+1];
  
  if (MF>Cutoff)
  {
   VE[pos]=Volume[pos];
  }
  else
  {
   if (MF<-Cutoff)
   {
    VE[pos]=-Volume[pos];
   }
   else
   {
    VE[pos]=0.;
   }
  }
  
  pos--;
 }
 
 double MA_VE;
 pos=limit;
 while(pos>=0)
 {
  MA_VE=iMAOnArray(VE, 0, Length1, 0, MODE_SMA, pos);
  MA1=iMAOnArray(Vol, 0, Length1, 0, MA1_Method, pos);
  if (MA1!=0.)
  {
   FVE[pos]=100.*MA_VE/(MA1*Point);
  }
  else
  {
   FVE[pos]=0.;
  } 

  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(FVE, 0, Length2, 0, MA2_Method, pos);

  pos--;
 }  
   
 return(0);
}

