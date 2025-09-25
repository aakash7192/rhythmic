class DrumPad {
  final String id;
  final String name;
  final int note;
  final String key;
  final String color;
  final DrumPadPosition position;

  DrumPad({
    required this.id,
    required this.name,
    required this.note,
    required this.key,
    required this.color,
    required this.position,
  });

  factory DrumPad.fromJson(Map<String, dynamic> json) {
    return DrumPad(
      id: json['id'],
      name: json['name'],
      note: json['note'],
      key: json['key'],
      color: json['color'],
      position: DrumPadPosition.fromJson(json['position']),
    );
  }
}

class DrumPadPosition {
  final int row;
  final int col;

  DrumPadPosition({required this.row, required this.col});

  factory DrumPadPosition.fromJson(Map<String, dynamic> json) {
    return DrumPadPosition(
      row: json['row'],
      col: json['col'],
    );
  }
}

class DrumInstrument {
  final String id;
  final String name;
  final String description;
  final String category;
  final String sfzFile;
  final List<DrumPad> pads;

  DrumInstrument({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.sfzFile,
    required this.pads,
  });

  factory DrumInstrument.fromJson(Map<String, dynamic> json) {
    return DrumInstrument(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      sfzFile: json['sfzFile'],
      pads: (json['pads'] as List)
          .map((pad) => DrumPad.fromJson(pad))
          .toList(),
    );
  }
}