// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&p=145263
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
//|                                                                       https://mario-jemic.com/ |
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
  #property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
input string           InpName="Button";            // Button name
// input string           InpName2="Buttonss";            // Button name
 ENUM_BASE_CORNER InpCorner=CORNER_LEFT_UPPER; // Chart corner for anchoring
input string           InpFont="Arial";             // Font
input int              InpFontSize=14;              // Font size
input color            InpColor=clrBlack;           // Text color
input color            InpBackColor=C'236,233,216'; // Background color
input color            InpBorderColor=clrNONE;      // Border color
input bool             InpState=false;              // Pressed/Released
input bool             InpBack=false;               // Background object
input bool             InpSelection=false;          // Highlight to move
input bool             InpHidden=true;              // Hidden in the object list
input long             InpZOrder=1;                 // Priority for mouse click
 bool DynamicFiboFlag=true;                          // DynamicFibo display flag 
 color DynamicFibo_color=Blue;                       // DynamicFibo color
 ENUM_LINE_STYLE DynamicFibo_style=STYLE_DASHDOTDOT; // DynamicFibo style
 int DynamicFibo_width=1;                            // DynamicFibo line width
 bool DynamicFibo_AsRay=true;                        // DynamicFibo ray


input double LEVEL_1 = 0.236; // Level 1
input color LevelColor1 = clrRed; // Level 1 color
input int LevelWidth1 = 1; // Level 1 width
input ENUM_LINE_STYLE LevelStyle1 = STYLE_SOLID; // Level 1 style
input double LEVEL_2 = 0.382; // Level 2
input color LevelColor2 = clrGreen; // Level 2 color
input int LevelWidth2 = 1; // Level 2 width
input ENUM_LINE_STYLE LevelStyle2 = STYLE_SOLID; // Level 2 style
input double LEVEL_3 = 0.500; // Level 3
input color LevelColor3 = Blue; // Level 3 color
input int LevelWidth3 = 1; // Level 3 width
input ENUM_LINE_STYLE LevelStyle3 = STYLE_SOLID; // Level 3 style
input double LEVEL_4 = 0.618; // Level 4
input color LevelColor4 = Yellow; // Level 4 color
input int LevelWidth4 = 1; // Level 4 width
input ENUM_LINE_STYLE LevelStyle4 = STYLE_SOLID; // Level 4 style
input double LEVEL_5 = 0.762; // Level 5
input color LevelColor5 = Lime; // Level 5 color
input int LevelWidth5 = 1; // Level 5 width
input ENUM_LINE_STYLE LevelStyle5 = STYLE_SOLID; // Level 5 style
int  count_data   =   0  ;
input  bool    delete_previous_fibo        =   false;   //  Delete  Previous  Fibo

int OnInit()
  {    
long x_distance = 100;
long y_distance  =100;
int x_step=(int)x_distance/32;
int y_step=(int)y_distance/32;
int x=(int)x_distance/32;
int y=(int)y_distance/32;
int x_size=(int)x_distance*15/16;
int y_size=(int)y_distance*15/16;
ButtonCreate(0,InpName,0,x,y,x_size,y_size,InpCorner,"Add  Fibo",InpFont,InpFontSize,
InpColor,InpBackColor,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder);
   return(INIT_SUCCEEDED);
  }

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
   return(rates_total);
  }
//+------------------------------------------------------------------+







  bool ButtonCreate2(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text="SELLING",            // text
                  const string            font="Arial",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=true,              // hidden in the object list
                  const long              z_order=1)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create the button
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x*40);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y*1);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,100);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,50);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,0);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }



bool ButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text="BUYING",            // text
                  const string            font="Arial",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=true,              // hidden in the object list
                  const long              z_order=1)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create the button
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,0);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }



