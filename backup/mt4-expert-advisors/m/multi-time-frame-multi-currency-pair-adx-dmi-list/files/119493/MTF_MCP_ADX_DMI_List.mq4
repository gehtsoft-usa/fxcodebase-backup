// Id: 21515
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65018
// Id:  

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
string   WindowName = "MTF_MCP_ADX_DMI_List";

#property indicator_separate_window

extern int      ADX_Period             = 14;
extern int      ADX_Level              = 20;
extern string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
extern string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";
extern bool     Include_M1               = true;
extern bool     Include_M5               = true;
extern bool     Include_M15              = true;
extern bool     Include_M30              = true;
extern bool     Include_H1               = true;
extern bool     Include_H4               = true;
extern bool     Include_D1               = true;
extern bool     Include_W1               = true;
extern bool     Include_MN1              = true;
extern color    Labels_Color             = clrWhite;
extern color    Unconfirmed_Up_Color     = clrLime;
extern color    Confirmed_Up_Color       = clrDarkGreen;
extern color    Unconfirmed_Dn_Color     = clrRed;
extern color    Confirmed_Dn_Color       = clrDarkRed;
extern color    Neutral_Color            = clrDarkGray;
extern bool     Alert_Confirmed_Signals  = false;
extern bool     Alert_Unconfirmed_Signals = false;
extern bool     Alert_Confirmed_In_Line_Signals = true;
extern bool     Alert_Unconfirmed_In_Line_Signals = true;
extern bool     Sound_Alert              = true;
extern bool     Email_Alert              = false;
extern bool     Telegram_Alert           = false; // External alert
extern string   Telegram_Key             = ""; // External alert key
extern string   Comment2                 = "- You can get a external alert key by starting a dialog with @profit_robots_bot Telegram bot -";
extern string   Comment3                 = "- Also, you need to install TelegramNotificationsLib.dll and allow use of dll in the indicator parameters window -";

int      WindowNumber;

// TelegramNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "TelegramNotificationsLib.dll"
void AlertTelegram(string key, string text, string instrument, string timeframe);
#import

class Notificator
{
    string _symbol;
    int _timeframe;
    int _lastSent;
    datetime _lastDatetime;
public:
    Notificator(const string symbol, const int timeframe)
    {
        _symbol = symbol;
        _timeframe = timeframe;
        _lastSent = 0;
        _lastDatetime = 0;
    }

    void SendNotifications(const int direction, const bool confirmed)
    {
        if (direction == 0)
            return;

        datetime currentTime = iTime(_symbol, _timeframe, 0);
        int lastSentDirection = _lastSent;
        if (_lastDatetime == currentTime && lastSentDirection == direction)
            return;

        _lastDatetime = currentTime;
        _lastSent = direction;

        string confirmedStr = confirmed ? " (Confirmed)" : " (Unconfirmed)";
        string tf = GetTimeframe();
        string alert_Subject;
        string alert_Body;
        switch (direction)
        {
            case 1:
                alert_Subject = "Buy signal on " + _symbol + "/" + tf + confirmedStr;
                alert_Body = "Buy signal on " + _symbol + "/" + tf + confirmedStr;
                break;
            case -1:
                alert_Subject = "Sell signal on " + _symbol + "/" + tf + confirmedStr;
                alert_Body = "Sell signal on " + _symbol + "/" + tf + confirmedStr;
                break;
            case 2:
                alert_Subject = "Exit buy signal on " + _symbol + "/" + tf + confirmedStr;
                alert_Body = "Exit buy signal on " + _symbol + "/" + tf + confirmedStr;
                break;
            case -2:
                alert_Subject = "Exit sell signal on " + _symbol + "/" + tf + confirmedStr;
                alert_Body = "Exit sell signal on " + _symbol + "/" + tf + confirmedStr;
                break;
        }
        
        if (Sound_Alert)
            Alert(alert_Body);
        if (Email_Alert)
            SendMail(alert_Subject, alert_Body);
        if (Telegram_Alert && Telegram_Key != "")
            AlertTelegram(Telegram_Key, alert_Body, _symbol, tf);
    }
    
private:
    string GetTimeframe()
    {
        switch (_timeframe)
        {
            case PERIOD_M1: return "M1";
            case PERIOD_M5: return "M5";
            case PERIOD_D1: return "D1";
            case PERIOD_H1: return "H1";
            case PERIOD_H4: return "H4";
            case PERIOD_M15: return "M15";
            case PERIOD_M30: return "M30";
            case PERIOD_MN1: return "MN1";
            case PERIOD_W1: return "W1";
        }
        return "M1";
    }
};

