// Id: 14147
//+------------------------------------------------------------------+
//|                                           CCI_OBOS_Crossover.mq4 |
//|                               Copyright � 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int OBOS_Length=9;
extern int CCI_Length=14;
extern bool Use_Filter=false;
extern double Overbought_Level=50.;
extern double Oversold_Level=-50.;
extern int Dot_Size=3;

double Up[], Dn[];

int init()
{
     double temp = iCustom(NULL, 0, "OBOS", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'OBOS' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("CCI OBOS Crossover");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,Dot_Size);
 SetIndexArrow(0,119);
 SetIndexBuffer(0,Up);
 SetIndexStyle(1,DRAW_ARROW,0,Dot_Size);
 SetIndexArrow(1,119);
 SetIndexBuffer(1,Dn);

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
 double CCI0, CCI1;
 double OBOS_H0, OBOS_H1, OBOS_L0, OBOS_L1;
 pos=limit;
 while(pos>=0)
 {
  CCI0=iCCI(NULL, 0, CCI_Length, PRICE_TYPICAL, pos);
  CCI1=iCCI(NULL, 0, CCI_Length, PRICE_TYPICAL, pos+1);
  
  OBOS_H0=iCustom(NULL, 0, "OBOS", OBOS_Length, 100, 0, pos);
  OBOS_H1=iCustom(NULL, 0, "OBOS", OBOS_Length, 100, 0, pos+1);
  OBOS_L0=iCustom(NULL, 0, "OBOS", OBOS_Length, 100, 1, pos);
  OBOS_L1=iCustom(NULL, 0, "OBOS", OBOS_Length, 100, 1, pos+1);
  
  if (CCI1<OBOS_H1 && CCI0>OBOS_H0 && (!Use_Filter || (Use_Filter && OBOS_L0<Oversold_Level)))
  {
   Up[pos]=Low[pos];
  }
  else
  {
   Up[pos]=EMPTY_VALUE;
  }

  if (CCI1>OBOS_L1 && CCI0<OBOS_L0 && (!Use_Filter || (Use_Filter && OBOS_H0>Overbought_Level)))
  {
   Dn[pos]=High[pos];
  }
  else
  {
   Dn[pos]=EMPTY_VALUE;
  }

  pos--;
 } 
 return(0);
}

