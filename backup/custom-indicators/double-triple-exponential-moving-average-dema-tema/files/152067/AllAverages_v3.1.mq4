//+------------------------------------------------------------------+
//|                                             AllAverages_v3.1.mq4 |
//|                             Copyright © 2007-13, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
// List of MAs:
// MA_Method= 0: SMA        - Simple Moving Average
// MA_Method= 1: EMA        - Exponential Moving Average
// MA_Method= 2: Wilder     - Wilder Exponential Moving Average
// MA_Method= 3: LWMA       - Linear Weighted Moving Average 
// MA_Method= 4: SineWMA    - Sine Weighted Moving Average
// MA_Method= 5: TriMA      - Triangular Moving Average
// MA_Method= 6: LSMA       - Least Square Moving Average (or EPMA, Linear Regression Line)
// MA_Method= 7: SMMA       - Smoothed Moving Average
// MA_Method= 8: HMA        - Hull Moving Average by Alan Hull
// MA_Method= 9: ZeroLagEMA - Zero-Lag Exponential Moving Average
// MA_Method=10: DEMA       - Double Exponential Moving Average by Patrick Mulloy
// MA_Method=11: T3_basic   - T3 by T.Tillson (original version)
// MA_Method=12: ITrend     - Instantaneous Trendline by J.Ehlers
// MA_Method=13: Median     - Moving Median
// MA_Method=14: GeoMean    - Geometric Mean
// MA_Method=15: REMA       - Regularized EMA by Chris Satchwell
// MA_Method=16: ILRS       - Integral of Linear Regression Slope 
// MA_Method=17: IE/2       - Combination of LSMA and ILRS 
// MA_Method=18: TriMAgen   - Triangular Moving Average generalized by J.Ehlers
// MA_Method=19: VWMA       - Volume Weighted Moving Average 
// MA_Method=20: JSmooth    - Smoothing by Mark Jurik
// MA_Method=21: SMA_eq     - Simplified SMA
// MA_Method=22: ALMA       - Arnaud Legoux Moving Average
// MA_Method=23: TEMA       - Triple Exponential Moving Average by Patrick Mulloy
// MA_Method=24: T3         - T3 by T.Tillson (correct version)
// MA_Method=25: Laguerre   - Laguerre filter by J.Ehlers
// MA_Method=26: MD         - McGinley Dynamic

// List of Prices:
// Price    = 0 - Close  
// Price    = 1 - Open  
// Price    = 2 - High  
// Price    = 3 - Low  
// Price    = 4 - Median Price   = (High+Low)/2  
// Price    = 5 - Typical Price  = (High+Low+Close)/3  
// Price    = 6 - Weighted Close = (High+Low+Close*2)/4
// Price    = 7 - Heiken Ashi Close  
// Price    = 8 - Heiken Ashi Open
// Price    = 9 - Heiken Ashi High
// Price    =10 - Heiken Ashi Low
 
#property copyright "Copyright © 2007-13, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  Silver
#property indicator_width1  2  
#property indicator_color2  DeepSkyBlue
#property indicator_width2  2  
#property indicator_color3  Tomato
#property indicator_width3  2  


//---- 
extern int     TimeFrame    =  0;
extern int     Price        =  0;
extern int     MA_Period    = 14;
extern int     MA_Shift     =  0;
extern int     MA_Method    =  0;
extern int     Color_Mode   =  0;
extern int     Sound_Mode   =  0; //0-off,1-on(works only with Color_Mode=1)
extern int     Sound_Shift  =  0; //0-open bar(multiple),1-closed bar(once)
extern string  Buy_Sound    =  "alert.wav";
extern string  Sell_Sound   =  "alert2.wav";

