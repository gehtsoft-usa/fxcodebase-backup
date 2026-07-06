// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68513

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

extern string suffix="";
extern ENUM_TIMEFRAMES timeframe = PERIOD_D1;
extern string reference_time = "000000"; // Time to compare
extern bool only_history=false;

int shift_seconds = 0;
int ParseTime(const string time, string &error)
{
   int hours;
   int minutes;
   int seconds;
   if (StringFind(time, ":") == -1)
   {
      //hh:mm:ss
      int time_parsed = (int)StringToInteger(time);
      seconds = time_parsed % 100;
      time_parsed /= 100;
      minutes = time_parsed % 100;
      time_parsed /= 100;
      hours = time_parsed % 100;
   }
   else
   {
      //hhmmss
      int time_parsed = (int)StringToInteger(time);
      hours = time_parsed % 100;
      
      time_parsed /= 100;
      minutes = time_parsed % 100;
      time_parsed /= 100;
      seconds = time_parsed % 100;
   }
   if (hours > 24)
   {
      error = "Incorrect number of hours in " + time;
      return -1;
   }
   if (minutes > 59)
   {
      error = "Incorrect number of minutes in " + time;
      return -1;
   }
   if (seconds > 59)
   {
      error = "Incorrect number of seconds in " + time;
      return -1;
   }
   if (hours == 24 && (minutes != 0 || seconds != 0))
   {
      error = "Incorrect date";
      return -1;
   }
   return (hours * 60 + minutes) * 60 + seconds;
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
   IndicatorName = GenerateIndicatorName("PairsPercentChange");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   string error;
   shift_seconds = ParseTime(reference_time, error);
   if (shift_seconds == -1)
   {
      Print("Incorrect time format: " + reference_time);
      return INIT_FAILED;
   }
   string text=Symbol();
   string substr=StringSubstr(text,6,1);

   displayAUD();
   displayCAD();
   displayCHF();
   displayEUR();
   displayGBP();
   displayJPY();
   displayNZD();
   displayUSD();
   displayAll();
   displayC07();
   displayCurrSum();
   DisplayTime();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   displayAUD();
   displayCAD();
   displayCHF();
   displayEUR();
   displayGBP();
   displayJPY();
   displayNZD();
   displayUSD();
   displayAll();
   displayC07();
   displayCurrSum();
   DisplayTime();
//----
   return(0);
  }
//+------------------------------------------------------------------+

