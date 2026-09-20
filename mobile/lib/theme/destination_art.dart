/// Shared travel photography used only for visual composition.
/// Does not change catalog IDs or the Backend request.
class DestinationArt {
  static const istanbul = 'assets/intro/dest_istanbul.png';
  static const rome = 'assets/intro/dest_rome.png';
  static const aqaba = 'assets/intro/dest_aqaba.png';
  static const recommend = 'assets/intro/recommend_istanbul.png';
  static const days = 'assets/intro/days_landscape.png';
  static const map = 'assets/intro/map_cream.png';
  static const featured = 'assets/intro/plan_featured.png';
  static const floral = 'assets/intro/onboard_floral_wash.png';

  static const blurbs = {
    'istanbul': 'Mosques, bazaars & Bosphorus light',
    'rome': 'Forums, fountains & golden hours',
    'aqaba': 'Red Sea calm and desert sky',
  };

  static String photoFor(String? destinationId) {
    switch (destinationId) {
      case 'istanbul':
        return istanbul;
      case 'rome':
        return rome;
      case 'aqaba':
        return aqaba;
      default:
        return featured;
    }
  }
}
