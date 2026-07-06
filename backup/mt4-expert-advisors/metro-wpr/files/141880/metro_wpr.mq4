// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=71169
// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71169


//+------------------------------------------------------------------------+
//|                                    Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                 http://fxcodebase.com  |
//+------------------------------------------------------------------------+
//|                                      Support our efforts by donating   | 
//|                                         Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------+
//|                                           Developed by : Mario Jemic   |                    
//|                                               mario.jemic@gmail.com    |
//|                                https://AppliedMachineLearning.systems  |
//|                                     Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------+

//+------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |  
//|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
//|Binance MEMO (BEP2 only)   : 107152697                                  |   
//|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |  
//+------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

// based on TrendLaboratory Ltd.  igorad2004@list.ru
#property indicator_separate_window
#property indicator_buffers 3 
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkViolet
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_label1  "WPR"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
#property indicator_label2  "StepWPR fast"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
#property indicator_label3  "StepWPR slow"
#property indicator_level1  70
#property indicator_level2  50
#property indicator_level3  30
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT

input uint PeriodWPR=7;                               // ������ ����������
input int StepSizeFast=5;                             // ������� ���
input int StepSizeSlow=15;                            // ��������� ���
input int Shift=0;                                    // ����� ���������� �� ����������� � �����
double Line1Buffer[];
double Line2Buffer[];
double Line3Buffer[];
int WPR_Handle;
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
{
   min_rates_total=int(PeriodWPR);
   SetIndexBuffer(0,Line1Buffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(Line1Buffer,true);

   SetIndexBuffer(1,Line2Buffer,INDICATOR_DATA);
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(Line2Buffer,true);

   SetIndexBuffer(2,Line3Buffer,INDICATOR_DATA);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(Line3Buffer,true);

   string shortname;
   StringConcatenate(shortname,"METRO_WPR(",PeriodWPR,", ",StepSizeFast,", ",StepSizeSlow,", ",Shift,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // ���������� ������� � ����� �� ������� ����
                const int prev_calculated,// ���������� ������� � ����� �� ���������� ����
                const datetime &time[],
                const double &open[],
                const double& high[],     // ������� ������ ���������� ���� ��� ������� ����������
                const double& low[],      // ������� ������ ��������� ����  ��� ������� ����������
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int limit,to_copy,bar,ftrend,strend;
   double fmin0,fmax0,smin0,smax0,WPR0;
   static double fmax1,fmin1,smin1,smax1;
   static int ftrend_,strend_;
   if(prev_calculated>rates_total || prev_calculated<=0) // �������� �� ������ ����� ������� ����������
   {
      limit=rates_total-1; // ��������� ����� ��� ������� ���� �����
      fmin1=+999999;
      fmax1=-999999;
      smin1=+999999;
      smax1=-999999;
      ftrend_=0;
      strend_=0;
   }
   else 
      limit=rates_total-prev_calculated; // ��������� ����� ��� ������� ����� �����
   to_copy=limit+1;
   ftrend = ftrend_;
   strend = strend_;
//---- �������� ���� ������� ����������
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
   {
      double WPR = iWPR(NULL, 0, PeriodWPR, bar);
      if(rates_total!=prev_calculated && bar==0)
      {
         ftrend_=ftrend;
         strend_=strend;
      }
      WPR0 = WPR + 100;
      fmax0=WPR0+2*StepSizeFast;
      fmin0=WPR0-2*StepSizeFast;
      if(WPR0>fmax1)  ftrend=+1;
      if(WPR0<fmin1)  ftrend=-1;
      if(ftrend>0 && fmin0<fmin1) fmin0=fmin1;
      if(ftrend<0 && fmax0>fmax1) fmax0=fmax1;
      smax0=WPR0+2*StepSizeSlow;
      smin0=WPR0-2*StepSizeSlow;
      if(WPR0>smax1)  strend=+1;
      if(WPR0<smin1)  strend=-1;
      if(strend>0 && smin0<smin1) smin0=smin1;
      if(strend<0 && smax0>smax1) smax0=smax1;
      Line1Buffer[bar]=WPR0;
      if(ftrend>0) Line2Buffer[bar]=fmin0+StepSizeFast;
      if(ftrend<0) Line2Buffer[bar]=fmax0-StepSizeFast;
      if(strend>0) Line3Buffer[bar]=smin0+StepSizeSlow;
      if(strend<0) Line3Buffer[bar]=smax0-StepSizeSlow;
      if(bar>0)
      {
         fmin1=fmin0;
         fmax1=fmax0;
         smin1=smin0;
         smax1=smax0;
      }
   }
   return(rates_total);
}