class Iterator
{
    int _initialValue; int _shift; int _current;
public:
    Iterator(int initialValue, int shift) { _initialValue = initialValue; _shift = shift; _current = _initialValue - _shift; }
    int GetNext() { _current += _shift; return _current; }
};

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

class ICell
{
public:
    virtual void Draw() = 0;
protected:
    void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 )
    { 
        ObjectDelete(IndicatorObjPrefix + nm); 
        ObjectCreate(IndicatorObjPrefix + nm, OBJ_LABEL, Window, 0, 0); 
        ObjectSet(IndicatorObjPrefix + nm, OBJPROP_CORNER, LabelCorner); 
        ObjectSet(IndicatorObjPrefix + nm, OBJPROP_XDISTANCE, xoff); 
        ObjectSet(IndicatorObjPrefix + nm, OBJPROP_YDISTANCE, yoff); 
        ObjectSet(IndicatorObjPrefix + nm, OBJPROP_BACK, false); 
        ObjectSetText(IndicatorObjPrefix + nm, LabelTexto, FSize, Font, LabelColor); }
};

class Row
{
    ICell *_cells[];
public:
    ~Row() { int count = ArraySize(_cells); for (int i = 0; i < count; ++i) { delete _cells[i]; } }
    void Draw() { int count = ArraySize(_cells); for (int i = 0; i < count; ++i) { _cells[i].Draw(); } }
    void Add(ICell *cell) { int count = ArraySize(_cells); ArrayResize(_cells, count + 1); _cells[count] = cell; } 
};

//draws nothing
class EmptyCell : public ICell
{
public:
    virtual void Draw() { }
};

//draws a label
class LabelCell : public ICell
{
    string _id; string _text; int _x; int _y;
public:
    LabelCell(const string id, const string text, const int x, const int y) { _id = id; _text = text; _x = x; _y = y; } 
    virtual void Draw() { ObjectMakeLabel(_id, _x, _y, _text, Labels_Color, 1, WindowNumber, "Arial", 12); }
};

class SignalDetector
{
    bool _cleared;
    int _signal;
public:
    SignalDetector()
    {
        _cleared = true;
    }

    void Clear()
    {
        _cleared = true;
    }

    void SetSignal(const int signal)
    {
        if (_cleared)
        {
            _cleared = false;
            _signal = signal;
        }
        else if (_signal != signal)
        {
            _signal = 0;
        }
    }

    int GetSignal()
    {
        if (_cleared)
            return 0;
        return _signal;
    }
};

class ValueCell : public ICell
{
    string _id; int _x; int _y; string _symbol; int _timeframe;
    int _lastConfirmedSignal;
    SignalDetector *_confirmedSignal;
    SignalDetector *_unconfirmedSignal;
    Notificator *_confirmedNotificator;
    Notificator *_unconfirmedNotificator;
public:
    ValueCell(const string id, const int x, const int y, const string symbol, const int timeframe)
    { _id = id; _x = x; _y = y; _symbol = symbol; _timeframe = timeframe; _lastConfirmedSignal = 0; 
    _confirmedNotificator = new Notificator(symbol, timeframe); _unconfirmedNotificator = new Notificator(symbol, timeframe);}
    ~ValueCell() { delete _confirmedNotificator; delete _unconfirmedNotificator; }

    void SetSignalDetectors(SignalDetector *confirmed, SignalDetector *unconfirmed)
    {
        _confirmedSignal = confirmed;
        _unconfirmedSignal = unconfirmed;
    }

