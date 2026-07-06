// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65696

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                    Paypal: https://goo.gl/9Rj74e |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+


#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_chart_window
#property indicator_buffers 2

extern double Step = 0.02;
extern double Max = 0.2;
extern double Level1 = 1;
extern double Level2 = 1.5;
extern double Level3 = 2;
extern double Level4 = 0;
extern color StartLineColor = clrBlue;
extern int width1 = 1;
extern color LabelColor = clrGray;
extern int FontSize = 10;
extern color StopLineColor = clrRed;
extern int width2 = 1;
extern color TargetLineColor1 = clrGreen;
extern int width3 = 1;
extern color TargetLineColor2 = clrGreen;
extern int width4 = 1;
extern color TargetLineColor3 = clrGreen;
extern int width5 = 1;

extern color TargetLineColor4 = clrGreen;
extern int width6 = 1;

extern bool       Sound_Alert                   = true;
double Pp;
double position[];
double SAR[];

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    IndicatorName = GenerateIndicatorName("SAR Price Targets");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
    if (Point() == 0.0001 || Point() == 0.00001) Pp = 0.0001;
    if (Point() == 0.01 || Point() == 0.001) Pp = 0.01;
    
    SetIndexStyle(0,DRAW_NONE);
    SetIndexBuffer(0,position);
    SetIndexStyle(1,DRAW_NONE);
    SetIndexBuffer(1,SAR);

    return(INIT_SUCCEEDED);
}

int FindLast(const int period)
{
    int X=0;
    for(int i = 1; i <= Bars; ++i)
    {
        if (position[i] != position[i+1])
        {
            X=i;
			break;
        }
    }

    return X;
}

