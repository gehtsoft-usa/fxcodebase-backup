// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65018

//+------------------------------------------------------------------+
//|                                       MTF_MCP_ADX_DMI_Filter.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC |
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

#property indicator_chart_window

extern int Length = 14;
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
extern color    Up_Color                 = clrLime;
extern color    Dn_Color                 = clrRed;
extern color    Neutral_Color            = clrDarkGray;
extern color    All_Sync_Color           = clrYellow;
extern bool       Sound_Alert                   = true;
extern bool       Email_Alert                   = false;

string   WindowName;
int      WindowNumber;

class Iterator
{
    int _initialValue;
    int _shift;
    int _current;
public:
    Iterator(int initialValue, int shift)
    {
        _initialValue = initialValue;
        _shift = shift;
        _current = _initialValue - _shift;
    }

    int GetNext()
    {
        _current += _shift;
        return _current;
    }
};

class ICell
{
public:
    virtual int Draw() = 0;
protected:
    void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 )
    {
        ObjectDelete(IndicatorObjPrefix + nm);
        ObjectCreate(IndicatorObjPrefix + nm, OBJ_LABEL, Window, 0, 0);
        ObjectSet(IndicatorObjPrefix + nm, OBJPROP_CORNER, LabelCorner);
        ObjectSet(IndicatorObjPrefix + nm, OBJPROP_XDISTANCE, xoff);
        ObjectSet(IndicatorObjPrefix + nm, OBJPROP_YDISTANCE, yoff);
        ObjectSet(IndicatorObjPrefix + nm, OBJPROP_BACK, false);
        ObjectSetText(IndicatorObjPrefix + nm, LabelTexto, FSize, Font, LabelColor);
    }
};

class TotalCell : public ICell
{
    string _id;
    int _x;
    int _y;
    string _symbol;
    datetime _lastDatetime;
    int _direction;
public:
    TotalCell(const string id, const int x, const int y, const string symbol)
    {
        _id = id;
        _x = x;
        _y = y;
        _symbol = symbol;
    }

    void SetDirection(const int direction)
    {
        _direction = direction;
    }

    virtual int Draw()
    {
        if (_direction != 0) 
        {
            SendNotifications(_direction);
            ObjectMakeLabel(_id, _x, _y, "è", All_Sync_Color, 1, WindowNumber, "Wingdings", 10);
        }
        else
        {
            ObjectDelete(_id);
        }
        return _direction;
    }
private:
    void SendNotifications(const int direction)
    {
        datetime currentTime = iTime(Symbol(), Period(), 0);
        if (_lastDatetime == currentTime)
            return;

        _lastDatetime = currentTime;
        if (direction == 0)
            return;
            
        string alert_Subject = "WDMI on " + Symbol();
        string alert_Body = "WDMI on " + Symbol() + (direction == 1 ? " All TFs in Sync for the Up" : " All TFs in Sync for the Down");
        
        if (Sound_Alert)
            Alert(alert_Body);
        if (Email_Alert)
            SendMail(alert_Subject, alert_Body);
    }
};

class Row
{
    ICell *_cells[];
    TotalCell *_totalCell;
public:
    Row()
    {
        _totalCell = NULL;
    }
    
    ~Row()
    {
        int count = ArraySize(_cells);
        for (int i = 0; i < count; ++i)
        {
            delete _cells[i];
        }
    }

    int Draw()
    {
        int lastSignal = INT_MAX;
        bool allAligned = true;
        int count = ArraySize(_cells);
        for (int i = 0; i < count; ++i)
        {
            int signal = _cells[i].Draw();
            if (lastSignal == INT_MAX && signal != INT_MAX)
                lastSignal = signal;
            else if (lastSignal != signal)
                allAligned = false;
        }
        if (_totalCell != NULL)
        {
            _totalCell.SetDirection(allAligned ? lastSignal : 0);
            _totalCell.Draw();
        }
        return allAligned ? lastSignal : 0;
    }

    void Add(ICell *cell)
    {
        int count = ArraySize(_cells);
        ArrayResize(_cells, count + 1);
        _cells[count] = cell;
    }

    void SetTotal(TotalCell *cell)
    {
        _totalCell = cell;
    }
};

//draws nothing
class EmptyCell : public ICell
{
public:
    virtual int Draw()
    {
        //do nothing
        return INT_MAX;
    }
};

//draws a label
class LabelCell : public ICell
{
    string _id;
    string _text;
    int _x;
    int _y;
public:
    LabelCell(const string id, const string text, const int x, const int y)
    {
        _id = id;
        _text = text;
        _x = x;
        _y = y;
    }

    virtual int Draw()
    {
        ObjectMakeLabel(_id, _x, _y, _text, Labels_Color, 1, WindowNumber, "Arial", 12);
        return INT_MAX;
    }
};

