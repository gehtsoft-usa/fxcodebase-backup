// Id: 9354
//+------------------------------------------------------------------+
//|                                                        spavo.mq4 |
//|                               Copyright � 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Red

extern int Length=10;
extern double Cutoff=1;
extern double devH=1.5;
extern double devL=1.3;
extern int StdDevLength=100;

double spavo[], ULine[], LLine[];
double vtr[], calc[], Base[];

int init()
  {
       double temp = iCustom(NULL, 0, "HA_EMA3", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'HA_EMA3' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "Volume_LR_EMA3", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Volume_LR_EMA3' indicator");
       return INIT_FAILED;
   }
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,spavo);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ULine);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,LLine);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,vtr);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,calc);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,Base);

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
 double haC0, haC1;
 double vc;
 int i;
 double sum;
 double vmax, vave;
 pos=limit;
 while(pos>0)
 {
  haC0=3*iCustom(NULL, 0, "HA_EMA3", Length, 1, 1, pos)-3*iCustom(NULL, 0, "HA_EMA3", Length, 1, 2, pos)+iCustom(NULL, 0, "HA_EMA3", Length, 1, 0, pos);
  haC1=3*iCustom(NULL, 0, "HA_EMA3", Length, 1, 1, pos+1)-3*iCustom(NULL, 0, "HA_EMA3", Length, 1, 2, pos+1)+iCustom(NULL, 0, "HA_EMA3", Length, 1, 0, pos+1);
  vtr[pos]=3*iCustom(NULL, 0, "Volume_LR_EMA3", Length, 1, 1, pos)-3*iCustom(NULL, 0, "Volume_LR_EMA3", Length, 1, 2, pos)+iCustom(NULL, 0, "Volume_LR_EMA3", Length, 1, 0, pos);
  sum=0;
  for (i=0;i<Length*5;i++)
  {
   sum=sum+Volume[pos-i+1];
  }
  vave=sum/(5*Length);
  vmax=vave*2;

  vc=MathMin(vmax, Volume[pos]);
  
  
  if (haC0>haC1*(1+Cutoff/1000) && vtr[pos]>=vtr[pos+1] && vtr[pos+1]>vtr[pos+2]) 
  {
   calc[pos]=vc;
  }
  else
  {
   if (haC0<haC1*(1-Cutoff/1000) && vtr[pos]>=vtr[pos+1] && vtr[pos+1]>vtr[pos+2])
   {
    calc[pos]=-vc;
   }
   else
   {
    calc[pos]=0;
   } 
  }
  pos--;
 } 
 
 pos=limit;
 while(pos>0)
 {
  Base[pos]=iMAOnArray(calc, 0, Length, 0, MODE_SMA, pos)*Length/(vave+1);
  pos--;
 }  

 pos=limit;
 while(pos>0)
 {
  spavo[pos]=100*(3*iCustom(NULL, 0, "Volume_LR_EMA3", Length, 1, 1, pos)-3*iCustom(NULL, 0, "Volume_LR_EMA3", Length, 1, 2, pos)+iMAOnArray(Base, 0, Length, 0, MODE_EMA, pos));
  pos--;
 }  
 
 double StdDev;
 pos=limit;
 while(pos>0)
 {
  StdDev=iStdDevOnArray(spavo, 0, StdDevLength, 0, MODE_SMA, pos);
  ULine[pos]=devH*StdDev;
  LLine[pos]=-devL*StdDev;
  pos--;
 }  

 return(0);
}