    virtual void Draw()
    {
        int last_direction = GetDirection(1);
        if (last_direction != 0 && CanApplyDirection(last_direction))
        {
            if (_lastConfirmedSignal != last_direction)
            {
                if (Alert_Confirmed_Signals)
                {
                    _confirmedNotificator.SendNotifications(last_direction, true);
                }
                _lastConfirmedSignal = last_direction;
            }
            if (_confirmedSignal != NULL)
                _confirmedSignal.SetSignal(last_direction);
        }
        else
        {
            if (_confirmedSignal != NULL)
                _confirmedSignal.SetSignal(0);
        }
        int direction = GetDirection(0);
        bool confirmed = false;
        if (direction == 0 || !CanApplyDirection(direction))
        {
            direction = _lastConfirmedSignal;
            confirmed = true;
        }
        else if (Alert_Unconfirmed_Signals)
        {
            _unconfirmedNotificator.SendNotifications(direction, false);
        }
        if (_unconfirmedSignal != NULL)
            _unconfirmedSignal.SetSignal(direction);
        
        double dmip = iADX(_symbol, _timeframe, ADX_Period, PRICE_CLOSE, MODE_PLUSDI, 0);
        double dmim = iADX(_symbol, _timeframe, ADX_Period, PRICE_CLOSE, MODE_MINUSDI, 0);
        ObjectMakeLabel(_id + "_plus", _x, _y, DoubleToStr(dmip, 2), Unconfirmed_Up_Color, 1, WindowNumber, "Arial", 9);
        ObjectMakeLabel(_id + "_sep", _x - 8, _y, "/", clrDarkGray, 1, WindowNumber, "Arial", 9);
        ObjectMakeLabel(_id + "_minus", _x - 43, _y, DoubleToStr(dmim, 2), Unconfirmed_Dn_Color, 1, WindowNumber, "Arial", 9);

        ObjectMakeLabel(_id, _x - 78, _y, GetDirectionSymbol(direction), GetDirectionColor(direction, confirmed), 1, WindowNumber, "Arial", 10);
    }

private:
    bool CanApplyDirection(const int newDirection)
    {
        switch (_lastConfirmedSignal)
        {
            case 0:
                return true;
            case 1:
                return newDirection == 2 || newDirection == -1;
            case 2:
            case -2:
                return newDirection == 1 || newDirection == -1;
            case -1:
                return newDirection == -2 || newDirection == 1;
        }
        return false;
    }

    int GetDirection(const int shift)
    {
        double adx0 = iADX(_symbol, _timeframe, ADX_Period, PRICE_CLOSE, MODE_MAIN, shift);
        double adx1 = iADX(_symbol, _timeframe, ADX_Period, PRICE_CLOSE, MODE_MAIN, shift + 1);
        double dmip = iADX(_symbol, _timeframe, ADX_Period, PRICE_CLOSE, MODE_PLUSDI, shift);
        double dmim = iADX(_symbol, _timeframe, ADX_Period, PRICE_CLOSE, MODE_MINUSDI, shift);
        if (adx0 > ADX_Level && adx0 > adx1 && dmip > dmim)
        {
            return 1;
        }
        else if (adx0 > ADX_Level && adx0 > adx1 && dmip < dmim)
        {
            return -1;
        }
        return 0;
    }

    color GetDirectionColor(const int direction, const bool confirmed)
    {
        if (direction >= 1)
        {
            return confirmed ? Confirmed_Up_Color : Unconfirmed_Up_Color;
        }
        else if (direction <= -1)
        {
            return confirmed ? Confirmed_Dn_Color : Unconfirmed_Dn_Color;
        }
        return Neutral_Color;
    }
    string GetDirectionSymbol(const int direction)
    {
        if (direction == 1)
        {
            return "BUY";
        }
        else if (direction == -1)
        {
            return "SELL";
        }
        if (direction == 2)
        {
            return "EXIT BUY";
        }
        else if (direction == -2)
        {
            return "EXIT SELL";
        }
        return "-";
    }
};

Row *rows[];
SignalDetector *confirmedSignal[];
SignalDetector *unconfirmedSignal[];
Notificator *confirmedNotificator[];
Notificator *unconfirmedNotificator[];

int GetTimeframesCount()
{
    int count = 0;
    if (Include_M1) count++;
    if (Include_M5) count++;
    if (Include_M15) count++;
    if (Include_M30) count++;
    if (Include_H1) count++;
    if (Include_H4) count++;
    if (Include_D1) count++;
    if (Include_W1) count++;
    if (Include_MN1) count++;
    return count;
}

