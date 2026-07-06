// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68850

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 2
//--- indicator buffers
double bp[];
double sp[];
double tmp_bp[];
double tmp_sp[];
double nsp[];
double nbp[];
double diff[], nv[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   SetIndexBuffer(0, bp); 
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2, clrMediumSeaGreen);
   SetIndexBuffer(1, sp); 
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 2, clrCrimson);

   IndicatorBuffers(8);
   
   SetIndexBuffer(2, tmp_bp);
   SetIndexBuffer(3, nbp);
   SetIndexBuffer(4, tmp_sp);
   SetIndexBuffer(5, nsp);
   SetIndexBuffer(6, diff);
   SetIndexBuffer(7, nv);

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
//---
//sp = H-C;
//bp = C-L;
//bpavg = EMA(bp,80);
//spavg = EMA(sp,80);
//nbp = bp/bpavg;
//nsp = sp/spavg;
//diff = nbp-nsp;
//diffcolor = IIf(diff>0,colorGreen,colorOrange);
//Varg = EMA(V,80);
//nv = V/Varg;
//nbfraw = nbp * nv;
//nsfraw = nsp * nv;
//nbf = EMA(nbp * nv,20);
//nsf = EMA(nsp * nv,20);
//Plot(nbf,"Buying Pressure",colorTurquoise,1|styleThick);
//Plot(nsf,"selling Pressure",colorYellow,1|styleThick);
//diff = nbf-nsf;
//diffcolor = IIf(diff>0,colorGreen,colorRed);
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   for (int i = limit; i >= 0; --i)
   {
      tmp_sp[i] = high[i] - close[i];
      tmp_bp[i] = close[i] - low[i];
      nsp[i] = tmp_sp[i] / iMAOnArray(tmp_sp, 0, 80, 0, MODE_EMA, i);
      nbp[i] = tmp_bp[i] / iMAOnArray(tmp_bp, 0, 80, 0, MODE_EMA, i);
      nv[i] = NormalizedVolume(i, 80);
      double nsfraw = nsp[i] * nv[i];
      double nbfraw = nbp[i] * nv[i];
      double nsf = iMAOnArray(nsp, 0, 20, 0, MODE_EMA, i);
      double nbf = iMAOnArray(nbp, 0, 20, 0, MODE_EMA, i);
      diff[i]   = nbf - nsf;
      if (diff[i] > 0)
         bp[i] = diff[i];
      if (diff[i] < 0)
         sp[i] = diff[i];
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
//---
}
//+------------------------------------------------------------------+
double NormalizedVolume(int i, int VolumePeriod)
{
    double nv = 1;
    for (int j = i; j <= (VolumePeriod); j++)
        nv = nv + Volume[j];
    nv = nv / VolumePeriod;
    return(Volume[i] / nv);
}
