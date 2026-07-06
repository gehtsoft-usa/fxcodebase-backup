// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66218

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

#property indicator_chart_window
#property indicator_buffers 0
#property strict

extern color LRclr = clrRed; // Round numbers Label Color
extern color Rclr = clrRed; // Round numbers Line Color
extern color LQclr = clrYellow; // Quarter points Label Color
extern color Qclr = clrYellow; // Quarter points Line Color
extern color LHclr = clrGreen; // Half points Label Color
extern color Hclr = clrGreen; // Half points Line Color
extern color LEclr = clrBlue; // Hesitation points Label Color
extern color Eclr = clrBlue; // Hesitation points Line Color
extern int Rwidth = 3; // Round numbers size
extern int Qwidth = 2; // Quarter points size
extern int Hwidth = 1; // Half points size
extern int Ewidth = 1; // Hesitation points size
extern double ps = 0; // Manual pip value (0 - Autocalculation)

double PS;

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


int init()
{
    IndicatorName = GenerateIndicatorName("Quarters Theory");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
    IndicatorDigits(Digits);

    PS = ps == 0.0 ? 1.0 / pow(10, Digits) : ps;

    return(0);
}

int deinit()
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    return(0);
}

bool IsStartOfQuater(const int index)
{
    MqlDateTime currentDate;
    TimeToStruct(Time[index], currentDate);
    MqlDateTime previousDate;
    TimeToStruct(Time[index + 1], previousDate);
    if (currentDate.mon == 1 && currentDate.day >= 1 && previousDate.mon != 1)
        return true;
    if (currentDate.mon == 4 && currentDate.day >= 1 && previousDate.mon != 4)
        return true;
    if (currentDate.mon == 7 && currentDate.day >= 1 && previousDate.mon != 7)
        return true;
    if (currentDate.mon == 10 && currentDate.day >= 1 && previousDate.mon != 10)
        return true;
    return false;
}

int start()
{
    if(Bars<=3) return(0);
    int ExtCountedBars=IndicatorCounted();
    if (ExtCountedBars<0) return(-1);
    int limit=Bars-2;
    if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;

    double Min = DBL_MAX;
    double Max = -DBL_MAX;
    datetime startDate = Time[0];
    int pos = limit;
    while (pos >= 0)
    {
        if (IsStartOfQuater(pos))
        {
            Min = DBL_MAX;
            Max = -DBL_MAX;
            startDate = Time[pos];
        }
        
        if (High[pos] > Max)
        {
            Max = High[pos];
        }
        if (Low[pos] < Min)
        {
            Min = Low[pos];
        }
        --pos;
    }
    double Rmin = floor(Min / (1000 * PS)) * PS * 1000;
    double Rmax = ceil(Max / (1000 * PS)) * PS * 1000;

    int line = 0;
    double Rcurr = Rmin;
    int step = 0;
    while (Rcurr <= Rmax)
    {
        if (step % 1000 == 0)
        {
            ObjectCreate(IndicatorObjPrefix + "QT_Line" + IntegerToString(line), OBJ_TREND, 0, startDate, Rcurr, Time[0], Rcurr);
            ObjectSetInteger(0, IndicatorObjPrefix + "QT_Line" + IntegerToString(line), OBJPROP_COLOR, Rclr);
            ObjectCreate(IndicatorObjPrefix + "QT_Lbl" + IntegerToString(line), OBJ_TEXT, 0, Time[0], Rcurr);
            ObjectSetText(IndicatorObjPrefix + "QT_Lbl" + IntegerToString(line++), DoubleToStr(Rcurr, 5), 12, "Arial", LRclr);
        }
        else if (step % 250 == 0)
        {
            ObjectCreate(IndicatorObjPrefix + "QT_Line" + IntegerToString(line), OBJ_TREND, 0, startDate, Rcurr, Time[0], Rcurr);
            ObjectSetInteger(0, IndicatorObjPrefix + "QT_Line" + IntegerToString(line), OBJPROP_COLOR, Qclr);
            ObjectCreate(IndicatorObjPrefix + "QT_Lbl" + IntegerToString(line), OBJ_TEXT, 0, Time[0], Rcurr);
            ObjectSetText(IndicatorObjPrefix + "QT_Lbl" + IntegerToString(line++), DoubleToStr(Rcurr, 5), 12, "Arial", LQclr);
        }
        else if (step % 125 == 0)
        {
            ObjectCreate(IndicatorObjPrefix + "QT_Line" + IntegerToString(line), OBJ_TREND, 0, startDate, Rcurr, Time[0], Rcurr);
            ObjectSetInteger(0, IndicatorObjPrefix + "QT_Line" + IntegerToString(line), OBJPROP_COLOR, Hclr);
            ObjectCreate(IndicatorObjPrefix + "QT_Lbl" + IntegerToString(line), OBJ_TEXT, 0, Time[0], Rcurr);
            ObjectSetText(IndicatorObjPrefix + "QT_Lbl" + IntegerToString(line++), DoubleToStr(Rcurr, 5), 12, "Arial", LHclr);

            ObjectCreate(IndicatorObjPrefix + "QT_Line" + IntegerToString(line), OBJ_TREND, 0, startDate, Rcurr - PS * 50, Time[0], Rcurr - PS * 50);
            ObjectSetInteger(0, IndicatorObjPrefix + "QT_Line" + IntegerToString(line), OBJPROP_COLOR, Eclr);
            ObjectCreate(IndicatorObjPrefix + "QT_Lbl" + IntegerToString(line), OBJ_TEXT, 0, Time[0],  Rcurr - PS * 50);
            ObjectSetText(IndicatorObjPrefix + "QT_Lbl" + IntegerToString(line++), DoubleToStr(Rcurr - PS * 50, 5), 12, "Arial", LEclr);
            
            ObjectCreate(IndicatorObjPrefix + "QT_Line" + IntegerToString(line), OBJ_TREND, 0, startDate, Rcurr + PS * 50, Time[0], Rcurr + PS * 50);
            ObjectSetInteger(0, IndicatorObjPrefix + "QT_Line" + IntegerToString(line), OBJPROP_COLOR, Eclr);
            ObjectCreate(IndicatorObjPrefix + "QT_Lbl" + IntegerToString(line), OBJ_TEXT, 0, Time[0], Rcurr + PS * 50);
            ObjectSetText(IndicatorObjPrefix + "QT_Lbl" + IntegerToString(line++), DoubleToStr(Rcurr + PS * 50, 5), 12, "Arial", LEclr);
        }
        Rcurr += PS * 125;
        step += 125;
    }
    return(0);
}
