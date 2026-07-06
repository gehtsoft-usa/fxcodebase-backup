// More information about this indicator can be found at:
// http://fxcodebase.com/ 

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
#property strict
#property indicator_chart_window
#property indicator_buffers 4

#property indicator_color1 clrSilver
#property indicator_width1 1
#property indicator_style1 STYLE_DOT
#property indicator_type1  DRAW_LINE
#property indicator_label1 "Moving average"

#property indicator_color2 clrLimeGreen
#property indicator_width2 3
#property indicator_style2 STYLE_SOLID
#property indicator_type2  DRAW_LINE
#property indicator_label2 "Gadis"

#property indicator_color3 clrRed
#property indicator_width3 3
#property indicator_style3 STYLE_SOLID
#property indicator_type3  DRAW_LINE
#property indicator_label3 "Slope down"

#property indicator_color4 clrRed
#property indicator_width4 3
#property indicator_style4 STYLE_SOLID
#property indicator_type4  DRAW_LINE
#property indicator_label4 "Slope down"

enum enCol
{
 int_average, //on average cross
 int_slope    //on slope change
};

input int inpPeriod = 3;                        //Period
input ENUM_APPLIED_PRICE inpPrice = PRICE_CLOSE; //Price
input ENUM_MA_METHOD inpMethod = MODE_SMA;       //Method
input enCol          inpColor  = int_average;    //Color change

double ma[],cma[],up[],dn[],trend[];    
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(5);
//--- indicator buffers mapping
      SetIndexBuffer(0,ma,INDICATOR_DATA);
      SetIndexBuffer(1,cma,INDICATOR_DATA);
      SetIndexBuffer(2,up,INDICATOR_DATA);
      SetIndexBuffer(3,dn,INDICATOR_DATA);
      SetIndexBuffer(4,trend,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Gadis SMA("+(string)inpPeriod+")");
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
   if (rates_total<inpPeriod) return(0);
   if (IsStopped()) return(0);
   int start = (prev_calculated==0) ? rates_total-inpPeriod-1 : rates_total-prev_calculated;
//---
   if (trend[start]==-1) iCleanPoint(start,rates_total,up,dn);
   for (int i=start; i>=1 && !IsStopped(); i--)
   {
       ma[i] = iMA(Symbol(),Period(),inpPeriod,0,inpMethod,inpPrice,i);
       
       double deviation = iStdDev(Symbol(),Period(),inpPeriod,0,inpMethod,inpPrice,i)/_Point;
       double error     = (cma[i+1]-ma[i])/_Point;
       
       double variance  = MathPow(deviation,2);
       double sqrerror  = MathPow(error,2);
       double gain      = (variance==0||sqrerror==0) ? 1 : sqrt(sqrerror/(variance+sqrerror));
       
   //---   
       static double tolerance = MathPow(10,-5);
       double err   = 1;
       double kPrev = 1;
       double k     = 1;
       double iSize = SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
       
   //Calculate gain factor
       while (err > tolerance)
         {
          k     = gain * kPrev * (2 - kPrev);
          err   = kPrev - k;
          kPrev = k;
         }
       
       cma[i]    = cma[i+1]+k*(ma[i]-cma[i+1]);
       switch(inpColor)
       {
        case int_slope: trend[i]  = cma[i]>cma[i+1] && MathAbs(cma[i]-cma[i+1])>iSize ? 1 : cma[i]<cma[i+1] && MathAbs(cma[i]-cma[i+1])>iSize ? -1 : trend[i+1]; break;
        default:        trend[i]  = cma[i]>cma[i+1] ? 1 : cma[i]<cma[i+1] ? -1 : trend[i+1];
       } 
       up[i]     = EMPTY_VALUE;
       dn[i]     = EMPTY_VALUE;
       if (trend[i]==-1) iPlotPoint(i,rates_total,up,dn,cma);   
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//
//
//
//

void iCleanPoint(int i, int bars, double& first[], double& second[])
{
   if (i>=bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}
void iPlotPoint(int i, int bars, double& first[], double& second[], double& from[])
{
   if (i>=bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE)
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}