extern string  PriceMode    = "";
extern string  _0           = "Close";
extern string  _1           = "Open";
extern string  _2           = "High";
extern string  _3           = "Low";
extern string  _4           = "Median";
extern string  _5           = "Typical";
extern string  _6           = "Weighted Close";
extern string  _7           = "Heiken Ashi Close";
extern string  _8           = "Heiken Ashi Open";
extern string  _9           = "Heiken Ashi High";
extern string  _10          = "Heiken Ashi Low";
extern string  MAMode       = "";
extern string  __0          = "SMA";
extern string  __1          = "EMA";
extern string  __2          = "Wilder";
extern string  __3          = "LWMA";
extern string  __4          = "SineWMA";
extern string  __5          = "TriMA";
extern string  __6          = "LSMA";
extern string  __7          = "SMMA";
extern string  __8          = "HMA";
extern string  __9          = "ZeroLagEMA";
extern string  __10         = "DEMA";
extern string  __11         = "T3 basic";
extern string  __12         = "ITrend";
extern string  __13         = "Median";
extern string  __14         = "GeoMean";
extern string  __15         = "REMA";
extern string  __16         = "ILRS";
extern string  __17         = "IE/2";
extern string  __18         = "TriMAgen";
extern string  __19         = "VWMA";
extern string  __20         = "JSmooth";
extern string  __21         = "SMA_eq";
extern string  __22         = "ALMA";
extern string  __23         = "TEMA";
extern string  __24         = "T3";
extern string  __25         = "Laguerre";
extern string  __26         = "MD";



double MA[];
double Up[];
double Dn[];
double aPrice[];
//----
double tmp[][2];
double haClose[2], haOpen[2], haHigh[2], haLow[2];
int    draw_begin, arraysize; 
string IndicatorName, TF, short_name;
int    sUp = 0, sDn =0; 
datetime prevtime, prevhatime;  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- 
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   
   if(TimeFrame == 0 || TimeFrame < Period()) TimeFrame = Period();

//----
   IndicatorBuffers(4); 
   
   SetIndexBuffer(0,    MA); SetIndexStyle(0,DRAW_LINE); SetIndexShift(0,MA_Shift*TimeFrame/Period());
   SetIndexBuffer(1,    Up); SetIndexStyle(1,DRAW_LINE); SetIndexShift(1,MA_Shift*TimeFrame/Period());
   SetIndexBuffer(2,    Dn); SetIndexStyle(2,DRAW_LINE); SetIndexShift(2,MA_Shift*TimeFrame/Period());
   SetIndexBuffer(3,aPrice);
   
   draw_begin=2*MathCeil(0.5*(MA_Period+1))*TimeFrame/Period();
   SetIndexDrawBegin(0,draw_begin);   
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);

//---- 
   
   
   switch(MA_Method)
   {
   case 1 : short_name="EMA(";  break;
   case 2 : short_name="Wilder("; break;
   case 3 : short_name="LWMA("; break;
   case 4 : short_name="SineWMA("; break;
   case 5 : short_name="TriMA("; break;
   case 6 : short_name="LSMA("; break;
   case 7 : short_name="SMMA("; break;
   case 8 : short_name="HMA("; break;
   case 9 : short_name="ZeroLagEMA("; break;
   case 10: short_name="DEMA("; arraysize = 2; break;
   case 11: short_name="T3 basic("; arraysize = 6; break;
   case 12: short_name="InstTrend(";  break;
   case 13: short_name="Median(";  break;
   case 14: short_name="GeometricMean("; break;
   case 15: short_name="REMA(";  break;
   case 16: short_name="ILRS(";  break;
   case 17: short_name="IE/2(";  break;
   case 18: short_name="TriMA_gen("; break;
   case 19: short_name="VWMA("; break;
   case 20: short_name="JSmooth("; arraysize = 5; break;
   case 21: short_name="SMA_eq("; break;
   case 22: short_name="ALMA("; break;
   case 23: short_name="TEMA("; arraysize = 4; break;
   case 24: short_name="T3("; arraysize = 6; break;
   case 25: short_name="Laguerre("; arraysize = 4; break;
   case 26: short_name="McGinleyDynamic(";  break;
   default: MA_Method=0; short_name="SMA(";
   }
   
   switch(TimeFrame)
   {
   case 1     : TF = "M1" ; break;
   case 5     : TF = "M5" ; break;
   case 15    : TF = "M15"; break;
   case 30    : TF = "M30"; break;
   case 60    : TF = "H1" ; break;
   case 240   : TF = "H4" ; break;
   case 1440  : TF = "D1" ; break;
   case 10080 : TF = "W1" ; break;
   case 43200 : TF = "MN1"; break;
   default    : TF = "Current";
   } 
   
   IndicatorName = WindowExpertName(); 
   
   IndicatorShortName(short_name+MA_Period+")"+" "+TF);
   
   SetIndexLabel(1,short_name+MA_Period+")"+" "+TF+" UpTrend");
   SetIndexLabel(2,short_name+MA_Period+")"+" "+TF+" DnTrend");
   SetIndexLabel(0,short_name+MA_Period+")"+" "+TF);
      
