// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69307

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                         https://AppliedMachineLearning.systems   |
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

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict
                          
//---- indicator settings
#property indicator_chart_window
#property  indicator_buffers 3 
#property  indicator_plots 3 
#property  indicator_color1 CLR_NONE
#property  indicator_color2 Maroon
#property  indicator_color3 Maroon
#property  indicator_width1 0
#property  indicator_width2 0
#property  indicator_width3 0
#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT

//---- input parameters
input int eintTimeframe = 0;
input int eintHalfLength = 56;
input double edblAtrMultiplier = 2.0;
input int eintAtrPeriod = 100;
input int eintBarsToProcess = 0;
input bool eblnAlerts = false;
input color gc_Mid   = CLR_NONE;
input color gc_Upper = White;
input color gc_Lower = White;

//---- indicator buffers
double gadblMid[];
double gadblUpper[];
double gadblLower[];

ENUM_TIMEFRAMES gintTF = PERIOD_CURRENT;
datetime gdtLastAlert = 0;
int gi_PipsDecimal;

string IndicatorName;
string IndicatorObjPrefix;
string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}
int atr;
int OnInit(void)
{
   IndicatorName = GenerateIndicatorName("TmaTrue 2.0 With Distances 6xx");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   if (eintTimeframe == 0)
      gintTF = Period();
   else
      gintTF = eintTimeframe;
   atr = iATR(_Symbol, gintTF, eintAtrPeriod);
   
   gdtLastAlert = 0;
   gi_PipsDecimal = Get_Pips_Decimal();

   SetIndexBuffer(0, gadblMid, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(0, PLOT_LABEL, "TMA Mid");

   SetIndexBuffer(1, gadblUpper, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(1, PLOT_LABEL, "TMA Upper");
   
   SetIndexBuffer(2, gadblLower, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(2, PLOT_LABEL, "TMA Lower");

   return INIT_SUCCEEDED;//INIT_FAILED
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   IndicatorRelease(atr);
}

int OnCalculate(const int rates_total,       // size of input time series
                const int prev_calculated,   // number of handled bars at the previous call
                const datetime& time[],      // Time array
                const double& open[],        // Open array
                const double& high[],        // High array
                const double& low[],         // Low array
                const double& close[],       // Close array
                const long& tick_volume[],   // Tick Volume array
                const long& volume[],        // Real Volume array
                const int& spread[]          // Spread array
)
{
   double dblTma,  dblRange;
   int intBarShift;
   for (int inx = prev_calculated; inx < rates_total; ++inx)
   {
      if ( gintTF == Period() ) 
      {
         double buffer[1];
         if (CopyBuffer(atr, 0, rates_total - 1 - inx + 10, 1, buffer) != 1)
         {
            continue;
         }
         dblRange = buffer[0];
         dblTma = calcTma( eintHalfLength, rates_total - 1 - inx );
      }
      else
      {
         intBarShift = iBarShift( Symbol(), gintTF, time[inx] );
         double buffer[1];
         if (CopyBuffer(atr, 0, intBarShift + 10, 1, buffer) != 1)
         {
            continue;
         }
         dblRange = buffer[0];
         dblTma = calcTmaMtf( gintTF, eintHalfLength, intBarShift, close[inx]);
      }
      gadblMid[inx] = dblTma;
      gadblUpper[inx] = dblTma + ( edblAtrMultiplier * dblRange );
      gadblLower[inx] = dblTma - ( edblAtrMultiplier * dblRange );
   }
   
   if ( eblnAlerts && gdtLastAlert < time[rates_total - 2] )
   {
      if ( ( close[rates_total - 2] > gadblUpper[rates_total - 2] ) && ( close[rates_total - 3] < gadblUpper[rates_total - 3] ) )
      {
         Alert( Symbol(), " - M", Period(), " - ", TimeToString( time[rates_total - 2], TIME_DATE|TIME_MINUTES ), " closed above upper TMA." );
         gdtLastAlert = time[rates_total - 2];
      }
      
      if ( ( close[rates_total - 2] < gadblLower[rates_total - 2] ) && ( close[rates_total - 3] > gadblLower[rates_total - 3] ) )
      {
         Alert( Symbol(), " - M", Period(), " - ", TimeToString( time[rates_total - 2], TIME_DATE|TIME_MINUTES ), " closed below lower TMA." );
         gdtLastAlert = time[rates_total - 2];
      }
   }
   
   // Calculate the distances between bid & bands
   double ld_Dist_Pts, ld_Dist_Pips;
   
   double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   // Distance to mid
   ld_Dist_Pts = MathAbs(Bid - gadblMid[rates_total - 1]);
   ld_Dist_Pips = Convert_2_Pips(ld_Dist_Pts);
   ObjectCreate(0, IndicatorObjPrefix + "!Mid",OBJ_TEXT,0,0,0);
   ObjectSetInteger(0, IndicatorObjPrefix + "!Mid",OBJPROP_TIME,time[rates_total - 1]+(3*Period()*60));
   ObjectSetDouble(0, IndicatorObjPrefix + "!Mid",OBJPROP_PRICE,gadblMid[rates_total - 1]);
   
   // Distance to upper
   ld_Dist_Pts = MathAbs(Bid - gadblUpper[rates_total - 1]);
   ld_Dist_Pips = Convert_2_Pips(ld_Dist_Pts);
   ObjectCreate(0, IndicatorObjPrefix + "!Upp",OBJ_TEXT,0,0,0);
   ObjectSetInteger(0, IndicatorObjPrefix + "!Upp",OBJPROP_TIME,time[rates_total - 1]+(3*Period()*60));
   ObjectSetDouble(0, IndicatorObjPrefix + "!Upp",OBJPROP_PRICE,gadblUpper[rates_total - 1]);
   ObjectSetText(IndicatorObjPrefix + "!Upp",DoubleToString(ld_Dist_Pips,gi_PipsDecimal),6,"Arial",gc_Upper);
   
   // Distance to lower
   ld_Dist_Pts = MathAbs(Bid - gadblLower[rates_total - 1]);
   ld_Dist_Pips = Convert_2_Pips(ld_Dist_Pts);
   ObjectCreate(0, IndicatorObjPrefix + "!Low",OBJ_TEXT,0,0,0);
   ObjectSetInteger(0, IndicatorObjPrefix + "!Low",OBJPROP_TIME,time[rates_total - 1]+(3*Period()*60));
   ObjectSetDouble(0, IndicatorObjPrefix + "!Low",OBJPROP_PRICE,gadblLower[rates_total - 1]);
   ObjectSetText(IndicatorObjPrefix + "!Low",DoubleToString(ld_Dist_Pips,gi_PipsDecimal),6,"Arial",gc_Lower);
   
   // Display the total range of the bands
   ld_Dist_Pts = MathAbs(gadblUpper[rates_total - 1] - gadblLower[rates_total - 1]);
   ld_Dist_Pips = Convert_2_Pips(ld_Dist_Pts);
   Object_Create(IndicatorObjPrefix + "!Range",4,4,"TMA Range: "+DoubleToString(ld_Dist_Pips,gi_PipsDecimal),12,"Curlz MT",gc_Lower);

   return rates_total;
}

void ObjectSetText(string id, string text, int fontSize, string font, color clr)
{
   ObjectSetString(0, id, OBJPROP_TEXT, text);
   ObjectSetString(0, id, OBJPROP_FONT, font);
   ObjectSetInteger(0, id, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
}

//+------------------------------------------------------------------+
//| calcTma()                                                        |
//+------------------------------------------------------------------+
double calcTma( int intHalfLength, int intShift )
{
   double dblResult, dblSum, dblSumW;
   int inx, jnx;
   
   dblSumW = intHalfLength + 1;
   dblSum = dblSumW * iClose(_Symbol, _Period, intShift);
   jnx = intHalfLength;
   
   for ( inx = 1, jnx = intHalfLength; inx <= intHalfLength; inx++, jnx-- )
   {
      dblSumW += jnx;
      dblSum += ( jnx * iClose(_Symbol, _Period, intShift + inx));
   } 
   
   dblResult = dblSum / dblSumW;
   
   return( dblResult );
}

//+------------------------------------------------------------------+
//| calcTmaMtf()                                                     |
//+------------------------------------------------------------------+
double calcTmaMtf(ENUM_TIMEFRAMES intTF, int intHalfLength, int intUpperTfShift, double dblClose )
{
   double dblResult, dblSum, dblSumW;
   int inx, jnx;
   
   // This is the current bar
   dblSumW = intHalfLength + 1;
   dblSum = dblSumW * dblClose;
   jnx = intHalfLength;
   
   for ( inx = 1, jnx = intHalfLength; inx <= intHalfLength; inx++, jnx-- )
   {
      dblSumW += jnx;
      dblSum += ( jnx * iClose( Symbol(), intTF, intUpperTfShift+inx ) );  
   } 
   
   dblResult = dblSum / dblSumW;
   
   return( dblResult );
}
//+------------------------------------------------------------------+
//| create screen objects                                            |
//+------------------------------------------------------------------+
void Object_Create(string ps_name,int pi_x,int pi_y,string ps_text=" ",int pi_size=12,
                  string ps_font="Arial",color pc_colour=CLR_NONE)
{
   ObjectCreate(0, ps_name,OBJ_LABEL,0,0,0,0,0);
   ObjectSetInteger(0, ps_name,OBJPROP_CORNER,3);
   ObjectSetInteger(0, ps_name,OBJPROP_COLOR,pc_colour);
   ObjectSetInteger(0, ps_name,OBJPROP_XDISTANCE,pi_x);
   ObjectSetInteger(0, ps_name,OBJPROP_YDISTANCE,pi_y);
   
   ObjectSetText(ps_name,ps_text,pi_size,ps_font,pc_colour);
}
//+------------------------------------------------------------------+
//| convert to points                                                |
//+------------------------------------------------------------------+
double Convert_2_Pts(double pd_Pips)
{
   int pd_Points=pd_Pips;  // Default - no conversion
   
 	if (Digits() == 5 || (Digits() == 3 && StringFind(Symbol(), "JPY") != -1)) 
 	   pd_Points=pd_Pips*10;
 	   
 	if (Digits() == 6 || (Digits() == 4 && StringFind(Symbol(), "JPY") != -1)) 
 	   pd_Points=pd_Pips*100;
   return(pd_Points);
}
//+------------------------------------------------------------------+
//| convert to pips                                                  |
//+------------------------------------------------------------------+
double Convert_2_Pips(double pd_Points)
{
   double pd_Pips=pd_Points/Point();  // Default - no conversion
   
 	if (Digits() == 5 || (Digits() == 3 && StringFind(Symbol(), "JPY") != -1)) 
   {
 	   pd_Pips=pd_Points/Point()/10;
   }
 	   
 	if (Digits() == 6 || (Digits() == 4 && StringFind(Symbol(), "JPY") != -1)) 
   {
 	   pd_Pips=pd_Points/Point()/100;
   }
   return(pd_Pips);
}
//+------------------------------------------------------------------+
//| get the pips decimal places                                      |
//+------------------------------------------------------------------+
int Get_Pips_Decimal()
{
   int pi_PipsDecimal = 0;  // Default - no decimals
   
 	if (Digits() == 5 || (Digits() == 3 && StringFind(Symbol(), "JPY") != -1)) 
   {
 	   pi_PipsDecimal = 1;
   }
 	   
 	if (Digits() == 6 || (Digits() == 4 && StringFind(Symbol(), "JPY") != -1)) 
   {
 	   pi_PipsDecimal = 2;
   }
   return(pi_PipsDecimal);
}