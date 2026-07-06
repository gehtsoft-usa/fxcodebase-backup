// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71764

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Output
#property indicator_label1  "Output"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

input int      n=3;
input ENUM_APPLIED_PRICE  price=PRICE_CLOSE;

double         OutputBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
SetIndexBuffer(0,OutputBuffer,INDICATOR_DATA);
 
//---
return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   int limit;
   if(prev_calculated==0)
     {
      limit=rates_total-n;
     }
   else
     {
      limit=prev_calculated+1;
     }
   for(int i=limit; i>=0; i--)
     {
      double v=0, // speed (point / minute)
             d=0; // distance (point)
      int    t=GetMinute(); // time (minute)
      double sumv=0; //(x1+, ..., +xn) for A = 1 / n (x1+, ..., +xn)
      
		for(int j=i+n-1; j>=i; j--)
        {
         switch(price)
           {
            case PRICE_CLOSE:
              {
               d=MathAbs(close[j]-close[j+1])/_Point;
               v=d/t;
               sumv+=v;
               break;
              }
            case PRICE_HIGH:
              {
               d=MathAbs(high[j]-high[j+1])/_Point;
               v=d/t;
               sumv+=v;
               break;
              }
            case PRICE_LOW:
              {
               d=MathAbs(low[j]-low[j+1])/_Point;
               v=d/t;
               sumv+=v;
               break;
              }
            case PRICE_MEDIAN:
              {
               d=MathAbs((high[j]+low[j])/2-(high[j+1]+low[j+1])/2)/_Point;
               v=d/t;
               sumv+=v;
               break;
              }
            case PRICE_OPEN:
              {
               d=MathAbs(open[j]-open[j+1])/_Point;
               v=d/t;
               sumv+=v;
               break;
              }
            case PRICE_TYPICAL:
              {
               d=MathAbs((high[j]+low[j]+close[j])/3-(high[j+1]+low[j+1]+close[j+1])/3)/_Point;
               v=d/t;
               sumv+=v;
               break;
              }
            case PRICE_WEIGHTED:
              {
               d=MathAbs((high[j]+low[j]+close[j]+close[j])/4-(high[j+1]+low[j+1]+close[j+1]+close[j+1])/4)/_Point;
               v=d/t;
               sumv+=v;
               break;
              }
           }
        }
      // A = 1 / n (x1+, ..., +xn)
      double A=1.0/n*sumv;
      // Output = point / minute
      OutputBuffer[i]=A;
     }
	//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

int GetMinute()
  {
   switch(Period())
     {
      case PERIOD_M1: return(1);
      case PERIOD_M2: return(2);
      case PERIOD_M3: return(3);
      case PERIOD_M4: return(4);
      case PERIOD_M5: return(5);
      case PERIOD_M6: return(6);
      case PERIOD_M10: return(10);
      case PERIOD_M12: return(12);
      case PERIOD_M15: return(15);
      case PERIOD_M20: return(20);
      case PERIOD_M30: return(30);
      case PERIOD_H1: return(60);
      case PERIOD_H2: return(120);
      case PERIOD_H3: return(180);
      case PERIOD_H4: return(240);
      case PERIOD_H6: return(360);
      case PERIOD_H8: return(480);
      case PERIOD_H12: return(720);
      case PERIOD_D1: return(1440);
      case PERIOD_W1: return(10080);
      case PERIOD_MN1: return(43200);
     }
   // by default it will return 1 minute
   return(1);
  }

