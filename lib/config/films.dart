import 'package:flutter/material.dart';
import '../lang/lang.dart';

class FilmFilterParams {
  final double brightness;
  final double contrast;
  final double saturation;
  final double hue;

  const FilmFilterParams({
    this.brightness = 1,
    this.contrast = 1,
    this.saturation = 1,
    this.hue = 0,
  });
}

class FilmConfig {
  final String id;
  final String name;
  final String description;
  final Color iconColor;
  final FilmFilterParams filterParams;

  const FilmConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.iconColor,
    required this.filterParams,
  });
}

const List<FilmConfig> filmConfigs = [
  FilmConfig(
    id: 'none',
    name: Lang.filmNone,
    description: Lang.filmNoneDesc,
    iconColor: Color(0xFF9E9E9E),
    filterParams: FilmFilterParams(),
  ),
  FilmConfig(
    id: 'superia100',
    name: Lang.superia100,
    description: Lang.superia100Desc,
    iconColor: Color(0xFF2E7D32),
    filterParams: FilmFilterParams(brightness: 1.04, contrast: 1.12, saturation: 1.28, hue: 8),
  ),
  FilmConfig(
    id: 'gold200',
    name: Lang.gold200,
    description: Lang.gold200Desc,
    iconColor: Color(0xFFF9A825),
    filterParams: FilmFilterParams(brightness: 1.06, contrast: 1.05, saturation: 1.32, hue: 18),
  ),
  FilmConfig(
    id: 'vista800',
    name: Lang.vista800,
    description: Lang.vista800Desc,
    iconColor: Color(0xFFC62828),
    filterParams: FilmFilterParams(brightness: 1.08, contrast: 0.82, saturation: 0.72, hue: -10),
  ),
  FilmConfig(
    id: 'color100',
    name: Lang.color100,
    description: Lang.color100Desc,
    iconColor: Color(0xFF1565C0),
    filterParams: FilmFilterParams(brightness: 1.02, contrast: 1.08, saturation: 1.2, hue: 3),
  ),
  FilmConfig(
    id: 'reala500d',
    name: Lang.reala500d,
    description: Lang.reala500dDesc,
    iconColor: Color(0xFF6D4C41),
    filterParams: FilmFilterParams(brightness: 1.03, contrast: 1.14, saturation: 1.38, hue: 14),
  ),
  FilmConfig(
    id: 'ultra50',
    name: Lang.ultra50,
    description: Lang.ultra50Desc,
    iconColor: Color(0xFFE91E63),
    filterParams: FilmFilterParams(brightness: 1.02, contrast: 1.16, saturation: 1.55, hue: 0),
  ),
  FilmConfig(
    id: 'lomo800',
    name: Lang.lomo800,
    description: Lang.lomo800Desc,
    iconColor: Color(0xFF558B2F),
    filterParams: FilmFilterParams(brightness: 0.94, contrast: 1.28, saturation: 1.26, hue: 16),
  ),
];
