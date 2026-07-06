//+------------------------------------------------------------------+
//|                                                          VFI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Yellow

extern int Length=130;
extern double Coeff=0.2;
extern double VCoeff=2.5;
extern int Smoothing_Length=3;

double VFI[];
double _VFI[], DirectionalVolume[], Inter[], Vol[];

int init()
{
 IndicatorShortName("Volume Flow oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,VFI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,_VFI);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,DirectionalVolume);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Inter);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Vol);

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
 double T0, T1;
 double VAve, VMax, VC, MF;
 pos=limit;
 while(pos>=0)
 {
  T0=(High[pos]+Low[pos]+Close[pos])/3.;
  T1=(High[pos+1]+Low[pos+1]+Close[pos+1])/3.;
  Inter[pos]=MathLog(T0)-MathLog(T1);
  Vol[pos]=Volume[pos];

  pos--;
 } 
 
 double Vinter, CutOff;
 pos=limit;
 while(pos>=0)
 {
  Vinter=iStdDevOnArray(Inter, 0, 30, 0, MODE_SMA, pos);
  CutOff=Coeff*Vinter*Close[pos];
  VAve=iMAOnArray(Vol, 0, Length, 0, MODE_SMA, pos+1);
  VMax=VAve*VCoeff;
  
  if (Volume[pos]<VMax)
  {
   VC=Volume[pos];
  }
  else
  {
   VC=VMax;
  }

  T0=(High[pos]+Low[pos]+Close[pos])/3.;
  T1=(High[pos+1]+Low[pos+1]+Close[pos+1])/3.;
  MF=T0-T1;
  if (MF>CutOff)
  {
   DirectionalVolume[pos]=VC;
  }
  else
  {
   if (MF<-CutOff)
   {
    DirectionalVolume[pos]=-VC;
   }
   else
   {
    DirectionalVolume[pos]=0.;
   }
  }
  
  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  if (VAve!=0.)
  {
   _VFI[pos]=Length*iMAOnArray(DirectionalVolume, 0, Length, 0, MODE_SMA, pos)/(VAve*Point);
  }
  else
  {
   _VFI[pos]=0.;
  }

  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  if (Smoothing_Length>0.)
  {
   VFI[pos]=iMAOnArray(_VFI, 0, Smoothing_Length, 0, MODE_EMA, pos);
  }
  else
  {
   VFI[pos]=_VFI[pos];
  }

  pos--;
 }  
   
 return(0);
}