//----   
   ArrayResize(tmp,arraysize);
      
   return(0);
}
//+------------------------------------------------------------------+
//| AllAverages_v3.1                                                 |
//+------------------------------------------------------------------+
int start()
{
   int limit, y, i, shift, cnt_bars = IndicatorCounted(); 
   
   if(cnt_bars > 0)  limit = Bars - cnt_bars - 1;
   if(cnt_bars < 0)  return(0);    
   if(cnt_bars < 1)
   {
   limit = Bars - 1;
   
      for(i=Bars-1;i>0;i--) 
      { 
      MA[i] = EMPTY_VALUE; 
      Up[i] = EMPTY_VALUE;
      Dn[i] = EMPTY_VALUE;
      }
   }
   
   
//---- 
   if(TimeFrame != Period())
	{
   limit = MathMax(limit,TimeFrame/Period()+1);   
      
      for(shift = 0;shift < limit;shift++) 
      {	
      y = iBarShift(NULL,TimeFrame,Time[shift]);
      
      MA[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,Price,MA_Period,MA_Shift,MA_Method,Color_Mode,Sound_Mode,Sound_Shift,Buy_Sound,Sell_Sound,0,y);    
         
         if(Color_Mode > 0)
         {
         Up[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,Price,MA_Period,MA_Shift,MA_Method,Color_Mode,Sound_Mode,Sound_Shift,Buy_Sound,Sell_Sound,1,y);    
         Dn[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,Price,MA_Period,MA_Shift,MA_Method,Color_Mode,Sound_Mode,Sound_Shift,Buy_Sound,Sell_Sound,2,y);    
         }
      }  
	
	return(0);
	}
   else
   {
      for(shift=limit;shift>=0;shift--) 
      {
         if(arraysize > 1 && prevtime != Time[shift])
         {
         for(i=0;i<arraysize;i++) tmp[i][1] = tmp[i][0];
         prevtime = Time[shift];
         }

         
         if(Price <= 6) aPrice[shift] = iMA(NULL,0,1,0,0,Price,shift);   
         else
         if(Price > 6 && Price <= 10) aPrice[shift] = HeikenAshi(Price-7,shift);

         switch(MA_Method)
         {
         case 1 : MA[shift] = EMA(aPrice[shift],MA[shift+1],MA_Period,shift); break;
         case 2 : MA[shift] = Wilder(aPrice[shift],MA[shift+1],MA_Period,shift); break;  
         case 3 : MA[shift] = LWMA(aPrice,MA_Period,shift); break;
         case 4 : MA[shift] = SineWMA(aPrice,MA_Period,shift); break;
         case 5 : MA[shift] = TriMA(aPrice,MA_Period,shift); break;
         case 6 : MA[shift] = LSMA(aPrice,MA_Period,shift); break;
         case 7 : MA[shift] = SMMA(aPrice,MA[shift+1],MA_Period,shift); break;
         case 8 : MA[shift] = HMA(aPrice,MA_Period,shift); break;
         case 9 : MA[shift] = ZeroLagEMA(aPrice,MA[shift+1],MA_Period,shift); break;
         case 10: MA[shift] = DEMA(0,aPrice[shift],MA_Period,1,shift); break;
         case 11: MA[shift] = T3_basic(0,aPrice[shift],MA_Period,0.7,shift); break;
         case 12: MA[shift] = ITrend(aPrice,MA,MA_Period,shift); break;
         case 13: MA[shift] = Median(aPrice,MA_Period,shift); break;
         case 14: MA[shift] = GeoMean(aPrice,MA_Period,shift); break;
         case 15: MA[shift] = REMA(aPrice[shift],MA,MA_Period,0.5,shift); break;
         case 16: MA[shift] = ILRS(aPrice,MA_Period,shift); break;
         case 17: MA[shift] = IE2(aPrice,MA_Period,shift); break;
         case 18: MA[shift] = TriMA_gen(aPrice,MA_Period,shift); break;
         case 19: MA[shift] = VWMA(aPrice,MA_Period,shift); break;
         case 20: MA[shift] = JSmooth(0,aPrice[shift],MA_Period,1,shift); break;
         case 21: MA[shift] = SMA_eq(aPrice,MA,MA_Period,shift); break;
         case 22: MA[shift] = ALMA(aPrice,MA_Period,0.85,8,shift); break;
         case 23: MA[shift] = TEMA(aPrice[shift],MA_Period,1,shift); break;
         case 24: MA[shift] = T3(0,aPrice[shift],MA_Period,0.7,shift); break;
         case 25: MA[shift] = Laguerre(aPrice[shift],MA_Period,4,shift); break;
         case 26: MA[shift] = McGinley(aPrice[shift],MA,MA_Period,shift); break;
         default: MA[shift] = SMA(aPrice,MA_Period,shift); break;
         }
                  
        
         if(Color_Mode == 1)
         {
         Up[shift] = EMPTY_VALUE; 
         Dn[shift] = EMPTY_VALUE;
            
            if(MA[shift] > MA[shift+1]) Up[shift] = MA[shift]; 
            else
            if(MA[shift] < MA[shift+1]) Dn[shift] = MA[shift];
                    
      
            if(Sound_Mode == 1 && shift == 0)
            {
               if(((Sound_Shift > 0 && sUp == 0) || Sound_Shift == 0) && MA[shift+Sound_Shift] > MA[shift+1+Sound_Shift] && MA[shift+1+Sound_Shift] <= MA[shift+2+Sound_Shift]) 
               {
               if(Sound_Shift > 0) {sUp = 1; sDn = 0;}
               PlaySound(Buy_Sound);
               }
               else
               if(((Sound_Shift > 0 && sDn == 0) || Sound_Shift == 0) && MA[shift+Sound_Shift] < MA[shift+1+Sound_Shift] && MA[shift+1+Sound_Shift] >= MA[shift+2+Sound_Shift]) 
               {
               if(Sound_Shift > 0) {sUp = 0; sDn = 1;}
               PlaySound(Sell_Sound);
               }
            }
         }
      }
   }
   
//---- 
   return(0);
}