// Grid v.1.0
class ValueCell : public ICell
{
    string _id;
    int _x;
    int _y;
    string _symbol;
    int _timeframe;
    datetime _lastDatetime;
public:
    ValueCell(const string id, const int x, const int y, const string symbol, const int timeframe)
    {
        _id = id;
        _x = x;
        _y = y;
        _symbol = symbol;
        _timeframe = timeframe;
    }

    virtual int Draw()
    {
        int direction = GetDirection();
        //SendNotifications(direction);
        double dmip = iCustom(_symbol, _timeframe, "Wilders DMI", "Current time frame", Length, 0, 0);
        double dmim = iCustom(_symbol, _timeframe, "Wilders DMI", "Current time frame", Length, 1, 0);
        ObjectMakeLabel(_id, _x - 60, _y, GetDirectionSymbol(direction), GetDirectionColor(direction), 1, WindowNumber, "Wingdings", 10);
        ObjectMakeLabel(_id + "plus", _x, _y, DoubleToStr(dmip, 2), Up_Color, 1, WindowNumber, "Arial", 9);
        ObjectMakeLabel(_id + "sep", _x - 8, _y, "/", clrDarkGray, 1, WindowNumber, "Arial", 9);
        ObjectMakeLabel(_id + "minus", _x - 43, _y, DoubleToStr(dmim, 2), Dn_Color, 1, WindowNumber, "Arial", 9);
        return direction;
    }

private:
    string GetTimeframe()
    {
        switch (_timeframe)
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

    void SendNotifications(const int direction)
    {
        datetime currentTime = iTime(_symbol, _timeframe, 0);
        if (_lastDatetime == currentTime)
            return;

        _lastDatetime = currentTime;
        if (direction == 0)
            return;
            
        string tf = GetTimeframe();
        string alert_Subject = "WDMI on " + _symbol + "/" + tf;
        string alert_Body = "WDMI on " + _symbol + "/" + tf;
        
        if (Sound_Alert)
            Alert(alert_Body);
        if (Email_Alert)
            SendMail(alert_Subject, alert_Body);
    }

    int GetDirection()
    {
        double adx0 = iCustom(_symbol, _timeframe, "Wilders DMI", "Current time frame", Length, 2, 0);
        double adx1 = iCustom(_symbol, _timeframe, "Wilders DMI", "Current time frame", Length, 2, 1);
        double dmip = iCustom(_symbol, _timeframe, "Wilders DMI", "Current time frame", Length, 0, 0);
        double dmim = iCustom(_symbol, _timeframe, "Wilders DMI", "Current time frame", Length, 1, 0);
        if (adx0 > ADX_Level && adx0 > adx1 && dmip > dmim)
        {
            return 1;
        }
        if (adx0 > ADX_Level && adx0 > adx1 && dmip < dmim)
        {
            return -1;
        }
        return 0;
    }

    color GetDirectionColor(const int direction)
    {
        if (direction == 1)
        {
            return Up_Color;
        }
        else if (direction == -1)
        {
            return Dn_Color;
        }
        return Neutral_Color;
    }

    string GetDirectionSymbol(const int direction)
    {
        if (direction == 1)
        {
            return "é";
        }
        else if (direction == -1)
        {
            return "ê";
        }
        return "û";
    }
};

Row *rows[];

int GetTimeframesCount()
{
    int count = 0;
    
    if (Include_M1)
        count++;
    if (Include_M5)
        count++;
    if (Include_M15)
        count++;
    if (Include_M30)
        count++;
    if (Include_H1)
        count++;
    if (Include_H4)
        count++;
    if (Include_D1)
        count++;
    if (Include_W1)
        count++;
    if (Include_MN1)
        count++;
    return count;
}

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
        double temp = iCustom(NULL, 0, "Wilders DMI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Wilders DMI' indicator");
       return INIT_FAILED;
   }
   WindowName = "MTF_MCP_WDMI_List";
    IndicatorName = GenerateIndicatorName(WindowName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

    int Original_x = 1000;
    string sym_arr[];
    split(sym_arr, Pairs, ",");
    int sym_count = ArraySize(sym_arr);
    int timeframes_count = GetTimeframesCount();
    ArrayResize(rows, sym_count + 1);
    for (int i = 0; i <= sym_count; ++i)
    {
        rows[i] = new Row();
    }
    rows[0].Add(new EmptyCell());
    Iterator yIterator(50, 30);
    int currentCell = 1;
    for (i = 0; i < sym_count; i++)
    {
        rows[currentCell++].Add(new LabelCell(sym_arr[i] + "_Name", sym_arr[i], Original_x + 80, yIterator.GetNext()));
    }

    Iterator xIterator(Original_x, -100);
    if (Include_M1)
    {
        int m1_x = xIterator.GetNext();
        rows[0].Add(new LabelCell("M1_Label", "M1", m1_x, 20));
        Iterator m1YIterator(50, 30);
        currentCell = 1;
        for (i = 0; i < sym_count; i++)
        {
            rows[currentCell++].Add(new ValueCell(sym_arr[i] + "_M1", m1_x, m1YIterator.GetNext(), sym_arr[i], PERIOD_M1));
        }
    }
    if (Include_M5)
    {
        int m5_x = xIterator.GetNext();
        rows[0].Add(new LabelCell("M5_Label", "M5", m5_x, 20));
        Iterator m5YIterator(50, 30);
        currentCell = 1;
        for (i = 0; i < sym_count; i++)
        {
            rows[currentCell++].Add(new ValueCell(sym_arr[i] + "_M5", m5_x, m5YIterator.GetNext(), sym_arr[i], PERIOD_M5));
        }
    }
    if (Include_M15)
    {
        int m15_x = xIterator.GetNext();
        rows[0].Add(new LabelCell("M15_Label", "M15", m15_x, 20));
        Iterator m15YIterator(50, 30);
        currentCell = 1;
        for (i = 0; i < sym_count; i++)
        {
            rows[currentCell++].Add(new ValueCell(sym_arr[i] + "_M15", m15_x, m15YIterator.GetNext(), sym_arr[i], PERIOD_M15));
        }
    }
    if (Include_M30)
    {
        int m30_x = xIterator.GetNext();
        rows[0].Add(new LabelCell("M30_Label", "M30", m30_x, 20));
        Iterator m30YIterator(50, 30);
        currentCell = 1;
        for (i = 0; i < sym_count; i++)
        {
            rows[currentCell++].Add(new ValueCell(sym_arr[i] + "_M30", m30_x, m30YIterator.GetNext(), sym_arr[i], PERIOD_M30));
        }
    }
    if (Include_H1)
    {
        int h1_x = xIterator.GetNext();
        rows[0].Add(new LabelCell("H1_Label", "H1", h1_x, 20));
        Iterator h1YIterator(50, 30);
        currentCell = 1;
        for (i = 0; i < sym_count; i++)
        {
            rows[currentCell++].Add(new ValueCell(sym_arr[i] + "_H1", h1_x, h1YIterator.GetNext(), sym_arr[i], PERIOD_H1));
        }
    }
    if (Include_H4)
    {
        int h4_x = xIterator.GetNext();
        rows[0].Add(new LabelCell("H4_Label", "H4", h4_x, 20));
        Iterator h4yIterator(50, 30);
        currentCell = 1;
        for (i = 0; i < sym_count; i++)
        {
            rows[currentCell++].Add(new ValueCell(sym_arr[i] + "_H4", h4_x, h4yIterator.GetNext(), sym_arr[i], PERIOD_H4));
        }
    }
    if (Include_D1)
    {
        int d1_x = xIterator.GetNext();
        rows[0].Add(new LabelCell("D1_Label", "D1", d1_x, 20));
        Iterator d1yIterator(50, 30);
        currentCell = 1;
        for (i = 0; i < sym_count; i++)
        {
            rows[currentCell++].Add(new ValueCell(sym_arr[i] + "_D1", d1_x, d1yIterator.GetNext(), sym_arr[i], PERIOD_D1));
        }
    }
    if (Include_W1)
    {
        int w1_x = xIterator.GetNext();
        rows[0].Add(new LabelCell("W1_Label", "W1", w1_x, 20));
        Iterator w1yIterator(50, 30);
        currentCell = 1;
        for (i = 0; i < sym_count; i++)
        {
            rows[currentCell++].Add(new ValueCell(sym_arr[i] + "_W1", w1_x, w1yIterator.GetNext(), sym_arr[i], PERIOD_W1));
        }
    }
    if (Include_MN1)
    {
        int mn1_x = xIterator.GetNext();
        rows[0].Add(new LabelCell("MN1_Label", "MN1", mn1_x, 20));
        Iterator mn1yIterator(50, 30);
        currentCell = 1;
        for (i = 0; i < sym_count; i++)
        {
            rows[currentCell++].Add(new ValueCell(sym_arr[i] + "_MN1", mn1_x, mn1yIterator.GetNext(), sym_arr[i], PERIOD_MN1));
        }
    }
    int total_x = xIterator.GetNext();
    rows[0].Add(new LabelCell("Total_Label", "Total", total_x, 20));
    Iterator totalYIterator(50, 30);
    currentCell = 1;
    for (i = 0; i < sym_count; i++)
    {
        TotalCell *totalCell = new TotalCell(sym_arr[i] + "_Total", total_x, totalYIterator.GetNext(), sym_arr[i]);
        rows[currentCell++].SetTotal(totalCell);
    }

    return(0);
}

int deinit()
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    int i_count = ArraySize(rows);
    for (int i = 0; i < i_count; ++i)
    {
        delete rows[i];
    }
    return(0);
}

int start()
{
    WindowNumber = 0;
    int i_count = ArraySize(rows);
    for (int i = 0; i < i_count; ++i)
    {
        rows[i].Draw();
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
