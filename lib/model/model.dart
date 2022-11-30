class ModelClass {
  ModelClass({
    this.videos = const [],
  });

  ModelClass.fromJson(dynamic json) {
    if (json['videos'] != null) {
      videos = [];
      json['videos'].forEach((v) {
        videos.add(Videos.fromJson(v));
      });
    }
  }

  List<Videos> videos = const [];

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['videos'] = videos.map((v) => v.toJson()).toList();
    return map;
  }
}

class Videos {
  Videos({
    this.description = "",
    this.sources = const [],
    this.subtitle = "",
    this.thumb = "",
    this.title = "",
  });

  Videos.fromJson(dynamic json) {
    description = json['description'];
    sources = json['sources'] != null ? json['sources'].cast<String>() : [];
    subtitle = json['subtitle'];
    thumb = json['thumb'];
    title = json['title'];
  }

  String description = "";
  List<String> sources = const [];
  String subtitle = "";
  String thumb = "";
  String title = "";

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['description'] = description;
    map['sources'] = sources;
    map['subtitle'] = subtitle;
    map['thumb'] = thumb;
    map['title'] = title;
    return map;
  }
}
