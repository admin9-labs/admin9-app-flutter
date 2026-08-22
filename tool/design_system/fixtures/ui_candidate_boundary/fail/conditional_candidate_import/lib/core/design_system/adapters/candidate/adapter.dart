import 'fallback.dart'
    if (dart.library.io) 'package:candidate_ui/candidate_ui.dart'
    as candidate;

candidate.Style publicStyle() => throw UnimplementedError();
