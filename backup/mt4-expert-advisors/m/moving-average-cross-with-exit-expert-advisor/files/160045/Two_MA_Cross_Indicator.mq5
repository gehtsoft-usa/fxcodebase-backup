//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=159876#p159876

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   4

#property indicator_color1  clrRed
#property indicator_width1  1
#property indicator_type1   DRAW_LINE
#property indicator_label1  "MA1"

#property indicator_color2  clrWhite
#property indicator_width2  2
#property indicator_type2   DRAW_LINE
#property indicator_label2  "MA2"

#property indicator_color3  clrLime
#property indicator_width3  2
#property indicator_type3   DRAW_ARROW
#property indicator_label3  "Up"

#property indicator_color4  clrRed
#property indicator_width4  2
#property indicator_type4   DRAW_ARROW
#property indicator_label4  "Dn"

enum e_method
  {
   M_SMA        =  1,
   M_EMA        =  2,
   M_Wilder     =  3,
   M_LWMA       =  4,
   M_SineWMA    =  5,
   M_TriMA      =  6,
   M_LSMA       =  7,
   M_SMMA       =  8,
   M_HMA        =  9,
   M_ZeroLagEMA = 10,
   M_ITrend     = 11,
   M_Median     = 12,
   M_GeoMean    = 13,
   M_REMA       = 14,
   M_ILRS       = 15,
   M_IE_2       = 16,
   M_TriMAgen   = 17
  };

input int                MA_Period1      = 30;
input e_method           MA_Method1      = M_SMA;
input ENUM_APPLIED_PRICE MA_Price_Type1  = PRICE_CLOSE;
input int                MA_Period2      = 100;
input e_method           MA_Method2      = M_SMA;
input ENUM_APPLIED_PRICE MA_Price_Type2  = PRICE_CLOSE;
input int                Limit_Bars      = 800;

double MA1[];
double MA2[];
double Up[];
double Dn[];

double Price1[];
double Price2[];

int g_rates_total = 0;

double GetPrice(const int index,const ENUM_APPLIED_PRICE price_type,
                const double &open[],const double &high[],const double &low[],const double &close[])
  {
   switch(price_type)
     {
      case PRICE_OPEN:     return open[index];
      case PRICE_HIGH:     return high[index];
      case PRICE_LOW:      return low[index];
      case PRICE_MEDIAN:   return (high[index]+low[index])/2.0;
      case PRICE_TYPICAL:  return (high[index]+low[index]+close[index])/3.0;
      case PRICE_WEIGHTED: return (high[index]+low[index]+2.0*close[index])/4.0;
      case PRICE_CLOSE:
      default:             return close[index];
     }
  }

