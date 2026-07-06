//+------------------------------------------------------------------+
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow
 
extern int Length=1;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  
 
extern int First_Smooth_Length=7;
extern int Second_Smooth_Length=14;
extern double Up_Level=25;
extern double Dn_Level=-25;                         

double TSI[];
double UDM[], ADM[], UDM1[], UDM2[] , ADM1[], ADM2[];

int init()
{
 IndicatorShortName("True Strength Index");
 IndicatorDigits(Digits);
 
 IndicatorBuffers(7);
  
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TSI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,UDM);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,ADM);
 SetIndexStyle(3,DRAW_NONE);
 
 
 SetIndexBuffer(3,ADM1);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,ADM2);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,UDM1);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,UDM2);
 
 SetLevelValue(0, Up_Level);
 SetLevelValue(1, Dn_Level);
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=1) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;

 pos=limit;
 while(pos>=0)
 {
  UDM[pos]=Close[pos]-Close[pos+1];
  ADM[pos]=MathAbs(UDM[pos]);
  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  UDM1[pos]=iMAOnArray(UDM, 0, First_Smooth_Length, 0, MODE_EMA, pos);
  ADM1[pos]=iMAOnArray(ADM, 0, First_Smooth_Length, 0, MODE_EMA, pos);
  pos--;
 }  
   
 pos=limit;
 while(pos>=0)
 {
  UDM2[pos]=iMAOnArray(UDM1, 0, Second_Smooth_Length, 0, MODE_EMA, pos);
  ADM2[pos]=iMAOnArray(ADM1, 0, Second_Smooth_Length, 0, MODE_EMA, pos);
  pos--;
 }  

 
 pos=limit;
 while(pos>=0)
 {
   
  if ( ADM2[pos]!=0)
  {
   TSI[pos]=100.*UDM2[pos]/ ADM2[pos];
  }
  else
  {
   TSI[pos]=0;
  } 
  pos--;
 }  
 
 
   
 return(0);
}
 