int init()
{
    IndicatorName = GenerateIndicatorName(WindowName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
    
    int Original_x = 1000;
    string sym_arr[];
    split(sym_arr, Pairs, ",");
    int sym_count = ArraySize(sym_arr);
    
    ArrayResize(confirmedSignal, sym_count);
    ArrayResize(unconfirmedSignal, sym_count);
    ArrayResize(confirmedNotificator, sym_count);
    ArrayResize(unconfirmedNotificator, sym_count);
    for (int i = 0; i < sym_count; ++i)
    {
        confirmedSignal[i] = new SignalDetector();
        unconfirmedSignal[i] = new SignalDetector();
        confirmedNotificator[i] = new Notificator(sym_arr[i], PERIOD_M1);
        unconfirmedNotificator[i] = new Notificator(sym_arr[i], PERIOD_M1);
    }

    int timeframes_count = GetTimeframesCount();
    ArrayResize(rows, timeframes_count + 1);
    for (i = 0; i <= timeframes_count; ++i)
    {
        rows[i] = new Row();
    }
    rows[0].Add(new EmptyCell());
    Iterator yIterator(50, 30);
    for (i = 0; i < sym_count; i++)
    {
        rows[0].Add(new LabelCell(WindowName + sym_arr[i] + "_Name", sym_arr[i], Original_x + 80, yIterator.GetNext()));
    }

    ValueCell *newCell;
    int currentCell = 1;
    Iterator xIterator(Original_x, -120);
    if (Include_M1)
    {
        int m1_x = xIterator.GetNext();
        rows[currentCell++].Add(new LabelCell(WindowName + "M1_Label", "M1", m1_x, 20));
        Iterator ym1Iterator(50, 30);
        for (i = 0; i < sym_count; i++)
        {
            newCell = new ValueCell(WindowName + sym_arr[i] + "_M1", m1_x, ym1Iterator.GetNext(), sym_arr[i], PERIOD_M1);
            newCell.SetSignalDetectors(confirmedSignal[i], unconfirmedSignal[i]);
            rows[currentCell - 1].Add(newCell);
        }
    }
    if (Include_M5)
    {
        int m5_x = xIterator.GetNext();
        rows[currentCell++].Add(new LabelCell(WindowName + "M5_Label", "M5", m5_x, 20));
        Iterator ym5Iterator(50, 30);
        for (i = 0; i < sym_count; i++)
        {
            newCell = new ValueCell(WindowName + sym_arr[i] + "_M5", m5_x, ym5Iterator.GetNext(), sym_arr[i], PERIOD_M5);
            newCell.SetSignalDetectors(confirmedSignal[i], unconfirmedSignal[i]);
            rows[currentCell - 1].Add(newCell);
        }
    }
    if (Include_M15)
    {
        int m15_x = xIterator.GetNext();
        rows[currentCell++].Add(new LabelCell(WindowName + "M15_Label", "M15", m15_x, 20));
        Iterator ym15Iterator(50, 30);
        for (i = 0; i < sym_count; i++)
        {
            newCell = new ValueCell(WindowName + sym_arr[i] + "_M15", m15_x, ym15Iterator.GetNext(), sym_arr[i], PERIOD_M15);
            newCell.SetSignalDetectors(confirmedSignal[i], unconfirmedSignal[i]);
            rows[currentCell - 1].Add(newCell);
        }
    }
    if (Include_M30)
    {
        int m30_x = xIterator.GetNext();
        rows[currentCell++].Add(new LabelCell(WindowName + "M30_Label", "M30", m30_x, 20));
        Iterator ym30Iterator(50, 30);
        for (i = 0; i < sym_count; i++)
        {
            newCell = new ValueCell(WindowName + sym_arr[i] + "_M30", m30_x, ym30Iterator.GetNext(), sym_arr[i], PERIOD_M30);
            newCell.SetSignalDetectors(confirmedSignal[i], unconfirmedSignal[i]);
            rows[currentCell - 1].Add(newCell);
        }
    }
    if (Include_H1)
    {
        int h1_x = xIterator.GetNext();
        rows[currentCell++].Add(new LabelCell(WindowName + "H1_Label", "H1", h1_x, 20));
        Iterator yH1Iterator(50, 30);
        for (i = 0; i < sym_count; i++)
        {
            newCell = new ValueCell(WindowName + sym_arr[i] + "_H1", h1_x, yH1Iterator.GetNext(), sym_arr[i], PERIOD_H1);
            newCell.SetSignalDetectors(confirmedSignal[i], unconfirmedSignal[i]);
            rows[currentCell - 1].Add(newCell);
        }
    }
    if (Include_H4)
    {
        int h4_x = xIterator.GetNext();
        rows[currentCell++].Add(new LabelCell(WindowName + "H4_Label", "H4", h4_x, 20));
        Iterator yH4Iterator(50, 30);
        for (i = 0; i < sym_count; i++)
        {
            newCell = new ValueCell(WindowName + sym_arr[i] + "_H4", h4_x, yH4Iterator.GetNext(), sym_arr[i], PERIOD_H4);
            newCell.SetSignalDetectors(confirmedSignal[i], unconfirmedSignal[i]);
            rows[currentCell - 1].Add(newCell);
        }
    }
    if (Include_D1)
    {
        int d1_x = xIterator.GetNext();
        rows[currentCell++].Add(new LabelCell(WindowName + "D1_Label", "D1", d1_x, 20));
        Iterator yD1Iterator(50, 30);
        for (i = 0; i < sym_count; i++)
        {
            newCell = new ValueCell(WindowName + sym_arr[i] + "_D1", d1_x, yD1Iterator.GetNext(), sym_arr[i], PERIOD_D1);
            newCell.SetSignalDetectors(confirmedSignal[i], unconfirmedSignal[i]);
            rows[currentCell - 1].Add(newCell);
        }
    }
    if (Include_W1)
    {
        int w1_x = xIterator.GetNext();
        rows[currentCell++].Add(new LabelCell(WindowName + "W1_Label", "W1", w1_x, 20));
        Iterator yW1Iterator(50, 30);
        for (i = 0; i < sym_count; i++)
        {
            newCell = new ValueCell(WindowName + sym_arr[i] + "_W1", w1_x, yW1Iterator.GetNext(), sym_arr[i], PERIOD_W1);
            newCell.SetSignalDetectors(confirmedSignal[i], unconfirmedSignal[i]);
            rows[currentCell - 1].Add(newCell);
        }
    }
    if (Include_MN1)
    {
        int mn1_x = xIterator.GetNext();
        rows[currentCell++].Add(new LabelCell(WindowName + "MN1_Label", "MN1", mn1_x, 20));
        Iterator yMN1Iterator(50, 30);
        for (i = 0; i < sym_count; i++)
        {
            newCell = new ValueCell(WindowName + sym_arr[i] + "_MN1", mn1_x, yMN1Iterator.GetNext(), sym_arr[i], PERIOD_MN1);
            newCell.SetSignalDetectors(confirmedSignal[i], unconfirmedSignal[i]);
            rows[currentCell - 1].Add(newCell);
        }
    }

    return(0);
}

int deinit()
{
    int i_count = ArraySize(confirmedSignal);
    for (int i = 0; i < i_count; ++i)
    {
        delete confirmedSignal[i];
        delete unconfirmedSignal[i];
        delete confirmedNotificator[i];
        delete unconfirmedNotificator[i];
    }
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    i_count = ArraySize(rows);
    for (i = 0; i < i_count; ++i)
    {
        delete rows[i];
    }
    return(0);
}

int start()
{
    WindowNumber = WindowFind(WindowName);
    
    int sym_count = ArraySize(confirmedSignal);
    for (int i = 0; i < sym_count; ++i)
    {
        confirmedSignal[i].Clear();
        unconfirmedSignal[i].Clear();
    }
    
    int i_count = ArraySize(rows);
    for (i = 0; i < i_count; ++i)
    {
        rows[i].Draw();
    }
    
    for (i = 0; i < sym_count; ++i)
    {
        if (Alert_Confirmed_In_Line_Signals && confirmedSignal[i].GetSignal() != 0)
        {
            confirmedNotificator[i].SendNotifications(confirmedSignal[i].GetSignal(), true);
        }
        if (Alert_Unconfirmed_In_Line_Signals && unconfirmedSignal[i].GetSignal() != 0)
        {
            unconfirmedNotificator[i].SendNotifications(confirmedSignal[i].GetSignal(), false);
        }
    }

    return(0);
}

void split(string& arr[], string str, string sym) 
{
    ArrayResize(arr, 0);
    int len = StringLen(str);
    for (int i=0; i < len;)
    {
        int pos = StringFind(str, sym, i);
        if (pos == -1)
            pos = len;

        string item = StringSubstr(str, i, pos-i);
        item = StringTrimLeft(item);
        item = StringTrimRight(item);

        int size = ArraySize(arr);
        ArrayResize(arr, size+1);
        arr[size] = item;

        i = pos+1;
    }
}