void displayAUD()
  {
   Display("aud",20,20,20);
   ObjectSetText(IndicatorObjPrefix + "aud","AUD",20,"Verdana",Yellow);
   Display("audchange",90,35,20);
   ObjectSetText(IndicatorObjPrefix + "audchange","change",10,"Verdana",Yellow);
   Display("aud_change",160,35,20);
   ObjectSetText(IndicatorObjPrefix + "aud_change","%change",10,"Verdana",Yellow);

   string audlist[7]={"AUDCAD","AUDCHF","EURAUD","GBPAUD","AUDJPY","AUDNZD","AUDUSD"};

   double array[7][2];
   for(int a=0;a<7;a++)
     {
      array[a][0] = Percent_Change(audlist[a]);
      array[a][1] = a;
     }
   ArraySort(array,WHOLE_ARRAY,0,MODE_DESCEND);

   for(int i=0;i<7;i++)
     {
      int t=array[i][1];
      string ss=audlist[t];
      double change=Change(ss);
      color currencyclr=Green;
      if(change<0) currencyclr=Red;
      Display("aud_"+i+"",20,(i*15),80);
      ObjectSetText(IndicatorObjPrefix + "aud_"+i+"",ss,10,"Verdana",currencyclr);
      Display("aud_"+i+"change",90,(i*15),80);
      int digits=MarketInfo(ss+suffix,MODE_DIGITS);
      ObjectSetText(IndicatorObjPrefix + "aud_"+i+"change",DoubleToStr(change,1),10,"Verdana",currencyclr);
      Display("aud_"+i+"_change",160,(i*15),80);
      double percentChange=Percent_Change(ss);
      ObjectSetText(IndicatorObjPrefix + "aud_"+i+"_change",DoubleToStr(percentChange,2)+"%",10,"Verdana",currencyclr);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void displayCAD()
  {
   Display("cad",260,20,20);
   ObjectSetText(IndicatorObjPrefix + "cad","CAD",20,"Verdana",Yellow);
   Display("cadchange",330,35,20);
   ObjectSetText(IndicatorObjPrefix + "cadchange","change",10,"Verdana",Yellow);
   Display("cad_change",400,35,20);
   ObjectSetText(IndicatorObjPrefix + "cad_change","%change",10,"Verdana",Yellow);

   string cadlist[7]={"CADJPY","CADCHF","AUDCAD","NZDCAD","USDCAD","GBPCAD","EURCAD"};

   double array[7][2];
   for(int a=0;a<7;a++)
     {
      array[a][0] = Percent_Change(cadlist[a]);
      array[a][1] = a;
     }
   ArraySort(array,WHOLE_ARRAY,0,MODE_DESCEND);

   for(int i=0;i<7;i++)
     {
      int t=array[i][1];
      string ss=cadlist[t];
      double change=Change(ss);
      color currencyclr=Green;
      if(change<0) currencyclr=Red;
      Display("cad_"+i+"",260,(i*15),80);
      ObjectSetText(IndicatorObjPrefix + "cad_"+i+"",ss,10,"Verdana",currencyclr);
      Display("cad_"+i+"change",330,(i*15),80);
      int digits=MarketInfo(ss+suffix,MODE_DIGITS);
      ObjectSetText(IndicatorObjPrefix + "cad_"+i+"change",DoubleToStr(change,1),10,"Verdana",currencyclr);
      Display("cad_"+i+"_change",400,(i*15),80);
      double percentChange=Percent_Change(ss);
      ObjectSetText(IndicatorObjPrefix + "cad_"+i+"_change",DoubleToStr(percentChange,2)+"%",10,"Verdana",currencyclr);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void displayCHF()
  {
   Display("chf",500,20,20);
   ObjectSetText(IndicatorObjPrefix + "chf","CHF",20,"Verdana",Yellow);
   Display("chfchange",570,35,20);
   ObjectSetText(IndicatorObjPrefix + "chfchange","change",10,"Verdana",Yellow);
   Display("chf_change",640,35,20);
   ObjectSetText(IndicatorObjPrefix + "chf_change","%change",10,"Verdana",Yellow);

   string chflist[7]={"AUDCHF","CADCHF","GBPCHF","NZDCHF","USDCHF","EURCHF","CHFJPY"};

   double array[7][2];
   for(int a=0;a<7;a++)
     {
      array[a][0] = Percent_Change(chflist[a]);
      array[a][1] = a;
     }
   ArraySort(array,WHOLE_ARRAY,0,MODE_DESCEND);

   for(int i=0;i<7;i++)
     {
      int t=array[i][1];
      string ss=chflist[t];
      double change=Change(ss);
      color currencyclr=Green;
      if(change<0) currencyclr=Red;
      Display("chf_"+i+"",500,(i*15),80);
      ObjectSetText(IndicatorObjPrefix + "chf_"+i+"",ss,10,"Verdana",currencyclr);
      Display("chf_"+i+"change",570,(i*15),80);
      int digits=MarketInfo(ss+suffix,MODE_DIGITS);
      ObjectSetText(IndicatorObjPrefix + "chf_"+i+"change",DoubleToStr(change,1),10,"Verdana",currencyclr);
      Display("chf_"+i+"_change",640,(i*15),80);
      double percentChange=Percent_Change(ss);
      ObjectSetText(IndicatorObjPrefix + "chf_"+i+"_change",DoubleToStr(percentChange,2)+"%",10,"Verdana",currencyclr);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void displayEUR()
  {
   Display("eur",20,180,20);
   ObjectSetText(IndicatorObjPrefix + "eur","EUR",20,"Verdana",Yellow);
   Display("eurchange",90,195,20);
   ObjectSetText(IndicatorObjPrefix + "eurchange","change",10,"Verdana",Yellow);
   Display("eur_change",150,195,20);
   ObjectSetText(IndicatorObjPrefix + "eur_change","%change",10,"Verdana",Yellow);

   string eurlist[7]={"EURAUD","EURNZD","EURCAD","EURUSD","EURGBP","EURCHF","EURJPY"};

   double array[7][2];
   for(int a=0;a<7;a++)
     {
      array[a][0] = Percent_Change(eurlist[a]);
      array[a][1] = a;
     }
   ArraySort(array,WHOLE_ARRAY,0,MODE_DESCEND);

   for(int i=0;i<7;i++)
     {
      int t=array[i][1];
      string ss=eurlist[t];
      double change=Change(ss);
      color currencyclr=Green;
      if(change<0) currencyclr=Red;
      Display("eur_"+i+"",20,(i*15),240);
      ObjectSetText(IndicatorObjPrefix + "eur_"+i+"",ss,10,"Verdana",currencyclr);
      Display("eur_"+i+"change",90,(i*15),240);
      int digits=MarketInfo(ss+suffix,MODE_DIGITS);
      ObjectSetText(IndicatorObjPrefix + "eur_"+i+"change",DoubleToStr(change,1),10,"Verdana",currencyclr);
      Display("eur_"+i+"_change",160,(i*15),240);
      double percentChange=Percent_Change(ss);
      ObjectSetText(IndicatorObjPrefix + "eur_"+i+"_change",DoubleToStr(percentChange,2)+"%",10,"Verdana",currencyclr);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void displayGBP()
  {
   Display("gbp",260,180,20);
   ObjectSetText(IndicatorObjPrefix + "gbp","GBP",20,"Verdana",Yellow);
   Display("gbpchange",330,195,20);
   ObjectSetText(IndicatorObjPrefix + "gbpchange","change",10,"Verdana",Yellow);
   Display("gbp_change",400,195,20);
   ObjectSetText(IndicatorObjPrefix + "gbp_change","%change",10,"Verdana",Yellow);

   string gbplist[7]={"EURGBP","GBPAUD","GBPCAD","GBPUSD","GBPCHF","GBPJPY","GBPNZD"};

   double array[7][2];
   for(int a=0;a<7;a++)
     {
      array[a][0] = Percent_Change(gbplist[a]);
      array[a][1] = a;
     }
   ArraySort(array,WHOLE_ARRAY,0,MODE_DESCEND);

   for(int i=0;i<7;i++)
     {
      int t=array[i][1];
      string ss=gbplist[t];
      double change=Change(ss);
      color currencyclr=Green;
      if(change<0) currencyclr=Red;
      Display("gbp_"+i+"",260,(i*15),240);
      ObjectSetText(IndicatorObjPrefix + "gbp_"+i+"",ss,10,"Verdana",currencyclr);
      Display("gbp_"+i+"change",330,(i*15),240);
      int digits=MarketInfo(ss+suffix,MODE_DIGITS);
      ObjectSetText(IndicatorObjPrefix + "gbp_"+i+"change",DoubleToStr(change,1),10,"Verdana",currencyclr);
      Display("gbp_"+i+"_change",400,(i*15),240);
      double percentChange=Percent_Change(ss);
      ObjectSetText(IndicatorObjPrefix + "gbp_"+i+"_change",DoubleToStr(percentChange,2)+"%",10,"Verdana",currencyclr);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void displayJPY()
  {
   Display("jpy",500,180,20);
   ObjectSetText(IndicatorObjPrefix + "jpy","JPY",20,"Verdana",Yellow);
   Display("jpychange",570,195,20);
   ObjectSetText(IndicatorObjPrefix + "jpychange","change",10,"Verdana",Yellow);
   Display("jpy_change",640,195,20);
   ObjectSetText(IndicatorObjPrefix + "jpy_change","%change",10,"Verdana",Yellow);

   string jpylist[7]={"AUDJPY","GBPJPY","CADJPY","USDJPY","NZDJPY","CHFJPY","EURJPY"};

   double array[7][2];
   for(int a=0;a<7;a++)
     {
      array[a][0] = Percent_Change(jpylist[a]);
      array[a][1] = a;
     }
   ArraySort(array,WHOLE_ARRAY,0,MODE_DESCEND);

   for(int i=0;i<7;i++)
     {
      int t=array[i][1];
      string ss=jpylist[t];
      double change=Change(ss);
      color currencyclr=Green;
      if(change<0) currencyclr=Red;
      Display("jpy_"+i+"",500,(i*15),240);
      ObjectSetText(IndicatorObjPrefix + "jpy_"+i+"",ss,10,"Verdana",currencyclr);
      Display("jpy_"+i+"change",570,(i*15),240);
      int digits=MarketInfo(ss+suffix,MODE_DIGITS);
      ObjectSetText(IndicatorObjPrefix + "jpy_"+i+"change",DoubleToStr(change,1),10,"Verdana",currencyclr);
      Display("jpy_"+i+"_change",640,(i*15),240);
      double percentChange=Percent_Change(ss);
      ObjectSetText(IndicatorObjPrefix + "jpy_"+i+"_change",DoubleToStr(percentChange,2)+"%",10,"Verdana",currencyclr);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void displayNZD()
  {
   Display("nzd",20,340,20);
   ObjectSetText(IndicatorObjPrefix + "nzd","NZD",20,"Verdana",Yellow);
   Display("nzdchange",90,355,20);
   ObjectSetText(IndicatorObjPrefix + "nzdchange","change",10,"Verdana",Yellow);
   Display("nzd_change",150,355,20);
   ObjectSetText(IndicatorObjPrefix + "nzd_change","%change",10,"Verdana",Yellow);

   string nzdlist[7]={"AUDNZD","EURNZD","GBPNZD","NZDCAD","NZDUSD","NZDCHF","NZDJPY"};

   double array[7][2];
   for(int a=0;a<7;a++)
     {
      array[a][0] = Percent_Change(nzdlist[a]);
      array[a][1] = a;
     }
   ArraySort(array,WHOLE_ARRAY,0,MODE_DESCEND);

   for(int i=0;i<7;i++)
     {
      int t=array[i][1];
      string ss=nzdlist[t];
      double change=Change(ss);
      color currencyclr=Green;
      if(change<0) currencyclr=Red;
      Display("nzd_"+i+"",20,(i*15),400);
      ObjectSetText(IndicatorObjPrefix + "nzd_"+i+"",ss,10,"Verdana",currencyclr);
      Display("nzd_"+i+"change",90,(i*15),400);
      int digits=MarketInfo(ss+suffix,MODE_DIGITS);
      ObjectSetText(IndicatorObjPrefix + "nzd_"+i+"change",DoubleToStr(change,1),10,"Verdana",currencyclr);
      Display("nzd_"+i+"_change",160,(i*15),400);
      double percentChange=Percent_Change(ss);
      ObjectSetText(IndicatorObjPrefix + "nzd_"+i+"_change",DoubleToStr(percentChange,2)+"%",10,"Verdana",currencyclr);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void displayUSD()
  {
   Display("usd",260,340,20);
   ObjectSetText(IndicatorObjPrefix + "usd","USD",20,"Verdana",Yellow);
   Display("usdchange",330,355,20);
   ObjectSetText(IndicatorObjPrefix + "usdchange","change",10,"Verdana",Yellow);
   Display("usd_change",400,355,20);
   ObjectSetText(IndicatorObjPrefix + "usd_change","%change",10,"Verdana",Yellow);

   string usdlist[7]={"USDCHF","USDCAD","USDJPY","AUDUSD","NZDUSD","GBPUSD","EURUSD"};

   double array[7][2];
   for(int a=0;a<7;a++)
     {
      array[a][0] = Percent_Change(usdlist[a]);
      array[a][1] = a;
     }
   ArraySort(array,WHOLE_ARRAY,0,MODE_DESCEND);

   for(int i=0;i<7;i++)
     {
      int t=array[i][1];
      string ss=usdlist[t];
      double change=Change(ss);
      color currencyclr=Green;
      if(change<0) currencyclr=Red;
      Display("usd_"+i+"",260,(i*15),400);
      ObjectSetText(IndicatorObjPrefix + "usd_"+i+"",ss,10,"Verdana",currencyclr);
      Display("usd_"+i+"change",330,(i*15),400);
      int digits=MarketInfo(ss+suffix,MODE_DIGITS);
      ObjectSetText(IndicatorObjPrefix + "usd_"+i+"change",DoubleToStr(change,1),10,"Verdana",currencyclr);
      Display("usd_"+i+"_change",400,(i*15),400);
      double percentChange=Percent_Change(ss);
      ObjectSetText(IndicatorObjPrefix + "usd_"+i+"_change",DoubleToStr(percentChange,2)+"%",10,"Verdana",currencyclr);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void displayAll()
  {
   Display("all",740,20,20);
   ObjectSetText(IndicatorObjPrefix + "all","ALL",20,"Verdana",Yellow);
   Display("allchange",810,35,20);
   ObjectSetText(IndicatorObjPrefix + "allchange","change",10,"Verdana",Yellow);
   Display("all_change",880,35,20);
   ObjectSetText(IndicatorObjPrefix + "all_change","%change",10,"Verdana",Yellow);

   string alllist[28]=
     {
      "GBPNZD","EURNZD","GBPAUD","GBPCAD","GBPJPY","GBPCHF","CADJPY","EURCAD","EURAUD",
      "USDCHF","GBPUSD","EURJPY","NZDJPY","AUDCHF","AUDJPY","USDJPY","EURUSD","NZDCHF",
      "CADCHF","AUDNZD","NZDUSD","CHFJPY","AUDCAD","USDCAD","NZDCAD","AUDUSD","EURCHF","EURGBP"
     };

   double array[28][2];
   for(int a=0;a<28;a++)
     {
      array[a][0] = Percent_Change(alllist[a]);
      array[a][1] = a;
     }
   ArraySort(array,WHOLE_ARRAY,0,MODE_DESCEND);

   for(int i=0;i<28;i++)
     {
      int t=array[i][1];
      string ss=alllist[t];
      double change=Change(ss);
      color currencyclr=Green;
      if(change<0) currencyclr=Red;
      Display("all_"+i+"",740,(i*15),80);
      ObjectSetText(IndicatorObjPrefix + "all_"+i+"",ss,10,"Verdana",currencyclr);
      Display("all_"+i+"change",810,(i*15),80);
      int digits=MarketInfo(ss+suffix,MODE_DIGITS);
      ObjectSetText(IndicatorObjPrefix + "all_"+i+"change",DoubleToStr(change,1),10,"Verdana",currencyclr);
      Display("all_"+i+"_change",880,(i*15),80);
      double percentChange=Percent_Change(ss);
      ObjectSetText(IndicatorObjPrefix + "all_"+i+"_change",DoubleToStr(percentChange,2)+"%",10,"Verdana",currencyclr);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void displayC07()
  {
   Display("c07",980,20,20);
   ObjectSetText(IndicatorObjPrefix + "c07","C07",20,"Verdana",Yellow);
   Display("c07change",1050,35,20);
   ObjectSetText(IndicatorObjPrefix + "c07change","change",10,"Verdana",Yellow);
   Display("c07_change",1120,35,20);
   ObjectSetText(IndicatorObjPrefix + "c07_change","%change",10,"Verdana",Yellow);

   string c07list[07]={"USDCHF","NZDUSD","GBPUSD","EURUSD","USDJPY","AUDUSD","USDCAD"};

   double array[07][2];
   for(int a=0;a<07;a++)
     {
      array[a][0] = Percent_Change(c07list[a]);
      array[a][1] = a;
     }
   ArraySort(array,WHOLE_ARRAY,0,MODE_DESCEND);

   for(int i=0;i<07;i++)
     {
      int t=array[i][1];
      string ss=c07list[t];
      double change=Change(ss);
      color currencyclr=Green;
      if(change<0) currencyclr=Red;
      Display("c07_"+i+"",980,(i*15),80);
      ObjectSetText(IndicatorObjPrefix + "c07_"+i+"",ss,10,"Verdana",currencyclr);

      if(ss=="EURJPY" || ss=="GBPJPY" || ss=="NZDUSD" || ss=="GBPUSD" || ss=="AUDJPY")
        {
         Display("graph"+ss,1035,(i*15),80);
         ObjectSetText(IndicatorObjPrefix + "graph"+ss,CharToStr(119),12,"Wingdings",currencyclr);
        }
      Display("c07_"+i+"change",1050,(i*15),80);
      int digits=MarketInfo(ss+suffix,MODE_DIGITS);
      ObjectSetText(IndicatorObjPrefix + "c07_"+i+"change",DoubleToStr(change,1),10,"Verdana",currencyclr);
      Display("c07_"+i+"_change",1120,(i*15),80);
      double percentChange=Percent_Change(ss);
      ObjectSetText(IndicatorObjPrefix + "c07_"+i+"_change",DoubleToStr(percentChange,2)+"%",10,"Verdana",currencyclr);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void displayCurrSum()
  {
   Display("currtitle",500,340,20);
   ObjectSetText(IndicatorObjPrefix + "currtitle","MoneyFlow",20,"Verdana",Yellow);
   Display("currname",500,372,20);
   ObjectSetText(IndicatorObjPrefix + "currname","CUR",10,"Verdana",Yellow);
   Display("currchange",570,372,20);
   ObjectSetText(IndicatorObjPrefix + "currchange","change",10,"Verdana",Yellow);
   Display("avgchange",640,372,20);
   ObjectSetText(IndicatorObjPrefix + "avgchange","avg",10,"Verdana",Yellow);

   string currlist[8]={"AUD","CAD","CHF","EUR","GBP","JPY","NZD","USD"};

   double array[8][2];
   for(int a=0;a<8;a++)
     {
      array[a][0] = ChangeCurrency(currlist[a]);
      array[a][1] = a;
     }
   ArraySort(array,WHOLE_ARRAY,0,MODE_DESCEND);

   for(int i=0;i<8;i++)
     {
      int t=array[i][1];
      string ss=currlist[t];
      double change=ChangeCurrency(ss);
      double avgchange=change/7;
      color currencyclr=Green;
      if(change<0) currencyclr=Red;
      Display("curr_"+i+"",500,(i*15),410);
      ObjectSetText(IndicatorObjPrefix + "curr_"+i+"",ss,10,"Verdana",currencyclr);
      Display("curr_"+i+"change",570,(i*15),410);
      int digits=MarketInfo(ss+suffix,MODE_DIGITS);
      ObjectSetText(IndicatorObjPrefix + "curr_"+i+"change",DoubleToStr(change,0),10,"Verdana",currencyclr);
      Display("curr_"+i+"avg",640,(i*15),410);
      ObjectSetText(IndicatorObjPrefix + "curr_"+i+"avg",DoubleToStr(avgchange,0),10,"Verdana",currencyclr);
   }
}
  
void DisplayTime()
{
   Display("time",1000,200,20);
   string timestr="";
   switch(timeframe)
   {
      case 1:
         timestr="M1";
         break;
      case 5:
         timestr="M5";
         break;
      case 15:
         timestr="M15";
         break;
      case 30:
         timestr="M30";
         break;
      case 60:
         timestr="H1";
         break;
      case 240:
         timestr="H4";
         break;
      case 1440:
         timestr="Daily";
         break;
      case 10080:
         timestr="Weekly";
         break;
      case 43200:
         timestr="Month";
         break;
      default:
         timestr="Daily";
         break;
   }
   ObjectSetText(IndicatorObjPrefix + "time",timestr,30,"Verdana",Yellow);
   Display("his_text",1000,270,20);
   string his_text="";
   if(only_history) 
      his_text="(history data)";
   ObjectSetText(IndicatorObjPrefix + "his_text",his_text,10,"Verdana",Red);
   Display("opentime",1000,250,20);
   string time="";

   int period = GetTimeShift(Symbol(), timeframe);
   datetime itime = iTime(Symbol(), timeframe, period);
   time=TimeYear(itime)+"-"+TimeMonth(itime)+"-"+TimeDay(itime)+" "+TimeHour(itime)+":"+TimeMinute(itime)+":"+TimeSeconds(itime);
   ObjectSetText(IndicatorObjPrefix + "opentime",time,10,"Verdana",Yellow);
}

datetime GetTimeShift(string symbol, int timeframe)
{
   datetime currentTime = iTime(symbol, timeframe, 0);
   datetime ref_time = MathFloor(currentTime / 86400) * 86400 + shift_seconds;
   if (ref_time >= currentTime)
      ref_time -= 86400;
   return iBarShift(symbol, timeframe, ref_time, false);
}

void Display(string name,int x,int y,int relative_YDISTANCE)
{
   ObjectDelete(IndicatorObjPrefix + name);
   ObjectCreate(IndicatorObjPrefix + name,OBJ_LABEL,0,0,0);
   ObjectSet(IndicatorObjPrefix + name,OBJPROP_CORNER,0);
   ObjectSet(IndicatorObjPrefix + name,OBJPROP_XDISTANCE,x);
   ObjectSet(IndicatorObjPrefix + name,OBJPROP_YDISTANCE,y+relative_YDISTANCE);
   ObjectSet(IndicatorObjPrefix + name,OBJPROP_BACK,FALSE);
}

double ChangeCurrency(string currency)
{
   double sumpips = 0;
   if (currency == "AUD") 
      sumpips = Change("AUDCAD") + Change("AUDCHF") + Change("AUDJPY") + Change("AUDNZD") + Change("AUDUSD") - Change("EURAUD") - Change("GBPAUD");
   else if (currency == "CAD") 
      sumpips = Change("CADCHF") + Change("CADJPY") - Change("AUDCAD") - Change("EURCAD") - Change("GBPCAD") - Change("NZDCAD") - Change("USDCAD");
   else if (currency == "CHF") 
      sumpips = Change("CHFJPY") - Change("AUDCHF") - Change("CADCHF") - Change("EURCHF") - Change("GBPCHF") - Change("NZDCHF") - Change("USDCHF");
   else if (currency == "EUR") 
      sumpips = Change("EURAUD") + Change("EURCAD") + Change("EURCHF") + Change("EURGBP") + Change("EURJPY") + Change("EURNZD") + Change("EURUSD");
   else if (currency == "GBP") 
      sumpips = Change("GBPAUD") + Change("GBPCAD") + Change("GBPCHF") + Change("GBPJPY") + Change("GBPNZD") + Change("GBPUSD") - Change("EURGBP");
   else if (currency == "JPY") 
      sumpips = -1*Change("AUDJPY") - Change("CADJPY") - Change("CHFJPY") - Change("EURJPY") - Change("GBPJPY") - Change("NZDJPY") - Change("USDJPY");
   else if (currency == "NZD") 
      sumpips = Change("NZDCAD") + Change("NZDCHF") + Change("NZDJPY") + Change("NZDUSD") - Change("AUDNZD") - Change("EURNZD") - Change("GBPNZD");
   else if (currency == "USD") 
      sumpips = Change("USDCAD") + Change("USDCHF") + Change("USDJPY") - Change("AUDUSD") - Change("EURUSD") - Change("GBPUSD") - Change("NZDUSD");
   return NormalizeDouble(sumpips,1);
}
  
double Change(string symbol)
{
   double pnt = MarketInfo(symbol,MODE_POINT);
   double dig = MarketInfo(symbol,MODE_DIGITS);
   if (dig == 3 || dig == 5)
      pnt *= 10;

   int shift = GetTimeShift(symbol, timeframe);
   double open = iOpen(symbol,timeframe,shift);
   double bid = MarketInfo(symbol,MODE_BID);
   if(only_history)
   {
      double close=iClose(symbol+suffix,timeframe,shift);
      return NormalizeDouble((close-open)/pnt,1);
   }
   return NormalizeDouble((bid-open)/pnt,1);
}

double Percent_Change(string symbol)
{
   double pnt = MarketInfo(symbol,MODE_POINT);
   double dig = MarketInfo(symbol,MODE_DIGITS);
   if (dig == 3 || dig == 5) {
     pnt *= 10;
   }
   int shift = GetTimeShift(symbol, timeframe);
   double change=Change(symbol+suffix);
   double open=iOpen(symbol+suffix,timeframe,shift);
   return change/open*100*pnt;
}

