// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                    Paypal: https://goo.gl/9Rj74e |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 13 * 8

#property indicator_color1  clrGreen
#property indicator_color2  clrLime
#property indicator_color3  clrLightCoral
#property indicator_color4  clrRed
#property indicator_color5  clrGray
#property indicator_color6  clrGray
#property indicator_color7  clrSilver
#property indicator_color8  clrSilver

#property indicator_color9  clrGreen
#property indicator_color10  clrLime
#property indicator_color11  clrLightCoral
#property indicator_color12  clrRed
#property indicator_color13  clrGray
#property indicator_color14  clrGray
#property indicator_color15  clrSilver
#property indicator_color16  clrSilver

#property indicator_color17  clrGreen
#property indicator_color18  clrLime
#property indicator_color19  clrLightCoral
#property indicator_color20  clrRed
#property indicator_color21  clrGray
#property indicator_color22  clrGray
#property indicator_color23  clrSilver
#property indicator_color24  clrSilver

#property indicator_color25  clrGreen
#property indicator_color26  clrLime
#property indicator_color27  clrLightCoral
#property indicator_color28  clrRed
#property indicator_color29  clrGray
#property indicator_color30  clrGray
#property indicator_color31  clrSilver
#property indicator_color32  clrSilver

#property indicator_color33  clrGreen
#property indicator_color34  clrLime
#property indicator_color35  clrLightCoral
#property indicator_color36  clrRed
#property indicator_color37  clrGray
#property indicator_color38  clrGray
#property indicator_color39  clrSilver
#property indicator_color40  clrSilver

#property indicator_color41  clrGreen
#property indicator_color42  clrLime
#property indicator_color43  clrLightCoral
#property indicator_color44  clrRed
#property indicator_color45  clrGray
#property indicator_color46  clrGray
#property indicator_color47  clrSilver
#property indicator_color48  clrSilver

#property indicator_color49  clrGreen
#property indicator_color50  clrLime
#property indicator_color51  clrLightCoral
#property indicator_color52  clrRed
#property indicator_color53  clrGray
#property indicator_color54  clrGray
#property indicator_color55  clrSilver
#property indicator_color56  clrSilver

#property indicator_color57  clrGreen
#property indicator_color58  clrLime
#property indicator_color59  clrLightCoral
#property indicator_color60  clrRed
#property indicator_color61  clrGray
#property indicator_color62  clrGray
#property indicator_color63  clrSilver
#property indicator_color64  clrSilver

#property indicator_color65  clrGreen
#property indicator_color66  clrLime
#property indicator_color67  clrLightCoral
#property indicator_color68  clrRed
#property indicator_color69  clrGray
#property indicator_color70  clrGray
#property indicator_color71  clrSilver
#property indicator_color72  clrSilver

#property indicator_color73  clrGreen
#property indicator_color74  clrLime
#property indicator_color75  clrLightCoral
#property indicator_color76  clrRed
#property indicator_color77  clrGray
#property indicator_color78  clrGray
#property indicator_color79  clrSilver
#property indicator_color80  clrSilver

#property indicator_color81  clrGreen
#property indicator_color82  clrLime
#property indicator_color83  clrLightCoral
#property indicator_color84  clrRed
#property indicator_color85  clrGray
#property indicator_color86  clrGray
#property indicator_color87  clrSilver
#property indicator_color88  clrSilver

#property indicator_color89  clrGreen
#property indicator_color90  clrLime
#property indicator_color91  clrLightCoral
#property indicator_color92  clrRed
#property indicator_color93  clrGray
#property indicator_color94  clrGray
#property indicator_color95  clrSilver
#property indicator_color96  clrSilver

#property indicator_color97  clrGreen
#property indicator_color98  clrLime
#property indicator_color99  clrLightCoral
#property indicator_color100  clrRed
#property indicator_color101  clrGray
#property indicator_color102  clrGray
#property indicator_color103  clrSilver
#property indicator_color104  clrSilver

#property indicator_minimum 0
#property indicator_maximum 8