// MA_Method=0: SMA - Simple Moving Average
double SMA(double array[],int per,int bar)
{
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += array[bar+i];
   
   return(Sum/per);
}                
// MA_Method=1: EMA - Exponential Moving Average
double EMA(double price,double prev,int per,int bar)
{
   if(bar >= Bars - 2) double ema = price;
   else 
   ema = prev + 2.0/(1+per)*(price - prev); 
   
   return(ema);
}
// MA_Method=2: Wilder - Wilder Exponential Moving Average
double Wilder(double price,double prev,int per,int bar)
{
   if(bar >= Bars - 2) double wilder = price; //SMA(array1,per,bar);
   else 
   wilder = prev + (price - prev)/per; 
   
   return(wilder);
}
// MA_Method=3: LWMA - Linear Weighted Moving Average 
double LWMA(double array[],int per,int bar)
{
   double Sum = 0;
   double Weight = 0;
   
      for(int i = 0;i < per;i++)
      { 
      Weight+= (per - i);
      Sum += array[bar+i]*(per - i);
      }
   if(Weight>0) double lwma = Sum/Weight;
   else lwma = 0; 
   return(lwma);
} 
// MA_Method=4: SineWMA - Sine Weighted Moving Average
double SineWMA(double array[],int per,int bar)
{
   double pi = 3.1415926535;
   double Sum = 0;
   double Weight = 0;
  
      for(int i = 0;i < per;i++)
      { 
      Weight+= MathSin(pi*(i+1)/(per+1));
      Sum += array[bar+i]*MathSin(pi*(i+1)/(per+1)); 
      }
   if(Weight>0) double swma = Sum/Weight;
   else swma = 0; 
   return(swma);
}
// MA_Method=5: TriMA - Triangular Moving Average
double TriMA(double array[],int per,int bar)
{
   double sma;
   int len = MathCeil((per+1)*0.5);
   
   double sum=0;
   for(int i = 0;i < len;i++) 
   {
   sma = SMA(array,len,bar+i);
   sum += sma;
   } 
   double trima = sum/len;
   
   return(trima);
}
// MA_Method=6: LSMA - Least Square Moving Average (or EPMA, Linear Regression Line)
double LSMA(double array[],int per,int bar)
{   
   double Sum=0;
   for(int i=per; i>=1; i--) Sum += (i-(per+1)/3.0)*array[bar+per-i];
   double lsma = Sum*6/(per*(per+1));
   return(lsma);
}
// MA_Method=7: SMMA - Smoothed Moving Average
double SMMA(double array[],double prev,int per,int bar)
{
   if(bar == Bars - per) double smma = SMA(array,per,bar);
   else 
   if(bar < Bars - per)
   {
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += array[bar+i+1];
   smma = (Sum - prev + array[bar])/per;
   }
   
   return(smma);
}                
// MA_Method=8: HMA - Hull Moving Average by Alan Hull
double HMA(double array[],int per,int bar)
{
   double tmp[];
   int len = MathSqrt(per);
   
   ArrayResize(tmp,len);
   
   if(bar == Bars - per) double hma = array[bar]; 
   else
   if(bar < Bars - per)
   {
   for(int i=0;i<len;i++) tmp[i] = 2*LWMA(array,per/2,bar+i) - LWMA(array,per,bar+i);  
   hma = LWMA(tmp,len,0); 
   }  

   return(hma);
}
// MA_Method=9: ZeroLagEMA - Zero-Lag Exponential Moving Average
double ZeroLagEMA(double price[],double prev,int per,int bar)
{
   double alfa = 2.0/(1+per); 
   int lag = 0.5*(per - 1); 
   
   if(bar >= Bars - lag) double zema = price[bar];
   else 
   zema = alfa*(2*price[bar] - price[bar+lag]) + (1-alfa)*prev;
   
   return(zema);
}
// MA_Method=10: DEMA - Double Exponential Moving Average by Patrick Mulloy
double DEMA(int num,double price,double per,double v,int bar)
{
   double alpha = 2.0/(1+per);
   if(bar == Bars - 2) {double dema = price; tmp[num][0] = dema; tmp[num+1][0] = dema;}
   else 
   if(bar <  Bars - 2) 
   {
   tmp[num  ][0] = tmp[num  ][1] + alpha*(price       - tmp[num  ][1]); 
   tmp[num+1][0] = tmp[num+1][1] + alpha*(tmp[num][0] - tmp[num+1][1]); 
   dema          = tmp[num  ][0]*(1+v) - tmp[num+1][0]*v;
   }
   
   return(dema);
}
// MA_Method=11: T3 by T.Tillson
double T3_basic(int num,double price,int per,double v,int bar)
{
   
   if(bar == Bars - 2) 
   {
   double T3 = price; 
   for(int k=0;k<6;k++) tmp[num+k][0] = T3;
   }
   else 
   if(bar < Bars - 2) 
   {
   double dema1 = DEMA(num  ,price,per,v,bar); 
   double dema2 = DEMA(num+2,dema1,per,v,bar); 
   T3 = DEMA(num+4,dema2,per,v,bar);
   }
   return(T3);
}
// MA_Method=12: ITrend - Instantaneous Trendline by J.Ehlers
double ITrend(double price[],double array[],int per,int bar)
{
   double alfa = 2.0/(per+1);
   if(bar < Bars - 7)
   double it = (alfa - 0.25*alfa*alfa)*price[bar] + 0.5*alfa*alfa*price[bar+1] - (alfa - 0.75*alfa*alfa)*price[bar+2] +
   2*(1-alfa)*array[bar+1] - (1-alfa)*(1-alfa)*array[bar+2];
   else
   it = (price[bar] + 2*price[bar+1] + price[bar+2])/4;
   
   return(it);
}
// MA_Method=13: Median - Moving Median
double Median(double price[],int per,int bar)
{
   double array[];
   ArrayResize(array,per);
   
   for(int i = 0; i < per;i++) array[i] = price[bar+i];
   ArraySort(array);
   
   int num = MathRound((per-1)/2); 
   if(MathMod(per,2) > 0) double median = array[num]; else median = 0.5*(array[num]+array[num+1]);
    
   return(median); 
}
// MA_Method=14: GeoMean - Geometric Mean
double GeoMean(double price[],int per,int bar)
{
   if(bar < Bars - per)
   { 
   double gmean = MathPow(price[bar],1.0/per); 
   for(int i = 1; i < per;i++) gmean *= MathPow(price[bar+i],1.0/per); 
   }
   
   return(gmean);
}
// MA_Method=15: REMA - Regularized EMA by Chris Satchwell 
double REMA(double price,double array[],int per,double lambda,int bar)
{
   double alpha =  2.0/(per + 1);
   if(bar >= Bars - 3) double rema = price;
   else 
   rema = (array[bar+1]*(1+2*lambda) + alpha*(price - array[bar+1]) - lambda*array[bar+2])/(1+lambda); 
   
   return(rema);
}
// MA_Method=16: ILRS - Integral of Linear Regression Slope 
double ILRS(double price[],int per,int bar)
{
   double sum = per*(per-1)*0.5;
   double sum2 = (per-1)*per*(2*per-1)/6.0;
     
   double sum1 = 0;
   double sumy = 0;
      for(int i=0;i<per;i++)
      { 
      sum1 += i*price[bar+i];
      sumy += price[bar+i];
      }
   double num1 = per*sum1 - sum*sumy;
   double num2 = sum*sum - per*sum2;
   
   if(num2 != 0) double slope = num1/num2; else slope = 0; 
   double ilrs = slope + SMA(price,per,bar);
   
   return(ilrs);
}
// MA_Method=17: IE/2 - Combination of LSMA and ILRS 
double IE2(double price[],int per,int bar)
{
   double ie = 0.5*(ILRS(price,per,bar) + LSMA(price,per,bar));
      
   return(ie); 
}
 