void OnDeinit(const int reason)
  {

   EventKillTimer();
   ObjectDelete(    0 ,    "Button");
   ObjectDelete(0 ,"Buttonss");
for(int i=ObjectsTotal(ChartID(),0,-1)-1;i>=0;i--){
  string output[];
  StringSplit(ObjectName(0,i), StringGetCharacter("_", 0) ,output );
  if(ArraySize(output)  == 2) {

  if    (    output[0]   == "Dynamic")  {
 
    ObjectDelete(    0 ,   ObjectName(0,i)     );


  }
  }
}


  }





 void  OnChartEvent(const  int id,
 const  long& lparam,
 const  double& dparam,
 const string& sparam  ){
 string ClickDesc=ObjectGetString(0,sparam,OBJPROP_TEXT);  
ObjectSetInteger(0,InpName,OBJPROP_STATE,false);
if (  ClickDesc    ==       "Add  Fibo")  {
   if  (  delete_previous_fibo     ==   false)  {


count_data   =  count_data   +1;





   } 


     if   (  delete_previous_fibo       == true)   {
      ObjectDelete(    0 ,   "Dynamic_Fibo"+  count_data  ) ;
for(int i=ObjectsTotal(ChartID(),0,-1)-1;i>=0;i--){
  string output[];
  StringSplit(ObjectName(0,i), StringGetCharacter("_", 0) ,output );
  if(ArraySize(output)  == 2) {
  if    (    output[0]   == "Dynamic")  {
    ObjectDelete(    0 ,   ObjectName(0,i)     );
  }
  }
}



     }  
   SetFibo(0,"Dynamic_Fibo"+  count_data,0,  iTime(  Symbol()    ,  PERIOD_CURRENT ,     10)  ,iClose(   Symbol()  ,  PERIOD_CURRENT ,  10), iTime( Symbol()   ,  PERIOD_CURRENT   ,   0),iClose(Symbol()   , PERIOD_CURRENT ,  0),
                 DynamicFibo_color,DynamicFibo_style,DynamicFibo_width,DynamicFibo_AsRay,"Dynamic_Fibo");


}












}







void CreateFibo(long     chart_id, // chart ID
                string   name,     // object name
                int      nwin,     // window index
                datetime time1,    // price level time 1
                double   price1,   // price level 1
                datetime time2,    // price level time 2
                double   price2,   // price level 2
                color    Color,    // line color
                int      style,    // line style
                int      width,    // line width
                int      ray,      // ray direction: -1 - to the left, +1 - to the right, other values - no ray
                string   text)     // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_FIBO,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);

   if(ray>0)ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
   if(ray<0)ObjectSetInteger(chart_id,name,OBJPROP_RAY_LEFT,true);

   if(ray==0)
     {
      ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,false);
      ObjectSetInteger(chart_id,name,OBJPROP_RAY_LEFT,false);
     }

   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);



     double   values[]   =    {  LEVEL_1,    LEVEL_2  ,  LEVEL_3  ,    LEVEL_4  ,  LEVEL_5  };
     color    clrData[]    =   {LevelColor1  ,  LevelColor2    , LevelColor3 ,  LevelColor4 ,  LevelColor5}  ; 
     string    levelData[]    =   {  LevelWidth1  ,  LevelWidth2 ,   LevelColor3   ,  LevelWidth4 , LevelWidth5};
     int  styleData[]     =    {LevelStyle1  , LevelStyle2 ,  LevelStyle3 ,  LevelStyle4  , LevelStyle5};
     
      ObjectSetInteger(chart_id,name,OBJPROP_LEVELS,5);
//--- set the properties of levels in the loop
   for(int i=0;i< ArraySize(values);i++)
     {
      
      //--- level value
      ObjectSetDouble(chart_id,name,OBJPROP_LEVELVALUE,i,values[i]);
      //--- level color
      ObjectSetInteger(chart_id,name,OBJPROP_LEVELCOLOR,i,clrData[i]);
      //--- level style
      ObjectSetInteger(chart_id,name,OBJPROP_LEVELSTYLE,i,styleData[i]);
      //--- level width
      ObjectSetInteger(chart_id,name,OBJPROP_LEVELWIDTH,i,levelData[i]);
      //--- level description
      ObjectSetString(chart_id,name,OBJPROP_LEVELTEXT,i,DoubleToString(100*values[i],1));
     }


  }


  void SetFibo(long     chart_id, // chart ID
             string   name,     // object name
             int      nwin,     // window index
             datetime time1,    // price level time 1
             double   price1,   // price level 1
             datetime time2,    // price level time 2
             double   price2,   // price level 2
             color    Color,    // line color
             int      style,    // line style
             int      width,    // line width
             int      ray,      // ray direction: -1 - to the left, 0 - no ray, +1 - to the right
             string   text)     // text
  {
   if(ObjectFind(chart_id,name)==-1) CreateFibo(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,ray,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
     }
  }