extern int      level1  = 25;
extern int      Length1 = 5;
extern int      level2  = 25;
extern int      Length2 = 10;
extern int      level3  = 25;
extern int      Length3 = 15;
extern int      level4  = 25;
extern int      Length4 = 30;
extern int      level5  = 25;
extern int      Length5 = 35;
extern int      level6  = 25;
extern int      Length6 = 40;
extern int      level7  = 25;
extern int      Length7 = 45;
extern int      level8  = 25;
extern int      Length8 = 50;
extern int      level9  = 25;
extern int      Length9 = 100;
extern int      level10  = 25;
extern int      Length10 = 150;
extern int      level11  = 25;
extern int      Length11 = 200;
extern int      level12  = 25;
extern int      Length12 = 250;
extern int      level13  = 25;
extern int      Length13 = 300;
extern bool       Sound_Alert                   = true;
extern bool       Email_Alert                   = false;

string IndName;
class HeatMapValueCalculator
{
    int _period; string _symbol; double _value; int _length; int _level; int _last_signal;
public:
    double up_up[]; double up_dn[]; double dn_up[]; double dn_dn[]; double nt_up_up[]; double nt_up_dn[]; double nt_dn_up[]; double nt_dn_dn[];
    HeatMapValueCalculator(const int period, const string symbol, const double value, const int length, const int level) { _symbol = symbol; _period = period; _value = value; _length = length; _level = level; _last_signal = 0; }
    void UpdateValue(const int period)
    {
        up_up[period] = -1.0;
        up_dn[period] = -1.0;
        dn_up[period] = -1.0;
        dn_dn[period] = -1.0;
        nt_up_up[period] = -1.0;
        nt_up_dn[period] = -1.0;
        nt_dn_up[period] = -1.0;
        nt_dn_dn[period] = -1.0;
        switch (GetSide(period))
        {
            case 4:
                up_up[period] = _value;
                AlertSignal(1, period);
                break;
            case 3:
                up_dn[period] = _value;
                AlertSignal(1, period);
                break;
            case 2:
                nt_up_up[period] = _value;
                AlertSignal(0, period);
                break;
            case 1:
                nt_up_dn[period] = _value;
                AlertSignal(0, period);
                break;
            case -4:
                dn_up[period] = _value;
                AlertSignal(-1, period);
                break;
            case -3:
                dn_dn[period] = _value;
                AlertSignal(-1, period);
                break;
            case -2:
                nt_dn_up[period] = _value;
                AlertSignal(0, period);
                break; 
            case -1:
                nt_dn_dn[period] = _value;
                AlertSignal(0, period);
                break;
        }
    }

    void AlertSignal(const int direction, const int period)
    {
        if (_last_signal == direction)
        {
            return;
        }
        if (period == 0)
        {
            switch (direction)
            {
                case 1:
                    SendNotifications("DMI Up Trend");
                    break;
                case -1:
                    SendNotifications("DMI Down Trend");
                    break;
                case 0:
                    SendNotifications("DMI Neutral Trend");
                    break;
            }
        }
        _last_signal = direction;
    }

    string GetTimeframe()
    {
        switch (_period)
        {
            case PERIOD_M1:
                return "M1";
            case PERIOD_M5:
                return "M5";
            case PERIOD_D1:
                return "D1";
            case PERIOD_H1:
                return "H1";
            case PERIOD_H4:
                return "H4";
            case PERIOD_M15:
                return "M15";
            case PERIOD_M30:
                return "M30";
            case PERIOD_MN1:
                return "MN1";
            case PERIOD_W1:
                return "W1";
        }
        return "M1";
    }

    void SendNotifications(const string message)
    {
        string tf = GetTimeframe();
        string alert_Subject = "DMI on " + _symbol + "/" + tf + " " + message;
        string alert_Body = "DMI on " + _symbol + "/" + tf + " (" + IntegerToString(_length) + "):" + message;
        if (Sound_Alert)
            Alert(alert_Body);
        if (Email_Alert)
            SendMail(alert_Subject, alert_Body);
    }

    int GetSide(const int period)
    {
        //customizable formula
        double dip = iCustom(_symbol, _period, "Wilders DMI", "Current time frame", _length, 0, period);
        double dip2 = iCustom(_symbol, _period, "Wilders DMI", "Current time frame", _length, 0, period + 1);
        double dim = iCustom(_symbol, _period, "Wilders DMI", "Current time frame", _length, 1, period);
        double dim2 = iCustom(_symbol, _period, "Wilders DMI", "Current time frame", _length, 1, period + 1);
        if (dip > dim)
        {
            if (dip > _level)
            {
                return dip > dip2 ? 4 : 3;
            }
            return dip > dip2 ? 2 : 1;
        }
        if (dim > _level)
        {
            return dim > dim2 ? -4 : -3;
        }
        return dim > dim2 ? -2 : -1;
    }