// MA_Method=18: TriMAgen - Triangular Moving Average Generalized by J.Ehlers
double TriMA_gen(double array[],int per,int bar)
{
   int len1 = MathFloor((per+1)*0.5);
   int len2 = MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len2;i++) sum += SMA(array,len1,bar+i);
   double trimagen = sum/len2;
   
   return(trimagen);
}

// MA_Method=19: VWMA - Volume Weighted Moving Average 
double VWMA(double array[],int per,int bar)
{
   double Sum = 0;
   double Weight = 0;
   
      for(int i = 0;i < per;i++)
      { 
      Weight+= Volume[bar+i];
      Sum += array[bar+i]*Volume[bar+i];
      }
   if(Weight>0) double vwma = Sum/Weight;
   else vwma = 0; 
   return(vwma);
} 

// MA_Method=20: JSmooth - Smoothing by Mark Jurik
double JSmooth(int num,double price,int per,double pow,int bar)
{
   double beta = 0.45*(per-1)/(0.45*(per-1)+2);
	double alpha = MathPow(beta,pow);
	if(bar == Bars - 2) {tmp[num+4][0] = price; tmp[num+0][0] = price; tmp[num+2][0] = price;}
	else 
   if(bar <  Bars - 2) 
   {
	tmp[num+0][0] = (1-alpha)*price + alpha*tmp[num+0][1];
	tmp[num+1][0] = (price - tmp[num+0][0])*(1-beta) + beta*tmp[num+1][1];
	tmp[num+2][0] = tmp[num+0][0] + tmp[num+1][0];
	tmp[num+3][0] = (tmp[num+2][0] - tmp[num+4][1])*MathPow((1-alpha),2) + MathPow(alpha,2)*tmp[num+3][1];
	tmp[num+4][0] = tmp[num+4][1] + tmp[num+3][0]; 
   }
   return(tmp[num+4][0]);
}

