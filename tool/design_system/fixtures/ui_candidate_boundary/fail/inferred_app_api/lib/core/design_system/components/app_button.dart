import '../adapters/candidate/button_adapter.dart';

class AppButton {
  final CandidateButtonAdapter _adapter = CandidateButtonAdapter();

  get style => _adapter.style;
}
