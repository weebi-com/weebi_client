/// Accent-insensitive label matching used by the mobile article validators.
extension ArticleLabel on String {
  static const _diacritics =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËĚèéêëěðČÇçčÐĎďÌÍÎÏìíîïĽľÙÚÛÜŮùúûüůŇÑñňŘřŠšŤťŸÝÿýŽž';
  static const _nonDiacritics =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEEeeeeeeCCccDDdIIIIiiiiLlUUUUUuuuuuNNnnRrSsTtYYyyZz';

  String get withoutAccents => splitMapJoin(
        '',
        onNonMatch: (char) =>
            char.isNotEmpty && _diacritics.contains(char)
                ? _nonDiacritics[_diacritics.indexOf(char)]
                : char,
      );

  String get asArticleKey => withoutAccents.toLowerCase().trim();
}
