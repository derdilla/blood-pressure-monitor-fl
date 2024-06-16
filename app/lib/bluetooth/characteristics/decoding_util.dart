import 'dart:math';

/// Whether the bit at offset (0-7) is set.
///
/// Masks the byte with a 1 that has [offset] to the right and moves the
/// remaining bit to the first position and checks if it's equal to 1.
bool isBitIntByteSet(int byte, int offset) =>
    (((byte & (1 << offset)) >> offset) == 1);

/// Attempts to read an IEEE-11073 16bit SFloat starting at data[offset].
double? readSFloat(List<int> data, int offset) {
  if (data.length < offset + 2) return null;
  // TODO: special values (NaN, Infinity)
  final mantissa = data[offset] + ((data[offset + 1] & 0x0F) << 8); // TODO: https://github.com/NordicSemiconductor/Kotlin-BLE-Library/blob/6b565e59de21dfa53ef80ff8351ac4a4550e8d58/core/src/main/java/no/nordicsemi/android/kotlin/ble/core/data/util/DataByteArray.kt#L392
  final exponent = data[offset + 1] >> 4;
  return (mantissa * (pow(10, exponent))).toDouble();
}

int? readUInt8(List<int> data, int offset) {
  if (data.length < offset + 1) return null;
  return data[offset];
}

int? readUInt16Le(List<int> data, int offset) {
  if (data.length < offset + 2) return null;
  return data[offset] + (data[offset+1] << 8);
}

int? readUInt16Be(List<int> data, int offset) {
  if (data.length < offset + 2) return null;
  return (data[offset] << 8) + data[offset + 1];
}
