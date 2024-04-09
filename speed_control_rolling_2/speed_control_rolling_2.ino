 #include <AutoPID.h>
 #include <Servo.h> // Using servo library to control ESC
 Servo esc; // Creating a servo class with name as esc
 //pins
 #define Motor 11
 #define Current_read A0
 //PID seting and gains
 #define KP 0.1
 #define KI 0.1
 #define KD 0.05
 #define OUTPUT_MIN -200
 #define OUTPUT_MAX 1200
 #define steps 30

 byte rpm_flag = 0;
 unsigned long timepoint[steps];
 volatile byte revolutions=0;
 double rpm=0, outputVal;
 unsigned long timeold;
 unsigned long crt;
 unsigned long dt;
 double rpm_set=2000;
 float I;
 String comdata;

 AutoPID RPM_PID(&rpm,&rpm_set,&outputVal, OUTPUT_MIN,OUTPUT_MAX, KP, KI, KD);

 
 void setup()
 {
   //set PID
    //RPM_PID.setBangBang(500);
  //set PID update interval to 4000ms
     RPM_PID.setTimeStep(80);
   
   //initia parameters
   revolutions=0;
   rpm=0;
   timeold=0;
   I=0;
   Serial.begin(9600);
   while(Serial.read()>= 0){}
   attachInterrupt(0, rpm_fun, RISING);
   esc.attach(Motor); // Specify the esc signal pin,Here as D11
   esc.writeMicroseconds(800); // initialize the signal to 1000
   delay(1000);
 }
 
 void loop()
 {
  rpm=get_rpm();
  rpm_control();
  //I=analogRead(Current_read);
  Serial.print("#");
  Serial.print(",");
  Serial.print(rpm);
  Serial.print(",");
  Serial.print(outputVal);
  Serial.print(",");
  //Serial.print(revolutions);
  //Serial.print(",");
  Serial.println(rpm_set);
  if(Serial.available()>0){
    rpm_set = set_rpm();
    }

 }

void rpm_control(){
  RPM_PID.run();
  esc.writeMicroseconds(1000+outputVal); // using val as the signal to esc
}

int set_rpm(){
    while(Serial.available()>0){
    //rpm_set=Serial.parseInt();
    comdata += char(Serial.read());
    delay(2);
  }
    rpm_set = comdata.toInt();
    comdata = "";
    return(rpm_set);
  }

 
 double get_rpm()
 {
  if (rpm_flag == 1) { 
     dt=timepoint[revolutions-1]-timepoint[0];
     rpm=double(revolutions-1)*1000/double(dt)*60;
     //rpm=revolutions*1000/dt*60;
     return(rpm);}
  else {
     return(0);
   }
  
  }

 void rpm_fun()
 {
   crt = millis();
   if (rpm_flag == 0)
   {    
        timepoint[revolutions] = crt;
        revolutions++;
        if (revolutions >= steps)
       {
           rpm_flag = 1;
        }
   }
  if (rpm_flag == 1)
  {
    for (int i=0; i<steps-1; i++){
      timepoint[i]=timepoint[i+1];
    }
    timepoint[steps-1]=crt;
  }
//      for (int ii=0; ii<steps; ii++){
//      Serial.print(timepoint[ii]);
//      Serial.print(",");
//    }
//      Serial.print(crt);
//      Serial.print(",");
//      Serial.print(revolutions);
//      Serial.print(",");
//      Serial.println(rpm);
   }
