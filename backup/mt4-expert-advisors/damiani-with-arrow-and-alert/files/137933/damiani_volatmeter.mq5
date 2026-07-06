
//---- The number of the indicator version
#property version   "1.00"
//---- The indicator is drawn in a separate window
#property indicator_separate_window 
//---- The number of indicator buffers is 3
#property indicator_buffers 3 
//---- 1 graphical construction is used
#property indicator_plots   1

//+-----------------------------------+
//|  Parameters of indicator 1        |
//+-----------------------------------+
//---- The indicator is drawn as a colored cloud
#property indicator_type1   DRAW_FILLING
//---- The following colors are used
#property indicator_color1  clrThistle,clrOrange
//---- The label of the indicator
#property indicator_label1  "Lower Damiani_volatmeter;Upper Damiani_volatmeter"

//+-----------------------------------+
//|  Declaring constants              |
//+-----------------------------------+
#define RESET  0 // A constant for returning an indicator recalculation command to the terminal
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input int    Viscosity=7;
input int    Sedimentation=50;
input double Threshold_level=1.1;
input bool   lag_supressor=true;
//+-----------------------------------+

//---- Declaring integer variables of data calculation start
int  min_rates_total;
//---- Declaring dynamic arrays that will be further 
// used as indicator buffers
double UpBuffer[],DnBuffer[],ThBuffer[],ClBuffer[];

double lag_s_K;
//---- Declaring integer variables for the indicator handles
int ATR1_Handle,ATR2_Handle,Std1_Handle,Std2_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(Viscosity,Sedimentation)+4);
   lag_s_K=0.5;

//---- Getting the handle of the ATR indicator
   ATR1_Handle=iATR(NULL,0,Viscosity);
   if(ATR1_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the ATR indicator");

//---- Getting the handle of the ATR indicator
   ATR2_Handle=iATR(NULL,0,Sedimentation);
   if(ATR2_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the ATR indicator");

//---- Getting the handle of the StdDev indicator
   Std1_Handle=iStdDev(NULL,0,Viscosity,0,MODE_LWMA,PRICE_TYPICAL);
   if(Std1_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the StdDev indicator");

//---- Getting the handle of the StdDev indicator
   Std2_Handle=iStdDev(NULL,0,Sedimentation,0,MODE_LWMA,PRICE_TYPICAL);
   if(Std2_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the StdDev indicator");
   
//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpBuffer,true);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnBuffer,true);

//---- Set the dynamic array as as a buffer for storing data
   SetIndexBuffer(2,ClBuffer,INDICATOR_CALCULATIONS);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ClBuffer,true);

//---- Performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Damiani_volatmeter");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- Checking if the number of bars is enough for the calculation
   if(BarsCalculated(ATR1_Handle)<rates_total
      || BarsCalculated(ATR2_Handle)<rates_total
      || BarsCalculated(Std1_Handle)<rates_total
      || BarsCalculated(Std2_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- Declaring floating point variables  
   double ATR1[],ATR2[],STD1[],STD2[];
   double vol;
//---- Declaration of integer variables
   int to_copy,limit;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated;  // starting index for the calculation of the new bars only

   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(ATR1_Handle,0,0,to_copy,ATR1)<=0) return(RESET);
   if(CopyBuffer(ATR2_Handle,0,0,to_copy,ATR2)<=0) return(RESET);
   if(CopyBuffer(Std1_Handle,0,0,to_copy,STD1)<=0) return(RESET);
   if(CopyBuffer(Std2_Handle,0,0,to_copy,STD2)<=0) return(RESET);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(ATR1,true);
   ArraySetAsSeries(ATR2,true);
   ArraySetAsSeries(STD1,true);
   ArraySetAsSeries(STD2,true);

//---- main cycle of calculation of the indicator
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double sa=ATR1[bar];
      double s1=ClBuffer[bar+1];
      double s3=ClBuffer[bar+3];
      double atr=NormalizeDouble(sa,_Digits);

      if(lag_supressor) vol=sa/ATR2[bar]+lag_s_K*(s1-s3);
      else vol=sa/ATR2[bar];
      double anti_thres=STD1[bar];
      anti_thres/=STD2[bar];
      double t=Threshold_level;
      t-=anti_thres;

      if(vol>t)
        {
         DnBuffer[bar]=vol;
         IndicatorSetString(INDICATOR_SHORTNAME,
                            "DAMIANI Signal/Noise: TRADE  /  ATR= "+DoubleToString(atr,_Digits)+"    values:");
        }
      else
        {
         DnBuffer[bar]=vol;
         IndicatorSetString(INDICATOR_SHORTNAME,
                            "DAMIANI Signal/Noise: DO NOT trade  /  ATR= "+DoubleToString(atr,_Digits)+"    values:");
        }

      ClBuffer[bar]=vol;
      UpBuffer[bar]=t;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
