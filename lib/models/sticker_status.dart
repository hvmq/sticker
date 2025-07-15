enum StickerStatus {
  active('active'),
  inactive('inactive'),
  pending('pending'),
  deleted('deleted');

  final String value;
  const StickerStatus(this.value);

  factory StickerStatus.fromString(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => StickerStatus.active,
    );
  }
}