int OnInit()
  {
   SetIndexBuffer(0,MA1,INDICATOR_DATA);
   SetIndexBuffer(1,MA2,INDICATOR_DATA);
   SetIndexBuffer(2,Up ,INDICATOR_DATA);
   SetIndexBuffer(3,Dn ,INDICATOR_DATA);

   SetIndexBuffer(4,Price1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,Price2,INDICATOR_CALCULATIONS);

   PlotIndexSetInteger(2,PLOT_ARROW,233);
   PlotIndexSetInteger(3,PLOT_ARROW,234);

   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);

   ArraySetAsSeries(MA1,true);
   ArraySetAsSeries(MA2,true);
   ArraySetAsSeries(Up ,true);
   ArraySetAsSeries(Dn ,true);
   ArraySetAsSeries(Price1,true);
   ArraySetAsSeries(Price2,true);

   return(INIT_SUCCEEDED);
  }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   g_rates_total=rates_total;

   if(rates_total<MathMax(MA_Period1,MA_Period2)+10)
      return(prev_calculated);

   int limit=Limit_Bars;
   if(limit>rates_total-2)
      limit=rates_total-2;

   for(int i=limit;i>=0;i--)
     {
      int idx=rates_total-1-i;
      Price1[i]=GetPrice(idx,MA_Price_Type1,open,high,low,close);

      switch(MA_Method1)
        {
         case M_SMA :  MA1[i]=SMA(Price1,MA_Period1,i,1);                                    break;
         case M_EMA :  MA1[i]=EMA(Price1[i],MA1[i+1],MA_Period1,i);                          break;
         case M_Wilder:MA1[i]=Wilder(Price1[i],MA1[i+1],MA_Period1,i);                       break;
         case M_LWMA:  MA1[i]=LWMA(Price1,MA_Period1,i,1);                                   break;
         case M_SineWMA:MA1[i]=SineWMA(Price1,MA_Period1,i,1);                               break;
         case M_TriMA: MA1[i]=TriMA(Price1,MA_Period1,i,1);                                  break;
         case M_LSMA:  MA1[i]=LSMA(Price1,MA_Period1,i,1);                                   break;
         case M_SMMA:  MA1[i]=SMMA(Price1,MA1[i+1],MA_Period1,i,1);                          break;
         case M_HMA:   MA1[i]=HMA(Price1,MA_Period1,i,1);                                    break;
         case M_ZeroLagEMA: MA1[i]=ZeroLagEMA(Price1,MA1[i+1],MA_Period1,i,1);               break;
         case M_ITrend:MA1[i]=ITrend(Price1,MA1,MA_Period1,i,1);                             break;
         case M_Median:MA1[i]=Median(Price1,MA_Period1,i,1);                                 break;
         case M_GeoMean:MA1[i]=GeoMean(Price1,MA_Period1,i,1);                               break;
         case M_REMA:  MA1[i]=REMA(Price1[i],MA1,MA_Period1,0.5,i,1);                        break;
         case M_ILRS:  MA1[i]=ILRS(Price1,MA_Period1,i,1);                                   break;
         case M_IE_2:  MA1[i]=IE2(Price1,MA_Period1,i,1);                                    break;
         case M_TriMAgen:MA1[i]=TriMA_gen(Price1,MA_Period1,i,1);                            break;
         default:    MA1[i]=SMA(Price1,MA_Period1,i,1);                                   break;
        }
     }

   for(int i=limit;i>=0;i--)
     {
      int idx=rates_total-1-i;
      Price2[i]=GetPrice(idx,MA_Price_Type2,open,high,low,close);

      switch(MA_Method2)
        {
         case M_SMA :  MA2[i]=SMA(Price2,MA_Period2,i,1);                                    break;
         case M_EMA :  MA2[i]=EMA(Price2[i],MA2[i+1],MA_Period2,i);                          break;
         case M_Wilder:MA2[i]=Wilder(Price2[i],MA2[i+1],MA_Period2,i);                       break;
         case M_LWMA:  MA2[i]=LWMA(Price2,MA_Period2,i,1);                                   break;
         case M_SineWMA:MA2[i]=SineWMA(Price2,MA_Period2,i,1);                               break;
         case M_TriMA: MA2[i]=TriMA(Price2,MA_Period2,i,1);                                  break;
         case M_LSMA:  MA2[i]=LSMA(Price2,MA_Period2,i,1);                                   break;
         case M_SMMA:  MA2[i]=SMMA(Price2,MA2[i+1],MA_Period2,i,1);                          break;
         case M_HMA:   MA2[i]=HMA(Price2,MA_Period2,i,1);                                    break;
         case M_ZeroLagEMA: MA2[i]=ZeroLagEMA(Price2,MA2[i+1],MA_Period2,i,1);               break;
         case M_ITrend:MA2[i]=ITrend(Price2,MA2,MA_Period2,i,1);                             break;
         case M_Median:MA2[i]=Median(Price2,MA_Period2,i,1);                                 break;
         case M_GeoMean:MA2[i]=GeoMean(Price2,MA_Period2,i,1);                               break;
         case M_REMA:  MA2[i]=REMA(Price2[i],MA2,MA_Period2,0.5,i,1);                        break;
         case M_ILRS:  MA2[i]=ILRS(Price2,MA_Period2,i,1);                                   break;
         case M_IE_2:  MA2[i]=IE2(Price2,MA_Period2,i,1);                                    break;
         case M_TriMAgen:MA2[i]=TriMA_gen(Price2,MA_Period2,i,1);                            break;
         default:    MA2[i]=SMA(Price2,MA_Period2,i,1);                                   break;
        }
     }

   for(int i=Limit_Bars;i>=Limit_Bars-MathMax(MA_Period1,MA_Period2);i--)
     {
      if(i>=0)
        {
         MA1[i]=EMPTY_VALUE;
         MA2[i]=EMPTY_VALUE;
        }
     }

   for(int i=limit;i>=0;i--)
     {
      if(MA2[i+1]>MA1[i+1] && MA2[i]<MA1[i])
         Up[i]=MA1[i];
      else
         Up[i]=EMPTY_VALUE;

      if(MA2[i+1]<MA1[i+1] && MA2[i]>MA1[i])
         Dn[i]=MA1[i];
      else
         Dn[i]=EMPTY_VALUE;
     }

   return(rates_total);
  }

double SMA(double &array[],int per,int bar,int mult=1)
  {
   double Sum=0;
   for(int i=0;i<per;i++) Sum+=array[bar+i*mult];
   return(Sum/per);
  }

double EMA(double price,double prev,int per,int bar)
  {
   double ema;
   if(bar>=g_rates_total-2)
      ema=price;
   else
      ema=prev+2.0/(1+per)*(price-prev);
   return(ema);
  }

double Wilder(double price,double prev,int per,int bar)
  {
   double wilder;
   if(bar>=g_rates_total-2)
      wilder=price;
   else
      wilder=prev+(price-prev)/per;
   return(wilder);
  }

double LWMA(double &array[],int per,int bar,int mult=1)
  {
   double Sum=0,Weight=0;
   for(int i=0;i<per;i++)
     {
      Weight+=(per-i);
      Sum+=array[bar+i*mult]*(per-i);
     }
   return(Weight>0?Sum/Weight:0);
  }

