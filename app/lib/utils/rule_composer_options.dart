import 'package:nitella_app/common/common.pb.dart' as common;

List<common.ConditionType> defaultRuleConditionTypeOptions() {
  return common.ConditionType.values
      .where((type) => type != common.ConditionType.CONDITION_TYPE_UNSPECIFIED)
      .toList();
}

List<common.ActionType> defaultRuleActionOptions() {
  return common.ActionType.values
      .where((type) => type != common.ActionType.ACTION_TYPE_UNSPECIFIED)
      .toList();
}