// MA_Method=21: SMA_eq     - Simplified SMA
double SMA_eq(double price[],double array[],int per,int bar)
{
   if(bar == Bars - per) double sma = SMA(price,per,bar);
   else 
   if(bar <  Bars - per) sma = (price[bar] - price[bar+per])/per + array[bar+1]; 
   
   return(sma);
}                        		

// MA_Method=22: ALMA by Arnaud Legoux / Dimitris Kouzis-Loukas / Anthony Cascino
double ALMA(double price[],int per,double offset,double sigma,int bar)
{
   double m = MathFloor(offset * (per - 1));
	double s = per/sigma;
		
	double w, sum =0, wsum = 0;		
	for (int i=0;i < per;i++) 
	{
	w = MathExp(-((i - m)*(i - m))/(2*s*s));
   wsum += w;
   sum += price[bar+(per-1-i)] * w; 
   }
   
   if(wsum != 0) double alma = sum/wsum; 
   
   return(alma);
}   

// MA_Method=23: TEMA - Triple Exponential Moving Average by Patrick Mulloy
double TEMA(double price,int per,double v,int bar)
{
   double alpha = 2.0/(per+1);
	
	if(bar == Bars - 2) {tmp[0][0] = price; tmp[1][0] = price; tmp[2][0] = price;}
	else 
   if(bar <  Bars - 2) 
   {
	tmp[0][0] = tmp[0][1] + alpha *(price     - tmp[0][1]);
	tmp[1][0] = tmp[1][1] + alpha *(tmp[0][0] - tmp[1][1]);
	tmp[2][0] = tmp[2][1] + alpha *(tmp[1][0] - tmp[2][1]);
	tmp[3][0] = tmp[0][0] + v*(tmp[0][0] + v*(tmp[0][0]-tmp[1][0]) - tmp[1][0] - v*(tmp[1][0] - tmp[2][0])); 
	}
   
   return(tmp[3][0]);
}