    int RegisterStreams(const int index)
    {
        SetIndexBuffer(index, up_up);
        SetIndexBuffer(index + 1, up_dn);
        SetIndexBuffer(index + 2, dn_up);
        SetIndexBuffer(index + 3, dn_dn);
        SetIndexBuffer(index + 4, nt_up_up);
        SetIndexBuffer(index + 5, nt_up_dn);
        SetIndexBuffer(index + 6, nt_dn_up);
        SetIndexBuffer(index + 7, nt_dn_dn);
        return index + 8;
    }

    string GetLabel()
    {
        return IntegerToString(_length);
    }
};

HeatMapValueCalculator *rows[];

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


int init(){
        double temp = iCustom(NULL, 0, "Wilders DMI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Wilders DMI' indicator");
       return INIT_FAILED;
   }
   ArrayResize(rows, 13);
    rows[0] = new HeatMapValueCalculator(Period(), NULL, 1.0, Length1, level1);
    rows[1] = new HeatMapValueCalculator(Period(), NULL, 1.5, Length2, level2);
    rows[2] = new HeatMapValueCalculator(Period(), NULL, 2.0, Length3, level3);
    rows[3] = new HeatMapValueCalculator(Period(), NULL, 2.5, Length4, level4);
    rows[4] = new HeatMapValueCalculator(Period(), NULL, 3.0, Length5, level5);
    rows[5] = new HeatMapValueCalculator(Period(), NULL, 3.5, Length6, level6);
    rows[6] = new HeatMapValueCalculator(Period(), NULL, 4.0, Length7, level7);
    rows[7] = new HeatMapValueCalculator(Period(), NULL, 4.5, Length8, level8);
    rows[8] = new HeatMapValueCalculator(Period(), NULL, 5.0, Length9, level9);
    rows[9] = new HeatMapValueCalculator(Period(), NULL, 5.5, Length10, level10);
    rows[10] = new HeatMapValueCalculator(Period(), NULL, 6.0, Length11, level11);
    rows[11] = new HeatMapValueCalculator(Period(), NULL, 6.5, Length12, level12);
    rows[12] = new HeatMapValueCalculator(Period(), NULL, 7.0, Length13, level13);
    
    IndicatorBuffers(8 * 13);

    int index = 0;
    for (int i = 0; i < 13; i++)
    {
        index = rows[i].RegisterStreams(index);
    }

    int arrow = 110;
    for (i = 0; i < index; i++) {
        SetIndexStyle(i, DRAW_ARROW);
        SetIndexArrow(i, arrow);
        SetIndexLabel(i, "");
    }

    IndName = "Multi Period DMI Heat Map with Alert";
    IndicatorName = GenerateIndicatorName(IndName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

    Limpiar();

    return(0);
}

int deinit(){
    Limpiar();
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    for (int i = 0; i < 13; i++)
    {
        delete rows[i];
    }
    return(0);
}

int start(){
    int counted_bars=IndicatorCounted();
    int limit = Bars-counted_bars-1;
    double location = 1.0;
    for (int j = 0; j < 13; j++)
    {
        for(int i = limit ; i>=0; i--)
        {
            rows[j].UpdateValue(i);
        }
        Etiqueta(rows[j].GetLabel(), rows[j].GetLabel(), location + j * 0.5 + 0.2, Time[0]);
    }
    return(0);
}

int Etiqueta(string sName, string sLabel,double dPrice, datetime tTime)
{
    ObjectCreate(IndicatorObjPrefix + sName, OBJ_TEXT, WindowFind(IndName), tTime+Period()*60*2, dPrice);
    ObjectSetText(IndicatorObjPrefix + sName, " " + sLabel, 8, "Lucida Console", clrWhite);
    ObjectMove(IndicatorObjPrefix + sName, 0, tTime + Period() * 60 * 2, dPrice);
    return(0);
}

void Limpiar()
{
    for (int i = 0; i < 13; i++)
    {
        ObjectDelete(rows[i].GetLabel());
    }
}