#include <megaAVR_PWM.h>

const int input = A2;  // Analog input pin for reading
const int pwm = 9;     // PWM output pin

double freq = 500;              // Frequency in Hz
double real_dutyCycle = 50;      // Static duty cycle as a percentage
double bits = 65535;             // Max value for duty cycle in 16-bit resolution

// Create PWM instance
megaAVR_PWM* PWM_Instance;

void setup() {
  Serial.begin(115200);

  // Initialize PWM instance with a frequency of 1 kHz and an initial duty cycle
  double initialDutyCycle = (real_dutyCycle * bits) / 100; // Convert to 16-bit value
  PWM_Instance = new megaAVR_PWM(pwm, freq, initialDutyCycle); 
  delay(100);

  Serial.println("PWM initialized. Adjust frequency and duty cycle dynamically.");
  Serial.println("sensorValue\tFrequency\tDutyCycle"); // Headers for Serial Plotter
}

void loop() {
  // Read input from the analog pin
  int sensorValue = analogRead(input);

  // Map sensor value to a dynamic duty cycle range (10%-90%)
  double dutyCyclePercent = map(sensorValue, 0, 1023, 10, 90); // Duty cycle in percentage
  double dutyCycle = (dutyCyclePercent * bits) / 100;          // Convert to 16-bit resolution

  // Update the PWM frequency and duty cycle
  PWM_Instance->setPWM(pwm, freq, dutyCycle); 

  // Print sensor value, frequency, and duty cycle for Serial Plotter
  Serial.print(sensorValue);          // A2 sensor value
  Serial.print("\t");                 // Tab-separated
  Serial.print(freq);                 // Frequency in Hz
  Serial.print("\t");                 // Tab-separated
  Serial.println(dutyCyclePercent);   // Duty cycle in percentage

  delay(100); // Small delay for stability
}