// MA_Method=24: T3 by T.Tillson (correct version) 
double T3(int num,double price,int per,double v,int bar)
{
   double len = MathMax((per + 5.0)/3.0-1,1), dema1, dema2;
   
   if(bar == Bars - 2) 
   {
   double T3 = price; 
   for(int k=0;k<=5;k++) tmp[num+k][0] = T3;
   }
   else 
   if(bar < Bars - 2) 
   {
   dema1 = DEMA(num  ,price,len,v,bar); 
   dema2 = DEMA(num+2,dema1,len,v,bar); 
   T3    = DEMA(num+4,dema2,len,v,bar);
   }
   
   return(T3);
}

// MA_Method=25: Laguerre filter by J.Ehlers
double Laguerre(double price,int per,int order,int bar)
{
   double gamma = 1-10.0/(per+9);
   double aPrice[];
   
   ArrayResize(aPrice,order);
   
   for(int i=0;i<order;i++)
   {
      if(bar >= Bars - order) tmp[i][0] = price;
      else
      {
         if(i == 0) tmp[i][0] = (1 - gamma)*price + gamma*tmp[i][1];
         else
         tmp[i][0] = -gamma * tmp[i-1][0] + tmp[i-1][1] + gamma * tmp[i][1];
      
      aPrice[i] = tmp[i][0];
      }
   }
   double laguerre = TriMA_gen(aPrice,order,0);  

   return(laguerre);
}

// MA_Method=26:  MD - McGinley Dynamic
double McGinley(double price,double array[],int per,int bar)
{
   if(bar == Bars - 2) double md = price;
   else 
   if(bar <  Bars - 2) md = array[bar+1] + (price - array[bar+1])/(per*MathPow(price/array[bar+1],4)/2); 

   return(md);
}

// HeikenAshi Price:  7 - Close,8 - Open,9 - High,10 - Low 
double HeikenAshi(int price,int bar)
{ 
   if(prevhatime != Time[bar])
   {
   haClose[1] = haClose[0];
   haOpen [1] = haOpen [0];
   haHigh [1] = haHigh [0];
   haLow  [1] = haLow  [0];
   prevhatime = Time[bar];
   }
   
   if(bar == Bars - 1) 
   {
   haClose[0] = Close[bar];
   haOpen [0] = Open [bar];
   haHigh [0] = High [bar];
   haLow  [0] = Low  [bar];
   }
   else
   {
   haClose[0] = (Open[bar] + High[bar] + Low[bar] + Close[bar])/4;
   haOpen [0] = (haOpen[1] + haClose[1])/2;
   haHigh [0] = MathMax(High[bar],MathMax(haOpen[0],haClose[0]));
   haLow  [0] = MathMin(Low [bar],MathMin(haOpen[0],haClose[0]));
   }
   
   switch(price)
   {
   case 0: return(haClose[0]); break;
   case 1: return(haOpen [0]); break;
   case 2: return(haHigh [0]); break;
   case 3: return(haLow  [0]); break;
   }
}     
   

