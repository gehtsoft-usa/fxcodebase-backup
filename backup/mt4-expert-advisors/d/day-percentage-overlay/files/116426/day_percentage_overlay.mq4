//+------------------------------------------------------------------+
//|                                             Aaron_Oscillator.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property  indicator_buffers 3
#property  indicator_color1  clrRed
#property  indicator_color2  clrPink
#property  indicator_color3  clrRed

extern string Overlay_Symbol = "GBPUSD";

double Up[];
double Down[];
double Middle[];

class PeriodFinder
{
    string _symbol;
    int _timeframe;
    bool _initialized;
    datetime _dt;
    int _period;
    datetime _current;
    datetime _next;
public:
    PeriodFinder(const string symbol, const int timeframe)
    {
        _symbol = symbol;
        _timeframe = timeframe;
        _initialized = false;
    }

    datetime GetDate(const int period)
    {
        datetime d = iTime(_symbol, _timeframe, _period);
        int err = GetLastError();
        while ((err == 4066 || err == 4073) && !IsStopped())
        {
            d = iTime(_symbol, _timeframe, _period);
            err = GetLastError();
        }
        if (err != 0)
            return 0;
        return d;
    }
    
    datetime GetCurrent()
    {
        return _current;
    }

    datetime GetNext()
    {
        return _next;
    }

    int SetDateTime(datetime dt)
    {
        if (!_initialized)
        {
            _period = 0;
            _current = GetDate(_period);
            _next = _current;
            if (_current == 0)
               return -1;
            while (_current > dt)
            {
                _next = _current;
                _period++;
                _current = GetDate(_period);
                if (_current == 0)
                    return -1;
            }
            _initialized = true;
        }
        else
        {
            if (_period == 0)
                return _period;
            while (_period > 0 && _next < dt)
            {
                _current = _next;
                _period--;
                _next = GetDate(_period - 1);
                if (_next == 0)
                    return -1;
            }
        }
        return _period;
    }
};
int init()
{
    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(0, Up);
    SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(1, Middle);
    SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexBuffer(2, Down);
    
    IndicatorShortName("DPO");
    
    return(0);
}

int deinit()
{
    return 0;
}

int start()
{
    int countedBars = IndicatorCounted();
    int limit = Bars - countedBars - 1;

    if (Period() < PERIOD_D1)
    {
        PeriodFinder overlayPeriodFinder(Overlay_Symbol, PERIOD_D1);
        PeriodFinder mainPeriodFinder(Symbol(), PERIOD_D1);
        PeriodFinder periodFinder(Symbol(), Period());

        for (int i = limit; i >= 0;)
        {
            datetime dt = iTime(Symbol(), Period(), i);
            int overlayD1Period = overlayPeriodFinder.SetDateTime(dt);
            int mainD1Period = mainPeriodFinder.SetDateTime(dt);
            if (overlayD1Period != -1 && mainD1Period != -1)
            {
                datetime mainDateStart = mainPeriodFinder.GetCurrent();
                int start = periodFinder.SetDateTime(mainDateStart);
                int end = 0;
                if (mainD1Period > 0)
                {
                    datetime mainDateEnd = mainPeriodFinder.GetNext();
                    end = periodFinder.SetDateTime(mainDateEnd);
                }
                else
                {
                    end = 0;
                }
                
                if (end != -1)
                {
                    if (start == -1 && end != -1)
                    {
                        start = Bars - 1;
                    }

                    double overlayOpen = iOpen(Overlay_Symbol, PERIOD_D1, overlayD1Period);
                    double change = (iClose(Overlay_Symbol, PERIOD_D1, overlayD1Period) - overlayOpen) / (overlayOpen / 100);

                    double middle = iOpen(Symbol(), PERIOD_D1, mainD1Period);
                    double up = middle + (middle / 100) * change;
                    double down = middle - (middle / 100) * change;

                    for (i = start; i >= 0 && i >= end; --i)
                    {
                        Up[i] = up;
                        Down[i] = down;
                        Middle[i] = middle;
                    }
                }
                else
                {
                    i--;
                }
            }
            else
            {
                i--;
            }
        }
    }
    return limit;
}