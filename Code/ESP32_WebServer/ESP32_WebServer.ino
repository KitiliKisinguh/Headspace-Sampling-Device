#include <Arduino.h>
#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include "LittleFS.h"
#include <Arduino_JSON.h>

// LM35 Pin (ADC1)
const int lm35_pin = 34;
const int pwm_pin = 4;
const int pump_pin = 13;
const int solenoid_valve = 14;
const int motor_pin = 27;
const int flow_sensor = 32;


// Temperature sensor and PID control variables
float temp_val = 0;
double dt, last_time;
double integral = 0, previous = 0;
double kp, ki, kd;
double temp_set = 25;  // Temperature setpoint in °C
double dutycycle = 0;
double airflow = 0;

// Anti-windup limit for the integral term
const double INTEGRAL_MAX = 100.0;

#define ADC_VREF_mV 3300.0  // ADC reference voltage in millivolts
#define ADC_RESOLUTION 4095.0

// Access Point credentials
const char *ssid = "ESP32";
const char *password = "123";

// Create AsyncWebServer object on port 80
AsyncWebServer server(80);

// Create an Event Source on /events
AsyncEventSource events("/events");

// JSON variable to hold sensor readings
JSONVar readings;

// Timer variables; readings every 1 second
unsigned long lastTime = 0;
unsigned long timerDelay = 1000;

// Get sensor readings and return a JSON string
String getSensorReadings() {
  readings["sensor"] = readTemperature();
  return JSON.stringify(readings);
};

// Initialize LittleFS
void initLittleFS() {
  if (!LittleFS.begin()) {
    Serial.println("An error has occurred while mounting LittleFS");
  } else {
    Serial.println("LittleFS mounted successfully");
  }
};

// Initialize WiFi in Access Point mode
void initWiFi() {
  WiFi.mode(WIFI_AP);
  WiFi.softAP(ssid, password);
  Serial.print("AP IP address: ");
  Serial.println(WiFi.softAPIP());
}

double readTemperature() {
  int adcVal = analogRead(lm35_pin);
  float milliVolt = adcVal * (ADC_VREF_mV / ADC_RESOLUTION);
  float tempC = milliVolt / 10.0;
  return tempC;
};

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
};


void setup() {

  // Serial port for debugging
  Serial.begin(115200);
  initWiFi();
  initLittleFS();

  analogWriteFrequency(pump_pin, 10000);
  analogWriteFrequency(motor_pin, 5000);

  // Serve index.html from LittleFS at root URL
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
    request->send(LittleFS, "/index.html", "text/html");
  });

  // Serve static files from LittleFS
  server.serveStatic("/", LittleFS, "/");

  // Endpoint for sensor readings
  server.on("/readings", HTTP_GET, [](AsyncWebServerRequest *request) {
    String json = getSensorReadings();
    request->send(200, "application/json", json);
  });

  // Set up event source for clients
  events.onConnect([](AsyncEventSourceClient *client) {
    if (client->lastId()) {
      // Serial.printf("Client reconnected! Last message ID that it got is: %u\n", client->lastId());
    }
    client->send("hello!", NULL, millis(), 10000);
  });
  server.addHandler(&events);

  // Start the web server
  server.begin();

  // Initialize solenoid_valve (Pin 14)
  pinMode(solenoid_valve, OUTPUT);
  digitalWrite(solenoid_valve, LOW);


  // PID constants and timer
  kp = 10;
  ki = 1;
  kd = 0.01;
  last_time = millis();

  // Endpoint to adjust the temperature setpoint
  server.on("/setTemp", HTTP_GET, [](AsyncWebServerRequest *request) {
    if (request->hasParam("temp")) {
      String tempStr = request->getParam("temp")->value();
      float newTempSet = tempStr.toFloat();
      if (newTempSet >= 0 && newTempSet <= 150) {
        temp_set = newTempSet;
        Serial.print("New temperature setpoint: ");
        Serial.println(temp_set);
      }
    }

    request->redirect("/?setpoint=" + String(temp_set, 0));
  });

  // Endpoint to adjust the flow rate
  server.on("/setFlow", HTTP_GET, [](AsyncWebServerRequest *request) {
    if (request->hasParam("airflow")) {
      String flowStr = request->getParam("airflow")->value();
      float newairflow = flowStr.toFloat();
      if (newairflow >= 0 && newairflow <= 100) {
        airflow = newairflow;
        Serial.print("New AirFlow setpoint: ");
        Serial.println(airflow);
      }
    }

    request->redirect("/?flowrate=" + String(airflow, 0));
  });

  // Endpoint to update solenoid_valve state
  server.on("/updateSolenoid", HTTP_GET, [](AsyncWebServerRequest *request) {
    if (request->hasParam("state")) {
      String state = request->getParam("state")->value();
      Serial.print("Updating solenoid_valve (Pin 14) state to: ");
      Serial.println(state);
      digitalWrite(solenoid_valve, state.toInt());
    }
    request->send(200, "text/plain", "OK");
  });

  // Endpoint to return the current state of solenoid_valve
  server.on("/stateSolenoid", HTTP_GET, [](AsyncWebServerRequest *request) {
    String currentState = String(digitalRead(solenoid_valve));
    request->send(200, "text/plain", currentState);
  });

  // Endpoint to adjust the motor duty cycle
  server.on("/setMotor", HTTP_GET, [](AsyncWebServerRequest *request) {
    if (request->hasParam("motor")) {
      String motorStr = request->getParam("motor")->value();
      float newdutycycle = motorStr.toFloat();
      if (newdutycycle >= 0 && newdutycycle <= 100) {
        dutycycle = newdutycycle;
        Serial.print("NewDutyCycle: ");
        Serial.println(dutycycle);
      }
    }


    request->redirect("/?dutycycle=" + String(dutycycle, 0));
  });
}

void loop() {
  // Send sensor readings via events every 1 second
  if ((millis() - lastTime) > timerDelay) {
    events.send("ping", NULL, millis());
    events.send(getSensorReadings().c_str(), "new_readings", millis());
    lastTime = millis();
  };
  temp_val = readTemperature();
  Serial.print("Temperature = ");
  Serial.print(temp_val);
  Serial.println(" °C");

  double now = millis();
  dt = (now - last_time) / 1000.0;
  last_time = now;

  double error = temp_set - temp_val;
  double pidOutput = computePID(error);
  //Constrains PID from the range 0-255
  pidOutput = constrain(pidOutput, 0, 255);

  Serial.print("PID Output: ");
  Serial.println(pidOutput);

  //Writing PID
  analogWrite(pwm_pin, pidOutput);

  // Writing Vacumm Pump Air Flow
  int pumpout = map(airflow, 0, 100, 0, 255);
  analogWrite(pump_pin, pumpout);

  // Writing Motor Duty Cycle
  int motorout = map(dutycycle, 0, 100, 0, 255);
  analogWrite(motor_pin, motorout);

  Serial.print("Flow rate= ");
  Serial.print(flow_sensor);
  Serial.println("ml");

  delay(100);  // 100ms delay to give PID output enought time to take effect
}
