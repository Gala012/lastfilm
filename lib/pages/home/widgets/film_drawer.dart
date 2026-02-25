import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/films.dart';
import '../../../db_last_film/db_last_film_entity.dart';
import '../../../lang/lang.dart';
import '../../../theme/app_theme.dart';
class FilmDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final void Function(FilmConfig) onSelectFilm;
  final void Function(RollEntity) onSelectRoll;
  final FilmConfig currentFilm;
  final RollEntity? currentRoll;
  final double statusBarHeight;

  const FilmDrawer({
    super.key,
    required this.onClose,
    required this.onSelectFilm,
    required this.onSelectRoll,
    required this.currentFilm,
    this.currentRoll,
    this.statusBarHeight = 0,
  });

  @override
  State<FilmDrawer> createState() => _FilmDrawerState();
}

class _FilmDrawerState extends State<FilmDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 16, offset: const Offset(4, 0))],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildFilmsTab(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(top: widget.statusBarHeight + ScreenUtil().setWidth(16), left: ScreenUtil().setWidth(16), right: ScreenUtil().setWidth(16), bottom: ScreenUtil().setWidth(16)),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onClose,
            child: Icon(Icons.arrow_back_ios, size: ScreenUtil().setSp(20), color: theme.colorScheme.onSurface),
          ),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Text(Lang.appName, style: TextStyle(fontSize: ScreenUtil().setSp(18), fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildFilmsTab(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16), vertical: ScreenUtil().setHeight(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: filmConfigs.map((film) => _buildFilmItem(context, film, film.id == widget.currentFilm.id)).toList(),
      ),
    );
  }

  Widget _buildFilmItem(BuildContext context, FilmConfig film, bool isSelected) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(12)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onSelectFilm(film),
          borderRadius: BorderRadius.circular(ScreenUtil().radius(12)),
          child: Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
            decoration: BoxDecoration(
              color: isSelected ? film.iconColor.withOpacity(0.15) : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(ScreenUtil().radius(12)),
              border: Border.all(color: isSelected ? AppTheme.primary : Colors.transparent, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Container(
                  width: ScreenUtil().setWidth(48),
                  height: ScreenUtil().setWidth(48),
                  decoration: BoxDecoration(color: film.iconColor, borderRadius: BorderRadius.circular(ScreenUtil().radius(8))),
                  child: Center(child: Icon(Icons.camera_roll, color: Colors.white, size: ScreenUtil().setSp(24))),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(film.name, style: TextStyle(fontSize: ScreenUtil().setSp(16), fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                      SizedBox(height: ScreenUtil().setHeight(4)),
                      Text(film.description, style: TextStyle(fontSize: ScreenUtil().setSp(12), color: theme.colorScheme.onSurface.withOpacity(0.6)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (isSelected) Padding(padding: EdgeInsets.only(left: ScreenUtil().setWidth(12)), child: Icon(Icons.check_circle, color: AppTheme.primary, size: ScreenUtil().setSp(24))),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
