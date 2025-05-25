# Heater Control System

## Headspace Sampling Device

### Headspace Sampler Operation
<div style="text-align:center">
<img src="Documents/Videos/Headspace%20Sampling%20Device%20Operation.gif" width="600" alt="Headspace Sampler Operation">
</div>
<p style="text-align:center">This video demonstrates the proper operation of the headspace sampling device.</p>

---

### Vial Agitation
<div style="text-align:center">
<video width="600" controls loop>
  <source src="Documents/Videos/Vial%20Agitation.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>
</div>
<p style="text-align:center">This video shows the correct technique for vial agitation during the sampling process.</p>

---

## PWM Control Circuit

### Interposer Board for ESP32 Controller
This board is designed to hold and interface with the ESP32 controller used for PWM signal generation.

<div style="text-align:center">
<img src="Interpose/Images/Interpose.JPEG" width="400" alt="Interpose Control Board">
</div>

**Features:**
- ESP32 microcontroller interface
- Signal conditioning
- I/O protection

---

### Heater Control PCB (KiCad Design)
Regulates PWM from 24V to 12V for the Kapton heater used in the headspace sampling system.

<div style="text-align:center">
<img src="Heater-Control-PCB/Images/PWM%20controller%20V1.JPEG" width="400" alt="PWM Control Board V1">
</div>

**Specifications:**
- Input: 24V DC
- Input: 5V PWM
- Output: 24V PWM
- Max current: 5A

---

### PWM Control for Inductive Loads
A second version of the PWM control board, specifically designed for driving inductive loads with regulated output.

<div style="text-align:center">
<img src="PWM%20Control%20Circuit/Images/PWM%20Controller%20V2.JPEG" width="400" alt="PWM Control Board V2">
</div>

**Specifications:**
- Input: 24V DC
- Input: 5V PWM
- Output: 12V PWM
- Max current: 5A

---

## Project Structure