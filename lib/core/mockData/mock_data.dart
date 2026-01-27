import '../../db/database_helper.dart';
import '../../models/inquiry.dart';
import '../../models/property.dart';
import '../../models/user.dart';
import '../../repository/inquiry_repository.dart';
import '../../repository/property_repository.dart';

class MockData {
  static Future<void> seedPropertiesAndInquiries() async {
    final propertyRepo = PropertyRepository();
    final inquiryRepo = InquiryRepository();

    // ---------- MOCK USER ----------
    final user = await _seedUser();

    // ---------- MOCK PROPERTIES ----------
    final properties = [
      Property(
        id: null,
        title: 'Modern Apartment',
        description: '2 bedroom apartment with balcony and parking',
        location: 'Addis Ababa, Ethiopia',
        price: 120000,
        imageUrls: [
         'https://media.inmobalia.com/imgV1/B95mbh8olwFQm~uCUaVOI2kQT0hb0a8sZ9turUNfnwtvuccYCzs0YVPfPbfkc2VnnN1JFDplhuC3TbFKfXVuwuplORa3JhgMpth4H49R6vsah7SzBjVKlw9XCoFK_kEqT4~iT~9klDs3U9FB8Unxn4VObZDr53vZLPsi~uMq3VqZKZ1KBCjlMtToP5NDfDryyAd_2KMy~Us2~u_mU8U76nsFStMXUhGCou3vMU~HUPTvZBUUeG3oAm8CpFk1ZJBvQ5AMaEJ~20oYcqO~rvCpsM5AzfY4FJ3U~oczAUpxP9RzVK_lTynhsvfBaT4~3mpLBuFvJLGj_qt6kznEiSTIkXquTq~W3h1pS3N4cm~9QdRfVaf8mEfGmW9NTpVNGrVwGMvYKOl0m2C_U7FG2lcsP2Z8mw--.jpg',
        ],
        status: 'published',
        syncStatus: 'synced',
        lastUpdated: DateTime.now(),
      ),
      Property(
        id: null,
        title: 'Cozy Studio',
        description: 'Studio apartment in city center, ideal for singles',
        location: 'Bole, Addis Ababa',
        price: 80000,
        imageUrls: [
          'https://media.inmobalia.com/imgV1/B95mbh8olwFQm~uCUaVOI2kQT0hb0a8sZ9turUNfnwtvuccYCzs0YVPfPbfkc2VnnN1JFDpiUtpDtNzRBb3njP34INKjN3sD1X_xE86_z1WaEh0LP~mU5SIKjuUUTuKYGmVU~mNY7eXEWVuwoF5pbMsvvmgRlkP74w32eXgL9Whln3bFUWzomZ3R86MKnP9gTcIQkcrQw7f6Kd45r7tx_DmyfhduMzAmgVxE7~xQUcDfpDb9cZp7Jpr08FYDUOwi6dH2_S4GwmmyTrMWmsTGIyKGrmN_KYYevwO73Frbb3aNThqKlYh7AcOJhnYHP2o5L8kGCyAFLCPREYoQXWwM0nV7FNNIwpEbWDnEphIBkRuwtf1MtjZ4KtPqJb_iQpVScE2KmoA-.jpg',
        ],
        status: 'published',
        syncStatus: 'synced',
        lastUpdated: DateTime.now(),
      ),
    ];

    final insertedProperties = <Property>[];
    for (var property in properties) {
      await propertyRepo.saveProperty(property);
      final allProps = await propertyRepo.fetchProperties();
      insertedProperties.add(allProps.last);
    }

    print('✅ Mock properties inserted');

    // ---------- MOCK INQUIRIES ----------
    final inquiries = [
      Inquiry(
        propertyId: insertedProperties[0].id!,
        userId: user.id!,
        message: 'Is this apartment still available?',
        status: 'queued',
        timestamp: DateTime.now(),
      ),
      Inquiry(
        propertyId: insertedProperties[1].id!,
        userId: user.id!,
        message: 'Can I schedule a visit next week?',
        status: 'queued',
        timestamp: DateTime.now(),
      ),
    ];

    for (var inquiry in inquiries) {
      await inquiryRepo.saveInquiry(inquiry);
    }

    print('✅ Mock inquiries inserted');
  }

  // ---- helper ----
  static Future<UserModel> _seedUser() async {
    final user = UserModel(
      name: 'Jane Doe',
      email: 'jane.doe@example.com',
      isDarkMode: false,
      createdAt: DateTime.now(),
    );

    await DatabaseHelper.instance.saveUser(user);
    return (await DatabaseHelper.instance.getUser())!;
  }
}
