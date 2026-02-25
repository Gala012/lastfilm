import 'dart:math' as math;

const double _lr = 0.2126;
const double _lg = 0.7152;
const double _lb = 0.0722;

List<double> buildFilmColorMatrix(double brightness, double contrast, double saturation, double hueDeg) {
  final s = saturation;
  final sat = [
    [s + (1 - s) * _lr, (1 - s) * _lg, (1 - s) * _lb],
    [(1 - s) * _lr, (1 - s) * _lg + s, (1 - s) * _lb],
    [(1 - s) * _lr, (1 - s) * _lg, (1 - s) * _lb + s],
  ];
  final h = hueDeg * math.pi / 180;
  final a = math.cos(h);
  final b = math.sin(h);
  final u2 = 1 / 3;
  final ub = b / math.sqrt(3);
  final hue = [
    [a + u2 * (1 - a), u2 * (1 - a) - ub, u2 * (1 - a) + ub],
    [u2 * (1 - a) + ub, a + u2 * (1 - a), u2 * (1 - a) - ub],
    [u2 * (1 - a) - ub, u2 * (1 - a) + ub, a + u2 * (1 - a)],
  ];
  final hs = List.generate(3, (i) => List.filled(3, 0.0));
  for (var i = 0; i < 3; i++) {
    for (var j = 0; j < 3; j++) {
      for (var k = 0; k < 3; k++) {
        hs[i][j] += hue[i][k] * sat[k][j];
      }
    }
  }
  final scale = brightness * contrast;
  final offset = brightness * 0.5 * (1.0 - contrast);
  final offset255 = offset * 255;
  return [
    hs[0][0] * scale, hs[0][1] * scale, hs[0][2] * scale, 0, offset255,
    hs[1][0] * scale, hs[1][1] * scale, hs[1][2] * scale, 0, offset255,
    hs[2][0] * scale, hs[2][1] * scale, hs[2][2] * scale, 0, offset255,
    0, 0, 0, 1, 0,
  ];
}
