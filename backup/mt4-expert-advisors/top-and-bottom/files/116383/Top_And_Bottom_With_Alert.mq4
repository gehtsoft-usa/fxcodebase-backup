
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65437

//+------------------------------------------------------------------+
//|                               Copyright � 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright � 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Frame=2;
extern bool       Sound_Alert                   = true;
extern bool       Email_Alert                   = false;

double Top[] , Bottom[] ;

int init()
{
 IndicatorShortName("Top_And_Bottom");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,2);
 SetIndexArrow(0,119);
 SetIndexBuffer(0,Top);
 SetIndexStyle(1,DRAW_ARROW,0,2);
 SetIndexArrow(1,119);
 SetIndexBuffer(1,Bottom);
 
 return(0);
}

int deinit()
{

 return(0);
}

bool IsTop(int index )
{
 int i;
 bool ItIs=true;
 
 
  for (i=1;i<=Frame;i++)
 {
 
      if (High[index-i+1]<=High[index-i] || High[index+i-1]<=High[index+i] )
	   { 
        ItIs=false;
       }
	  
 }
 
 return (ItIs);
}

bool IsBottom(int index )
{
 int i;
 bool ItIs=true;
 
 
 for (i=1;i<=Frame;i++)
 {
 
     if (Low[index-i+1]>=Low[index-i] || Low[index+i-1]>=Low[index+i] )
	   { 
        ItIs=false;
       }
   
 } 
 
 return (ItIs);
}

void DoAlert(const string side)
{
    string alert_Subject = side + " on " + Symbol() + "/" + Period();
    string alert_Body = side + " on " + Symbol() + "/" + Period();
    
    if (Sound_Alert)
        Alert(alert_Body);
    if (Email_Alert)
        SendMail(alert_Subject, alert_Body);
}

int start()
{
 if(Bars<=Frame) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 int Start_Point;
 
 pos=limit;
 
 while(pos>=0)
 {
    Start_Point= pos+Frame+1;

    if (IsTop(Start_Point ))
    {
        Top[Start_Point]=High[Start_Point];
        if (pos == 0)
            DoAlert("Top");
    }
    else
    {
        Top[Start_Point]=EMPTY_VALUE;
    }

    if (IsBottom(Start_Point ))
    {
        Bottom[Start_Point]=Low[Start_Point];
        if (pos == 0)
            DoAlert("Bottom");
    }
    else
    {
        Bottom[Start_Point]=EMPTY_VALUE;
    }

  
  pos--;
 } 
 return(0);
}

