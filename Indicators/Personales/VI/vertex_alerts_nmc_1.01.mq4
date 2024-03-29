//  Vertex.mq4 ������ 0.1� 

#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_minimum 0

#property indicator_color1 Gray
#property indicator_width1 1

#property indicator_color2 Red
#property indicator_width2 2

#property indicator_color3 DodgerBlue
#property indicator_width3 2

extern int TrendPeriod = 20;
extern int ForcePeriod = 60;    // ��� �������� � TD&FI ������������� ForcePeriod = 3 * TrendPeriod

extern double LineValue = 0.25;
extern double VerticalShift = 0;
extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = true;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = true;
extern bool   alertsEmail     = false;
extern bool   alertsNotificaton = false;
extern string soundfile       = "alert2.wav";

double line[];
double pos_values[];
double neg_values[];

double values[];
double ema[];
double dema[];
double force[];
double trend[];

int init() {
  IndicatorBuffers(8);
  
  SetIndexStyle(0, DRAW_LINE);      SetIndexBuffer(0, line);
  SetIndexStyle(1, DRAW_HISTOGRAM); SetIndexBuffer(1, pos_values); SetIndexEmptyValue(1,VerticalShift);
  SetIndexStyle(2, DRAW_HISTOGRAM); SetIndexBuffer(2, neg_values); SetIndexEmptyValue(2,VerticalShift);
  
  SetIndexBuffer(3, values);
  SetIndexBuffer(4, ema);
  SetIndexBuffer(5, dema);
  SetIndexBuffer(6, force);
  SetIndexBuffer(7, trend);

  return(0);
}

int deinit() {

  return(0);
}

int start() {
  int idx;
  int counted = IndicatorCounted();
  if (counted < 0) return (-1);
  if (counted > 0) counted--;
  int limit = MathMin(Bars-counted,Bars-1);

  for (idx = limit; idx >= 0; idx--) ema[idx]  = iMA(NULL, 0, TrendPeriod, 0, MODE_EMA, PRICE_CLOSE, idx);
  for (idx = limit; idx >= 0; idx--) dema[idx] = iMAOnArray(ema, 0, TrendPeriod, 0, MODE_EMA, idx);
  
  for (idx = limit; idx >= 0; idx--) {
    double ema_direct = ema[idx] - ema[idx+1]; 
    double dema_direct = dema[idx] - dema[idx+1];
    double delta = MathAbs(ema[idx] - dema[idx]) / Point;  
    double direct = 0.5*(ema_direct + dema_direct) / Point;    
    force[idx] = delta * MathPow(direct, 3);
    double extremum = FindExtremum(force, ForcePeriod, idx);  
    if (extremum > 0.0) values[idx] = force[idx] / extremum; else values[idx] = 0.0;
  }
  
  for (idx = limit; idx >= 0; idx--) {
    line[idx] = VerticalShift+LineValue; 
    if (values[idx] > 0.0) {pos_values[idx] = VerticalShift+MathAbs(values[idx]); neg_values[idx] = VerticalShift+0.0;} 
      else if (values[idx] < 0.0) {pos_values[idx] = VerticalShift+0.0; neg_values[idx] = VerticalShift+MathAbs(values[idx]);}
        else {pos_values[idx] = VerticalShift+0.0; neg_values[idx] = VerticalShift+0.0;} 
  } 
  for (idx=limit; idx>=0; idx--)  
  {
     trend[idx] = trend[idx+1];
     if (pos_values[idx]>line[idx])trend[idx] = 1; 
     if (neg_values[idx]>line[idx])trend[idx] =-1; 
  }
  if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1;
      if (trend[whichBar] != trend[whichBar+1])
      if (trend[whichBar] == 1)
            doAlert("Red crossed line");
      else  doAlert("Blue crossed line");       
   }
  return(0);
}

double FindExtremum(double& data[], int count, int index) {
  double result = 0.0;
  for (int idx = count - 1; idx >= 0; idx--)
    if (result < MathAbs(data[index+idx])) result = MathAbs(data[index+idx]);
  return (result);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Vertex ",doWhat);
             if (alertsMessage)     Alert(message);
             if (alertsEmail)       SendMail(StringConcatenate(Symbol()," Vertex "),message);
             if (alertsNotificaton) SendNotification(StringConcatenate(Symbol()," Vertex ",message));
             if (alertsSound)       PlaySound(soundfile);
      }
}