void DrawLabel(const double rate, const datetime date, const string text, const int id, const color clr, const int width)
{
    ObjectCreate(ChartID(), IndicatorObjPrefix + "Line" + IntegerToString(id), OBJ_TREND, 0, date, rate, Time[0], rate);
    ObjectSetInteger(ChartID(), IndicatorObjPrefix + "Line" + IntegerToString(id), OBJPROP_COLOR, clr);
    ObjectSetInteger(ChartID(), IndicatorObjPrefix + "Line" + IntegerToString(id), OBJPROP_WIDTH, width);

    ObjectCreate(ChartID(), IndicatorObjPrefix + "Label" + IntegerToString(id), OBJ_TEXT, 0, date, rate);
    ObjectSetText(IndicatorObjPrefix + "Label" + IntegerToString(id), text, FontSize, "Arial", LabelColor);
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
    int precision = 5;
	int i;
	
    for (i = Bars - 2; i >= 0; i--)
    {
        SAR[i] = iSAR(_Symbol, _Period, Step, Max, i);
        if (SAR[i] > close[i])
        {
            position[i] = -1;
        }
        else
        {
            position[i] = 1;
        }
        if (position[i] == 1 && position[i + 1] != 1)
        {
            ArrowBuyCreate("B" + TimeToString(time[i], TIME_DATE|TIME_MINUTES), time[i], SAR[i]);
        }
        else if (position[i] == -1 && position[i + 1] != -1)
        {
            ArrowSellCreate("S" + TimeToString(time[i], TIME_DATE|TIME_MINUTES), time[i], SAR[i]);
        }
    }
	
	i=1;
	int p = FindLast(i);
        double Delta;
        if (p!=0)
        {
            if (position[p] == 1)
            {
                Delta=MathAbs(SAR[p] - High[p]);
                DrawLabel(High[p], Time[i]
                    , "Entry :" + DoubleToString(High[p], precision)
                    , 1, StartLineColor, width1);
                DrawLabel(SAR[p], Time[i]
                    , "Stop : " + DoubleToString(SAR[p], precision) + " (" + DoubleToString(MathAbs(SAR[p] - Low[p]) / Pp, 1) + ")"
                    , 2, StopLineColor, width2);
                DrawLabel(High[p]+Delta*Level1, Time[i]
                    , "1. Target : " + DoubleToString(High[p]+Delta*Level1, precision) + " (" + DoubleToString(( Delta * Level1) / Pp, 1) + ")"
                    , 3, TargetLineColor1, width3);
                DrawLabel(High[p]+Delta*Level2, Time[i]
                    , "2. Target : " + DoubleToString(High[p]+Delta*Level2, precision) + " (" + DoubleToString(( Delta * Level2 ) / Pp, 1) + ")"
                    , 4, TargetLineColor2, width4);
                DrawLabel(High[p]+Delta*Level3, Time[i]
                    , "3. Target : " + DoubleToString(High[p]+Delta*Level3, precision) + " (" +  DoubleToString(( Delta * Level3) / Pp, 1) + ")"
                    , 5, TargetLineColor3, width5);
				
                if(Level4!=0)  
                {				
				DrawLabel(High[p]+Level4*Pp, Time[i]
                    , "Trigger : " + DoubleToString(High[p]+Level4*Pp, precision) + " (" +  DoubleToString((Level4 )  , 1) + ")"
                    , 6, TargetLineColor4, width6);	
				}	
            }
            else
            {
                Delta=MathAbs(SAR[p]- Low[p]);
                DrawLabel(Low[p], Time[i]
                    , "Entry : " + DoubleToString(Low[p], precision)
                    , 1, StartLineColor, width1);
                DrawLabel(SAR[p], Time[i]
                    , "Stop : " + DoubleToString(SAR[p], precision) + " (" + DoubleToString(MathAbs(SAR[p] - Low[p]) / Pp, 1) + ")"
                    , 2, StopLineColor, width2);
                DrawLabel(Low[p]-Delta*Level1, Time[i]
                    , "1. Target : " + DoubleToString(Low[p]-Delta*Level1, precision) + " (" + DoubleToString(( Delta * Level1) / Pp, 1) + ")"
                    , 3, TargetLineColor1, width3);
                DrawLabel(Low[p]-Delta*Level2, Time[i]
                    , "2. Target : " + DoubleToString(Low[p]-Delta*Level2, precision) + " (" + DoubleToString(( Delta * Level2 ) / Pp, 1) + ")"
                    , 4, TargetLineColor2, width4);
                DrawLabel(Low[p]-Delta*Level3, Time[i]
                    , "3. Target : " + DoubleToString(Low[p]-Delta*Level3, precision) + " (" + DoubleToString(( Delta * Level3) / Pp, 1) + ")"
                    , 5, TargetLineColor3, width5);
					
				 if(Level4!=0)  
                {		
				DrawLabel(Low[p]-Level4*Pp, Time[i]
                    , "Trigger : " + DoubleToString(Low[p]-Level4*Pp , precision) + " (" + DoubleToString(( Level4 ) , 1) + ")"
                    , 6, TargetLineColor4, width6);	
				}	
            }
        }
        if (position[i] == 1 && position[i+1] != 1)
        {
            doAlert("Open Long");
        }
        else if (position[i] == -1 && position[i+1] != -1)
        {
            doAlert("Open Short");
        }
	
    //--- return value of prev_calculated for next call
    return(rates_total);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrowSellCreate(string name, datetime time, double price)
  {
   ResetLastError();
   
   if(ObjectCreate(0,IndicatorObjPrefix + name,OBJ_ARROW_SELL,0,time,price))
    {
     ObjectSetInteger(0,IndicatorObjPrefix + name,OBJPROP_COLOR,clrTomato);
     ObjectSetInteger(0,IndicatorObjPrefix + name,OBJPROP_STYLE,STYLE_SOLID);
     ObjectSetInteger(0,IndicatorObjPrefix + name,OBJPROP_WIDTH,1);
     ObjectSetInteger(0,IndicatorObjPrefix + name,OBJPROP_BACK,true);
     ObjectSetInteger(0,IndicatorObjPrefix + name,OBJPROP_SELECTABLE,false);
     ObjectSetInteger(0,IndicatorObjPrefix + name,OBJPROP_HIDDEN,true);
     ObjectSetInteger(0,IndicatorObjPrefix + name,OBJPROP_ZORDER,0);
    }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrowBuyCreate(string name, datetime time, double price)
  {
   ResetLastError();
   
   if(ObjectCreate(0,IndicatorObjPrefix + name,OBJ_ARROW_BUY,0,time,price))
    {
     ObjectSetInteger(0,IndicatorObjPrefix + name,OBJPROP_COLOR,clrDodgerBlue);
     ObjectSetInteger(0,IndicatorObjPrefix + name,OBJPROP_STYLE,STYLE_SOLID);
     ObjectSetInteger(0,IndicatorObjPrefix + name,OBJPROP_WIDTH,1);
     ObjectSetInteger(0,IndicatorObjPrefix + name,OBJPROP_BACK,true);
     ObjectSetInteger(0,IndicatorObjPrefix + name,OBJPROP_SELECTABLE,false);
     ObjectSetInteger(0,IndicatorObjPrefix + name,OBJPROP_HIDDEN,true);
     ObjectSetInteger(0,IndicatorObjPrefix + name,OBJPROP_ZORDER,0);
    }
  }
//+-----------------------------------------------------------------+
void doAlert(string message)
{
    if (!Sound_Alert)
        return;

    static datetime previousTime;
    if (previousTime != Time[0])
    {
        previousTime = Time[0];
        Alert(message);
        PlaySound("alert2.wav");
    }
}
