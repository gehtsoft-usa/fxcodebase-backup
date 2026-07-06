// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72407

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property indicator_chart_window

#define day_seconds 86400

//--- indicator buffers
double Linea1Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
  datetime lastValidDay;

  if (isWeekend(MonthEnd()))
  {
    lastValidDay = SearchLastFriday(MonthEnd());
  } else
  {
    lastValidDay = MonthEnd();
  }

  // mostrar por pantalla:
  MqlDateTime dt;
  TimeToStruct(lastValidDay, dt);  
	Comment("Last Valid Day this Month is: ",strDay(TimeDayOfWeek(lastValidDay)),", ",dt.day,".",dt.mon,".",dt.year);

  return (rates_total);
}

datetime MonthEnd()
{
  int currentMonth = Month();

  MqlDateTime date;
  TimeToStruct(TimeCurrent(), date);
  // 18.06.2022

  // empezar desde 31, e ir para atrás
  // sumarle los segundos que faltan hasta el "31" del mes
  int      secondToEnd = (31 - date.day) * day_seconds;
  datetime finMes      = TimeCurrent() + secondToEnd;
  int      endMonth    = TimeMonth(finMes);

  while (endMonth != currentMonth)
  {
    finMes -= day_seconds;
    endMonth = TimeMonth(finMes);
  }

  return finMes;
}

bool isWeekend(datetime dt)
{
  if (TimeDayOfWeek(dt) == 0 || TimeDayOfWeek(dt) == 6)
  {
    return true;
  }

  return false;
}

datetime SearchLastFriday(datetime dt)
{
  datetime fr;
  if (TimeDayOfWeek(dt) == 0)
  {
    fr = dt - day_seconds * 2;
  }
  if (TimeDayOfWeek(dt) == 6)
  {
    fr = dt - day_seconds * 1;
  }

  return fr;
}

string strDay(int day)
{
  string dayName;
  switch (day)
  {
		case 0 : dayName = "Sunday"; break;
		case 1 : dayName = "Monday"; break;
		case 2 : dayName = "Tuesday"; break;
		case 3 : dayName = "Wednesday"; break;
		case 4 : dayName = "Thursday"; break;
		case 5 : dayName = "Friday"; break;
		case 6 : dayName = "Saturday"; break;
	}
    
		return dayName;
}


//+------------------------------------------------------------------+