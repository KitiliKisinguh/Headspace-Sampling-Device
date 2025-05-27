const int pwm = 9;      // PWM output pin
const int sensor = A2;  // Analog input pin

double duty = 70; // Initial duty cycle (50% for 8-bit PWM)

void setup() {
  Serial.begin(9600);

  // Set the initial PWM duty cycle
  analogWrite(pwm, duty);

  // Print column headers for Serial Plotter
  Serial.println("Sensor_Value\tDuty_Cycle");
}

void loop() {
  // Read the sensor value (0-1023)
  double Sensor_val = analogRead(sensor);

  // Map the sensor value to the PWM duty cycle range (0-255 for 8-bit)
  //duty = map(Sensor_val, 0, 1023, 0, 255);

  double duty_cycle=(duty/100)*255;

  // Set the PWM output based on the mapped duty cycle
  analogWrite(pwm, duty_cycle);

  // Print sensor value and duty cycle for Serial Plotter
  Serial.print(Sensor_val);
  Serial.print("\t");       // Tab-separated for Serial Plotter
  Serial.println(duty);     // Duty cycle as second column

}
