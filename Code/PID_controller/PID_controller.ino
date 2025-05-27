#include <Arduino.h>
#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include "LittleFS.h"
#include <Arduino_JSON.h> 
#include <ESP_Google_Sheet_Client.h>

// For SD/SD_MMC mounting helper
#include <GS_SDHelper.h>

#define WIFI_SSID "ESP32"
#define WIFI_PASSWORD "123"

// Google Project ID
#define PROJECT_ID "9e9c44a7a838061c6f3242ec38fd5c678c424f16"

// Service Account's client email
#define CLIENT_EMAIL "data-logging@data-logging-454823.iam.gserviceaccount.com"

// Service Account's private key
const char PRIVATE_KEY[] PROGMEM = "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDYwGe+I5Ju9WOb\njt/OW6VyIc6N1LTwn/7UsU+gxltJTcwituvZhCbzedMMFWH/DF4ckZXgfGNmnHkR\ntncvJLKezoKJc/wCw4CEsFFQ9PdCNA/wenbPGDQHgQdFzCx/FTK3zY+WDtOM7vMI\n4l56+YpkMimwC4cwxW+6vQswczQzl9vl5wMo0ObMY/LHwj5gME6b4EAitupEabNk\nUK0puzzppxpWdagXZn9saepr7+wLDsJRNIZHbzYF2favWGsVl2883gpA7bhnLhid\noLGHaFu01hJ2sVW8g/tvXv2bdQ4n0kqcgljL5dSgiVmdPd+iwBU9Aj24mVxfdxcL\nc1vaH37zAgMBAAECggEAAPaF33iNUinhRJPTbGQdguQh5KEWdrU3RB76NsF62Viw\n+KcturyAEc0vl1pRok5ImBbmKWZUE2TMPZG9INFTFn/eC5n00Nb+hK27MWwNMdbv\ntTFOGChy3rpU28YG8pTtB0JbX3QhviViS16kwyYbASFJ7HV4px+mxJfKFhqE7QUU\ncHhwusFa1nCJzbhm392CYSO+sgXV9lY7VA7SfdDLqQalzG4Ay3SnGTQgRzIvEK51\nCD2ND8zGzG9ZUcGU4pPJYj6PGQG4ysnNSIo95GjW2usF871PGY3MmAUve/TCE0qW\nhlIZRnGH8iLUU1jD9EdKCTgF2ajny1fn8pED6CnIeQKBgQDyYAMbqHYeb6NCTXI6\ndRbyFrXSvRqV8nfAXeWBmcdzU72vrjj6zwtPTKTl9NtjkzukN6sXlNFTkFT7RZDO\n6n+w1DYZb8Kr1VfNly1v3wbwSyZMei/6vv7QDQmo8AM3mNJNOS2auuC9K0mFv2If\nkVRnwyx3vBxJ/qdsWe/RZx21GQKBgQDk76Yu1uI/Ym4fLclDuFpa7ILvI8nE2u7f\nkvYwt2lUzlnRdUUgDqq1vtuZpkxtVKLdmKhhDeenEno1M/D0rvi2Um7Im7G/MHQy\nZkNmAy0qkFUuYfjsnz08iogs1W8sPTw7To+Q5WAwOO1cbkOG4Un9n+IFkbs+ad3r\nDBs63otp6wKBgAOhuKozbgGqvpGBw5Joqr1Z5cOQndNdXLn/Li8w9LIfsRnuzF/F\ntm+rwFTJxHfLfvtI8kFaM4DDCuLw+eh/zwYBSAY9jHcyrSwhdcbVWq9DEQHYWtuw\n/PR1HY3wervciFor3ykQX8m12lYstfWvIcqkPAhXQz1AmZWgC13h46oRAoGBAKDS\nULVasnjAVoeEjHwMBz0UJC6Fv3mQKnnYLSWv0kiG5MWlUbfhVb5yoqVfExVCfV6Z\nnL8BG5hb/IlfQYdBWuoJIlW+ObELArVc7T++P35FAfGhVVIz0rqyvlJwZLZ5FdS7\nrVKmL1nww51IwBsCLA4EwKwU4apIiGJTkNVb/CedAoGAWC5cyfAVgVVsM83ZuFhI\nDQ5aA8SSnl/M+ZGM1LsH7+c7Q/BzgDSaLouA27l2Z1xRzj2ab980WCbYp7xlU+So\n8QDcq1c6mii3+agWW5t8cxN1qIsl3Mr4iyrM8/ODGe4/HR1R5jhpi9aNssflhxmc\n/Bibn7vJ7jwZp7nH/aN0HVs=\n-----END PRIVATE KEY-----\n";

