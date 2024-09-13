# Supported Bluetooth devices

In general any device that supports [`Blood Pressure Service (0x1810)`](https://bitbucket.org/bluetooth-SIG/public/src/main/assigned_numbers/uuids/service_uuids.yaml#lines-77:79) could be used. The blood pressure measurement values are stored in the characteristic [`Blood Pressure Measurement (0x2A35)`](https://bitbucket.org/bluetooth-SIG/public/src/main/assigned_numbers/uuids/characteristic_uuids.yaml#lines-161:163)

## Reading caveats

There are some difference in how devices report their measurements.

Most devices provide 2 ways to retrieve measurements over bluetooth, but there are also difference in how those operate:

1. Immediately after taking a measurement
    1. and returns all measurements stored in memory
    2. and only returns the latest measurement
2. As a download mode
    1. and automatically remove all locally stored measurements after a succesful download
    2. and leave measurements untouched, i.e. the user needs to remove the stored measurements themselves

> :warning: At the moment situation 2.i is not well supported. Do not use this unless you are ok with loosing previously stored measurements

## Known working devices

> If your device is not listed please edit this page and add it! :bow:

|Device|Bluetooth name|Read after measurement|Download mode|Automatically disconnects after reading|
|---|---| :---: | :---: | :---: |
|HealthForYou by Silvercrest (Type SBM 69)|SBM69| :1234: | :white_check_mark: | :white_check_mark: |
|Omron X4 Smart|X4 Smart| :one: | :white_check_mark::wastebasket: | :white_check_mark: |

#### Legenda

|Icon|Description|
| :---: | --- |
| :no_entry_sign: |Not supported / No|
| :white_check_mark: |Supported / Yes|
| :one: | Returns latest measurement|
| :1234: | Returns all measurements|
| :white_check_mark::wastebasket: |Supported and removes all locally stored measurements|

## Specifications

- Assigned Numbers (f.e. service & characteristic UUID's): https://www.bluetooth.com/specifications/assigned-numbers/
- GATT Specification Supplement (f.e. data structures): https://www.bluetooth.com/specifications/gss/
- Current Time Service: https://www.bluetooth.com/specifications/specs/current-time-service-1-1/
