import '../../model/medtag_model.dart';

String getTTSMessage(MedTag medTag) {
  DateTime expiryDate = DateTime.parse(medTag.expiryDate!);
  if (expiryDate.isBefore(DateTime.now())) {
    return "CAUTION!! Your medicine ${medTag.medicineName} has expired. Please dispose it off.";
  }
  return "${medTag.medicineName}: ${medTag.medicineDose} ${medTag.medicineFrequency}, ${medTag.medicineQuantityMorning} Morning, ${medTag.medicineQuantityAfternoon} Afternoon, ${medTag.medicineQuantityEvening} Evening, ${medTag.isBeforeMeal ?? false ? 'Before Meal' : 'After Meal'}. Prescribed by Dr. ${medTag.doctorName}. Expiring on ${medTag.expiryDate}. ${medTag.notes}";
}
