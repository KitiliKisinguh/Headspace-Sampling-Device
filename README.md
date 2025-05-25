# Heater Control System

## Headspace Sampling Device

### Headspace Sampler Operation
[![Headspace Sampler Operation](Documents/Videos/Headspace%20Sampling%20Device%20Operation.MP4)](Documents/Videos/Headspace%20Sampling%20Device%20Operation.MP4)  
This video demonstrates the proper operation of the headspace sampling device.

---

### Vial Agitation
[![Vial Agitation](Documents/Videos/Vial%20Agitation.mp4)](Documents/Videos/Vial%20Agitation.mp4)  
This video shows the correct technique for vial agitation during the sampling process.

---

## PWM Control Circuit

### Interposer Board for ESP32 Controller
This board is designed to hold and interface with the ESP32 controller used for PWM signal generation.

<img src="ESP32%20Interpose/Images/Interpose.JPEG" width="400" alt="Interpose Control Board">

**Features:**
- ESP32 microcontroller interface
- Signal conditioning
- I/O protection

---

### Heater Control PCB (KiCad Design)
Regulates PWM from 24V to 12V for the Kapton heater used in the headspace sampling system.

<img src="Heater-Control-PCB/Images/PWM%20controller%20V1.JPEG" width="400" alt="PWM Control Board V1">

**Specifications:**
- Input: 24V DC
- Output: 12V PWM
- Max current: 5A
- KiCad design files included

---

### PWM Control for Inductive Loads
A second version of the PWM control board, specifically designed for driving inductive loads with regulated output.

<img src="PWM%20Control%20Circuit/Images/PWM%20controller%20V2.JPEG" width="400" alt="PWM Control Board V2">

**Improvements:**
- Enhanced inductive load handling
- Better heat dissipation
- Reverse polarity protection

---

## Project Structure