// The ID of the spreadsheet where you'll publish the data
const char spreadsheetId[] = "1p5hMxy9seMgy1BizVp7Z7uj9_FPyGK3ifTQ6SjR4SQw";

// Timer variables
unsigned long lastTime = 0;  
unsigned long timerDelay = 30000;

// Token Callback function
void tokenStatusCallback(TokenInfo info);


const int lm35_pin = 34;	/* LM35 O/P pin */

//Temp sesnor constants
int temp_adc_val;
float temp_val;

//Pid constants
double dt, last_time;
double integral, previous, output=0;
double kp, ki, kd;
double temp_set=50;

// NTP server to request epoch time
const char* ntpServer = "pool.ntp.org";

// Variable to save current epoch time
unsigned long epochTime; 

// Function that gets current epoch time
unsigned long getTime() {
  time_t now;
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    //Serial.println("Failed to obtain time");
    return(0);
  }
  time(&now);
  return now;
}


void setup() {

  kp=10;
  ki=1;
  kd=0.01;
  last_time=0;
  Serial.begin(115200);

  Serial.println();
  Serial.println();

  //Configure time
  configTime(0, 0, ntpServer);



  GSheet.printf("ESP Google Sheet Client v%s\n\n", ESP_GOOGLE_SHEET_CLIENT_VERSION);

  // Connect to Wi-Fi
  WiFi.setAutoReconnect(true);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(1000);
  }
  
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  // Set the callback for Google API access token generation status (for debug only)
  GSheet.setTokenCallback(tokenStatusCallback);

  // Set the seconds to refresh the auth token before expire (60 to 3540, default is 300 seconds)
  GSheet.setPrerefreshSeconds(10 * 60);

  // Begin the access token generation for Google API authentication
  GSheet.begin(CLIENT_EMAIL, PROJECT_ID, PRIVATE_KEY);

}

void loop() {

  if (ready && millis() - lastTime > timerDelay){
      lastTime = millis();

      FirebaseJson response;

      Serial.println("\nAppend spreadsheet values...");
      Serial.println("----------------------------");

      FirebaseJson valueRange;

      temp = temp();
      // Get timestamp
      epochTime = getTime();

      valueRange.add("majorDimension", "COLUMNS");
      valueRange.set("values/[0]/[0]", epochTime);
      valueRange.set("values/[1]/[0]", temp);

      // Append values to the spreadsheet
      bool success = GSheet.values.append(&response /* returned response */, spreadsheetId /* spreadsheet Id to append */, "Sheet1!A1" /* range to append */, &valueRange /* data range to append */);
      if (success){
          response.toString(Serial, true);
          valueRange.clear();
        }
      else{
          Serial.println(GSheet.errorReason());
        }
      Serial.println();
      Serial.println(ESP.getFreeHeap());
    }
  
  temp_val=temp(); //Temp val stored in temp_val
  Serial.print("Temperature = ");
  Serial.print(temp_val);
  Serial.print(" Degree Celsius\n");
  
  double now = millis();
  dt = (now - last_time)/1000.00;
  last_time = now;

  double error = temp_set - temp_val;
  output = pid(error);
  
  // Map PID output to PWM duty cycle (0-255)
  output = constrain(output, 0, 255);
  
  // Set pwm pin to duty cycle defined by output
  analogWrite(pwm_pin, output);

}

double computePID(double error) {
  double proportional = error;
  integral += error * dt;

  //Clamp to prevent windup
  if (integral > INTEGRAL_MAX) {
    integral = INTEGRAL_MAX;
  } else if (integral < -INTEGRAL_MAX) {
    integral = -INTEGRAL_MAX;
  };

  double derivative = (error - previous) / dt;
  previous = error;
  double outputVal = (kp * proportional) + (ki * integral) + (kd * derivative);
  return outputVal;

  delay(100); //100ms delay
};

double temp(){
  temp_adc_val= analogRead(lm35_pin);
  temp_val = (temp_adc_val * 4.88);	/* Convert adc value to equivalent voltage */
  temp_val = (temp_val/10);	 /* LM35 gives output of 10mv/°C */
  return temp_val;
}

<<<<<<< HEAD
=======

>>>>>>> 698f5ef004c0fe18745274defdfb8af928cc5cc3