double SineWMA(double &array[],int per,int bar,int mult=1)
  {
   const double pi=3.1415926535;
   double Sum=0,Weight=0;
   for(int i=0;i<per;i++)
     {
      double w=MathSin(pi*(i+1)/(per+1));
      Weight+=w;
      Sum+=array[bar+i*mult]*w;
     }
   return(Weight>0?Sum/Weight:0);
  }

double TriMA(double &array[],int per,int bar,int mult=1)
  {
   int len=MathCeil((per+1)*0.5);
   double sum=0;
   for(int i=0;i<len;i++)
      sum+=SMA(array,len,bar+i*mult,mult);
   return(sum/len);
  }

double LSMA(double &array[],int per,int bar,int mult=1)
  {
   double Sum=0;
   for(int i=per;i>=1;i--) Sum+=(i-(per+1)/3.0)*array[bar+(per-i)*mult];
   return(Sum*6/(per*(per+1)));
  }

double SMMA(double &array[],double prev,int per,int bar,int mult=1)
  {
   double smma;
   if(bar==g_rates_total-per)
      smma=SMA(array,per,bar,mult);
   else if(bar<g_rates_total-per)
     {
      double Sum=0;
      for(int i=0;i<per;i++) Sum+=array[bar+(i+1)*mult];
      smma=(Sum-prev+array[bar])/per;
     }
   return(smma);
  }

double HMA(double &array[],int per,int bar,int mult=1)
  {
   double hma;
   int len=MathSqrt(per);
   static double tmp1[];
   ArrayResize(tmp1,len);
   if(bar==g_rates_total-per)
      hma=array[bar];
   else if(bar<g_rates_total-per)
     {
      for(int i=0;i<len;i++)
         tmp1[i]=2*LWMA(array,per/2,bar+i*mult,mult)-LWMA(array,per,bar+i*mult,mult);
      hma=LWMA(tmp1,len,0);
     }
   return(hma);
  }

double ZeroLagEMA(double &price[],double prev,int per,int bar,int mult=1)
  {
   double alfa=2.0/(1+per);
   int lag=0.5*(per-1);
   double zema;
   if(bar>=g_rates_total-lag)
      zema=price[bar];
   else
      zema=alfa*(2*price[bar]-price[bar+lag*mult])+(1-alfa)*prev;
   return(zema);
  }

double ITrend(double &price[],double &array[],int per,int bar,int mult=1)
  {
   double alfa=2.0/(per+1);
   double it;
   if(bar<g_rates_total-7)
      it=(alfa-0.25*alfa*alfa)*price[bar]+0.5*alfa*alfa*price[bar+1*mult]-(alfa-0.75*alfa*alfa)*price[bar+2*mult]
         +2*(1-alfa)*array[bar+1*mult]-(1-alfa)*(1-alfa)*array[bar+2*mult];
   else
      it=(price[bar]+2*price[bar+1*mult]+price[bar+2*mult])/4;
   return(it);
  }

double Median(double &price[],int per,int bar,int mult=1)
  {
   double arr[];
   ArrayResize(arr,per);
   for(int i=0;i<per;i++) arr[i]=price[bar+i*mult];
   ArraySort(arr);
   int num=MathRound((per-1)/2);
   if(MathMod(per,2)>0)
      return(arr[num]);
   else
      return(0.5*(arr[num]+arr[num+1]));
  }

double GeoMean(double &price[],int per,int bar,int mult=1)
  {
   double gmean=1.0;
   if(bar<g_rates_total-per)
     {
      gmean=MathPow(price[bar],1.0/per);
      for(int i=1;i<per;i++) gmean*=MathPow(price[bar+i*mult],1.0/per);
     }
   return(gmean);
  }

double REMA(double price,double &array[],int per,double lambda,int bar,int mult=1)
  {
   double alpha=2.0/(per+1);
   double rema;
   if(bar>=g_rates_total-3)
      rema=price;
   else
      rema=(array[bar+1*mult]*(1+2*lambda)+alpha*(price-array[bar+1*mult])-lambda*array[bar+2*mult])/(1+lambda);
   return(rema);
  }

double ILRS(double &price[],int per,int bar,int mult=1)
  {
   double sum=per*(per-1)*0.5;
   double sum2=(per-1)*per*(2*per-1)/6.0;
   double sum1=0,sumy=0;
   for(int i=0;i<per;i++)
     {
      sum1+=i*price[bar+i*mult];
      sumy+=price[bar+i*mult];
     }
   double num1=per*sum1-sum*sumy;
   double num2=sum*sum-per*sum2;
   double slope=(num2!=0?num1/num2:0);
   return(slope+SMA(price,per,bar,mult));
  }

double IE2(double &price[],int per,int bar,int mult=1)
  {
   return(0.5*(ILRS(price,per,bar,mult)+LSMA(price,per,bar,mult)));
  }

double TriMA_gen(double &array[],int per,int bar,int mult=1)
  {
   int len1=MathFloor((per+1)*0.5);
   int len2=MathCeil((per+1)*0.5);
   double sum=0;
   for(int i=0;i<len2;i++) sum+=SMA(array,len1,bar+i*mult,mult);
   return(sum/len2);
  }
  
 //Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=159876#p159876

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+