// Id: 23348
// More information about this indicator can be found at:
// http://fxcodebase.com/

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
#property version   "1.1"
#property strict

#property indicator_chart_window

#property indicator_buffers 1
#property indicator_color1 Red

extern int Length=10;
extern int Type=0;   // 0 - Close, 1 - High/Low

extern bool AlertMessage=true;
extern bool SoundAlert=true;
extern bool EmailAlert=false;

double TrendStop[];
datetime LastSignalTime;

int init()
  {
   IndicatorShortName("Trend stop");
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TrendStop);
   
   LastSignalTime=0;

   return(0);
  }

int deinit()
  {

   return(0);
  }
  
string GetSoundFileName()
{
 string Str=Symbol()+".wav";
 
 return (Str);
}  

void Signal(string M)
{
   M = _Symbol + " " + M;
 if (Time[0]!=LastSignalTime)
 {
  LastSignalTime=Time[0];
  if (AlertMessage)
  {
   Alert("Trend stop: "+M);
  }
  if (SoundAlert)
  {
   PlaySound(GetSoundFileName());
  }
  if (EmailAlert)
  {
   SendMail("Message from Trend Stop", M);
  } 
 }
 
 return;
}

int start()
  {
   bool Trend;
   double Stop, Min_, Max_;
   if(Bars<=Length) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int    limit=Bars-Length-1;
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars;
   int pos=limit;
   while(pos>=0)
   {
    double min=iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, Length+1, pos));
    double max=iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, Length+1, pos));
    bool Flag=false;
    if (Type==0)
    {
     if (pos==Bars-2)
     {
      if (Close[pos]>Close[pos+Length])
      {
       Trend=true;
       Stop=min;
       Min_=min;
       Max_=max;
      }
      else
      {
       Trend=false;
       Stop=max;
       Min_=min;
       Max_=max;
      } 
      TrendStop[pos]=Stop;
     }
     else
     {
      if (Close[pos]>TrendStop[pos+1] && !Trend)
      {
       Min_=min;
       Max_=max;
       Trend=true;
       Stop=Min_;
       Flag=true;
       if (pos==0)
       {
        Signal("Up signal");
       }
      }
      else
      {
       if (Close[pos]<TrendStop[pos+1] && Trend)
       {
        Min_=min;
        Max_=max;
        Trend=false;
        Stop=Max_;
        Flag=true;
        if (pos==0)
        {
         Signal("Dn signal");
        }
       }
       else
       {
        if (Trend)
        {
         Stop=min;
        }
        else
        {
         Stop=max;
        }
       }
      }
     }
    }
    else
    {
     if (pos==Bars-2)
     {
      if (Close[pos]>Close[pos+Length])
      {
       Trend=true;
       Stop=min;
       Min_=min;
       Max_=max;
      }
      else
      {
       Trend=false;
       Stop=max;
       Min_=min;
       Max_=max;
      } 
      TrendStop[pos]=Stop;
     }
     else
     {
      if (High[pos]>TrendStop[pos+1] && !Trend)
      {
       Min_=min;
       Max_=max;
       Trend=true;
       Stop=Min_;
       Flag=true;
       if (pos==0)
       {
        Signal("Up signal");
       }
      }
      else
      {
       if (Low[pos]<TrendStop[pos+1] && Trend)
       {
        Min_=min;
        Max_=max;
        Trend=false;
        Stop=Max_;
        Flag=true;
        if (pos==0)
        {
         Signal("Dn signal");
        }
       }
       else
       {
        if (Trend)
        {
         Stop=min;
        }
        else
        {
         Stop=max;
        }
       }
      }
     }
    }
    
    if (Trend && Stop>TrendStop[pos+1] && !Flag)
    {
     TrendStop[pos]=Stop;
    }
    else
    {
     if (!Trend && Stop<TrendStop[pos+1] && !Flag)
     {
      TrendStop[pos]=Stop;
     }
     else
     {
      if (Stop>TrendStop[pos+1] && Flag)
      {
       TrendStop[pos]=Stop;
      }
      else
      {
       if (Stop<TrendStop[pos+1] && Flag)
       {
        TrendStop[pos]=Stop;
       }
       else
       {
        TrendStop[pos]=TrendStop[pos+1];
       }
      }
     }
    }
    
    pos--;
   } 

   return(0);
  }

